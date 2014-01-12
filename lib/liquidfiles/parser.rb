module LiquidFiles # :nodoc: all
  module Parser

    def parse_settings(response, type=:user)
      @settings = {}
      # parse xml from reponse with Nokogiri Slop decorator
      xml = Nokogiri::Slop(response)
      # list of single value params to be extracted from response
      case type
      when :user
        attrs = [:api_version, :version, :version_numeric, :api_client_size_override, :max_expiration, :max_file_size,\
               :change_expiration, :default_file_expiration, :default_authorization, :allow_users_to_change_authorization,\
               :default_bcc_myself, :can_override_size_limit, :enable_send_folders, :api_enable_secure_send, \
               :limit_recipient_domains, :can_send_to_local_users, :can_use_file_requests]
        element = xml.user
      when :filedrop
        attrs = [:api_key, :post_url, :max_upload_size]
        element = xml.filedrop
      end
      attrs.each do |a|
        if element.send(a).attributes["type"]
          case element.send(a).attributes["type"].value
          when "integer"
            @settings[a] = element.send(a).content.to_i
          when "boolean"
            @settings[a] = (element.send(a).content == "true")
          end
        else
          @settings[a] = element.send(a).content
        end
      end

      [:accepted_filetypes, :blocked_extensions, :invalid_extensions].each do |setting|
        @settings[setting] = element.send(setting).content.split(", ") if !element.xpath("//#{setting.to_s}").empty?
      end

      # Extract allowed recipients domains
      @settings[:recipients_domains] = element.recipients_domains.recipients_domain.map &:content if !element.xpath("//recipients_domains").empty?
    end

    # allow both "example.com" and "(http|https)://example.com" as api url
    def parse_https_url(url)
      "https://"+url.split("://").last
    end

    def parse_message c
      xml = Nokogiri::Slop c
      return {
        id: xml.html.body.message.id.text,
        url: xml.html.body.message.url.text,
        expires_at: xml.html.body.message.expires_at.text,
        authorization: xml.html.body.message.authorization.text,
        authorization_description: xml.html.body.message.authorization_description.text,
        files: xml.html.body.message.table.tr[1..-1].map {|tds| {name: tds.td[0].text, size: tds.td[1].text, checksum: tds.td[2].text }}
      }
    end

    def parse_fliedrop_response c
      puts c
    end

  end
end