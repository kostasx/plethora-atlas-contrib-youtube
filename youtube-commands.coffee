colors = require 'colors'

initCommands = (program)->

	program
		.command('youtube')
		.description('YouTube utilities')
		.option('--download-video <video>', 'Download video. <video> can be YouTube URL or ID')
		.option('--output <filepath>', 'Filename and path of the downloaded video')
		.action (options) ->

			YT = require('./youtube')

			if options.downloadVideo

				YT.downloadVideo({ 

					video  : options.downloadVideo 
					output : options.output or null

				})

module.exports = initCommands