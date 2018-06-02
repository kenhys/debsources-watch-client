# frozen_string_literal: true

require_relative '../../command'

module Debsources
  module Watch
    module Client
      module Commands
        class Collect
          class Watch < Debsources::Watch::Client::Command
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
