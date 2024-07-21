require "./resp-commands"

module Nerdis
  module HandshakeCommands
    include RespCommands

    def handle_replconf(command, host)
      if command.includes?("listening-port")
        @connected_slaves << TCPSocket.new(host, command[2].to_i)
      end
      return_simple_string("OK")
    end

    def handle_psync(master_repl_id)
      return_simple_string("FULLRESYNC #{master_repl_id} 0")
    end

    def send_replconf_handshake(client, port_number)
      begin
        messages = ["REPLCONF listening-port #{port_number}", "REPLCONF capa psync2"]
        (0..1).each do |i|
          send_message(client, return_array_strings(messages[i]))
          response = read_value(client)
          if response != "+OK"
            raise "Error On Replconf #{i + 1}"
          end
        end
      rescue ex
        return return_simple_error("ERROR IN REPLCONF HANDSHAKE")
      else
      end
    end

    def start_replication_handshake(ms_host, ms_port, port)
      replica_client : IO? = nil
      begin
        replica_client = TCPSocket.new(ms_host, ms_port)
        send_message(replica_client, return_array_strings("PING"))
        response = read_value(replica_client)
        if response != "+PONG"
          raise "Handshake Did Not Work"
        end
        send_replconf_handshake(replica_client, port)
        send_psync_packets(replica_client)
      rescue ex
        "Error during handshake #{ex.message}"
      ensure
        if replica_client
          replica_client.close
          puts "Client Closed"
        end
      end
    end

    def send_psync_packets(client)
      begin
        send_message(client, return_array_strings("PSYNC ? -1"))
        response = read_value(client)
        if !response
          raise "Psync Failed"
        end
      rescue ex
        raise "Error #{ex}"
      end
    end

    def generate_rdb_file(client)
      puts "Generating RDB File"
      rdb_file_contents = Base64.decode("UkVESVMwMDEx+glyZWRpcy12ZXIFNy4yLjD6CnJlZGlzLWJpdHPAQPoFY3RpbWXCbQi8ZfoIdXNlZC1tZW3CsMQQAPoIYW9mLWJhc2XAAP/wbjv+wP9aog==")
      header = "$#{rdb_file_contents.size}\r\n".to_slice
      client.write(header)
      client.write(rdb_file_contents)
      client.close
      puts "RDB Values Sent"
    end
  end
end
