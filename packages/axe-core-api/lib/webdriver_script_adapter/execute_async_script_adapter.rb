require "dumb_delegator"
require "securerandom"
require "timeout"
require_relative "./exec_eval_script_adapter"

module WebDriverScriptAdapter
  class << self
    attr_accessor :async_results_identifier,
                  :max_wait_time,
                  :wait_interval

    def configure
      yield self
    end
  end

  module Defaults
    module_function

    def async_results_identifier
      -> { ::SecureRandom.uuid }
    end

    # set max_wait_time based on type of webdriver
    def max_wait_time
      if defined? ::Capybara
        if ::Capybara.respond_to? :default_max_wait_time
          ::Capybara.default_max_wait_time
        else
          ::Capybara.default_wait_time
        end
      elsif defined? ::Selenium::WebDriver::Wait::DEFAULT_TIMEOUT
        ::Selenium::WebDriver::Wait::DEFAULT_TIMEOUT
      else
        3
      end
    end

    # set wait interval based on webdriver
    def wait_interval
      if defined? ::Selenium::WebDriver::Wait::DEFAULT_INTERVAL
        ::Selenium::WebDriver::Wait::DEFAULT_INTERVAL
      else
        0.1
      end
    end
  end

  module ScriptWriter
    module_function

    def async_results_identifier
      id = WebDriverScriptAdapter.async_results_identifier
      "window['#{id.respond_to?(:call) ? id.call : id}']"
    end

    def callback(results_identifier)
      "function(err, returnValue){ #{results_identifier} = (err || returnValue); }"
    end

    def async_wrapper(script, *args)
      "(function(){ #{script} })(#{args.join(", ")});"
    end
  end

  module Patiently
    module_function

    def wait_until
      ::Timeout.timeout(WebDriverScriptAdapter.max_wait_time) do
        sleep(WebDriverScriptAdapter.wait_interval) while (value = yield).nil?
        value
      end
    end
  end

  class ExecuteAsyncScriptAdapter < ::DumbDelegator
    def self.wrap(driver)
      new driver
    end

    def execute_async_script(script, *args)
      results = ScriptWriter.async_results_identifier
      execute_script ScriptWriter.async_wrapper(script, *args, ScriptWriter.callback(results))
      Patiently.wait_until { evaluate_script results }
    end

    def execute_async_script_fixed(script, *args)
      if __getobj__.respond_to?(:execute_async_script)
        __getobj__.execute_async_script(script, *args)
      else
        __getobj__.evaluate_async_script(script, *args)
      end
    end
  end

  configure do |c|
    c.async_results_identifier = Defaults.async_results_identifier
    c.max_wait_time = Defaults.max_wait_time
    c.wait_interval = Defaults.wait_interval
  end
end
