# frozen_string_literal: true

module OnPage
  # OnPage::Configuration
  class Configuration
    attr_accessor :api_token, :company, :connect_timeout, :read_timeout

    def initialize
      @api_token = nil
      @company = nil
      @connect_timeout = 2000
      @read_timeout = 5000
    end
  end
end
