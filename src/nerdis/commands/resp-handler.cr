module Nerdis
  module Commands
    include HandshakeCommands
    include ReplicationCommands
    @client : IO
    @connected_slaves : Array(TCPSocket) = [] of TCPSocket

    def initialize(client : IO, @connected_slaves : Array(TCPSocket))
      @client = client
    end

    def parse(data)
      client_str = read_value(@client)
      if client_str.nil?
        @client << return_simple_error("Empty Command Not Allowed")
      end
      case client_str[0]
      when '+'
        @client << return_simple_string("PONG")
      when '*'
        @client << parse_array_strings(client_str, data)
      else
        @client << return_simple_error("No Command")
        return
      end
    end

    def parse_array_strings(value, data)
      values = [] of String
      while values.size < get_req_size(value)
        str = read_value(@client)
        if str[0] != '$'
          values << str
        end
      end
      if values[0].downcase == "psync"
        handle_psync(data[:ms_replid])
        generate_rdb_file(@client)
      end
      handle_bulk_string(values, data)
    end

    def handle_bulk_string(value, data)
      case value[0].downcase
      when "echo"
        handle_echo(value)
      when "ping"
        handle_ping()
      when "set"
        handle_set_command(value, data)
      when "get"
        handle_get_command(value)
      when "info"
        handle_info_command(value, data)
      when "replconf"
        handle_replconf(value, data[:host])
      else
        return_simple_error("Error")
      end
    end
  end
end
