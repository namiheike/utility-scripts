# TODO can't handle multiple searching results, say abp-516
# TODO handle tokyohot

require 'babel-core/register'
require 'babel-polyfill'

jav = require 'javlibrary-api'
fs = require 'fs'
path = require 'path'
execSync = require('child_process').execSync

sleep = require('sleep').sleep

uuid = require 'uuid/v4'

process.env.lang = 'tw'

# NOTE __cfduid and cf_clearance in cookies are required for passing DDOC protection
# TODO auto generate
jav.config
  headers:
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36'
    'Cookie': '__cfduid=d13f0c6385615e6dd5ab0ea7b1ec80e7d1526645143; cf_clearance=889352048189d9ea0c0cdaf85366b3560feb96a8-1532496409-3600;'

write = (str) ->
  fs.writeFileSync './COMMANDS', str + '\n', { flag: 'a+' }

main = ->
  for file in fs.readdirSync('/Volumes/Multimedia/x/video')
    do (file) ->
      extname = path.extname file
      return unless ['.mp4', '.avi', '.mkv', '.wmv'].includes extname

      console.log '\n---\n'
      console.log 'handling: ' + file

      # detecting the bango
      BANGO_REG = /^[a-z]{3,5}-[0-9]{3}/i
      basename = path.basename file

      unless basename.match BANGO_REG
        console.log 'bango detecting failed, skipping'
        return

      bango = basename.match(BANGO_REG)[0]
      console.log 'bango: ' + bango

      if fs.existsSync "/Volumes/Multimedia/x/video/#{bango}.metadone"
        return

      # custom tags like [ad] [zh-sub]
      tags = basename.match /\[.*\]/
      tags = '' if tags is null

      console.log 'fetching info...'
      if javlibid = (await jav.search(bango))?.jav
        if info = await jav.getVideoDetail javlibid
          # sleep 10

          title = info.name
          date = info.date
          artist = info.stars.map((d) -> d.name).join(', ')
          publisher = info.maker

          dest_file = bango.toUpperCase() + tags + extname

          # renaming original file
          ori_file = "ori_#{uuid()}#{extname}"
          console.log "RENAMING #{file} to #{ori_file}"
          write "mv #{file} #{ori_file}"

          console.log "WRITING writing info for #{bango} with title #{title}, date #{date}, artist #{artist}, publisher #{publisher}"
          write "ffmpeg -i #{ori_file} -metadata title=\"#{info.name}\" -metadata date=\"#{date}\" -metadata creation_time=\"#{date}\" -metadata artist=\"#{artist}\" -metadata publisher=\"#{publisher}\" -acodec copy -vcodec copy #{dest_file}"

          write "touch #{bango}.metadone"

          write "rm #{ori_file}"
          write ''

          return

      console.log 'FAILED for bango ' + bango
      # console.log 'javlibid searching: ' + ( await jav.search(bango) )


main()
