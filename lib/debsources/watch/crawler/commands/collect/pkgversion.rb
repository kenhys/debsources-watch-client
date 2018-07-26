# frozen_string_literal: true

require_relative '../../command'
require 'open-uri'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Collect
          class Pkgversion < Debsources::Watch::Crawler::Command
            def initialize(package, options)
              @package = package
              @options = options
              @config = ::Debsources::Watch::Crawler::Config.new
              Debsources::Watch::Crawler.create_or_open_database(@config.database_path)
              @pkgs = Groonga["Pkgs"]
            end

            def execute(input: $stdin, output: $stdout)
              # Command logic goes here ...
              packages = []
              @pkgs.each do |record|
                packages << record._key
              end
              packages.each do |package|
                p package
                info = fetch_package_info(package)
                unless info
                  next
                end
                suites = package_suites(info)
                version = package_version(info)
                p version
                p suites
                if version
                  timestamp = Time.now
                  @pkgs.add(package,
                            :name => package,
                            :version => version,
                            :suites => suites,
                            :created_at => timestamp,
                            :updated_at => timestamp)
                end
              end
            end

            def fetch_package_info(package)
              pkginfo_url = "https://sources.debian.org/api/src/#{package}/"
              p pkginfo_url
              version = nil
              json = nil
              begin
                open(pkginfo_url) do |request|
                  json = JSON.parse(request.read)
                end
              rescue
                p "error"
              end
              json
            end

            def package_suites(json)
              json["versions"][0]["suites"]
            end

            def package_version(json)
              json["versions"][0]["version"]
            end

          end
        end
      end
    end
  end
end
