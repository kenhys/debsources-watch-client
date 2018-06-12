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
                if record.watch_content =~ /version=(\d)/
                  #
                  #p $1.to_i
                  record.watch_version = $1.to_i
                else
                  #
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
            end

            def generate_watch_version_pie_graph
              @pkgs = GrnMini::Hash.new("Pkgs")
              groups = GrnMini::Util::group_with_sort(@pkgs, "watch_version")
              graph = Gruff::Pie.new(600)
              graph.title = "debian/watch version graph"
              graph.title_font_size = 36

              groups.each do |record|
                unless record._key == 0
                  graph.data("version #{record._key}", [record["_nsubrecs"]])
                end
              end
              graph.zero_degree = -90
              graph.sort = false
              graph.hide_legend = false
              graph.hide_title = false
              graph.hide_line_markers = false
              graph.marker_font_size = 20
              graph.show_values_as_labels = false
              graph.write("debian-watch-version-pie-graph.png")
            end
          end
        end
      end
    end
  end
end
