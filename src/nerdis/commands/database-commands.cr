require "./replication-commands"

module Nerdis
  module Commands
    include ReplicationCommands
    alias NerdisDBValueType = {value: String}
    @@nerdis_db = Hash(String, NerdisDBValueType).new

    def handle_set_command(command, data)
      if command.size < 3
        return return_simple_error("Error: Not Enough Arguments")
      end
      expires_at : Int32? = nil
      if command.includes?("px")
        indx = command.index("px")
        if indx.nil? || command[indx + 1].nil?
          return return_simple_error("Error: Expire Time Not Provided")
        end
        expires_at = command[indx + 1].to_i
      end

      @@nerdis_db[command[1]] = {value: command[2]}
      if expires_at
        spawn delete_value_from_db(command[1], expires_at)
      end
      if data[:role] == "master"
        propagate_replicas(@connected_slaves, command.join(" "))
      end
      return_simple_string("OK")
    end

    def handle_get_command(command)
      db_key = command[1]
      key_exists = @@nerdis_db.has_key?(db_key)
      if !key_exists
        return "$-1\r\n"
      end
      db_value = @@nerdis_db[db_key]
      return return_bulk_strings(db_value[:value])
    end

    def delete_value_from_db(key, expiration)
      sleep(expiration / 1000)
      handle_del_command(key)
    end

    def handle_del_command(key)
      if !@@nerdis_db.has_key?(key)
        return return_simple_error("Key Does Not Exists")
      end
      @@nerdis_db.delete(key)
    end
  end
end
