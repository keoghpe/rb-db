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
      sig { void }
      def initialize
        @log = T.let(File.open(LOG_FILE, 'a+'), File)
        @log.sync = true
        @index = T.let({}, T::Hash[Integer, Integer])
        populate_index
      end

      sig { params(key: Integer, value: T::Hash[T.untyped, T.untyped]).returns(NilClass) }
      def set(key, value)
        line = "#{key},#{value.to_json}\n"
        @log.write(line)
        # does the below work for UTF-8 chars?
        byte_offset = @log.pos - line.length
        @index[key] = byte_offset
        nil
      end

      sig { params(key: Integer).returns(T::Hash[T.untyped, T.untyped]) }
      def get(key)
        file = File.open(LOG_FILE, 'r')
        if @index[key]
          file.pos = T.must(@index[key])
          file.readline.gsub(/^\d+,/, '').yield_self { |h| JSON.parse(h) }
        else
          raise KeyNotFound
        end
      end

      private

      sig { returns(NilClass) }
      def populate_index
        file = File.open(LOG_FILE, 'r')
        loop do
          begin
            current_pos = file.pos
            line = file.readline
            key = T.must(line.match(/^(\d+),/))[1].to_i
            @index[key] = current_pos
          rescue EOFError
            break
          end
        end
      end
    end

    class KeyNotFound < StandardError
    end

    class Error < StandardError;
    end
  end
end
