require "./resp-parser"

module Nerdis
  class NerdisServer
    def start
      begin
        server = TCPServer.new("0.0.0.0", 6379)
        puts "Server Started"
        loop do
          client = server.accept
          spawn handle_client(client)
        end
      rescue ex
        ex
      end
    end

    def handle_client(client)
      begin
        loop do
          RespParser.new(client).parse
        end
      rescue ex
        ex
      end
    end
  end
end
