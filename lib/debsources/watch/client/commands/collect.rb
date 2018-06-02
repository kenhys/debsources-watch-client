# frozen_string_literal: true

require 'thor'

module Debsources
  module Watch
    module Client
      module Commands
        class Collect < Thor

          namespace :collect

          desc 'pkglist', 'Collect debian package list'
          method_option :help, aliases: '-h', type: :boolean,
                               desc: 'Display usage information'
          def pkglist(*)
            if options[:help]
              invoke :help, ['pkglist']
            else
              require_relative 'collect/pkglist'
              Debsources::Watch::Client::Commands::Collect::Pkglist.new(options).execute
            end
          end
        end
      end
    end
  end
end
