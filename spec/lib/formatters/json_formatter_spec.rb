# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('lib/formatters/json_formatter').to_s

RSpec.describe JsonFormatter, type: :Object do
  describe '.call' do
    it 'returns a JSON formatted log entry' do
      expect { JSON.parse(described_class.new.call(:info, 'timestamp', 'progname', 'message')) }.not_to raise_error
    end
  end
end
