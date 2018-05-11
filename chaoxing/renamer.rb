#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'
require 'JSON'
require 'pathname'

require 'byebug'

series_url = ARGV.first

series_page = Nokogiri::HTML open(series_url)
series_title = series_page.css('.videoIntr h1')[0].text

episodes = nil
File.open("#{series_title}/episodes.json", 'r') do |file|
  episodes = JSON.load file, nil, symbolize_names: true
end

# remove all extensions
Dir.glob("#{series_title}/*.*") do |f|
  path = Pathname.new f
  next if ( path.basename.to_s == 'episodes.json' ) or ( path.basename.to_s == 'urls.txt' )
  next if ( File.extname(f) == '.td' ) or ( File.extname(f) == '.cfg' )

  while not File.extname(path.to_s).empty?
    basename = File.basename path.to_s, File.extname(path.to_s)
    new_path = "#{series_title}/#{basename}"
    File.rename path.to_s, new_path
    path = Pathname.new new_path
  end
end

episodes.each do |e|
  if File.exist? "#{series_title}/#{e[:download_filename]}"
    File.rename "#{series_title}/#{e[:download_filename]}", "#{series_title}/#{e[:filename]}"
  end
end
