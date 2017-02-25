fs          = require 'fs'
ytdl        = require 'ytdl-core'
ProgressBar = require 'progress'

protocol = "https://"
ytPrefix = "#{protocol}www.youtube.com/watch?v="

# TERMINAL COLORS
Reset    = "\x1b[0m"
FgRed    = "\x1b[31m"
FgGreen  = "\x1b[32m"
FgYellow = "\x1b[33m"
FgCyan   = "\x1b[36m"

YT = 

	downloadVideo: (options)->

		video = options.video

		if video.indexOf("http") isnt 0
			if video.indexOf("www") isnt 0
				video = ytPrefix + video
			else
				video = protocol + video

		stream = ytdl(video, {
			# quality        : ""
			# filter         : ""
			# format         : ""
			# range          : ""
			# requestOptions : ""
		})

		output = 'video.flv'
		if options.output
			output = options.output

		stream.pipe(fs.createWriteStream(output))

		stream.on 'response', (res) ->

			totalSize  = res.headers['content-length']
			downloaded = 0

			bar = new ProgressBar('Downloading [:bar] :percent :etas',
				complete   : "#{FgRed}▇#{Reset}"
				incomplete : ' '
				width      : 20
				total      : parseInt( totalSize, 10 )
			)

			res.on 'data', (chunk)->

				downloaded += chunk.length
				downloadedPercentage = (( downloaded / totalSize ) * 100).toFixed()
				bar.tick chunk.length
				if downloadedPercentage > 25
					bar.chars.complete = "#{FgYellow}▇#{Reset}"
				if downloadedPercentage > 50
					bar.chars.complete = "#{FgCyan}▇#{Reset}"
				if downloadedPercentage > 75
					bar.chars.complete = "#{FgGreen}▇#{Reset}"

			res.on 'end', ()->

				console.log "Finished downloading video!".green

	debug: (options)->


module.exports = YT