#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'

# require 'byebug'

series_url = ARGV.first
episodes_amount = ARGV[1].to_i

series_page = Nokogiri::HTML open(series_url)
series_title = series_page.css('.videoIntr h1')[0].text

puts `mkdir -p #{series_title}`

episode_urls = series_page.css('.albumInfo .dmode .screen ul li a').map{|a| 'http://video.chaoxing.com' + a['href']}[0..episodes_amount-1]

threads = []

episode_urls.each_with_index do |e, index|
  # byebug
  # puts '==='
  # puts "thread ##{index}"

  flvcd_url = "http://www.flvcd.com/parse.php?format=&kw=#{e}"
  flvcd_page = Nokogiri::HTML open(flvcd_url), nil, 'gbk'

  episode = {
    url: flvcd_page.at('td:contains("复制文件名")').children[3]['href'],
    name: flvcd_page.at('td:contains("当前解析视频：")').children[2].text.rstrip.lstrip,
  }
  episode[:filename] = "#{index+1}-#{episode[:name]}.flv"

  # puts episode

  threads << Thread.new(episode) do |episode|
    puts episode
    puts `wget -c #{episode[:url]} -O #{series_title}/#{episode[:filename]}`
    # puts `aria2c -x2 -o #{series_title}/#{episode[:filename]} #{episode[:url]}`
  end

  # sleep to avoid being banned by flvcd
  sleep 3
end

threads.each { |aThread|  aThread.join }
