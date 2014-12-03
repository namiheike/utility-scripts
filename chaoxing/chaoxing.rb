#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'

series_url = ARGV.first
episodes_amount = ARGV[1].to_i

series_page = Nokogiri::HTML open(series_url)
series_title = series_page.css('.videoIntr h1')[0].text

puts `mkdir -p #{series_title}`

episode_urls = series_page.css('.albumInfo .dmode .screen ul li a').map{|a| 'http://video.chaoxing.com' + a['href']}[0..episodes_amount-1]

threads = []

episode_urls.each_with_index do |e, index|
  flvcd_url = "http://www.flvcd.com/parse.php?format=&kw=#{e}"
  flvcd_page = Nokogiri::HTML open(flvcd_url), nil, 'gbk'

  episode = {
    url: flvcd_page.css('tr[style*="table-layout:fixed"] th table:nth-child(2) tr:first-child td.mn.STYLE4 a')[0]['href'],
    name: flvcd_page.search('script')[4].children[0].text.split(' + ')[0].split(' = ')[1][1..-2],
  }
  episode[:filename] = "#{index+1}-#{episode[:name]}.flv"

  threads << Thread.new(episode) do |episode|
    puts episode
    puts `wget -c #{episode[:url]} -O #{series_title}/#{episode[:filename]}`
    # puts `aria2c -x 10 -o #{episode[:filename]} #{episode[:url]}`
  end
end

threads.each { |aThread|  aThread.join }
