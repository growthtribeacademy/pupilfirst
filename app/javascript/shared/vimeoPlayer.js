import Player from '@vimeo/player';

export function initPlayer(iframe, targetId, notiyfy) {
  var player = new Player(iframe);
  player.on('play', function() {
    notify("videoId", targetId, "started")
  });
  player.on('ended', function() {
    notify("videoId", targetId, "ended")
  });
  player.getVideoTitle().then(function(title) {
    console.log('title:', title);
  });
}
