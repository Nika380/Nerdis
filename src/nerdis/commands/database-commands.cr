module Nerdis
  module Commands
    alias NerdisDBValueType = {value: String, expires_at: Time?}
    @@nerdis_db = Hash(String, NerdisDBValueType).new

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
      db_key = command[1]
      key_exists = @@nerdis_db.has_key?(db_key)
      if !key_exists
        return return_simple_error("Error: Key Does Not Exists")
      end
      db_value = @@nerdis_db[db_key]
      if db_value.nil?
        return return_simple_error("Error: Value With That Key Does Not Exists")
      end
      is_expired = if expires_at = @@nerdis_db[db_key][:expires_at]
                     expires_at < Time.local
                   else
                     false
                   end
      if is_expired
        @@nerdis_db.delete(db_key)
        return "$-1\r\n"
      end
      return return_bulk_strings(db_value[:value])
    end
  end
end
