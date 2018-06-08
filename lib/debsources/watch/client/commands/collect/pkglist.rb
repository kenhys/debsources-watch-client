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
              packages = fetch_package_list
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
