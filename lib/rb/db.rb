# typed: strict
# frozen_string_literal: true

require_relative "db/version"
require 'sorbet-runtime'
require 'json'

module Rb
  module Db
    class Database
      LOG_FILE = T.let("./aof.txt", String)

      extend T::Sig
      sig {void}
      def initialize
        @log = T.let(File.open(LOG_FILE, 'a+'), File)
        @log.sync = true
      end

      sig {params(key: Integer, value: T::Hash[T.untyped, T.untyped]).returns(NilClass)}
      def set(key, value)
        @log.write("#{key},#{value.to_json}\n"); nil
      end

      sig {params(key: Integer).returns(T::Hash[T.untyped, T.untyped])}
      def get(key)
        File.open(LOG_FILE, 'r')
            .each_line.grep(/^#{key},/).last
            &.gsub(/^\d+,/, '')&.yield_self {|h| JSON.parse(h)}
      end
    end

    class Error < StandardError; end
  end
end
