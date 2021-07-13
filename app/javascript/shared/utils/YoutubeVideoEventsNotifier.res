%bs.raw(`
  window.onYouTubeIframeAPIReady = function() {
  var youtubeNodes = document.querySelectorAll('[id^="gt-course-youtube-video-"]');
  var playerList = Array.from(youtubeNodes).map(node => node.id);

  for (var i = 0; i < playerList.length; i++) {
    createPlayer(playerList[i]);
  };
}`)

module NotifyStudentVideoEvent = %graphql(
  `mutation NotifyStudentVideoEvent($studentId: String!, $courseId: String!, $videoId: String!) {
     notifyStudentVideoEvent(videoId: $videoId, courseId: $courseId studentId: $studentId)
     {
      success
     }
    }
  `
)

let init = (courseId, studentId) => {
  %bs.raw(`
    function() {
      var tag = document.createElement('script');
      tag.id = "course-youtube-player"
      tag.src = "https://www.youtube.com/iframe_api";
      tag.dataset.courseId = courseId
      tag.dataset.studentId = studentId
      document.head.appendChild(tag);
    }()
  `)
}

let onReady = (event) => {
  Js.log("ON-READY")
}

let onPlayerStateChange = (videoId, courseId, studentId) => {
  NotifyStudentVideoEvent.make(~videoId=videoId, ~courseId=courseId, ~studentId=studentId, ())
  |> GraphqlQuery.sendQuery
  |>Js.Promise.then_(response => {
    response["notifyStudentVideoEvent"]["success"] ? Js.log("success") : Js.log("failure")
    Js.Promise.resolve()
   })
  |> ignore
}

let createPlayer = (videoId) => {
  %bs.raw(`
    function() {
      var tag = document.getElementById("course-youtube-player");
      var courseId = tag.dataset.courseId;
      var studentId = tag.dataset.studentId;
      return new YT.Player(videoId, {
        events: {
          'onReady': onReady,
          'onStateChange': (e) => onPlayerStateChange(videoId, courseId, studentId)
        }
      })}()
    `)
  }


