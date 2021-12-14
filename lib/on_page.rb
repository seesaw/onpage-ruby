# frozen_string_literal: true

require "on_page/api"
require "on_page/configuration"
require "on_page/version"

# OnPage module
module OnPage
  def self.configuration
    @configuration ||= Config.new
  end

  # Used to configure OnPage.
  #
  # @example
  #    OnPage.configure do |config|
  #      config.some_config_option = true
  #    end
  #
  # @yield the configuration block
  def self.configure
    yield configuration
  end

  def self.schema(reload: false)
    @schema = Api.project_information if reload || @schema.nil?
    @schema
  end
end
