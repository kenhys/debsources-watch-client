# frozen_string_literal: true

require_relative '../../command'
require_relative '../../config'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Config
          class Init < Debsources::Watch::Crawler::Command
            def initialize(path=nil, options)
              @path = path
              @options = options
            end

            def execute(input: $stdin, output: $stdout)
              Debsources::Watch::Crawler::Config.new
            end
          end
        end
      end
    end
  end
end
