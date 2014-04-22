module Babelish
  # Faraday is a dependency of google_drive, this silents the warning
  # see https://github.com/CocoaPods/CocoaPods/commit/f33f967427b857bf73645fd4d3f19eb05e9be0e0
  # This is to make sure Faraday doesn't warn the user about the `system_timer` gem missing.
  old_warn, $-w = $-w, nil
  begin
    require "google_drive"
  ensure
    $-w = old_warn
  end

  class GoogleDoc
    attr_accessor :session

    def download(requested_filename, worksheet_index = 0, output_filename = "translations.csv")
      file = file_with_name(requested_filename)
      return nil unless file
      file.export_as_file(output_filename, "csv", worksheet_index)
      return output_filename
    end

    def open(requested_filename)
      file = file_with_name(requested_filename)
      if file
        system "open \"#{file.human_url}\""
      else
        puts "can't open requested file"
      end
    end

    def authenticate
      # will try to get token from ~/.ruby_google_drive.token
      @session = GoogleDrive.saved_session
    end

    def file_with_name(name)
      unless @session
        authenticate
      end
      result = @session.file_by_title(name)
      if result.is_a? Array
        file = result.first
      else
        file = result
      end
    end
  end
end
