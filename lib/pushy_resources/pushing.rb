module PushyResources
  module Pushing

    def push_changes
      push_updates
      push_creations
      push_destroys
    end

    def push_updates
      after_update do |record|
        Event.new(:event => :updated, :resource => record).send_to_channel!
      end
    end

    def push_creations
      after_create do |record|
        Event.new(:event => :created, :resource => record).send_to_channel!
      end
    end

    def push_destroys
      after_destroy do |record|
        Event.new(:event => :destroyed, :resource => record).send_to_channel!
      end
    end
  end
end
