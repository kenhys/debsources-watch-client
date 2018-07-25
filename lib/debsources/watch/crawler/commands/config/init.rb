# frozen_string_literal: true

require_relative '../../command'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Config
          class Init < Debsources::Watch::Crawler::Command
            def initialize(path, options)
              @path = path
              @options = options
            end

            def execute(input: $stdin, output: $stdout)
              # Command logic goes here ...
              output.puts "OK"
            end
          end
        end
      end
    end
  end
end
