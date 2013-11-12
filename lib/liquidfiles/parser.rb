module LiquidFiles
  module Parser
    def parse_settings(response)
      @settings = {}
      # parse xml from reponse with Nokogiri Slop decorator
      xml = Nokogiri::Slop(response)

      # list of single value params to be extracted from response
      attrs = [:api_version, :version, :version_numeric, :api_client_size_override, :max_expiration, :max_file_size,\
               :change_expiration, :default_file_expiration, :default_authorization, :allow_users_to_change_authorization,\
               :default_bcc_myself, :can_override_size_limit, :enable_send_folders, :api_enable_secure_send, \
               :limit_recipient_domains, :can_send_to_local_users, :can_use_file_requests]

      attrs.each do |a|
        if xml.user.send(a).attributes["type"]
          case xml.user.send(a).attributes["type"].value
          when "integer"
            @settings[a] = xml.user.send(a).content.to_i
          when "boolean"
            @settings[a] = (xml.user.send(a).content == "true")
          end
        else
          @settings[a] = xml.user.send(a).content
        end
      end

      @settings[:accepted_filetypes] = xml.user.accepted_filetypes.content.split ", "
      @settings[:blocked_extensions] = xml.user.blocked_extensions.content.split ", "

      # Extract allowed recipients domains
      @settings[:recipients_domains] = xml.user.recipients_domains.recipients_domain.map &:content
    end

    # allow both "example.com" and "(http|https)://example.com" as api url
    def parse_https_url(url)
      "https://"+url.split("://").last
    end

  end
end