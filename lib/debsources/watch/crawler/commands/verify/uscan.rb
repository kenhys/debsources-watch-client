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
                dataset = select_hosting_dataset("github.com")
                dataset.each do |record|
                  verify_uscan_package(record._key)
                end
              end
            end

            def select_hosting_dataset(hosting)
              dataset = @pkgs.select do |record|
                  record.watch_missing == 0 and record.watch_hosting =~ hosting
              end
              dataset
            end

            def rewrite_watch_file(package)
              content = ""
              watch = "debian/watch"
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
                    version = $1
                  end
                end
              end
              version
            end

            def recently_updated?(package)
              records = @dehs.select do |record|
                record._key == package
              end
              records.each do |record|
                if record.updated_at
                  return Time.now - 60 * 60 * 8 < record.updated_at
                end
              end
              false
            end

            def broken_package?(package)
              records = @dehs.select do |record|
                record._key == package
              end
              records.each do |record|
                if record.missing == 1
                  return true
                else
                  return false
                end
              end
              false
            end

            def verify_uscan_package(package)
              unless ENV["USCAN_PATH"]
                puts "USCAN_PATH is not set"
                return
              end

              return if broken_package?(package)
              return if recently_updated?(package)

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
              version = ""
              Dir.glob("#{package}*") do |dir|
                if File.directory?(dir)
                  Dir.chdir(dir) do
                    version = detect_downgrade_version
                    `dch --force-bad-version --newversion #{version}-1 "Test"`
                  end
                end
              end
              if version.empty?
                timestamp = Time.now
                @dehs.add(package,
                            :package => package,
                            :supported => 0,
                            :missing => 1,
                            :updated_at => timestamp
                         )
                return
              end
              doc = nil
              source = ""
              Dir.chdir("#{package}-#{version}") do
                `dch --release "Test"`
                rewrite_watch_file(package)
                source = `perl #{ENV["USCAN_PATH"]} --dehs --no-download`
                doc = REXML::Document.new(source)
              end
              if doc
                upstream_version = ""
                supported = 1
                if doc.elements["/dehs/upstream-version"]
                  upstream_version = doc.elements["/dehs/upstream-version"].text
                else
                  supported = 0
                end
                upstream_url = ""
                if doc.elements["/dehs/upstream-url"]
                  upstream_url = doc.elements["/dehs/upstream-url"].text
                else
                  supported = 0
                end
                status =""
                if doc.elements["/dehs/status"]
                  status = doc.elements["/dehs/status"].text
                else
                  supported = 0
                end
                timestamp = Time.now
                if status == "newer package available"
                  @dehs.add(package,
                            :package => package,
                            :revised => source,
                            :upstream_version => upstream_version,
                            :upstream_url => upstream_url,
                            :status => status,
                            :supported => supported,
                            :updated_at => timestamp
                           )
                else
                  @dehs.add(package,
                            :package => package,
                            :revised => source,
                            :upstream_version => upstream_version,
                            :upstream_url => upstream_url,
                            :supported => supported,
                            :missing => 1,
                            :status => status,
                            :updated_at => timestamp
                           )
                end
              end
              FileUtils.rm_rf("#{package}-#{version}", :secure => true)
              FileUtils.rm_rf(Dir.glob("#{package}_*"), :secure => true)
            end
          end
        end
      end
    end
  end
end
