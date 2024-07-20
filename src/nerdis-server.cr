require "./resp-parser"
require "socket"
require "./nerdis/commands/handshake-commands"

module Nerdis
  class NerdisServer
    include HandshakeCommands
    @master_port = 6379
    @master_host = "0.0.0.0"
    @port_number = 6379
    @host_address = "0.0.0.0"
    @role = "master"
    @master_replid = Random.new.hex(40)
    @connected_slaves = 0
    @master_repl_offset = 0

    def start
      packed_data = {ms_port: @master_port, ms_host: @master_host, port: @port_number, host: @host_address, role: @role, ms_replid: @master_replid, ms_offset: @master_repl_offset}
      begin
        if ARGV.size > 0
          parse_args
        end
        server = TCPServer.new(@host_address, @port_number)
        puts "Server Started On Port #{@port_number}"
        if @role == "slave"
          start_replication_handshake(@master_host, @master_port)
        end
        loop do
          client = server.accept
          spawn handle_client(client, packed_data)
        end
      rescue ex
        ex
      end
    end

    def handle_client(client, data)
      begin
        loop do
          RespParser.new(client).parse(data)
        end
      rescue ex
        ex
      end
    end

    def parse_args
      i = 0
      while i < ARGV.size
        begin
          case ARGV[i]
          when "--port"
            if ARGV[i + 1]
              @port_number = ARGV[i + 1].to_i
              i += 1
            else
              raise "Error: Port Number Is Not Specified"
              exit 1
            end
          when "--replicaof"
            @role = "slave"
            if ARGV[i + 1]
              args = ARGV[i + 1].split(/\s+/)
              if args.size > 1
                @master_host = args[0]
                @master_port = args[1].to_i
                i += 1
                return
              end

              @master_host = ARGV[i + 1]
              @master_port = ARGV[i + 2].to_i
              i += 2
            end
          end
        rescue ex
          puts ex
          exit 1
        end
        i += 1
      end
    end
  end
end
