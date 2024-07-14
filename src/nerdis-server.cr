require "./resp-parser"

module Nerdis
  class NerdisServer
    def start
      begin
        server = TCPServer.new("0.0.0.0", 6379)
        puts "Server Started"
        loop do
          client = server.accept
          puts "Accepted Requrest"

          client << "+Connected To Server\r\n"
          spawn handle_client(client)
        end
      rescue ex
        ex
      end
    end

    def handle_client(client)
      begin
        loop do
          RespParser.new.parse(client)
        end
      rescue ex
        ex
      end
    end
  end
end
