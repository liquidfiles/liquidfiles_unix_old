module LiquidFiles
  class Client
    
    def initialize(api_key, api_url="https://green.liquidfiles.net")
      @api_key = api_key
      @api_url = api_url
    end

    # Uploads provided files to server
    # files - array of paths to files to be uploaded
    # returns array of server ids of filesi
    def upload(files)
    
      # Placeholder for ids of uploaded files
      file_ids = []
    
      c = Curl::Easy.new "#{@api_url}/attachments" 

      c.http_auth_types = :basic
      c.username = @api_key
      c.password = "x"

      # Disable verification because of self-signed cert on green.liquidfiles.net
      c.ssl_verify_host=false
      c.ssl_verify_peer=false
      c.multipart_form_post = true

      c.verbose = true

      # Upload one file at a time
      files.each do |file|
        post_data = []
        post_data << Curl::PostField.file('Filedata', file)
        c.http_post(post_data)
        file_ids << c.body_str
      end

      return file_ids
    end

    def message(recipients=[], subject="", message="", attachments=[])
      uri = URI.parse("#{@api_url}/message")
      

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.request_uri)
      request.content_type = "text/xml"
      msg = build_message recipients,[],[],subject, message, attachments
      pp msg
      request.body = msg
      request.basic_auth @api_key, 'x'
      response = http.request(request)

      return response.body
    end

    private
    
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
