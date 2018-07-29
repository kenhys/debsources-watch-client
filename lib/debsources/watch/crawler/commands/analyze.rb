# frozen_string_literal: true

require 'thor'
begin
  require 'gruff'
rescue
end

module Debsources
  module Watch
    module Crawler
      module Commands
        class Analyze < Thor

          namespace :analyze

          desc 'graph [TYPE]', 'Command description...'
          method_option :help, aliases: '-h', type: :boolean,
                               desc: 'Display usage information'
          def graph(type = nil)
            if options[:help]
              invoke :help, ['graph']
            else
              require_relative 'analyze/graph'
              Debsources::Watch::Crawler::Commands::Analyze::Graph.new(type, options).execute
            end
          end

          desc 'content', 'Command description...'
          method_option :help, aliases: '-h', type: :boolean,
                               desc: 'Display usage information'
          def content(*)
            if options[:help]
              invoke :help, ['content']
            else
              require_relative 'analyze/content'
              Debsources::Watch::Crawler::Commands::Analyze::Content.new(options).execute
            end
          end
        end
      end
    end
  end
end
