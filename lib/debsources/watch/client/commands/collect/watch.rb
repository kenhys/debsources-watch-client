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
                @pkgs.each do |record|
                  update_watch_content(record.key)
                  sleep 5
                end
              end
            end

            def update_watch_content(package)
              p package
              raw_url = ""
              package_version = ""
              latest_watch_url = "https://sources.debian.org/api/src/#{package}/latest/debian/watch"
              p latest_watch_url
              open(latest_watch_url) do |response|
                json = JSON.parse(response.read)
                raw_url = json["raw_url"]
                package_version = json["version"]
              end
              if raw_url
                watch_file_url = "https://sources.debian.org/#{raw_url}"
                p watch_file_url
                open(watch_file_url) do |response|
                  @pkgs[package] = {watch_content: response.read, version: package_version}
                end
              end
            end
          end
        end
      end
    end
  end
end
