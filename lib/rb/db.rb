# typed: strict
# frozen_string_literal: true

require_relative "db/version"

module Rb
  module Db
    class Database
      extend T::Sig
      sig {void}
      def initialize
      end

      sig {params(key: Integer, value: T::Hash[T.untyped, T.untyped]).returns(NilClass)}
      def set(key, value)
      end

      sig {params(key: Integer).returns(NilClass)}
      def get(key)
      end
    end

    class Error < StandardError; end
  end
end
