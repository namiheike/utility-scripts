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
  while not File.extname(f).empty?
    basename = File.basename f, File.extname(f)
    File.rename path.to_s, "#{series_title}/#{basename}"
  end
end

episodes.each do |e|
  if File.exist? "#{series_title}/#{e[:download_filename]}"
    puts File.rename "#{series_title}/#{e[:download_filename]}", "#{series_title}/#{e[:filename]}"
  end
end
