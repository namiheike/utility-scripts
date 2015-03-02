#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'
require 'JSON'

# require 'byebug'
# byebug

series_url = ARGV.first
episodes_amount = ARGV[1].to_i

series_page = Nokogiri::HTML open(series_url)
series_title = series_page.css('.videoIntr h1')[0].text

episode_urls = series_page.css('.albumInfo .dmode .screen ul li a').map{|a| 'http://video.chaoxing.com' + a['href']}[0..episodes_amount-1]

episodes = []

episode_urls.each_with_index do |e, index|
  flvcd_url = "http://www.flvcd.com/parse.php?format=&kw=#{e}"
  flvcd_page = Nokogiri::HTML open(flvcd_url), nil, 'gbk'

  episode = {
    url: flvcd_page.at('td:contains("复制文件名")').children[3]['href'],
    name: flvcd_page.at('td:contains("当前解析视频：")').children[2].text.rstrip.lstrip,
  }
  episode[:filename] = "#{index+1}-#{episode[:name]}.flv"
  episode[:download_filename] = "#{episode[:url].gsub('http://video.superlib.com/', '')}"
  episodes << episode
  puts episode
end

puts `mkdir #{series_title}`
File.open("#{series_title}/urls.txt", 'w') do |file|
  episodes.each do |e|
    file.puts e[:url]
  end
end
File.open("#{series_title}/episodes.json", 'w') do |file|
  file.puts episodes.to_json
end
