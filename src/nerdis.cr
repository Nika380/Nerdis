require "./commands"
require "./nerdis-server"

Signal::TERM.trap { exit }

module Nerdis
  def self.run
    NerdisServer.new.start
  end
end

Nerdis.run
