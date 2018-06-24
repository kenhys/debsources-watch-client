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
              Groonga::Schema.define do |schema|
                schema.create_table("Hosts", options = {:type => :patricia_trie}) do |table|
                end

                schema.create_table("Pkgs", options = {:type => :patricia_trie}) do |table|
                  table.text("name")
                  table.text("version")
                  table.text("watch_content")
                  table.text("watch_original")
                  table.integer("watch_missing")
                  table.integer("watch_version")
                  table.integer("host_missing")
                  table.time("released_at")
                  table.time("created_at")
                  table.time("updated_at")
                  table.reference("watch_hosting", "Hosts")
                end
                schema.create_table("Hosts", options = {:type => :patricia_trie}) do |table|
                  table.reference("packages", "Pkgs", options = {:type => :vector})
                end
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
                  table.integer("verified")
                  table.integer("missing")
                  table.integer("broken_source")
                end
                schema.create_table("Terms",
                                    options = {
                                      :type => :patricia_trie,
                                      :default_tokenizer => :TokenBigramSplitSymbolAlphaDigit
                                    }) do |table|
                  table.index("Pkgs.name", with_position: true)
                  table.index("Pkgs.version", with_position: true)
                  table.index("Pkgs.watch_content", with_position: true)
                  table.index("Pkgs.watch_original", with_position: true)
                end
              end
            end
          end
        end
      end
    end
  end
end
