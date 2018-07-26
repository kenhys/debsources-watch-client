# frozen_string_literal: true

require_relative '../../command'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Collect
          class Opts < Debsources::Watch::Crawler::Command
            def initialize(package, options)
              @package = package
              @options = options
              @config = ::Debsources::Watch::Crawler::Config.new
            end

            def execute(input: $stdin, output: $stdout)
              # Command logic goes here ...
              output.puts "OK"
              Debsources::Watch::Crawler.create_or_open_database(@config.database_path)
            end
          end
        end
      end
    end
  end
end
