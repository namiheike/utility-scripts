#!/usr/bin/env ruby

# NOTE:
# 总之还有一个下载器可以解析出包括非免费的视频存到一个列表里，
# 接下来就是
# 1 read and convert to utf8
# 2 download and rename
# 
# prepare:
# 
# - ./fetched_lists/汉语文学创作.txt
# 
# params:
# 
# - 汉语文学创作
# 

# require 'open-uri'
# require 'nokogiri'

require 'pathname'
require 'pty'
# require 'byebug'

series_name = ARGV.first

# create a folder for series
puts `mkdir -p #{series_name}`

series_list_file = Pathname.new "./fetched_lists/#{series_name}.txt"

list_content = File.read(series_list_file).encode('UTF-8', 'GB2312')
list_content.gsub! "\r\n", "\n"

# save a list copy
File.write (Pathname.new "./#{series_name}/#{series_name}.txt"), list_content

# parse name and url
list = list_content.lines.keep_if{|l| l.include? 'http'}

threads = []

list.each_with_index do |l, i|
  name, url = l.split(' http://')
  url = 'http://' + url

  index = (i+1).to_s.rjust 3, '0'
  filename = "#{series_name} - s01e#{index} - #{name}.flv"

  episode = {
    filename: filename,
    url: url
  }

  threads << Thread.new(episode) do |episode|
    puts episode

    cmd = "aria2c -x1 --continue=true --disk-cache=32M -o \"#{series_name}/#{episode[:filename]}\" #{episode[:url]}"
    # puts `wget -c #{episode[:url]} -O \"#{series_name}/#{episode[:filename]}\"`

    begin
      PTY.spawn(cmd) do |stdout, stdin, pid|
        begin
          stdout.each { |line| print line }
        rescue Errno::EIO
        end
      end
    rescue PTY::ChildExited
      puts "The child process exited!"
    end

  end

  sleep 20
end

threads.each { |aThread|  aThread.join }


