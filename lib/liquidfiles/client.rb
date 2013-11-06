require 'liquidfiles/validator'
require 'liquidfiles/parser'

module LiquidFiles
  class Client
    include LiquidFiles::Validator
    include LiquidFiles::Parser

    attr_reader :settings   

 
    def initialize(api_key, api_url="https://green.liquidfiles.net")
      @api_key = api_key
      @api_url = api_url
      get_user_settings()
    end

    # Uploads provided files to server
    # files - array of paths to files to be uploaded
    # returns array of server ids of files
    def upload(files)
      c = prepare_curl_request("attachments")    

      # Upload one file at a time
      files.map do |file|
        c.http_post [Curl::PostField.file('Filedata', file)]
        validate_response(c.body_str)
        c.body_str
      end
    end

    def message(recipients=[], subject="", message="", attachments=[])
      http, request = prepare_http_request("message")

      msg = build_message recipients,[],[],subject, message, attachments
      request.body = msg
      response = http.request(request)

      return response.body
    end

    private
    
    def get_user_settings
      http, request = prepare_http_request("account")
      response = http.request(request).body
      validate_response response
      parse_settings(response)
    end

    def prepare_curl_request(call)
      c = Curl::Easy.new "#{@api_url}/#{call}" 

      c.http_auth_types = :basic
      c.username = @api_key
      c.password = "x"

      # Disable verification because of self-signed cert on green.liquidfiles.net
      c.ssl_verify_host=false
      c.ssl_verify_peer=false
      c.multipart_form_post = true

      c.verbose = true
      
      return c
    end

    def prepare_http_request(call)
      uri = URI.parse("#{@api_url}/#{call}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.request_uri)
      request.content_type = "text/xml"
      request.basic_auth @api_key, 'x'
      
      return http, request
    end 

    def build_message(recipients=[], cc=[], bcc=[], subject="", message="", attachments=[])
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.message {
            xml.recipients("type" => "array"){
              recipients.each do |recipient|
                xml.recipient_ recipient
              end
            }
            xml.expires_at("type" => "date"){ (Time.now+7*24*60*60) }
            xml.subject subject
            xml.message message
            xml.attachments("type" => "array"){
              attachments.each do |attachment_id|
                xml.attachment_ attachment_id
              end
            }
            xml.send_email "true"
            xml.authorization 3
          }
      end
      builder.to_xml
    end

  end
end
