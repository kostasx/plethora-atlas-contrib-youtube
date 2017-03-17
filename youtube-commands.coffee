colors = require 'colors'

initCommands = (program)->

	program
		.command('youtube')
		.description('YouTube utilities')
		.option('--download-video <video>', 'Download video. <video> can be YouTube URL or ID')
		.option('--output <filepath>', 'Filename and path of the downloaded video')
		.option('--get-caption <videoId>', 'Download video captions.')
		.action (options) ->

			YT = require('./youtube')

			if options.getCaption
				YT.getCaption({ id: options.getCaption })
				.then((res)->

					console.log res.captions

				)

			if options.downloadVideo

				YT.downloadVideo({ 

					video  : options.downloadVideo 
					output : options.output or null

				})

module.exports = initCommands