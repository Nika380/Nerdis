module Nerdis
  module RespCommands
    def read_value(client)
      value = client.gets
      if value.nil?
        raise "Null Value"
      end
      value
    end

    def get_req_size(value)
      value[1..-1].to_i
    end

    def return_simple_string(value)
      "+#{value}\r\n"
    end

    def return_simple_error(value)
      "-#{value}\r\n"
    end

    def return_bulk_strings(value)
      "$#{value.size}\r\n#{value}\r\n"
    end

    def return_array_strings(str : String)
      arr = str.split(" ")
      i = 0
      message = "*#{arr.size}\r\n"
      while i < arr.size
        message = "#{message}$#{arr[i].size}\r\n#{arr[i]}\r\n"
        i += 1
      end
      message
    end

    def send_message(client, message)
      client.puts message
    end
  end
end
