require "socket"

alias NerdisDBValueType = {value: String, expires_at: Time?}

module Nerdis
  module Commands
    @@nerdis_db = Hash(String, NerdisDBValueType).new

    def read_value(client)
      value = client.gets
      if value.nil?
        raise "Null Value"
      end
      value
    end

    def get_req_size(value)
      value[1..-1].to_i
    end

    def handle_ping
      return_simple_string "PONG"
    end

    def handle_echo(value)
      response = value[1..-1].join(" ")
      return_simple_string response
    end

    def return_simple_string(value)
      "+#{value}\r\n"
    end

    def return_simple_error(value)
      "-#{value}\r\n"
    end

    def return_bulk_strings(value)
      "$#{value.size}\r\n#{value}\r\n"
    end

    def handle_set_command(command)
      if command.size < 3
        return return_simple_error("Error: Not Enough Arguments")
      end
      expires_at = nil
      if command.includes?("px")
        indx = command.index("px")
        if indx.nil? || command[indx + 1].nil?
          return return_simple_error("Error: Expire Time Not Provided")
        end
        expires_at = Time.local + command[indx + 1].to_i.milliseconds
      end

      @@nerdis_db[command[1]] = {value: command[2], expires_at: expires_at}
      return_simple_string("OK")
    end

    def handle_get_command(command)
      key_exists = @@nerdis_db.has_key?(command[1])
      if !key_exists
        return return_simple_error("Error: Key Does Not Exists")
      end
      db_value = @@nerdis_db[command[1]]
      if db_value.nil?
        return return_simple_error("Error: Value With That Key Does Not Exists")
      end
      is_expired = if expires_at = @@nerdis_db[command[1]][:expires_at]
        expires_at < Time.local
      else
        false
      end
      if is_expired
        @@nerdis_db.delete("name")
        return "$-1\r\n"
      end
      return return_bulk_strings(db_value[:value])
    end
  end
end
