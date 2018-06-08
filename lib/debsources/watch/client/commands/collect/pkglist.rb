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

              packages = fetch_package_list
              GrnMini::create_or_open("data/debian-watch.db")
              pkgs = GrnMini::Hash.new("Pkgs")
              timestamp = Time.now
              packages.each do |package|
                version = fetch_package_version(package)
                if version
                  pkgs[package] = {name: package, version: version, created_at: timestamp, updated_at: timestamp}
                end
              end
            end

            def fetch_package_list
              packages = nil
              open("https://sources.debian.org/api/list/") do |request|
                response = request.read
                open("packagelist.json", "w+") do |file|
                  file.puts(response)
                end
                json = JSON.load(response)
                packages = json["packages"].collect do |package|
                  package["name"]
                end
              end
              packages
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
