require "debsources/watch/crawler/version"
require "groonga"

module Debsources
  module Watch
    module Crawler
      module_function

      def create_or_open_database(path)
        unless File.exist?(path)
          Groonga::Database.create(path: path)
        else
          Groonga::Database.open(path)
        end
      end
    end
  end
end
