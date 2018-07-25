# frozen_string_literal: true

require 'thor'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Config < Thor

          namespace :config

          desc 'init PATH', 'Command description...'
          method_option :help, aliases: '-h', type: :boolean,
                               desc: 'Display usage information'
          def init(path=nil)
            if options[:help]
              invoke :help, ['init']
            else
              require_relative 'config/init'
              Debsources::Watch::Crawler::Commands::Config::Init.new(path, options).execute
            end
          end
        end
      end
    end
  end
end
