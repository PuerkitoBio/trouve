require "./spec_helper"

describe "Trouve::Job" do
  it "finds with String pattern" do
    Trouve::Job.new("annel").run
  end

  it "stops after max matches with String pattern" do
    job = Trouve::Job.new("annel")
    job.max_matches = 1
    job.run
  end

  it "finds with Regex pattern" do
    Trouve::Job.new(/(case|when)/).run
  end

  it "stops after max matches with Regex pattern" do
    job = Trouve::Job.new(/(case|when)/)
    job.max_matches = 2
    job.run
  end
end
