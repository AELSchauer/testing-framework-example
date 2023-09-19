# frozen_string_literal: true

module Split
  class CustomSessionAdapter
    def initialize(context)
      @session = context.session
      @session[:split][:experiments] ||= {}
    end

    def [](key)
      # debugger
      @session[:split][:experiments][key]
    end

    def []=(key, value)
      split = @session[:split]
      split[:experiments][key] = value
      # debugger
      @session[:split] = split
    end

    def delete(key)
      @session[:split][:experiments].delete(key)
    end

    def keys
      # debugger
      @session[:split][:experiments].keys
    end
  end
end
