# frozen_string_literal: true

require_relative '../../command'
require 'grn_mini'
require 'open-uri'
require 'json'

module Debsources
  module Watch
    module Client
      module Commands
        class Collect
          class Pkglist < Debsources::Watch::Client::Command
            def initialize(options)
              @options = options
            end

            def execute(input: $stdin, output: $stdout)
              return unless File.exist?("pkglist.json")

              open("pkglist.json") do |file|
                json = JSON.load(file.read)
                GrnMini::create_or_open("data/debian-watch.db")
                pkgs = GrnMini::Hash.new("Pkgs")
                json["packages"].each do |package|
                  name = package["name"]
                  pkgs[name] = {name: name}
                end
              end

            end
          end
        end
      end
    end
  end
end
