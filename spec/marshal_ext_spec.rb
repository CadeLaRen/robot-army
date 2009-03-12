require File.dirname(__FILE__) + '/spec_helper'

class CannotMarshalMe
  def marshalable?
    false
  end
end

class CustomContainer
  def initialize(child)
    @child = child
  end
end

describe Marshal do
  it "can dump Fixnums" do
    42.must be_marshalable
  end

  it "can dump Strings" do
    "foo".must be_marshalable
  end

  it "can dump Arrays" do
    [2, 'foo'].must be_marshalable
  end

  it "can't dump things that return false for marshalable?" do
    CannotMarshalMe.new.must_not be_marshalable
  end

  it "can't dump Arrays containing unmarshalable items" do
    [2, $stdin].must_not be_marshalable
    [2, CannotMarshalMe.new].must_not be_marshalable
  end

  it "can dump hashes" do
    {:foo => 'bar'}.must be_marshalable
  end

  it "can't dump hashes with unmarshalable keys" do
    {$stdin => 'bar'}.must_not be_marshalable
    {CannotMarshalMe.new => 'bar'}.must_not be_marshalable
  end

  it "can't dump hashes with unmarshalable values" do
    {:foo => $stdin}.must_not be_marshalable
    {:foo => CannotMarshalMe.new}.must_not be_marshalable
  end

  it "can't dump hashes with an unmarshalable default value" do
    Hash.new($stdin).must_not be_marshalable
    Hash.new(CannotMarshalMe.new).must_not be_marshalable
  end

  it "can dump hashes with a marshalable default value" do
    Hash.new(0).must be_marshalable
  end

  it "can't dump hashes with a default proc" do
    Hash.new {|a,b| a[b] = rand}.must_not be_marshalable
  end

  it "can't dump objects containing references to unmarshalable objects" do
    CustomContainer.new(CannotMarshalMe.new).must_not be_marshalable
  end

  it "can't dump IOs" do
    $stdin.must_not be_marshalable
  end

  it "can't dump Methods" do
    method(:to_s).must_not be_marshalable
  end

  it "can't dump bindings" do
    binding.must_not be_marshalable
  end

  it "can't dump Procs" do
    proc{ 2 }.must_not be_marshalable
  end

  it "can't dump anything whose _dump method raises a TypeError" do
    class NotDumpable; def _dump(*args); raise TypeError; end; end
    NotDumpable.new.must_not be_marshalable
  end
end

