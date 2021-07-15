%bs.raw(`
  window.onYouTubeIframeAPIReady = function() {
  var youtubeNodes = document.querySelectorAll('[id^="gt-course-youtube-video-"]');
  var playerList = Array.from(youtubeNodes).map(node => node.id);

  for (var i = 0; i < playerList.length; i++) {
    createPlayer(playerList[i]);
  };
}`)

module NotifyStudentVideoEvent = %graphql(
  `mutation NotifyStudentVideoEvent($videoId: String!, $event: String!, $targetId: String!) {
     notifyStudentVideoEvent(videoId: $videoId, targetId: $targetId, event: $event)
     {
      success
     }
    }
  `
)


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

let onReady = (event) => {
  Js.log("ON-READY")
}

let notifyEvent = (videoId, targetId, event) => {
  NotifyStudentVideoEvent.make(~videoId=videoId, ~targetId, ~event=event, ())
  |> GraphqlQuery.sendQuery
  |>Js.Promise.then_(response => {
    response["notifyStudentVideoEvent"]["success"] ? Js.log("success") : Js.log("failure")
    Js.Promise.resolve()
   })
  |> ignore
}


let onPlayerStateChange = (event, videoId, targetId) => {
  if (event === 1 || event === 0) {
    notifyEvent(videoId, targetId, event === 1 ? "started" : "ended")
  }
}

let createPlayer = (videoId) => {
  %bs.raw(`
    function() {
      var tag = document.getElementById("course-youtube-player");
      var targetId = tag.dataset.targetId;
      return new YT.Player(videoId, {
        events: {
          'onReady': onReady,
          'onStateChange': (e) => onPlayerStateChange(e.data, videoId, targetId)
        }
      })}()
    `)
  }


