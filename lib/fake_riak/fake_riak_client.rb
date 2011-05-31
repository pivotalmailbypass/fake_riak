require 'json'
module FakeRiakClient
  class FileStorage
    def initialize(file_path)
      @file_path = file_path
    end

    def add(list_name, value)
      contents_as_string = File.read(@file_path) if File.exists?(@file_path)

      contents_as_string = "{}" if !contents_as_string || contents_as_string == ""
      contents = JSON.parse(contents_as_string)
      contents[list_name] ||= []
      contents[list_name] << value
      File.open(@file_path, "w") do |file|
        file << contents.to_json
      end
      nil
    end

    def get(list_name)
      if File.exists?(@file_path)
        contents_as_string = File.read(@file_path)
        contents_as_string = "{}" if contents_as_string == ""
        contents = JSON.parse(contents_as_string)
        contents[list_name] || []
      else
        []
      end
    end
  end

  class MemoryStorage
    def initialize
      @store = {}
    end

    def add(list_name, value)
      @store[list_name] = get(list_name) + [JSON.parse(value.to_json)]
      nil
    end

    def get(list_name)
      value = @store[list_name]
      value ? value : []
    end

    def reset_fake
      @store = {}
    end
  end
end
