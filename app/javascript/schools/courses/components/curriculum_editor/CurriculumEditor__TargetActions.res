let str = React.string

type rec state =
  | Ready
  | Saving

type action =
  | BeginSaving
  | FailSaving
  | Done

let reducer = (_state, action) =>
  switch action {
  | BeginSaving => Saving
  | FailSaving => Ready
  | Done => Ready
  }


@react.component
let make = (~targetId) => {
  let (state, send) = React.useReducer(reducer, Ready)

  let saving = state == Saving
  <DisablingCover disabled={saving}>
    <div className="max-w-3xl py-6 px-3 mx-auto">
      <div className="mt-5">
        <label
          className="inline-block tracking-wide text-xs font-semibold"
          htmlFor="clone-target">
          {"Copy Into" |> str}
        </label>
        <HelpIcon className="ml-1 text-sm">
          {str(
            "Pick course, level and target group to copy this target into. This action will copy all content blocks.",
          )}
        </HelpIcon>
      </div>
    </div>
  </DisablingCover>
}
