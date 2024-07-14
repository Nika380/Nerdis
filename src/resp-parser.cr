require "./commands"

module Nerdis
  class RespParser
    include Commands

    def parse(client)
      response = read_value(client)
      puts "Response: #{response}"
      if response.nil?
        client << return_simple_string "Empty Command Not Allowed"
      end
      case response[0]
      when '+'
        client << return_simple_string "PONG"
      when '*'
        client << parse_array_strings response, client
      else
        client << return_simple_string "No Command"
        return
      end
    end

    def parse_array_strings(value, client)
        values = [] of String
        while values.size < get_req_size(value)
          str = read_value(client)
          if str[0] != '$'
            values << str
          end
        end
        puts "Values: #{values}"
        puts "Bulk Strings: #{values}"
        "+bulk\r\n" 
      end
  end
end
