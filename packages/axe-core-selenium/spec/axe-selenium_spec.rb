require "spec_helper"
require "tempfile"

require_relative "../lib/axe-selenium"

describe AxeSelenium do
  subject { described_class }

  describe "driver" do
    it "validate yielded configuration" do
      driver = AxeSelenium.configure(:firefox) do
      end

      expect(driver).not_to be_nil
      driver.page.navigate.to "https://deque.com" # can navigate
      expect(driver).to respond_to :skip_iframes # can config
      expect(driver).to respond_to :jslib
      expect(driver.jslib).to include("axe.run=") # has axe injected
    end

    it "gets passed configuration options" do
      options = Selenium::WebDriver::Options.firefox
      options.args << '-headless'
      expect(Selenium::WebDriver).to receive(:for).with(:firefox, {options: options})
      driver = AxeSelenium.configure(:firefox, options) do
      end
    end
  end

  describe "#configure" do
    it "should yield default configuration" do
      actual = Axe::Configuration.instance
      expect { |stub_block|
        subject.configure(&stub_block)
      }.to yield_with_args(actual)
    end

    it "should yield configuration with specified jslib path" do
      different_axe_path = "different-axe-path/axe.js"

      # configure:
      # 1. driver for browser
      # 2. a different js path
      AxeSelenium.configure do |c|
        c.jslib_path = different_axe_path
      end

      actual = Axe::Configuration.instance
      expect(actual.jslib_path).to eq different_axe_path
    end

    it "should yield configuration with Chrome driver" do
      AxeSelenium.configure(:chrome) do
      end

      actual = Axe::Configuration.instance
      expect(actual.page).not_to be_nil
      expect(actual.page.to_s).to include("WebDriver::Chrome")
    end

    it "should yield configuration with Firefox driver" do
      AxeSelenium.configure(:firefox) do
      end

      actual = Axe::Configuration.instance
      expect(actual.page).not_to be_nil
      expect(actual.page.to_s).to include("WebDriver::Firefox")
    end

    it "should raise when no configuration block is provided" do
      expect { AxeSelenium.configure }.to raise_error("Please provide a configure block for AxeSelenium")
    end
  end
end
