# frozen_string_literal: true

module OnPage
  # OnPage::Downloadable
  class Downloadable
    def initialize(params)
      @name = params["name"]
      @token = params["token"]
    end

    def image?
      %w[.jpg .jpeg .png .gif].include? File.extname(@name)
    end

    def download_url(options = {})
      path = @token
      path += image_resize(options) if image?
      name = options[:original_name] ? @name : nil
      Api.storage_link(path, name)
    end

    private

    def image_resize(options)
      instructions = ""
      if options[:x] || options[:y]
        instructions += ".#{options[:x]}x#{options[:y]}"
        instructions += "-contain" unless options[:crop]
      end
      instructions += ".#{options[:ext]}" if options[:ext]
      instructions
    end
  end
end
