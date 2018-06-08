# frozen_string_literal: true

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
                    p "sourceforge.net"
                    record.watch_hosting = "sourceforge.net"
                  else
                    p matched
                    record.watch_hosting = $1
                  end
                  #p "#{record._key} #{record.watch_version} #{$1}"
                end
              end

              groups = GrnMini::Util::group_with_sort(@pkgs, "watch_version")
              #p groups.size
              groups = GrnMini::Util::group_with_sort(@pkgs, "watch_hosting")
              #p groups.size
              #p groups[0]
            end
          end
        end
      end
    end
  end
end
