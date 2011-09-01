module Alondra

  class BogusException < StandardError; end

  class BogusEvent < Event

    def to_json
      boom!
    end

    def boom!
      raise BogusException.new("Ha ha ha, I'm evil!")
    end
  end
end