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
                verify_uscan_package(@package)
              else
                @pkgs = Groonga["Pkgs"]
                dataset = @pkgs.select do |record|
                  record.watch_missing == 0 and record.watch_hosting =~ "github.com"
                end
                dataset.each do |record|
                  verify_uscan_package(record._key)
                end
              end
            end

            def rewrite_watch_file(package)
              content = ""
              watch = "#{package}-0.0.0/debian/watch"
              open(watch, "r") do |file|
                content = file.read
              end
              if content =~ /(ftp|https?):\/\/github.com\/(.+?)\/(.+?)\//
                owner = $2
                project = $3
                content = "version=5\ntype=github,owner=#{owner},project=#{project}"
              end
              open(watch, "w+") do |file|
                file.puts(content)
              end
            end

            def detect_downgrade_version
              version = ""
              count = 1
              open("debian/changelog", "r") do |file|
                file.readlines.each_with_index do |line,index|
                  next if index == 0
                  if line =~ /.+?\((.+?)-1\) unstable;/
                    if count == 0
                      return $1
                    end
                    count = count - 1
                  end
                end
              end
              version
            end

            def verify_uscan_package(package)
              unless ENV["USCAN_PATH"]
                puts "USCAN_PATH is not set"
                return
              end
              `apt source #{package}`
              apt_result=$?
              if apt_result != 0
                timestamp = Time.now
                @dehs.add(package,
                          :package => package,
                          :missing => 1,
                          :updated_at => timestamp
                         )
                return
              end
              target_dir = nil
              Dir.glob("#{package}*") do |dir|
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
                  rewrite_watch_file(package)
                  if doc
                    #p source
                    upstream_version = doc.elements["/dehs/upstream-version"].text
                    upstream_url = doc.elements["/dehs/upstream-url"].text
                    status = doc.elements["/dehs/status"].text
                    timestamp = Time.now
                    if status == "newer package available"
                      @dehs.add(package,
                                :package => package,
                                :revised => source,
                                :upstream_version => upstream_version,
                                :upstream_url => upstream_url,
                                :status => status,
                                :supported => 1,
                                :updated_at => timestamp
                               )
                    else
                      @dehs.add(package,
                                :package => package,
                                :revised => source,
                                :upstream_version => upstream_version,
                                :upstream_url => upstream_url,
                                :status => status,
                                :updated_at => timestamp
                               )
                    end
                  end
                  FileUtils.rm_rf(target_dir, :secure => true)
                  FileUtils.rm_rf("#{package}-0.0.0", :secure => true)
                  FileUtils.rm_rf(Dir.glob("#{package}_*"), :secure => true)
                end
              end
            end
          end
        end
      end
    end
  end
end
