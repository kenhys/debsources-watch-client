# frozen_string_literal: true

require 'thor'

module Debsources
  module Watch
    module Client
      # Handle the application command line parsing
      # and the dispatch to various command objects
      #
      # @api public
      class CLI < Thor
        # Error raised by this runner
        Error = Class.new(StandardError)

        desc 'version', 'debsources-watch-client version'
        def version
          require_relative 'version'
          puts "v#{Debsources::Watch::Client::VERSION}"
        end
        map %w(--version -v) => :version

        require_relative 'commands/collect'
        register Debsources::Watch::Client::Commands::Collect, 'collect', 'collect [SUBCOMMAND]', 'Collect debian package list'
      end
    end
  end
end
