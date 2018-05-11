(8..8).each do |season|
  season_index = "%02d" % season
  puts '---'
  puts 'season' + season_index
  (1..24).each do |episode|
    puts 'episode' + ( episode_index = "%02d" % episode )
    if video_file = Dir.glob("./Season #{season}/#{season}x#{episode_index} How I Met Your Mother*.{avi}").first
      puts video_file
      # File.rename video_file, video_file.gsub("How I Met Your Mother S#{episode_index}E#{episode_index}","How I Met Your Mother S#{season_index}E#{episode_index}")
      if srt_file = Dir.glob("./Season #{season}/*{S,s}#{season_index}{E,e}#{episode_index}*.srt").first
        puts srt_file
        File.rename srt_file, video_file.chomp('.avi').chomp('.mp4').concat('.srt')
      end
    end
  end
  # Dir.glob("./Season #{season}/*.avi").each do |video_file|
  #   puts video_file
  # end
end
