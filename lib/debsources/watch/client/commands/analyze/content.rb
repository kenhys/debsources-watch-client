require_relative '../../command'

module Debsources
  module Watch
    module Client
      module Commands
        class Analyze
          class Content < Debsources::Watch::Client::Command
            def initialize(options)
              @options = options
            end

            def execute(input: $stdin, output: $stdout)
              GrnMini::create_or_open("data/debian-watch.db")
              @pkgs = GrnMini::Hash.new("Pkgs")
              pkglist = []
              @pkgs.each do |record|
                if record.watch_content
                  if record.watch_content =~ /version=(\d)/
                    record.watch_version = $1.to_i
                  else
                    record.watch_version = 1
                  end
                else
                  record.watch_version = 0
                end
                if record.watch_content =~ /https?:\/\/(.+?)\//
                  matched = $1.strip
                  if matched.end_with?("sf.net") or matched.end_with?("sourceforge.net")
                    #p "sourceforge.net"
                    record.watch_hosting = "sourceforge.net"
                  else
                    record.watch_hosting = $1
                  end
                  #p "#{record._key} #{record.watch_version} #{$1}"
                end
              end
              generate_watch_version_pie_graph
              generate_watch_file_pie_graph
              generate_watch_host_top5_pie_graph
            end

            def generate_watch_version_pie_graph
              @pkgs = GrnMini::Hash.new("Pkgs")
              groups = GrnMini::Util::group_with_sort(@pkgs, "watch_version")
              graph = Gruff::Pie.new(600)
              graph.title = "debian/watch version graph"
              graph.title_font_size = 36

              groups.each do |record|
                unless record._key == 0
                  graph.data("version #{record._key} (#{record['_nsubrecs']})", [record["_nsubrecs"]])
                end
              end
              graph.zero_degree = -90
              graph.sort = false
              graph.show_values_as_labels = false
              graph.write("debian-watch-version-pie-graph.png")
            end

            def generate_watch_file_pie_graph
              @pkgs = GrnMini::Hash.new("Pkgs")
              groups = GrnMini::Util::group_with_sort(@pkgs, "watch_version")
              graph = Gruff::Pie.new(600)
              graph.title = "debian/watch file graph"
              graph.title_font_size = 36

              data = []
              no_data = []
              groups.each do |record|
                if record._key == 0
                  no_data << record["_nsubrecs"]
                else
                  data << record["_nsubrecs"]
                end
              end
              graph.data("watch file (#{data.inject(:+)})", data)
              graph.data("no watch file (#{no_data[0]})", no_data)
              graph.zero_degree = -90
              graph.sort = false
              graph.write("debian-watch-file-pie-graph.png")
            end

            def generate_watch_host_top5_pie_graph
              @pkgs = GrnMini::Hash.new("Pkgs")
              groups = GrnMini::Util::group_with_sort(@pkgs, "watch_hosting")
              graph = Gruff::Pie.new(600)
              graph.title = "upstream hosting graph"
              graph.title_font_size = 36

              other_data = []
              no_data = []
              i = 0
              groups.each_with_index do |record, index|
                if index < 5
                  graph.data("#{record._key} (#{record['_nsubrecs']})", record["_nsubrecs"])
                else
                  other_data << record["_nsubrecs"]
                end
              end
              graph.data("other (#{other_data.inject(:+)})", other_data)
              graph.zero_degree = -90
              graph.sort = false
              graph.write("debian-watch-hosting-top5-pie-graph.png")
            end
          end
        end
      end
    end
  end
end
