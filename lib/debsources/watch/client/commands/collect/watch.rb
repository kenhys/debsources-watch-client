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
                  package = record.key
                  if @pkgs[package].updated_at > Time.now - 60 * 60 * 24
                    p "SKIP #{package} #{Time.now - 60 * 60 * 24} < #{@pkgs[package].updated_at}"
                    next
                  end
                  update_watch_content(record.key)
                  sleep 5
                end
              end
            end

            def update_watch_content(package)
              p package
              raw_url = nil
              package_version = nil
              latest_watch_url = "https://sources.debian.org/api/src/#{package}/latest/debian/watch"
              p latest_watch_url
              open(latest_watch_url) do |response|
                json = JSON.parse(response.read)
                if json["error"] == 404
                  if response.base_uri.request_uri =~ /\/api\/src\/#{package}\/(.+)\/debian\/watch/
                    package_version = $1
                  end
                else
                  raw_url = json["raw_url"]
                  package_version = json["version"]
                end
              end

              timestamp = Time.now
              unless raw_url
                data = {}
                unless @pkgs[package].created_at
                  data = {
                    watch_missing: 1, version: package_version, updated_at: timestamp
                  }
                else
                  data = {
                    watch_missing: 1, version: package_version, created_at: timestamp, updated_at: timestamp
                  }
                end
                @pkgs[package] = data
                return
              end

              watch_file_url = "https://sources.debian.org/#{raw_url}"
              p watch_file_url
              open(watch_file_url) do |response|
                timestamp = Time.now
                unless record.created_at
                  @pkgs[package] = {
                    watch_content: response.read, version: package_version, created_at: timestamp, updated_at: timestamp
                  }
                else
                  @pkgs[package] = {
                    watch_content: response.read, version: package_version, updated_at: timestamp
                  }
                end
              end
            end
          end
        end
      end
    end
  end
end
