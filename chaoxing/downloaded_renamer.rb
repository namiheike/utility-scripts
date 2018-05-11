# NOTE
# rename 1-abc.flv -> series_name - s01e001 - abc.flv

require 'pathname'

series_name = '表演基础'

Dir['./*.flv'].each do |filepath|
  filename = Pathname.new(filepath)

  index, name = filename.sub_ext('').basename.to_s.split('-')

  new_filename = "#{series_name} - s01e#{index.rjust 3, '0'} - #{name}.flv"

  # puts new_filename
  File.rename filepath, new_filename
end
