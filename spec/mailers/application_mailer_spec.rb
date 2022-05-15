# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationMailer do
  it 'initializes' do
    expect { described_class.new }.not_to raise_exception
  end
end
