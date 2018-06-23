# frozen_string_literal: true

require_relative '../../command'
require 'grn_mini'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Init
          class Database < Debsources::Watch::Crawler::Command
            def initialize(options)
              @options = options
            end

            def execute(input: $stdin, output: $stdout)
              GrnMini::create_or_open("data/debian-watch.db")
              hosts = GrnMini::Hash.new("Hosts")
              pkgs = GrnMini::Hash.new("Pkgs")
              hosts.setup_columns(packages: [pkgs])
              pkgs.setup_columns(name: "",
                                 version: "",
                                 watch_missing: 0,
                                 watch_content: "",
                                 watch_version: 0,
                                 watch_hosting: hosts,
                                 watch_original: "",
                                 host_missing: 0,
                                 released_at: Time.new,
                                 created_at: Time.new,
                                 updated_at: Time.new
                                )
              Groonga::Schema.define do |schema|
                schema.create_table("Dehs", options = {:type => :patricia_trie}) do |table|
                  table.reference("package", "Pkgs")
                  table.text("original")
                  table.text("revised")
                  table.text("status")
                  table.text("uversion")
                  table.text("mangled_uversion")
                  table.text("upstream_url")
                  table.text("upstream_version")
                  table.text("target")
                  table.text("target_path")
                  table.time("updated_at")
                  table.integer("supported")
                end
              end
            end
          end
        end
      end
    end
  end
end
