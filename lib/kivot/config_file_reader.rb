module Kivot
  module ConfigFileReader
    def self.read_from_config_file(filename, current_path)
      config_file_path = find_file_recursively_or_in_home(filename, current_path)

      if config_file_path
        File.read(config_file_path).strip
      else
        nil
      end
    end

    private

    def self.find_file_in_home(filename)
      home_directory = Pathname(File.expand_path('~'))
      hypothetical_path = home_directory.join(filename)
      if hypothetical_path.file?
        hypothetical_path
      else
        nil
      end
    end

    def self.find_file_recursively_or_in_home(filename, current_path)
      hypothetical_path = current_path.join(filename)
      if hypothetical_path.file?
        return hypothetical_path
      else
        if current_path.root?
          return find_file_in_home(filename)
        else
          return find_file_recursively_or_in_home(filename, current_path.parent)
        end
      end
    end
  end
end
