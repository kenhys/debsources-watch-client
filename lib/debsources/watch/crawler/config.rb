require "yaml"
require 'open-uri'

module Debsources
  module Watch
    module Crawler

      class Config
        DEBSOURCES_WATCH_CRAWLER_CONFIG = "debsources-watch-crawler.yaml"
        DOT_DEBSOURCES_WATCH_CRAWLER = ".debsources-watch-crawler"
        DEBSOURCES_DB_FILE = "db/debian-watch.db"

        def initialize
          @keys = []
          load
        end

        def home
          dir = File.join(ENV['HOME'], DOT_DEBSOURCES_WATCH_CRAWLER)
          if ENV['DEBSOURCES_WATCH_CRAWLER_HOME']
            dir = ENV['DEBSOURCES_WATCH_CRAWLER_HOME']
          end
          unless Dir.exist?(dir)
            Dir.mkdir(dir)
          end
          dir
        end

        def path
          File.join(home, DEBSOURCES_WATCH_CRAWLER_CONFIG)
        end

        def load
          unless File.exist?(path)
            p path
            open(path, "w+") do |file|
              @keys["database_path"] = File.join(home, DEBSOURCES_DB_FILE)
              file.puts(YAML.dump(config))
            end
            return
          end
          YAML.load_file(path).each do |key, value|
            @keys << key
            instance_variable_set("@#{key}", value)
          end
        end

        def save
          config = {}
          instance_variables.each do |var|
            key = var.to_s.sub(/^@/, '')
            unless key == "keys"
              config[key] = instance_variable_get(var.to_s)
            end
          end
          File.open(path, "w+") do |file|
            file.puts(YAML.dump(config))
          end
        end
      end
    end
  end
end
