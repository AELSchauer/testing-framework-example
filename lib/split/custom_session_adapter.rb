# frozen_string_literal: true

module Split
  class CustomSessionAdapter
    def initialize(context)
      @session = context.session
      @session[:split] = if @session.dig(:split, :expires_at).blank? || @session.dig(:split, :expires_at) >= Time.now
                           @session[:split][:experiments]
                         else
                           { id: SecureRandom.hex(16), expires_at: Time.now + 7.days, experiments: {} }
                         end
    end

    def id
      @session[:split][:id]
    end

    def expires_at
      @session[:split][:expires_at]
    end

    def [](key)
      @session[:split][:experiments][key]
    end

    def []=(key, value)
      @session[:split][:experiments][key] = value
    end

    def delete(key)
      @session[:split][:experiments].delete(key)
    end

    def keys
      @session[:split][:experiments].keys
    end
  end
end
