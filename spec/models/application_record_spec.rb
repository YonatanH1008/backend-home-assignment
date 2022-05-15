# frozen_string_literal: true

require 'rails_helper'

class TestClass < ApplicationRecord
  def self.load_schema!
    @columns_hash = {}
  end
end

RSpec.describe ApplicationRecord, type: :model do
  it 'initializes instance inherited from company' do
    expect { TestClass.new }.not_to raise_exception
  end
end
