require_relative "./test_helper"

describe Triton::Messenger do

  before :each do
    Triton::Messenger.remove_all_listeners
  end

  it "registers listeners" do
    ok = false
    Triton::Messenger.on(:test) { ok = true }
    Triton::Messenger.emit(:test)
    ok.must_equal true
  end

  it "registers listeners once with the +once+ parameter" do
    ok = 0
    Triton::Messenger.on(:test, true) { ok += 1 }
    2.times { Triton::Messenger.emit(:test) }
    ok.must_equal 1
  end

  it "registers listeners once with _once_" do
    ok = 0
    Triton::Messenger.once(:test) { ok += 1 }
    2.times { Triton::Messenger.emit(:test) }
    ok.must_equal 1
  end

  it "emits a new_listener event when an listener is registered" do
    received_sender = nil
    received_args = nil
    cb = lambda do |s, *args|
      received_sender = s
      received_args = args
    end
    Triton::Messenger.on(:new_listener, false, &cb)
    received_sender.must_be_same_as Triton::Messenger
    received_args.must_equal [:new_listener, false, cb]
  end

  it "unregisters listeners" do
    ok = false
    Triton::Messenger.on(:test) { fail "it should not have been called" }
    Triton::Messenger.on(:test) { ok = true }
    Triton::Messenger.remove_listener(:test, Triton::Messenger.listeners[:test].first)
    Triton::Messenger.emit(:test)
    ok.must_equal true
  end

  it "should not unregister listeners of unknown type" do
    ok = false
    Triton::Messenger.on(:test) { ok = true }
    Triton::Messenger.remove_listener(:unknown, Triton::Messenger.listeners[:test].first)
    Triton::Messenger.emit(:test)
    ok.must_equal true
  end

  it "should not unregister unknown listeners" do
    ok = false
    Triton::Messenger.on(:test) { ok = true }
    Triton::Messenger.remove_listener(:test, Triton::Messenger::Listener.new(:test, nil))
    Triton::Messenger.emit(:test)
    ok.must_equal true
  end

  it "unregisters all listeners of one type" do
    ok = false
    Triton::Messenger.on(:test) { fail "it should not have been called" }
    Triton::Messenger.on(:test) { fail "it should not have been called" }
    Triton::Messenger.on(:test2) { ok = true }
    Triton::Messenger.remove_all_listeners(:test)
    Triton::Messenger.emit(:test)
    Triton::Messenger.emit(:test2)
    ok.must_equal true
  end

  it "unregisters all listeners of all type" do
    Triton::Messenger.on(:test) { fail "it should not have been called" }
    Triton::Messenger.on(:test2) { fail "it should not have been called" }
    Triton::Messenger.remove_all_listeners
    Triton::Messenger.emit(:test)
    Triton::Messenger.emit(:test2)
  end

  it "emits events to the right listener" do
    Triton::Messenger.on(:test) { }
    Triton::Messenger.on(:test2) { fail "it should not have been called" }
    Triton::Messenger.emit(:test)
  end

  it "should not emit events when the type is unknown" do
    Triton::Messenger.on(:test) { fail "it should not have been called" }
    Triton::Messenger.on(:test2) { fail "it should not have been called" }
    Triton::Messenger.emit(:unknown)
  end

  it "emits events and passes the sender" do
    received_sender = nil
    expected_sender = Object.new
    Triton::Messenger.on(:test) { |s| received_sender = s }
    Triton::Messenger.emit(:test, expected_sender)
    received_sender.must_be_same_as expected_sender
  end

  it "emits events and passes additional arguments" do
    received_args = nil
    expected_args = {:arg => "yeah"}
    Triton::Messenger.on(:test) { |s, opts| received_args = opts }
    Triton::Messenger.emit(:test, nil, :arg => "yeah")
    received_args.must_equal expected_args
  end
end


describe Triton::Messenger::Listener do

  it "should default the once instance variable to false" do
    event = Triton::Messenger::Listener.new(:test, nil)
    event.once.must_equal false
  end

  it "calls the provided callback" do
    called = false
    cb = lambda { |s| called = true }
    event = Triton::Messenger::Listener.new(:test, cb)
    event.fire
    called.must_equal true
  end

  it "unregisters itself once the event fired" do
    event = Triton::Messenger::Listener.new(:test, lambda { |s| }, true)
    Triton::Messenger.expects(:remove_listener).with(:test, event)
    event.fire
  end
end

describe Triton::Messenger::Emittable do

  it "should emit a signal on this name" do
    klass = Class.new { include Triton::Messenger::Emittable }
    instance = klass.new
    Triton::Messenger.expects(:emit).with(:test, instance, :arg)
    instance.emit(:test, :arg)
  end
end

describe Triton::Messenger::Listenable do

  before :each do
    Triton::Messenger.remove_all_listeners
    klass = Class.new { include Triton::Messenger::Listenable }
    @instance = klass.new
  end

  it "should shortcut the #add_listener method" do
    Triton::Messenger.expects(:add_listener).with(:test_add_listener, true)
    @instance.add_listener(:test_add_listener, true)
  end

  it "should shortcut the #on method" do
    Triton::Messenger.expects(:add_listener).with(:test_on, true)
    @instance.on(:test_on, true)
  end

  it "should shortcut the #once method" do
    Triton::Messenger.expects(:once).with(:test_once)
    @instance.once(:test_once)
  end
end