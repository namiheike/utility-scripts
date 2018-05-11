require 'pathname'

Dir.glob('./original/*.txt').each do |f|
  file = Pathname.new f
  puts file

  # 
  lines = file.each_line.to_a

  # require 'byebug'
  # byebug

  # NOTE for /r/r only
  lines = lines.first.split "\r"
  lines = lines.map{|l| l.concat "\n"}

  # lines.delete_if{|l| l == "\r"}

  # # remove id like `1. ` in the beginning of each line
  # lines.each do |l|
  #   if ( l =~ /^\d+\.[\t\ ]*/ ) == 0
  #     l.sub! /^\d+\.[\t\ ]*/, ''
  #   end
  # end

  puts "uniq..."
  original_count = lines.length

  # uniq
  lines.uniq!

  puts "removed: #{lines.length - original_count}"

  # sort
  lines.sort!

  # add index
  lines = lines.each.with_index.map{|l, i| "[#{i+1}] #{l}" }

  # 
  new_file = Pathname.new "./formatted/#{file.basename}"
  new_file.write lines.join
end
