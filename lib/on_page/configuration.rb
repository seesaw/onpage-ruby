# frozen_string_literal: true

require "anyway_config"

module OnPage
  # OnPage::Config
  class Config < Anyway::Config
    attr_config :api_token, :company, :connect_timeout, :read_timeout

    describe_options(
      api_token: "api developer token",
      company: "company unique code (i.e url prefix)",
      connect_timeout: "http client connection timeout in seconds",
      read_timeout: "http client read timeout in seconds"
    )

    required :api_token, :company
    coerce_types connect_timeout: :integer, read_timeout: :integer
  end
end
