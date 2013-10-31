module LiquidFiles
  class Client
    
    def initialize(api_key, api_url="http://liquidfiles.net")
    end

    def upload(files)
    
      # Placeholder for ids of uploaded files
      file_ids = []
    
      c = Curl::Easy.new('https://green.liquidfiles.net/attachments')

      c.http_auth_types = :basic
      c.username = api_key
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

end
