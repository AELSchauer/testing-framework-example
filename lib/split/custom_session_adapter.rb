# frozen_string_literal: true

module Split
  class CustomSessionAdapter
    def initialize(context)
      @session = context.session
    end

    def [](key)
      @session["split"]["experiments"][key]
    end

    def []=(key, value)
      @session["split"]["experiments"][key] = value
    end

    def delete(key)
      @session["split"]["experiments"].delete(key)
    end

    def keys
      @session["split"]["experiments"].keys
    end
  end
end
