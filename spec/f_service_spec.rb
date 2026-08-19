# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FService do
  describe 'version number' do
    # Kept in sync by release-please: this file is listed in extra-files, and the
    # marker below tells the generic updater which line to rewrite on release.
    it { expect(described_class::VERSION).to eq('0.4.1') } # x-release-please-version
  end
end
