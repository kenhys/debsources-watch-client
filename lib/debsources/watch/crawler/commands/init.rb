# frozen_string_literal: true

require 'thor'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Init < Thor

          namespace :init

          desc 'database', 'Initialize database file'
          method_option :help, aliases: '-h', type: :boolean,
                               desc: 'Display usage information'
          def database(*)
            if options[:help]
              invoke :help, ['database']
            else
              require_relative 'init/database'
              Debsources::Watch::Crawler::Commands::Init::Database.new(options).execute
            end
          end
        end
      end
    end
  end
end
