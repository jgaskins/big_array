require "spec/helpers/iterate"
require "./spec_helper"

describe BigArray do
  big_ary1 = BigArray{1, 2, 3}
  size = big_ary1.size

  it "works" do
    size.should be_a Int64
    size.should eq 3

    idx = big_ary1.each_index

    idx.next.should eq 0
    idx.next.should eq 1
    idx.next.should eq 2
  end

  big_ary2 = BigArray{4}
  big_ary2 << 5

  it_iterates "BigArray#each", [1, 2, 3, 4, 5], (big_ary1 + big_ary2).each
end
