%bs.raw(`
  window.onYouTubeIframeAPIReady = function() {
  var youtubeNodes = document.querySelectorAll('[id^="gt-course-youtube-video-"]');
  var playerList = Array.from(youtubeNodes).map(node => node.id);

  for (var i = 0; i < playerList.length; i++) {
    createPlayer(playerList[i]);
  };
}`)

let init = (targetId) => {
  %bs.raw(`
    function() {
      var tag = document.createElement('script');
      tag.id = "course-youtube-player"
      tag.src = "https://www.youtube.com/iframe_api";
      tag.dataset.targetId = targetId
      document.head.appendChild(tag);
    }()
  `)
}

let onPlayerStateChange = (event, videoId, targetId) => {
  if (event === 1 || event === 0) {
    let eventName = event === 1 ? "started" : "ended"
    NotifyStudentVideoEvent.notifyEvent(videoId, targetId, eventName)
  }
}

let createPlayer = (videoId) => {
  %bs.raw(`
    function() {
      var tag = document.getElementById("course-youtube-player");
      var targetId = tag.dataset.targetId;
      return new YT.Player(videoId, {
        events: {
          'onStateChange': (e) => onPlayerStateChange(e.data, videoId, targetId)
        }
      })}()
    `)
  }


