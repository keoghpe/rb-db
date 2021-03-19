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
        @index = T.let({}, T::Hash[Integer, Integer])
      end

      sig {params(key: Integer, value: T::Hash[T.untyped, T.untyped]).returns(NilClass)}
      def set(key, value)
        line = "#{key},#{value.to_json}\n"
        @log.write(line)
        # does the below work for UTF-8 chars?
        byte_offset = @log.pos - line.length
        @index[key] = byte_offset
        nil
      end

      sig {params(key: Integer).returns(T::Hash[T.untyped, T.untyped])}
      def get(key)
        file = File.open(LOG_FILE, 'r')
        file.pos = T.must(@index[key])
        file.readline.gsub(/^\d+,/, '').yield_self {|h| JSON.parse(h)}
      end
    end

    class Error < StandardError; end
  end
end
