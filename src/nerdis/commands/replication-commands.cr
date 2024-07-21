require "./resp-commands"

module Nerdis
  module ReplicationCommands
    include RespCommands

    def propagate_replicas(replica_list, command)
      replica_list.each do |replica|
        replica.puts(return_array_strings(command))
      end
    end
  end
end
