require "./spec_helper"

def create_with(values)
    cb = Trouve::CircularBuffer(Int32).new
    values.each { |e| cb << e }
    cb
end

def iter(cb)
    got = [] of Int32
    cb.each { |e| got << e }
    got
end

def create_with_and_iter(values)
    cb = create_with(values)
    iter(cb)
end

describe "Trouve::CircularBuffer" do
    it "can be created" do
        create_with([] of Int32).should_not be_nil
    end
    it "has a length of 0 by default" do
        create_with([] of Int32).length.should eq(0)
    end
    it "doesn't yield when empty" do
        create_with_and_iter([] of Int32).should eq([] of Int32)
    end
    it "can push a value" do
        create_with([1]).length.should eq(1)
    end
    it "can iterate on one value" do
        create_with_and_iter([1]).should eq([1])
    end
    it "can push two values" do
        create_with([1,2]).length.should eq(2)
    end
    it "can iterate on two values" do
        create_with_and_iter([1,2]).should eq([1,2])
    end
    it "can push three values" do
        create_with([1,2,3]).length.should eq(3)
    end
    it "can iterate on three values" do
        create_with_and_iter([1,2,3]).should eq([1,2,3])
    end
    it "rotates when pushing more than the capacity" do
        create_with([1,2,3,4]).length.should eq(3)
    end
    it "can iterate after rotation" do
        create_with_and_iter([1,2,3,4]).should eq([2,3,4])
    end
    it "rotates when pushing two more than the capacity" do
        create_with([1,2,3,4,5]).length.should eq(3)
    end
    it "can iterate after rotation of two" do
        create_with_and_iter([1,2,3,4,5]).should eq([3,4,5])
    end
    it "rotates when pushing three more than the capacity" do
        create_with([1,2,3,4,5,6]).length.should eq(3)
    end
    it "can iterate after rotation of three" do
        create_with_and_iter([1,2,3,4,5,6]).should eq([4,5,6])
    end
    it "rotates when pushing four more than the capacity" do
        create_with([1,2,3,4,5,6,7]).length.should eq(3)
    end
    it "can iterate after rotation of four" do
        create_with_and_iter([1,2,3,4,5,6,7]).should eq([5,6,7])
    end
    it "keeps going after expand" do
        cb = create_with([1,2,3,4,5,6,7]).expand(2).push(8).push(9).push(10)
        iter(cb).should eq([6,7,8,9,10])
    end
end
