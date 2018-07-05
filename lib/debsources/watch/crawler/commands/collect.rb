# frozen_string_literal: true

require 'thor'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Collect < Thor

          namespace :collect

          desc 'opts [PACKAGE]', 'Command description...'
          method_option :help, aliases: '-h', type: :boolean,
                               desc: 'Display usage information'
          def opts(package = nil)
            if options[:help]
              invoke :help, ['opts']
            else
              require_relative 'collect/opts'
              Debsources::Watch::Crawler::Commands::Collect::Opts.new(package, options).execute
            end
          end

          desc 'pkgversion [PACKAGE]', 'Command description...'
          method_option :help, aliases: '-h', type: :boolean,
                               desc: 'Display usage information'
          def pkgversion(package = nil)
            if options[:help]
              invoke :help, ['pkgversion']
            else
              require_relative 'collect/pkgversion'
              Debsources::Watch::Crawler::Commands::Collect::Pkgversion.new(package, options).execute
            end
          end

          desc 'watch PACKAGE', 'Collect debian/watch files'
          method_option :help, aliases: '-h', type: :boolean,
                               desc: 'Display usage information'
          def watch(package=nil)
            if options[:help]
              invoke :help, ['watch']
            else
              require_relative 'collect/watch'
              Debsources::Watch::Crawler::Commands::Collect::Watch.new(package, options).execute
            end
          end

          desc 'pkglist', 'Collect debian package list'
          method_option :help, aliases: '-h', type: :boolean,
                               desc: 'Display usage information'
          def pkglist(*)
            if options[:help]
              invoke :help, ['pkglist']
            else
              require_relative 'collect/pkglist'
              Debsources::Watch::Crawler::Commands::Collect::Pkglist.new(options).execute
            end
          end
        end
      end
    end
  end
end
