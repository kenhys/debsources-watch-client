require_relative '../../command'
require_relative '../../config'
require_relative '../../../crawler'
require 'tempfile'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Analyze
          class Content < Debsources::Watch::Crawler::Command
            def initialize(options)
              @options = options
              @config = ::Debsources::Watch::Crawler::Config.new
              Debsources::Watch::Crawler.create_or_open_database(@config.database_path)
              @pkgs = Groonga["Pkgs"]
              root_dir = File.dirname(File.dirname(File.expand_path($0)))
              @runner_path = File.join(root_dir,
                                       "bin/parse-watch-file")
            end

            def execute(input: $stdin, output: $stdout)
              pkglist = []
              @pkgs.each do |record|
                raw_content = record.watch_content
                watch_content = extract_watch_content(raw_content)
                if watch_content.empty?
                  record.watch_version = 0
                  record.watch_missing = 1
                  record.host_missing = 1
                  record.watch_content = watch_content
                  next
                end

                if watch_content =~ /version=(\d)/
                  record.watch_version = $1.to_i
                else
                  record.watch_version = 1
                end
                if watch_content =~ /(git|ftp|https?):\/\/(.+?)(\/|\s)/
                  host = $2.strip
                  if host.end_with?("sf.net") or host.end_with?("sourceforge.net")
                    #p "sourceforge.net"
                    record.watch_hosting = "sourceforge.net"
                  else
                    record.watch_hosting = $2
                  end
                else
                  # rhythmbox-ampache, tmux-themepack-jimeh,vflib3 doesn't have valid watch
                  record.host_missing = 1
                end
                record.watch_content = watch_content

                yaml = parse_watch_original(raw_content)
                modified = false
                unless yaml["component"].empty?
                  modified = true
                  record.component = yaml["component"]
                end
                unless yaml["compression"].empty?
                  modified = true
                  record.compression = yaml["compression"]
                end
                if yaml["repack"] == 1
                  modified = true
                  record.repack = 1
                end
                unless yaml["repacksuffix"].empty?
                  modified = true
                  record.repacksuffix = yaml["repacksuffix"]
                end
                unless yaml["mode"].empty?
                  modified = true
                  record.mode = yaml["mode"]
                end
                unless yaml["pretty"].empty?
                  modified = true
                  record.pretty = yaml["pretty"]
                end
                unless yaml["date"].empty?
                  modified = true
                  record.date = yaml["date"]
                end
                unless yaml["gitmode"].empty?
                  modified = true
                  record.gitmode = yaml["gitmode"]
                end
                unless yaml["pgpmode"].empty?
                  modified = true
                  record.pgpmode = yaml["pgpmode"]
                end
                if yaml["decompress"] == 1
                  modified = true
                  record.decompress = 1
                end
                if yaml["bare"] == 1
                  modified = true
                  record.bare = 1
                end
                unless yaml["user_agent"].empty?
                  modified = true
                  record.user_agent = yaml["user_agent"]
                end
                if yaml["pasv"] == 1
                  modified = true
                  record.pasv = 1
                end
                if yaml["passive"] == 1
                  modified = true
                  record.passive = 1
                end
                if yaml["active"] == 1
                  modified = true
                  record.active = 1
                end
                if yaml["nopasv"] == 1
                  modified = true
                  record.nopasv = 1
                end
                unless yaml["unzipopt"].empty?
                  modified = true
                  record.unzipopt = yaml["unzipopt"]
                end
                unless yaml["dversionmangle"].empty?
                  modified = true
                  record.dversionmangle = yaml["dversionmangle"]
                end
                unless yaml["dirversionmangle"].empty?
                  modified = true
                  record.dirversionmangle = yaml["dirversionmangle"]
                end
                unless yaml["pagemangle"].empty?
                  modified = true
                  record.pagemangle = yaml["pagemangle"]
                end
                unless yaml["uversionmangle"].empty?
                  modified = true
                  record.uversionmangle = yaml["uversionmangle"]
                end
                unless yaml["versionmangle"].empty?
                  modified = true
                  record.versionmangle = yaml["versionmangle"]
                end
                unless yaml["hrefdecode"].empty?
                  modified = true
                  record.hrefdecode = yaml["hrefdecode"]
                end
                unless yaml["downloadurlmangle"].empty?
                  modified = true
                  record.downloadurlmangle = yaml["downloadurlmangle"]
                end
                unless yaml["filenamemangle"].empty?
                  modified = true
                  record.filenamemangle = yaml["filenamemangle"]
                end
                unless yaml["pgpsigurlmangle"].empty?
                  modified = true
                  record.pgpsigurlmangle = yaml["pgpsigurlmangle"]
                end
                unless yaml["oversionmangle"].empty?
                  modified = true
                  record.oversionmangle = yaml["oversionmangle"]
                end
              end
              generate_watch_version_pie_graph
              generate_watch_file_pie_graph
              generate_watch_host_top5_pie_graph
              generate_watch_host_top5all_pie_graph
              generate_watch_host_salsa_pie_graph
            end

            def extract_watch_content(original_content)
              content = ""
              if original_content
                original_content.split("\n").collect do |line|
                  line = line.strip
                  unless line.start_with?("#")
                    if line.end_with?('\\')
                      content << "#{line}"
                    else
                      content << "#{line}\n"
                    end
                  end
                end
              end
              content
            end

            def parse_watch_original(original_content)
              tf = Tempfile.open("dwatch") do |f|
                f.puts(original_content)
                f
              end
              content = `perl -I#{@config.crawler_lib_path} #{@runner_path} #{tf.path}`
              YAML.load(content)
            end

            def setup_graph
              @graph = Gruff::Pie.new(600)
              @graph.title_font_size = 36
              @graph.zero_degree = -90
              @graph.sort = false
              @graph.show_values_as_labels = false
            end

            def generate_watch_version_pie_graph
              dataset = @pkgs.select do |record|
                record.watch_missing == 0
              end
              groups = GrnMini::Util::group_with_sort(dataset, "watch_version")
              setup_graph
              @graph.title = "Grouping by debian/watch version"

              groups.each do |record|
                unless record._key == 0
                  @graph.data("version #{record._key} (#{record['_nsubrecs']})", [record["_nsubrecs"]])
                end
              end
              @graph.write("group-by-watch-version.png")
            end

            def generate_watch_file_pie_graph
              groups = GrnMini::Util::group_with_sort(@pkgs, "watch_missing")
              setup_graph
              @graph.title = "How many packages\nsupports debian/watch?"

              groups.each do |record|
                if record._key == 0
                  @graph.data("watch file (#{record["_nsubrecs"]})", record["_nsubrecs"])
                else
                  @graph.data("no watch file (#{record["_nsubrecs"]})", record["_nsubrecs"])
                end
              end
              @graph.write("group-by-watch-file.png")
            end

            def generate_watch_host_top5_pie_graph
              dataset = @pkgs.select do |record|
                record.host_missing == 0
              end
              groups = GrnMini::Util::group_with_sort(dataset, "watch_hosting")
              setup_graph
              @graph.title = "Top 5 upstream hosting site"

              other_data = 0
              total = 0
              groups.each_with_index do |record, index|
                total += record["_nsubrecs"]
                if index < 5
                  @graph.data("#{record._key} (#{record['_nsubrecs']})", record["_nsubrecs"])
                else
                  other_data += record["_nsubrecs"]
                end
              end
              @graph.data("other (#{other_data})", [other_data])
              @graph.write("group-by-top5-hosting.png")
              p other_data
              p total
            end

            def generate_watch_host_top5all_pie_graph
              dataset = @pkgs.select do |record|
                record.host_missing == 0
              end
              groups = GrnMini::Util::group_with_sort(dataset, "watch_hosting")
              setup_graph
              @graph.title = "Top 5 upstream hosting site"

              other_data = 0
              top5 = 0
              groups.each_with_index do |record, index|
                if index < 5
                  top5 += record["_nsubrecs"]
                else
                  other_data += record["_nsubrecs"]
                end
              end
              @graph.data("top 5 sites (#{top5})", top5)
              @graph.data("other (#{other_data})", [other_data])
              @graph.write("group-by-top5all-hosting.png")
            end

            def generate_watch_host_salsa_pie_graph
              dataset = @pkgs.select do |record|
                record.host_missing == 0
              end
              other_count = dataset.size
              groups = GrnMini::Util::group_with_sort(dataset, "watch_hosting")
              setup_graph
              @graph.title = "How many upstream use salsa.d.o?"

              salsa = groups.select do |record|
                record._key == "salsa.debian.org"
              end
              salsa.each do |record|
                p record["_nsubrecs"]
                @graph.data("salsa.d.o (#{record['_nsubrecs']})", record["_nsubrecs"])
              end
              @graph.data("other (#{other_count})", other_count)
              @graph.write("group-by-hosting-salsa.png")
            end
          end
        end
      end
    end
  end
end
