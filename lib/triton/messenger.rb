module Triton
  # The Messenger module provides a simple event emitter/listener system
  #
  # == Example
  #
  #     require 'triton'
  #     Triton::Messenger.on(:alert) { puts "alert!" }
  #     Triton::Messenger.emit(:alert)
  #                         # -> alert!
  module Messenger
    extend self # This make Messenger behave like a singleton

    def listeners # this makes @listeners to be auto-initialized and accessed read-only
      @listeners ||= Hash.new
    end

    # Register the given block to be called when the events of type +type+ will be emitted.
    # if +once+, the block will be called once
    def add_listener(type, once=false, &listener)
      listeners[type] ||= []
      listeners[type] << Event.new(type, listener, once)
      emit(:new_listener, self, type, once, listener)
    end

    alias :on :add_listener

    # Register the given block to be called only once when the events of type +type+ will be emitted.
    def once(type, &listener)
      add_listener(type, true, &listener)
    end

    # Unregister the given block. It won't be call then went an event is emitted.
    def remove_listener(type, listener)
      if listeners.has_key? type
        listeners[type].delete(listener)
        listeners.delete(type) if listeners[type].empty?
      end
    end

    # Unregister all the listener for the +type+ events.
    # If +type+ is omitted, unregister *all* the listeners.
    def remove_all_listeners(type=nil)
      if type
        listeners.delete(type)
      else
        listeners.clear
      end
    end

    # Emit an event of type +type+ and call all the registered listeners to this event.
    # The +sender+ param will help the listener to identify who is emitting the event.
    # You can pass then every additional arguments you'll need
    def emit(type, sender=nil, *args)
      listeners[type].each { |l| l.fire(sender, *args) } if listeners.has_key? type
    end

    # Mixin that add shortcuts to emit events
    module Emitter
      def emit(type, *args)
        Triton::Messenger.emit(type, self, *args)
      end
    end

    # Mixin that add shortcuts to emit events
    module Listener
      def add_listener(type, once=false, &listener)
        Triton::Messenger.add_listener(type, once, &listener)
      end

      alias :on :add_listener

      def once(type, &listener)
        Triton::Messenger.once(type, &listener)
      end
    end

    # The Event class helps managing event triggering.
    # It may not be used as its own.
    class Event
      attr_accessor :type, :listener, :once

      def initialize(type, listener, once=false)
        @type = type
        @listener = listener
        @once = once
      end

      # Call the event listener passing through the +sender+ and the additional args
      def fire(sender=nil, *args)
        @listener.call(sender, *args)

        if @once
          Messenger::remove_listener(@type, self)
        end
      end
    end
  end
end