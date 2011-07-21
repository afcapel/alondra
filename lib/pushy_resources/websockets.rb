module PushyResources
  class Websockets

    class << self
      def list
        @list ||= {}
      end

      def subscriptions_for(websocket)
        list[websocket] ||= []
      end
    end
  end
end