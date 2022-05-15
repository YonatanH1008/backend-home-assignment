# frozen_string_literal: true

class String
  def clean
    gsub("\0", '').squish
  end

  def clean!
    gsub!("\0", '')
    squish!
  end
end
