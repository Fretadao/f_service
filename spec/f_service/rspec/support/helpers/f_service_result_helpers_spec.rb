# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FServiceResultHelpers do
  describe '#f_service_result' do
    context 'when the result is neither :success nor :failure' do
      it 'raises ArgumentError naming the accepted values and the one received' do
        expect { f_service_result(:skipped) }
          .to raise_error(ArgumentError, 'result must be :success or :failure, got :skipped')
      end
    end

    context 'when the result is :failure' do
      it { expect(f_service_result(:failure)).to be_a(FService::Result::Failure) }
      it { expect(f_service_result(:failure, nil, [:invalid_name])).to have_attributes(types: [:invalid_name]) }
      it { expect(f_service_result(:failure, 'is blank')).to have_attributes(error: 'is blank') }
    end

    context 'when the result is :success' do
      it { expect(f_service_result(:success)).to be_a(FService::Result::Success) }
      it { expect(f_service_result(:success, nil, [:created])).to have_attributes(types: [:created]) }
      it { expect(f_service_result(:success, 'John')).to have_attributes(value: 'John') }
    end
  end

  describe '#mock_service' do
    context 'when the result is neither :success nor :failure' do
      let(:service) { Class.new(FService::Base) }

      it 'raises ArgumentError naming the accepted values and the one received' do
        expect { mock_service(service, result: :skipped) }
          .to raise_error(ArgumentError, 'result must be :success or :failure, got :skipped')
      end
    end

    context 'when the result is valid' do
      context 'and the service is not a real class' do
        let(:service) { class_double(FService::Base) }

        before { mock_service(service, types: [:created]) }

        it { expect(service.call(name: 'John')).to have_succeed_with(:created) }
        it { expect(service.call('John', 42, unknown: true)).to have_succeed_with(:created) }
      end

      context 'and the service is a real class' do
        let(:run_log) { [] }
        let(:service) do
          executions = run_log
          initializer = service_initializer

          Class.new(FService::Base) do
            define_method(:initialize, &initializer)
            define_method(:run) { executions << :run }
          end
        end

        context 'and the mocked service is never called' do
          let(:service_initializer) { ->(name:) { name } }

          before { mock_service(service) }

          it { expect(run_log).to be_empty }
        end

        context 'and the mocked service is called' do
          context 'but the arguments break the initializer' do
            context 'with a required keyword missing' do
              let(:service_initializer) { ->(name:) { name } }

              before { mock_service(service) }

              it { expect { service.call }.to raise_error(ArgumentError, /missing keyword: :name/) }

              it 'does not run the service' do
                expect { service.call }.to raise_error(ArgumentError).and not_change(run_log, :size)
              end
            end

            context 'with an unknown keyword' do
              let(:service_initializer) { ->(name:) { name } }

              before { mock_service(service) }

              it 'raises ArgumentError' do
                expect { service.call(name: 'John', age: 42) }.to raise_error(ArgumentError, /unknown keyword: :age/)
              end

              it 'does not run the service' do
                expect { service.call(name: 'John', age: 42) }
                  .to raise_error(ArgumentError)
                  .and not_change(run_log, :size)
              end
            end

            context 'with the wrong number of positional arguments' do
              let(:service_initializer) { ->(params) { params } }

              before { mock_service(service) }

              it { expect { service.call('John', 42) }.to raise_error(ArgumentError, /wrong number of arguments/) }

              it 'does not run the service' do
                expect { service.call('John', 42) }.to raise_error(ArgumentError).and not_change(run_log, :size)
              end
            end
          end

          context 'and the arguments respect the initializer' do
            context 'with keyword arguments' do
              let(:service_initializer) { ->(name:) { name } }

              before { mock_service(service, types: [:created]) }

              it { expect(service.call(name: 'John')).to have_succeed_with(:created) }

              it 'does not run the service' do
                service.call(name: 'John')

                expect(run_log).to be_empty
              end
            end

            context 'with positional arguments' do
              let(:service_initializer) { ->(params) { params } }

              before { mock_service(service, types: [:created]) }

              it { expect(service.call({ name: 'John' })).to have_succeed_with(:created) }

              it 'does not run the service' do
                service.call({ name: 'John' })

                expect(run_log).to be_empty
              end
            end

            context 'and the spec also stubs the service .new' do
              let(:service_initializer) { ->(name:) { name } }

              before do
                allow(service).to receive(:new).and_call_original
                mock_service(service, types: [:created])
              end

              it { expect(service.call(name: 'John')).to have_succeed_with(:created) }

              it 'does not trigger the stubbed .new' do
                service.call(name: 'John')

                expect(service).not_to have_received(:new)
              end
            end

            context 'and the call is inspected with have_received' do
              let(:service_initializer) { ->(name:) { name } }

              before { mock_service(service) }

              it 'matches the arguments of the call' do
                service.call(name: 'John')

                expect(service).to have_received(:call).with(name: 'John')
              end
            end

            context 'and the service is called through to_proc' do
              let(:service_initializer) { ->(name:) { name } }

              before { mock_service(service, types: [:created]) }

              it { expect([{ name: 'John' }].map(&service)).to contain_exactly(have_succeed_with(:created)) }
            end

            context 'and the result is not informed' do
              let(:service_initializer) { ->(name:) { name } }

              before { mock_service(service) }

              it { expect(service.call(name: 'John')).to be_a(FService::Result::Success) }
            end

            context 'and the result is :failure' do
              let(:service_initializer) { ->(name:) { name } }

              before { mock_service(service, result: :failure) }

              it { expect(service.call(name: 'John')).to be_a(FService::Result::Failure) }
            end

            context 'and types are informed' do
              let(:service_initializer) { ->(name:) { name } }

              before { mock_service(service, types: %i[created notified]) }

              it { expect(service.call(name: 'John')).to have_attributes(types: %i[created notified]) }
            end

            context 'and a value is informed' do
              context 'and the result is a Success' do
                let(:service_initializer) { ->(name:) { name } }

                before { mock_service(service, value: 'John') }

                it { expect(service.call(name: 'John')).to have_attributes(value: 'John') }
              end

              context 'and the result is a Failure' do
                let(:service_initializer) { ->(name:) { name } }

                before { mock_service(service, result: :failure, value: 'is blank') }

                it { expect(service.call(name: 'John')).to have_attributes(error: 'is blank') }
              end
            end
          end
        end
      end
    end
  end
end
