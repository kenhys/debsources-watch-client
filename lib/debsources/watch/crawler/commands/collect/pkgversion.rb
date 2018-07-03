# frozen_string_literal: true

require_relative '../../command'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Collect
          class Pkgversion < Debsources::Watch::Crawler::Command
            def initialize(package, options)
              @package = package
              @options = options
              GrnMini::create_or_open("data/debian-watch.db")
              @pkgs = Groonga["Pkgs"]
            end

            def execute(input: $stdin, output: $stdout)
              # Command logic goes here ...
              packages = []
              @pkgs.each do |record|
                packages << record._key
              end
              packages.each do |package|
                version = fetch_package_version(package)
                if version
                  @pkgs.add(package,
                            :name => package,
                            :version => version
                            :created_at => timestamp,
                            :updated_at => timestamp)
                end
              end
            end

            def fetch_package_version(package)
              pkginfo_url = "https://sources.debian.org/api/src/#{package}"
              p pkginfo_url
              version = nil
              open(pkginfo_url) do |request|
                json = JSON.parse(request.read)
                if json["versions"][0]["suites"].include?("sid")
                  version = json["versions"][0]["version"]
                end
              end
              version
            end
          end
        end
      end
    end
  end
end
