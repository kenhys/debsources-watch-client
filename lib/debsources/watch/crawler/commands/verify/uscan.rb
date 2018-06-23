# frozen_string_literal: true

require_relative '../../command'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Verify
          class Uscan < Debsources::Watch::Crawler::Command
            def initialize(package, options)
              @package = package
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
