// Generated by CoffeeScript 1.10.0
var colors, initCommands;

colors = require('colors');

initCommands = function(program) {
  return program.command('youtube').description('YouTube utilities').option('--download-video <video>', 'Download video. <video> can be YouTube URL or ID').option('--output <filepath>', 'Filename and path of the downloaded video').action(function(options) {
    var YT;
    YT = require('./youtube');
    if (options.downloadVideo) {
      return YT.downloadVideo({
        video: options.downloadVideo,
        output: options.output || null
      });
    }
  });
};

module.exports = initCommands;