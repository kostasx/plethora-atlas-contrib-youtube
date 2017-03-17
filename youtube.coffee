fs          = require 'fs'
ytdl        = require 'ytdl-core'
ProgressBar = require 'progress'
request     = require 'request'
colors      = require 'colors'

protocol = "https://"
ytPrefix = "#{protocol}www.youtube.com/watch?v="

# TERMINAL COLORS
Reset    = "\x1b[0m"
FgRed    = "\x1b[31m"
FgGreen  = "\x1b[32m"
FgYellow = "\x1b[33m"
FgCyan   = "\x1b[36m"

userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36"

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

	getCaptionsList: (options)->

		vid         = options.id
		timedTxtUrl = "https://video.google.com/timedtext?hl=en&type=list&v=#{vid}"
		format      = options.fmt or "vtt"	# "ttml"

		new Promise((resolve, reject)->

			request {
				method  : 'GET'
				headers : 'User-Agent' : userAgent
				url     : timedTxtUrl
			}, (error, res, body)->

				if !error and res.statusCode is 200

					parseString = require('xml2js').parseString
					parseString(body, (err, res)->

						subs = res.transcript_list.track[0].$	
						options.captionsList = subs
						resolve(options)

					)

				else 
					if error
						resolve "Error #{error}".red
					console.log "Something went wrong!".red
					resolve res
		)

	getCaption: (options)->

		vid    = options.id
		format = options.fmt or "vtt"

		new Promise((resolve, reject)->

			YT.getCaptionsList(options)
			.then((res)->

				captionsList = res.captionsList
				# .id, .name, .lang_code, .lang_original, .lang_translated, .lang_default
				timedTxtApiUrl = "https://www.youtube.com/api/timedtext?"
				# PARAMS: v=<ID>, asr_langs=fr%2Cnl%2Cit%2Ces%2Cpt%2Cja%2Cko%2Cen%2Cru%2Cde, key=yttt1
				# caps=asr, hl=en_GB, sparams=asr_langs%2Ccaps%2Cv%2Cexpire
				# signature=<SIG>, expire=1468200843, kind=asr, lang=en, fmt=srv3

				timedTxtApiUrl += "lang=#{captionsList.lang_code}&v=#{vid}&fmt=#{format}&name=#{encodeURI(captionsList.name)}"

				request {
					method  : 'GET'
					headers : 'User-Agent' : userAgent
					url     : timedTxtApiUrl
				}, (error, res, body)->

					if !error and res.statusCode is 200

						options.captions = body
						return resolve(options)

					else 
						console.log "Something went wrong!".red
						if error
							resolve "Error #{error}".red
						resolve res

			).catch(console.log)
		)

module.exports = YT