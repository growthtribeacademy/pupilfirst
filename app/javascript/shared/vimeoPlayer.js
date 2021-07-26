import Player from '@vimeo/player';

export function initPlayer() {
  var iframe = document.querySelector('iframe');
  var player = new Player(iframe);
  player.on('play', function() {
    console.log('Played the video');
  });
  player.getVideoTitle().then(function(title) {
    console.log('title:', title);
  });
}
