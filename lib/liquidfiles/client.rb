require 'liquidfiles/validator'
require 'liquidfiles/parser'

module LiquidFiles # :nodoc: 

  class Client
    include LiquidFiles::Validator
    include LiquidFiles::Parser

    attr_reader :settings   

 
    def initialize(options)
      @insecure = options[:insecure]
      @mode = options[:mode]
      if options[:mode] == :filedrop
        @url = options[:url]
        @api_url = options[:url]
        get_filedrop_settings()
      else
        @api_key = options[:api_key]
        @api_url = parse_https_url options[:url]
        get_user_settings()
      end
    end

    # Uploads provided files to the server.
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

    # Send email massage 
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

      validate_response response.body

      return parse_message response.body
    end

    def filedrop_upload(opts)
      validate_filedrop_options opts
      options = opts

      # extract only main part of url from filedrop settings
      @api_url = /^\w+:\/\/[\d\w+\.]+/.match(@settings[:post_url])[0]
      @api_key = @settings[:api_key]

      # upload provided files, unless already provided with ids of attachments
      options[:attachments] ||= upload(opts[:files])

      # update url with full url from filedrop settings
      @api_url = @settings[:post_url]
      http, request = prepare_http_request("")

      msg = build_filedrop options
      request.body = msg  
      response = http.request(request)

      validate_response response.body

      return parse_fliedrop_response response.body
    end

    private
    
    def get_user_settings
      http, request = prepare_http_request("account")
      response = http.request(request).body
      validate_response response
      parse_settings(response, :user)
    end

    def get_filedrop_settings
      http, request = prepare_http_request("", true)
      response = http.request(request).body
      validate_response response
      parse_settings(response, :filedrop)      
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

    def prepare_http_request(call, no_auth = false)
      uri = URI.parse("#{@api_url}/#{call}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true #unless @insecure
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.request_uri)
      request.content_type = "text/xml"
      request.basic_auth @api_key, 'x' unless no_auth
      
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

    def build_filedrop(options)
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.message {
            xml.api_key @settings[:api_key]
            xml.subject options[:subject]
            xml.email options[:from]
            xml.message options[:body]
            xml.attachments("type" => "array"){
              options[:attachments].each do |attachment_id|
                xml.attachment_ attachment_id
              end
            }
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
