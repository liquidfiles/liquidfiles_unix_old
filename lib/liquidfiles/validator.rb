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

    end

  end
end