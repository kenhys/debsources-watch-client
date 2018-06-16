# frozen_string_literal: true

require_relative '../../command'
require 'grn_mini'
require 'open-uri'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Collect
          class Watch < Debsources::Watch::Crawler::Command
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
                  one_week = 60 * 60 * 24 * 7
                  if @pkgs[package].updated_at > Time.now - one_week
                    p "SKIP #{package} #{Time.now - one_week} < #{@pkgs[package].updated_at}"
                    next
                  end
                  update_watch_content(record.key)
                  sleep 5
                end
              end
            end

            def update_watch_content(package)
              p package
              unless @pkgs[package]
                return
              end
              package_version, watch_url = latest_package_version(package)

              unless watch_url
                add_missing_package(package, package_version)
                return
              end

              watch_file_url = "https://sources.debian.org/#{watch_url}"
              p watch_file_url
              open(watch_file_url) do |response|
                timestamp = Time.now
                unless @pkgs[package].created_at
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

            def add_missing_package(package, version)
              timestamp = Time.now
              data = {}
              unless @pkgs[package].created_at
                data = {
                  watch_missing: 1, version: version, updated_at: timestamp
                }
              else
                data = {
                  watch_missing: 1, version: version, created_at: timestamp, updated_at: timestamp
                }
              end
              @pkgs[package] = data
            end

            def latest_package_version(package)
              return nil, nil if package == "vmware-nsx"

              package_version = nil
              content_url = nil
              latest_watch_url = "https://sources.debian.org/api/src/#{package}/latest/debian/watch"
              p latest_watch_url
              open(latest_watch_url) do |response|
                json = JSON.parse(response.read)
                if json["error"] == 404
                  if response.base_uri.request_uri =~ /\/api\/src\/#{package}\/(.+)\/debian\/watch/
                    package_version = $1
                  end
                else
                  content_url = json["raw_url"]
                  package_version = json["version"]
                end
              end
              return package_version, content_url
            end

            def is_unstable
              @json["versions"][0]["suites"].include?("sid")
            end
          end
        end
      end
    end
  end
end
