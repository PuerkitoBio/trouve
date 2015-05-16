require "./spec_helper"

def it_matches (in, pat, exp, max = 0)
    it "matches #{in} with #{pat}" do
        f = Trouve::Finder.new(pat, max)
        
        got = [] of Int32
        f.find(StringIO.new(in)) do |line_num, match|
            got << line_num
        end
        got.should eq(exp)
    end
end

describe "Trouve::Finder" do
    it_matches "abc", "a", [0]
    it_matches "abc\ndef", "a", [0]
    it_matches "abc\ndef", "ad", [] of Int32
    it_matches "abc\ndef", "def", [1]
    it_matches "abc\ndef\nagh", "a", [0,2]
    it_matches "abc\ndef\nagh", "a", [0], 1

    it_matches "abc\ndef", /a/, [0]
    it_matches "abc\ndef", /abcd?/, [0]
    it_matches "abc\ndef", /abcd/, [] of Int32
    it_matches "abc\ndef", /d?/, [0,1]
    it_matches "abc\ndef", /d/, [1]
end
