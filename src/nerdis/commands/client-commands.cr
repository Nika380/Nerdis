module Nerdis
  module Commands
    def handle_ping
      return_simple_string "PONG"
    end

    def handle_echo(value)
      response = value[1..-1].join(" ")
      return_simple_string response
    end

    def handle_info_command(command, data)
      case command[1]
      when "replication"
        values = Nerdis
        if !values.nil?
          return_bulk_strings("role:#{data[:role]}\r\nmaster_replid:#{data[:ms_replid]}\r\nmaster_repl_offset:#{data[:ms_offset]}")
        end
      end
    end
  end
end
