import Player from '@vimeo/player';

export function initPlayer(iframe, targetId, notiyfy) {
  var player = new Player(iframe);
  player.on('play', function() {
    console.log('Played the video');
    notify("videoId", targetId, "started")
  });
  player.getVideoTitle().then(function(title) {
    console.log('title:', title);
  });
}
