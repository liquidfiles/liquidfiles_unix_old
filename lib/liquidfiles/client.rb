require 'liquidfiles/validator'
require 'liquidfiles/parser'

module LiquidFiles
  class Client
    include LiquidFiles::Validator
    include LiquidFiles::Parser

    attr_reader :settings   

 
    def initialize(options)
      @api_key = options[:api_key]
      @api_url = parse_https_url options[:api_url]
      @insecure = options[:insecure]
      get_user_settings()
    end

    # Uploads provided files to server
    # files - array of paths to files to be uploaded
    # returns array of server ids of files
    # curl is used insted of net/http because of performance,
    # no need to load files to Ruby
    def upload(files)
      
      validate_files(files)

      c = prepare_curl_request("attachments")    

      # Upload one file at a time
      files.map do |file|
        c.http_post [Curl::PostField.file('Filedata', file)]
        validate_response(c.body_str)
        c.body_str
      end
    end

    #def message(recipients=[], subject="", message="", attachments=[])
    def message(opts)
      # validate provided options
      validate_message_options opts

      # fill in opts with default values
      options = fill_default_values opts

      # upload provided files, unless already provided with ids of attachments
      options[:attachments] ||= upload(opts[:files])

      http, request = prepare_http_request("message")

      msg = build_message options
      request.body = msg
      response = http.request(request)

      return parse_message response.body
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

      if @insecure
        c.ssl_verify_host=false
        c.ssl_verify_peer=false
      end
      c.multipart_form_post = true

      c.verbose = false
      
      return c
    end

    def prepare_http_request(call)
      uri = URI.parse("#{@api_url}/#{call}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true unless @insecure
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.request_uri)
      request.content_type = "text/xml"
      request.basic_auth @api_key, 'x'
      
      return http, request
    end 

    #def build_message(recipients=[], cc=[], bcc=[], subject="", message="", attachments=[])
    def build_message(options)
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.message {
            xml.recipients("type" => "array"){
              options[:recipients].each do |recipient|
                xml.recipient_ recipient
              end
            }
            xml.expires_at("type" => "date"){ (Time.now+options[:expires_at]*24*60*60).strftime "%Y-%m-%d" }
            xml.subject options[:subject]
            xml.message options[:body]
            xml.attachments("type" => "array"){
              options[:attachments].each do |attachment_id|
                xml.attachment_ attachment_id
              end
            }
            xml.send_email options[:send_email]
            xml.authorization options[:authorization]
          }
      end
      builder.to_xml
    end

    def fill_default_values(options)
      options[:expires_at] ||= @settings[:default_file_expiration]
      options[:authorization] ||= @settings[:default_authorization]
      options[:send_email] ||= true
      options
    end

  end
end
