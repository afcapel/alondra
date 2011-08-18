module PushyResources
  module Pushing

    def push_changes
      push_updates
      push_creations
      push_destroys
    end

    def push_updates
      after_update do |record|
        event = Event.new(:event => :updated, :resource => record)
        Rails.logger.debug "resource #{record.class.name} #{record.id} updated. Sending event."
        EventQueue.push(event)
      end
    end

    def push_creations
      after_create do |record|
        event = Event.new(:event => :created, :resource => record)
        EventQueue.push(event)
      end
    end

    def push_destroys
      after_destroy do |record|
        event = Event.new(:event => :destroyed, :resource => record)
        EventQueue.push(event)
      end
    end
  end
end
