# frozen_string_literal: true

require_relative '../../command'
require_relative '../../config'
require_relative '../../../crawler'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Init
          class Database < Debsources::Watch::Crawler::Command
            def initialize(options)
              @options = options
              @config = ::Debsources::Watch::Crawler::Config.new
              Debsources::Watch::Crawler.create_or_open_database(@config.database_path)
            end

            def execute(input: $stdin, output: $stdout)
              Groonga::Schema.define do |schema|
                schema.create_table("Hosts", options = {:type => :patricia_trie}) do |table|
                end
                schema.create_table("Suites", options = {:type => :patricia_trie}) do |table|
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
                  table.reference("suites", "Suites", :type => :vector)
                end
                schema.change_table("Suites") do |table|
                  table.index("Pkgs.suites")
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
                  table.integer("error")
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
                schema.create_table("Opts", options = {:type => :patricia_trie}) do |table|
                  table.text("component")
                  table.text("compression")
                  table.integer("repack")
                  table.text("repacksuffix")
                  table.text("mode")
                  table.text("pretty")
                  table.text("date")
                  table.text("gitmode")
                  table.text("pgpmode")
                  table.integer("decompress")
                  table.integer("bare")
                  table.text("user_agent")
                  table.integer("pasv")
                  table.integer("passive")
                  table.integer("active")
                  table.integer("nopasv")
                  table.text("unzipopt")
                  table.text("dversionmangle")
                  table.text("dirversionmangle")
                  table.text("pagemangle")
                  table.text("uversionmangle")
                  table.text("versionmangle")
                  table.text("hrefdecode")
                  table.text("downloadurlmangle")
                  table.text("filenamemangle")
                  table.text("pgpsigurlmangle")
                  table.text("oversionmangle")
                  table.text("anon_dversionmangle")
                  table.text("anon_dirversionmangle")
                  table.text("anon_pagemangle")
                  table.text("anon_uversionmangle")
                  table.text("anon_versionmangle")
                  table.text("anon_downloadurlmangle")
                  table.text("anon_filenamemangle")
                  table.text("anon_pgpsigurlmangle")
                  table.text("anon_oversionmangle")
                  table.time("updated_at")
                end
              end
            end
          end
        end
      end
    end
  end
end
