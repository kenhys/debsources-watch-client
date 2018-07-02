# frozen_string_literal: true

require_relative '../../command'
require 'grn_mini'
require 'open-uri'
require 'json'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Collect
          class Pkglist < Debsources::Watch::Crawler::Command
            def initialize(options)
              @options = options
              GrnMini::create_or_open("data/debian-watch.db")
              @pkgs = Groonga["Pkgs"]
            end

            def execute(input: $stdin, output: $stdout)
              packages = fetch_package_list
              timestamp = Time.now
              packages.each do |package|
                @pkgs.add(package,
                          :name => package,
                          :created_at => timestamp,
                          :updated_at => timestamp)
              end
              registered_list = []
              @pkgs.each do |record|
                registered_list << record._key
              end
              remove_targets = []
              registered_list.each do |package|
                unless packages.include?(package)
                  remove_targets << package
                end
              end
              remove_targets.each do |target|
                p "removing #{target}"
                @pkgs.delete do |record|
                  record._key == target
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

          end
        end
      end
    end
  end
end
