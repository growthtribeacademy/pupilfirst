module NotifyStudentVideoEvent = %graphql(
  `mutation NotifyStudentVideoEvent($videoId: String!, $event: String!, $targetId: String!) {
     notifyStudentVideoEvent(videoId: $videoId, targetId: $targetId, event: $event)
     {
      success
     }
    }
  `
)

let notifyEvent = (videoId, targetId, event) => {
  NotifyStudentVideoEvent.make(~videoId=videoId, ~targetId, ~event=event, ())
  |> GraphqlQuery.sendQuery
  |>Js.Promise.then_(response => Js.Promise.resolve())
  |> ignore
}
