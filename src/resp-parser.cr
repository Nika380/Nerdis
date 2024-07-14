require "./commands"

module Nerdis
  class RespParser
    @client : IO
    include Commands

    def initialize(client : IO)
      @client = client
    end

    def parse
      client_str = read_value(@client)
      if client_str.nil?
        @client << return_simple_error("Empty Command Not Allowed")
      end
      case client_str[0]
      when '+'
        @client << return_simple_string("PONG")
      when '*'
        @client << parse_array_strings(client_str)
      else
        @client << return_simple_error("No Command")
        return
      end
    end

    def parse_array_strings(value)
      values = [] of String
      while values.size < get_req_size(value)
        str = read_value(@client)
        if str[0] != '$'
          values << str
        end
      end
      handle_bulk_string(values)
    end

    def handle_bulk_string(value)
      case value[0].downcase
      when "echo"
        handle_echo(value)
      when "ping"
        handle_ping
      else
         return_simple_error("Error")
      end
    end
  end
end
