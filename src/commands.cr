require "socket"

module Nerdis
  module Commands
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

    def handle_ping
      return_simple_string "PONG"
    end

    def handle_echo(value)
      response = value[1..-1].join(" ")
      return_simple_string response
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
  end
end
