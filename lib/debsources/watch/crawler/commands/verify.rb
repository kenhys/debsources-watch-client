# frozen_string_literal: true

require 'thor'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Verify < Thor

          namespace :verify

          desc 'uscan [PACKAGE]', 'Command description...'
          method_option :help, aliases: '-h', type: :boolean,
                               desc: 'Display usage information'
          def uscan(package = nil)
            if options[:help]
              invoke :help, ['uscan']
            else
              require_relative 'verify/uscan'
              Debsources::Watch::Crawler::Commands::Verify::Uscan.new(package, options).execute
            end
          end
        end
      end
    end
  end
end
