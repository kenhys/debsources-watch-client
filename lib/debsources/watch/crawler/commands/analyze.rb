# frozen_string_literal: true

require 'thor'
require 'gruff'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Analyze < Thor

          namespace :analyze

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
