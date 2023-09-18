# frozen_string_literal: true
module Split
  class CustomPersistenceAdapter
    def initialize(context)
      @session = context.session
      @session[:split] ||= {}
    end

    def [](key)
      @session[:split][key]
    end

    def []=(key, value)
      @session[:split][key] = value
    end

    def delete(key)
      @session[:split].delete(key)
    end

    def keys
      @session[:split].keys
    end
  end
end
