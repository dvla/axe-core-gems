require 'axe/api/selector'

module Axe
  module API
    class Context
      def initialize
        @inclusion = []
        @exclusion = []
      end

      def within(*selectors)
        @inclusion.concat selectors.map { |s| Array(Selector.new s) }
      end

      def excluding(*selectors)
        @exclusion.concat selectors.map { |s| Array(Selector.new s) }
      end

      def to_hash
        {}.tap do |context_param|
          # include key must not be included if empty
          # (when undefined, defaults to `document`)
          context_param[:include] = @inclusion unless @inclusion.empty?

          # exclude array allowed to be empty
          # and must exist in case `include` is omitted
          # because context_param cannot be empty object ({})
          context_param[:exclude] = @exclusion
        end
      end

      def to_json
        to_hash.to_json
      end

      alias :to_s :to_json

    end
  end
end
