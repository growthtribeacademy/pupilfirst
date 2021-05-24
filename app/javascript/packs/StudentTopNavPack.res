open StudentTopNav__Types
open Json.Decode

let decodeProps = json => (
  json |> field("schoolName", string),
  json |> field("logoUrl", nullable(string)) |> Js.Null.toOption,
  json |> field("links", array(NavLink.decode)),
  json |> field("isLoggedIn", bool),
  json |> field("currentUser", optional(User.decode)),
  json |> field("hasNotifications", bool),
  json |> field("communityHost", string),
)

let (schoolName, logoUrl, links, isLoggedIn, currentUser, hasNotifications, communityHost) =
  DomUtils.parseJSONTag(~id="student-top-nav-props", ()) |> decodeProps

switch ReactDOM.querySelector("#student-top-nav") {
| Some(element) =>
  ReactDOM.render(
    <StudentTopNav schoolName logoUrl links isLoggedIn currentUser hasNotifications communityHost />,
    element,
  )
| None => ()
}
