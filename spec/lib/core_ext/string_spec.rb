# frozen_string_literal: false

require 'rails_helper'

RSpec.describe String, type: :Object do
  describe '#clean' do
    it 'returns a clean version of a string' do
      clean_str = " bad   \0dirty  \000string  ".clean

      expect(clean_str).to eq('bad dirty string')
    end
  end

  describe '#clean!' do
    it 'cleans a string in place' do
      dirty_str = " bad   \0dirty  \000string  "
      dirty_str.clean!

      expect(dirty_str).to eq('bad dirty string')
    end
  end
end
