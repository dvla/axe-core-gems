require "spec_helper"

# Typical example using standard RSpec dsl
describe "ABCD CompuTech (RSpec DSL)",
         :type => :feature, :driver => :selenium do
  before :each do
    visit "http://abcdcomputech.dequecloud.com/"
  end

  it "is known to be inaccessible, should fail" do
    expect(page).not_to be_accessible
  end

  it "is known to have an accessible sub-tree (should pass)" do
    expect(page).to be_accessible.within "#intro"
  end

  it "is known to have an inaccessible sub-tree (should fail)" do
    expect(page).not_to be_accessible.within "#topbar"
  end
end