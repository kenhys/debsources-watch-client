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
              latest_version = ""
              open("debian/changelog", "r") do |file|
                file.readlines.each_with_index do |line,index|
                  if line =~ /.+?\((.+?)-1\) unstable;/
                    if index == 0
                      latest_version = $1
                      next
                    end
                    version = $1
                  end
                end
              end
              if version.empty?
                begin
                  v = Versionomy.parse(latest_version)
                  if v.tiny > 0
                    version = "#{v.major}.#{v.minor}.#{v.tiny-1}"
                  else
                    if v.minor > 0
                      version = "#{v.major}.#{v.minor-1}.#{v.tiny}"
                    else
                      if v.major > 0
                        version = "#{v.major-1}.#{v.minor}.#{v.tiny}"
                      end
                    end
                  end
                rescue
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
                if record.broken_source == 1
                  return true
                else
                  return false
                end
              end
              false
            end

            def add_broken_source(package)
              timestamp = Time.now
              @dehs.add(package,
                        :package => package,
                        :broken_source => 1,
                        :updated_at => timestamp
                       )
            end

            def add_verified_package(package, dehs)
              timestamp = Time.now
              @dehs.add(package,
                        :package => package,
                        :revised => dehs[:source],
                        :upstream_version => dehs[:upstream_version],
                        :upstream_url => dehs[:upstream_url],
                        :status => dehs[:status],
                        :verified => 1,
                        :updated_at => timestamp
                       )
            end

            def add_missing_package(package, dehs)
              timestamp = Time.now
              @dehs.add(package,
                        :package => package,
                        :revised => dehs[:source],
                        :upstream_version => dehs[:upstream_version],
                        :upstream_url => dehs[:upstream_url],
                        :missing => 1,
                        :status => dehs[:status],
                        :updated_at => timestamp
                       )
            end

            def parse_dehs_content(source)
              dehs = {
                :source => source,
                :upstream_url => "",
                :upstream_version => "",
                :status => "",
              }
              doc = REXML::Document.new(source)
              upstream_version = ""
              if doc.elements["/dehs/upstream-version"]
                dehs[:upstream_version] = doc.elements["/dehs/upstream-version"].text
              end
              if doc.elements["/dehs/upstream-url"]
                dehs[:upstream_url] = doc.elements["/dehs/upstream-url"].text
              end
              if doc.elements["/dehs/status"]
                dehs[:status] = doc.elements["/dehs/status"].text
              end
              dehs
            end

            def newer_package_available?(dehs)
              dehs.has_key?(:status) and dehs[:status] == "newer package available"
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
                add_broken_source(package)
                return
              end
              version = ""
              Dir.glob("#{package}*") do |dir|
                if File.directory?(dir)
                  Dir.chdir(dir) do
                    version = detect_downgrade_version
                    if version.empty?
                      timestamp = Time.now
                      @dehs.add(package,
                                :package => package,
                                :error => 1,
                                :updated_at => timestamp
                               )
                      return
                    end
                    `dch --force-bad-version --newversion #{version}-1 "Test"`
                  end
                end
              end
              dehs = {}
              doc = nil
              source = ""
              Dir.chdir("#{package}-#{version}") do
                `dch --release "Test"`
                rewrite_watch_file(package)
                source = `perl #{ENV["USCAN_PATH"]} --dehs --no-download`
                dehs = parse_dehs_content(source)
              end
              timestamp = Time.now
              if newer_package_available?(dehs)
                add_verified_package(package, dehs)
              else
                add_missing_package(package, dehs)
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
