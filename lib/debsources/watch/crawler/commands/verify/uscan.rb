# frozen_string_literal: true

require_relative '../../command'
require 'fileutils'
require 'rexml/document'

module Debsources
  module Watch
    module Crawler
      module Commands
        class Verify
          class Uscan < Debsources::Watch::Crawler::Command
            def initialize(package, options)
              @package = package
              @options = options
              path = "data/debian-watch.db"
              unless File.exist?(path)
                Groonga::Database.create(path: path)
              else
                Groonga::Database.open(path)
              end
              @dehs = Groonga["Dehs"]
            end

            def execute(input: $stdin, output: $stdout)
              # Command logic goes here ...
              output.puts "OK"
              if @package
                `apt source #{@package}`
                target_dir = nil
                Dir.glob("#{@package}*") do |dir|
                  if File.directory?(dir)
                    target_dir = dir
                    doc = nil
                    source = ""
                    Dir.chdir(dir) do
                      `dch --force-bad-version --newversion 0.0.0-1 "Test"`
                      `dch --release "Test"`
                      source=`perl #{ENV["USCAN_PATH"]} --dehs --no-download`
                      doc = REXML::Document.new(source)
                    end
                    if doc
                      #p source
                      upstream_version = doc.elements["/dehs/upstream-version"].text
                      upstream_url = doc.elements["/dehs/upstream-url"].text
                      status = doc.elements["/dehs/status"].text
                      if status == "newer package available"
                        timestamp = Time.now
                        @dehs.add(@package,
                                  :package => @package,
                                  :revised => source,
                                  :upstream_version => upstream_version,
                                  :upstream_url => upstream_url,
                                  :status => status,
                                  :updated_at => timestamp
                                 )
                      end
                    end
                    FileUtils.rm_rf(target_dir, :secure => true)
                    FileUtils.rm_rf("#{@package}-0.0.0", :secure => true)
                    FileUtils.rm_rf(Dir.glob("#{@package}_*"), :secure => true)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
