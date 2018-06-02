# frozen_string_literal: true

require_relative '../../command'
require 'grn_mini'
require 'open-uri'

module Debsources
  module Watch
    module Client
      module Commands
        class Collect
          class Watch < Debsources::Watch::Client::Command
            def initialize(package=nil, options)
              @package = package
              @options = options
              GrnMini::create_or_open("data/debian-watch.db")
              @pkgs = GrnMini::Hash.new("Pkgs")
            end

            def execute(input: $stdin, output: $stdout)
              if @package
                update_watch_content(@package)
              else
                p @pkgs.keys
              end
            end

            def update_watch_content(package)
              raw_url = ""
              open("https://sources.debian.org/api/src/#{package}/latest/debian/watch") do |response|
                json = JSON.parse(response.read)
                raw_url = json["raw_url"]
              end
              if raw_url
                open("https://sources.debian.org/#{raw_url}") do |response|
                  @pkgs[package] = {watch_content: response.read}
                end
              end
            end
          end
        end
      end
    end
  end
end
