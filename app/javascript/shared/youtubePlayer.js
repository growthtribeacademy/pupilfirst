window.onYouTubeIframeAPIReady = function() {
  var youtubeNodes = document.querySelectorAll('[id^="gt-course-youtube-video-"]');
  var playerList = Array.from(youtubeNodes).map(node => node.id);

  for (var i = 0; i < playerList.length; i++) {
    createPlayer(playerList[i]);
  };
}

function createPlayer(videoId) {
  return new YT.Player(videoId, {
    events: {
      'onReady': onReady,
      'onStateChange': onPlayerStateChange
    }
  });
}

function onReady(event) {
  console.log('* video ready');
}

function onPlayerStateChange(event) {
  console.log(YT.PlayerState);
}

export function initPlayer() {
  var tag = document.createElement('script');
  tag.src = "https://www.youtube.com/iframe_api";
  document.head.appendChild(tag);
}
