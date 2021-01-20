open CoursesCurriculum__Types

@react.component
let make = (~targetDetails) => {
  let contentBlocks = targetDetails |> TargetDetails.contentBlocks |> ContentBlock.sort
  <div id="learn-component"> <TargetContentView contentBlocks /> </div>
}
