# frozen_string_literal: true

require_relative '../../command'
require 'grn_mini'

module Debsources
  module Watch
    module Client
      module Commands
        class Init
          class Database < Debsources::Watch::Client::Command
            def initialize(options)
              @options = options
            end

            def execute(input: $stdin, output: $stdout)
              GrnMini::create_or_open("debian-watch.db")
              pkgs = GrnMini::Hash.new("Pkgs")
            end
          end
        end
      end
    end
  end
end
