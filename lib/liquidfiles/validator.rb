module LiquidFiles # :nodoc: all
  module Validator

    def validate_response(response)
      xml = Nokogiri::Slop(response)
      raise LiquidFiles::ApiError, xml.css("error").first.text if xml.css("error").first
    end

    def validate_files(files)
      raise ArgumentError, "Provide at least one file to upload." if files.empty?

      validate_file_existance files

      # if api providede list of blocked extensions
      # check each of provided files if it has any of those extention
      unless @settings[:blocked_extensions].nil? or @settings[:blocked_extensions].empty?
        files.each do |file|
          # Extract file extension from file name
          file_ext = file.split(".").last
          if @settings[:blocked_extensions].any? {|extension| Regexp.new(extension) =~ file_ext}
            raise ArgumentError, "#{file_ext} is not allowed file extension."
          end
        end
      end

      unless @settings[:accepted_filetypes].nil? or @settings[:accepted_filetypes].empty?
        files.each do |file|
          # Use unix 'file' tool to read files type
          file_type = IO.popen(["file", "--brief", "--mime-type", file]).read.chomp
          unless @settings[:accepted_filetypes].any? {|type| Regexp.new(type) =~ file_type}
            raise ArgumentError, "#{file_type} is not accepted file type."
          end
        end
      end


      if @settings[:max_file_size] and @settings[:max_file_size] > 0
        files.each do |file|
          # calculate file size in MB
          file_size = File.size(file).to_f / 2**20
          raise ArgumentError, "Size of #{file} is greater than #{@settings[:max_file_size]}MB" if file_size > @settings[:max_file_size]
        end
      end

    end

    def validate_message_options(opts)

      # Check if either files to be uploded or attachment ids to be sent are set
      if (opts[:files].nil? or opts[:files].empty?) and (opts[:attachments].nil? or opts[:attachments].empty?)
        raise ArgumentError, "Message must have at least one file attached."
      end

      raise ArgumentError, "Message body can't be empty." if opts[:body].nil? or opts[:body].empty?   
      raise ArgumentError, "Message subject can't be empty." if opts[:subject].nil? or opts[:subject].empty?
      raise ArgumentError, "Expiration must be lower that #{@settings[:max_expiration]} days." if opts[:expires_at] and opts[:expires_at] > @settings[:max_expiration]
      raise ArgumentError, "Authorization must be either 0, 1, 2 or 3." if !opts[:authorization].nil? and !([0,1,2,3].include? opts[:authorization])


      # If message is missing recipients, ccs and bccs we should complain 
      if (opts[:recipients].nil? or opts[:recipients].empty?)
        raise ArgumentError, "Message must have recipients." 
      end

      # Check if provided emails are realy emails
      # Check if all recipients emails are from allowed domains.
      # Recipients, cc and bcc are joined; before that explicitely converted to arrays,
      # in case any of those options is nil
      (opts[:recipients].to_a+opts[:cc].to_a+opts[:bcc].to_a).each do |recipient|

        raise ArgumentError, "#{recipient} is not a valid email." unless recipient =~ /.+@.+\..+/i

        unless @settings[:recipients_domains].include? recipient.split('@').last
          raise ArgumentError, "Message recipients emails can only be from allowed domains."
        end

      end

    end

    def validate_filedrop_options(opts)
    end

    def validate_file_existance files
      (files||[]).each do |file|
        raise ArgumentError, "File #{file} doesn't exist." unless File.exists? file
      end
    end

  end
end