# frozen_string_literal: true

require 'thor'

module Debsources
  module Watch
    module Crawler
      # Handle the application command line parsing
      # and the dispatch to various command objects
      #
      # @api public
      class CLI < Thor
        # Error raised by this runner
        Error = Class.new(StandardError)

        desc 'version', 'debsources-watch-crawler version'
        def version
          require_relative 'version'
          puts "v#{Debsources::Watch::Crawler::VERSION}"
        end
        map %w(--version -v) => :version

        require_relative 'commands/analyze'
        register Debsources::Watch::Crawler::Commands::Analyze, 'analyze', 'analyze [SUBCOMMAND]', 'Command description...'

        require_relative 'commands/init'
        register Debsources::Watch::Crawler::Commands::Init, 'init', 'init [SUBCOMMAND]', 'Initialize database file'

        require_relative 'commands/collect'
        register Debsources::Watch::Crawler::Commands::Collect, 'collect', 'collect [SUBCOMMAND]', 'Collect debian package list'
      end
    end
  end
end
