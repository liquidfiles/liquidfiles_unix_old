module LiquidFiles
  module Validator
    def validate_response(response)
      xml = Nokogiri::Slop(response)
      raise LiquidFiles::ApiError, xml.error.content if xml.css("error").first
    end

    def validate_files(files)
      raise ArgumentError, "Provide ate least one file to upload." if files.empty?

      # if api providede list of blocked extensions
      # check each of provided files if it has any of those extention
      unless @settings[:blocked_extensions].empty?
        files.each do |file|
          # Extract file extension from file name
          file_ext = file.split(".").last
          if @settings[:blocked_extensions].include? file_ext
            raise ArgumentError, "#{file_ext} is not allowed file extension."
          end
        end
      end

      unless @settings[:accepted_filetypes].empty?
        files.each do |file|
          # Use unix 'file' tool to read files type
          file_type = IO.popen(["file", "--brief", "--mime-type", file]).read.chomp
          unless @settings[:accepted_filetypes].include? file_type
            raise ArgumentError, "#{file_type} is not accepted file type."
          end
        end
      end


      if @settings[:max_file_size] > 0
        files.each do |file|
          # calculate file size in MB
          file_size = File.size(file).to_f / 2**20
          raise ArgumentError, "Size of #{file} is greater than #{@settings[:max_file_size]}MB" if file_size > @settings[:max_file_size]
        end
      end

    end

    def validate_message_options(opts)
      raise ArgumentError, "Message must have at least one file attached" if (opts[:files].nil? or opts[:files].empty?) and (opts[:attachments].nil? or opts[:attachments].empty?)
      raise ArgumentError, "Message must have recipients" if opts[:recipients].nil? or opts[:recipients].empty?
      raise ArgumentError, "Message body can't be empty" if opts[:message].nil? or opts[:message].empty?
      raise ArgumentError, "Message subject can't be empty" if opts[:subject].nil? or opts[:subject].empty?

      opts[:recipients].each do |recipient|
        unless @settings[:recipients_domains].include? recipient.split('@').last
          raise ArgumentError, "Message recipients emails can only be from allowed domains"
        end
      end
    end

  end
end