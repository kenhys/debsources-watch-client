require "yaml"

module Debsources
  module Watch
    module Crawler

      class Config
        DEBSOURCES_WATCH_CRAWLER_CONFIG = "debsources-watch-crawler.yaml"
        DOT_DEBSOURCES_WATCH_CRAWLER = ".debsources-watch-crawler"

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
          YAML.load_file(path).each do |key, value|
            @keys << key
            instance_variable_set("@#{key}", value)
          end
        end
      end
    end
  end
end
