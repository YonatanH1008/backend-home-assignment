# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::BaseController, type: :controller do
  it 'raises error if permitted_params is not overridden' do
    params = double

    allow(params).to receive(:require).and_return(params)
    allow_any_instance_of(described_class).to receive(:resource_class_model)
    allow_any_instance_of(described_class).to receive(:params).and_return(params)

    expect { described_class.new.create }.to raise_error(NotImplementedError)
  end
end
