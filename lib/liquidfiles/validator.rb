module LiquidFiles
  module Validator
    def validate_response(response)
      xml = Nokogiri::Slop(response)
      raise LiquidFiles::ApiError, xml.error.content if xml.css("error").first
    end
  end
end