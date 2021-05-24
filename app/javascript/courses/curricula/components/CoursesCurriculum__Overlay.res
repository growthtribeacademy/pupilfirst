exception UnexpectedSubmissionStatus(string)

%bs.raw(`require("./CoursesCurriculum__Overlay.css")`)

@bs.module external backSvg: string = "../../../shared/images/back.svg"

open CoursesCurriculum__Types

module TargetStatus = CoursesCurriculum__TargetStatus

let str = React.string

let t = I18n.t(~scope="components.CoursesCurriculum__Overlay")

type tab =
  | Learn
  | Discuss
  | Complete(TargetDetails.completionType)

type state = {
  targetDetails: option<TargetDetails.t>,
}

type action =
  | ResetState
  | SetTargetDetails(TargetDetails.t)
  | AddSubmission(Target.role)
  | ClearTargetDetails

let initialState = {targetDetails: None}

let reducer = (state, action) =>
  switch action {
  | ResetState => initialState
  | SetTargetDetails(targetDetails) => {
      targetDetails: Some(targetDetails),
    }
  | ClearTargetDetails => {targetDetails: None}
  | AddSubmission(role) =>
    switch role {
    | Target.Student => state
    | Team => {
        targetDetails: state.targetDetails |> OptionUtils.map(TargetDetails.clearPendingUserIds),
      }
    }
  }

let closeOverlay = course =>
  RescriptReactRouter.push("/courses/" ++ ((course |> Course.id) ++ "/curriculum"))

let loadTargetDetails = (target, send, ()) => {
  {
    open Js.Promise
    Fetch.fetch("/targets/" ++ ((target |> Target.id) ++ "/details_v2"))
    |> then_(Fetch.Response.json)
    |> then_(json => send(SetTargetDetails(json |> TargetDetails.decode)) |> resolve)
  } |> ignore

  None
}

let completionTypeToString = (completionType, targetStatus) =>
  switch (targetStatus |> TargetStatus.status, (completionType: TargetDetails.completionType)) {
  | (Pending, Evaluated) => t("completion_tab_complete")
  | (Pending, TakeQuiz) => t("completion_tab_take_quiz")
  | (Pending, LinkToComplete) => t("completion_tab_visit_link")
  | (Pending, MarkAsComplete) => t("completion_tab_mark_complete")
  | (
      PendingReview
      | Completed
      | Rejected
      | Locked(CourseLocked | AccessLocked),
      Evaluated,
    ) =>
    t("completion_tab_submissions")
  | (
      PendingReview
      | Completed
      | Rejected
      | Locked(CourseLocked | AccessLocked),
      TakeQuiz,
    ) =>
    t("completion_tab_quiz_result")
  | (PendingReview | Completed | Rejected, LinkToComplete | MarkAsComplete) =>
    t("completion_tab_completed")
  | (Locked(_), Evaluated | TakeQuiz | LinkToComplete | MarkAsComplete) =>
    t("completion_tab_locked")
  }

let tabToString = (targetStatus, tab) =>
  switch tab {
  | Learn => t("learn_tab")
  | Discuss => t("discuss_tab")
  | Complete(completionType) => completionTypeToString(completionType, targetStatus)
  }

let addSubmission = (target, state, send, addSubmissionCB, submission, levelUpEligibility) => {
  switch state.targetDetails {
  | Some(targetDetails) =>
    let newTargetDetails = targetDetails |> TargetDetails.addSubmission(submission)

    send(SetTargetDetails(newTargetDetails))
  | None => ()
  }

  switch submission |> Submission.status {
  | MarkedAsComplete =>
    addSubmissionCB(
      LatestSubmission.make(~pending=false, ~targetId=target |> Target.id),
      levelUpEligibility,
    )
  | Pending =>
    addSubmissionCB(
      LatestSubmission.make(~pending=true, ~targetId=target |> Target.id),
      levelUpEligibility,
    )
  | Completed =>
    raise(
      UnexpectedSubmissionStatus(
        "CoursesCurriculum__Overlay.addSubmission cannot handle a submsision with status Completed",
      ),
    )
  | Rejected =>
    raise(
      UnexpectedSubmissionStatus(
        "CoursesCurriculum__Overlay.addSubmission cannot handle a submsision with status Rejected",
      ),
    )
  }
}

let addVerifiedSubmission = (
  target,
  state,
  send,
  addSubmissionCB,
  submission,
  levelUpEligibility,
) => {
  switch state.targetDetails {
  | Some(targetDetails) =>
    let newTargetDetails = targetDetails |> TargetDetails.addSubmission(submission)
    send(SetTargetDetails(newTargetDetails))
  | None => ()
  }

  addSubmissionCB(
    LatestSubmission.make(~pending=false, ~targetId=target |> Target.id),
    levelUpEligibility,
  )
}

let targetStatusClass = (prefix, targetStatus) =>
  prefix ++ (targetStatus |> TargetStatus.statusClassesSufix)

let renderTargetStatus = targetStatus => {
  let className =
    "curriculum__target-status bg-white text-xs mt-2 md:mt-0 py-1 px-2 md:px-4 " ++
    targetStatusClass("curriculum__target-status--", targetStatus)

  ReactUtils.nullIf(
    <div className> {targetStatus |> TargetStatus.statusToString |> str} </div>,
    TargetStatus.isPending(targetStatus),
  )
}

let renderLocked = text =>
  <div
    className="mx-auto text-center bg-gray-900 text-white max-w-fc px-4 py-2 text-sm font-semibold relative z-10 rounded-b-lg">
    <i className="fas fa-lock text-lg" /> <span className="ml-2"> {text |> str} </span>
  </div>

let overlayStatus = (course, target, targetStatus, preview) =>
  <div className="max-w-container pt-8 px-4 mx-auto">
    <div id="overlayHeaderTitle">
      <button
        className="text-siliconBlue-900 opacity-50  hover:opacity-100 mb-2 transition duration-300 flex items-center"
        onClick={_e => closeOverlay(course)}>
        <img alt="" src={backSvg}/>
        <span className="ml-3 text-xl font-semibold"> {t("close_button")->str} </span>
      </button>
      <div className="w-full flex flex-wrap md:flex-no-wrap items-center justify-between relative">
        <h1 className="text-siliconBlue-900 leading-snug  text-3xl md:text-4xl">
          {target |> Target.title |> str}
        </h1>
        {renderTargetStatus(targetStatus)}
      </div>
    </div>
    {ReactUtils.nullUnless(<div> {renderLocked(t("preview_mode_text"))} </div>, preview)}
  </div>

let renderLockReason = reason => renderLocked(reason |> TargetStatus.lockReasonToString)

let prerequisitesIncomplete = (reason, target, targets, statusOfTargets, send) => {
  let prerequisiteTargetIds = target |> Target.prerequisiteTargetIds

  let prerequisiteTargets =
    targets |> Js.Array.filter(target =>
      prerequisiteTargetIds |> Js.Array.includes(Target.id(target))
    )

  <div className="relative px-3 md:px-0">
    {renderLockReason(reason)}
    <div
      className="course-overlay__prerequisite-targets z-10 max-w-3xl mx-auto bg-white text-center rounded-lg overflow-hidden shadow mt-6">
      {prerequisiteTargets |> Js.Array.map(target => {
        let targetStatus =
          statusOfTargets |> ArrayUtils.unsafeFind(
            ts => ts |> TargetStatus.targetId == Target.id(target),
            "Could not find status of target with ID " ++ Target.id(target),
          )

        <Link
          onClick={_ => send(ResetState)}
          href={"/targets/" ++ (target |> Target.id)}
          ariaLabel={"Select Target " ++ (target |> Target.id)}
          key={target |> Target.id}
          className="bg-white border-t px-6 py-4 relative z-10 flex items-center justify-between hover:bg-gray-200 hover:text-primary-500 cursor-pointer">
          <span className="font-semibold text-left leading-snug">
            {target |> Target.title |> str}
          </span>
          {renderTargetStatus(targetStatus)}
        </Link>
      }) |> React.array}
    </div>
  </div>
}

let handleLocked = (target, targets, targetStatus, statusOfTargets, send) =>
  switch targetStatus |> TargetStatus.status {
  | Locked(reason) =>
    switch reason {
    | PrerequisitesIncomplete =>
      prerequisitesIncomplete(reason, target, targets, statusOfTargets, send)
    | CourseLocked
    | AccessLocked
    | LevelLocked =>
      renderLockReason(reason)
    }
  | Pending
  | PendingReview
  | Completed
  | Rejected => React.null
  }

let learnSection = (
  targetDetails,
  author,
  courseId,
  targetId,
  coaches,
) => {
  <div>
    <CoursesCurriculum__Learn targetDetails author courseId targetId coaches />
  </div>
}

let discussSection = (target, targetDetails, targetStatus) =>
  TargetDetails.communities(targetDetails) == [] ?
    React.null :
    <div>
      <div id="discuss" className="text-2xl mt-4 pt-4 font-bold border-t border-1">
        {Discuss |> tabToString(targetStatus) |> str}
      </div>
      <CoursesCurriculum__Discuss
        targetId={target |> Target.id} communities={targetDetails |> TargetDetails.communities}
      />
    </div>

let completeSection = (
  state,
  send,
  target,
  targetDetails,
  targetStatus,
  addSubmissionCB,
  evaluationCriteria,
  coaches,
  users,
  preview,
  completionType,
) => {
  let addVerifiedSubmissionCB = addVerifiedSubmission(target, state, send, addSubmissionCB)

  let completeSection =
  <div>
    <div id="complete" className="text-2xl mt-4 pt-4 font-bold border-t border-1">
      {Complete(completionType) |> tabToString(targetStatus) |> str}
    </div>
    {switch (targetStatus |> TargetStatus.status, completionType) {
    | (Pending, Evaluated) =>
      [
        <CoursesCurriculum__CompletionInstructions
          key="completion-instructions" targetDetails title="Instructions"
        />,
        <CoursesCurriculum__SubmissionBuilder
          key="courses-curriculum-submission-form"
          target
          checklist={targetDetails |> TargetDetails.checklist}
          addSubmissionCB={addSubmission(target, state, send, addSubmissionCB)}
          preview
        />,
      ] |> React.array
    | (Pending, TakeQuiz) =>
      [
        <CoursesCurriculum__CompletionInstructions
          key="completion-instructions" targetDetails title="Instructions"
        />,
        <CoursesCurriculum__Quiz
          key="courses-curriculum-quiz"
          target
          targetDetails
          addSubmissionCB=addVerifiedSubmissionCB
          preview
        />,
      ] |> React.array

    | (
        PendingReview
        | Completed
        | Rejected
        | Locked(CourseLocked | AccessLocked),
        Evaluated | TakeQuiz,
      ) =>
      <CoursesCurriculum__SubmissionsAndFeedback
        targetDetails
        target
        evaluationCriteria
        addSubmissionCB={addSubmission(target, state, send, addSubmissionCB)}
        targetStatus
        coaches
        users
        preview
        checklist={targetDetails |> TargetDetails.checklist}
      />
    | (Pending | PendingReview | Completed | Rejected, LinkToComplete | MarkAsComplete) =>
      <CoursesCurriculum__AutoVerify
        target targetDetails targetStatus addSubmissionCB=addVerifiedSubmissionCB preview
      />
    | (Locked(_), Evaluated | TakeQuiz | MarkAsComplete | LinkToComplete) => React.null
    }}
  </div>


  {switch (targetStatus |> TargetStatus.status, completionType) {
  | (Pending | PendingReview | Completed | Rejected, Evaluated | TakeQuiz) =>
    completeSection
  | (Locked(CourseLocked | AccessLocked), Evaluated | TakeQuiz) =>
    TargetDetails.submissions(targetDetails) != []
      ? completeSection
      : React.null
  | (Pending | PendingReview | Completed | Rejected, LinkToComplete | MarkAsComplete) =>
    completeSection
  | (Locked(_), _) => React.null
  }}
}

let renderPendingStudents = (pendingUserIds, users) =>
  <div className="max-w-3xl mx-auto text-center mt-4">
    <div className="font-semibold text-md"> {t("pending_team_members_notice")->str} </div>
    <div className="flex justify-center flex-wrap"> {pendingUserIds |> Js.Array.map(studentId => {
        let user =
          users |> ArrayUtils.unsafeFind(
            u => u |> User.id == studentId,
            "Unable to find user with id " ++ (studentId ++ "in CoursesCurriculum__Overlay"),
          )

        <div
          key={user |> User.id}
          title={(user |> User.name) ++ " has not completed this target."}
          className="w-10 h-10 rounded-full border border-yellow-400 flex items-center justify-center overflow-hidden mx-1 shadow-md flex-shrink-0 mt-2">
          {user |> User.avatar}
        </div>
      }) |> React.array} </div>
  </div>

let handlePendingStudents = (targetStatus, targetDetails, users) =>
  switch (targetDetails, targetStatus |> TargetStatus.status) {
  | (Some(targetDetails), PendingReview | Completed) =>
    let pendingUserIds = TargetDetails.pendingUserIds(targetDetails)
    pendingUserIds == [] ? React.null : renderPendingStudents(pendingUserIds, users)
  | (Some(_) | None, Locked(_) | Pending | PendingReview | Completed | Rejected) => React.null
  }

let performQuickNavigation = (send, _event) => {
  {
    open // Scroll to the top of the overlay before pushing the new URL.
    Webapi.Dom
    switch document |> Document.getElementById("target-overlay") {
    | Some(element) => Webapi.Dom.Element.setScrollTop(element, 0.0)
    | None => ()
    }
  }

  // Clear loaded target details.
  send(ClearTargetDetails)
}

let navigationLink = (direction, url, send) => {
  let (cssClass, text) = switch direction {
  | #Previous => ("btn-primary-ghost", t("previous_target_button"))
  | #Next => ("btn-primary", t("next_target_button"))
  }


  <Link
    href=url
    onClick={performQuickNavigation(send)}
    className={cssClass}>
    <span className=""> {text |> str} </span>
  </Link>
}

let scrollOverlayToTop = _event => {
  let element = {
    open Webapi.Dom
    document |> Document.getElementById("target-overlay")
  }
  element->Belt.Option.mapWithDefault((), element => element->Webapi.Dom.Element.setScrollTop(0.0))
}

let quickNavigationLinks = (targetDetails, send) => {
  let (previous, next) = targetDetails |> TargetDetails.navigation

  <div className="pb-12">
    <hr className="my-12" />
    <div className="container mx-auto max-w-6xl flex px-3 lg:px-0 justify-between">
      <div>
        {previous->Belt.Option.mapWithDefault(React.null, previousUrl =>
          navigationLink(#Previous, previousUrl, send)
        )}
      </div>
      <div>
        <button
          onClick=scrollOverlayToTop
          >
          <span className="mx-2 hidden md:inline"> {t("scroll_to_top")->str}</span>
          <span className="mx-2 md:hidden"> <i className="fas fa-arrow-up" /> </span>
        </button>
      </div>
      <div>
        {next->Belt.Option.mapWithDefault(React.null, nextUrl =>
          navigationLink(#Next, nextUrl, send)
        )}
      </div>
    </div>
  </div>
}

let updatePendingUserIdsWhenAddingSubmission = (
  send,
  target,
  addSubmissionCB,
  submission,
  levelUpEligibility,
) => {
  send(AddSubmission(target |> Target.role))
  addSubmissionCB(submission, levelUpEligibility)
}

@react.component
let make = (
  ~target,
  ~course,
  ~targetStatus,
  ~addSubmissionCB,
  ~targets,
  ~statusOfTargets,
  ~users,
  ~evaluationCriteria,
  ~coaches,
  ~preview,
  ~author,
) => {
  let (state, send) = React.useReducer(reducer, initialState)

  React.useEffect1(loadTargetDetails(target, send), [Target.id(target)])

  React.useEffect(() => {
    ScrollLock.activate()
    Some(() => ScrollLock.deactivate())
  })

  <div
    id="target-overlay"
    className="fixed z-30 top-0 left-0 w-full h-full overflow-y-scroll bg-white">
    <div className="">
      <div className="pt-12 lg:pt-0 mx-auto">
        {overlayStatus(course, target, targetStatus, preview)}
        {handleLocked(target, targets, targetStatus, statusOfTargets, send)}
        {handlePendingStudents(targetStatus, state.targetDetails, users)}
      </div>
    </div>
    {switch state.targetDetails {
    | Some(targetDetails) =>
      let completionType = targetDetails |> TargetDetails.computeCompletionType

      <div>
        <div className="max-w-container px-4 mx-auto text-siliconBlue-900">
          {learnSection(
            targetDetails,
            author,
            Course.id(course),
            Target.id(target),
            coaches,
          )}
          {discussSection(target, targetDetails, targetStatus)}
          {completeSection(
            state,
            send,
            target,
            targetDetails,
            targetStatus,
            updatePendingUserIdsWhenAddingSubmission(send, target, addSubmissionCB),
            evaluationCriteria,
            coaches,
            users,
            preview,
            completionType,
          )}
        </div>
        { quickNavigationLinks(targetDetails, send) }
      </div>

    | None =>
      <div className="course-overlay__skeleton-body-container max-w-3xl w-full pb-4 mx-auto">
        <div className="course-overlay__skeleton-body-wrapper mt-8 px-3 lg:px-0">
          <div
            className="course-overlay__skeleton-line-placeholder-md mt-4 w-2/4 skeleton-animate"
          />
          <div className="course-overlay__skeleton-line-placeholder-sm mt-4 skeleton-animate" />
          <div className="course-overlay__skeleton-line-placeholder-sm mt-4 skeleton-animate" />
          <div
            className="course-overlay__skeleton-line-placeholder-sm mt-4 w-3/4 skeleton-animate"
          />
          <div className="course-overlay__skeleton-image-placeholder mt-5 skeleton-animate" />
          <div
            className="course-overlay__skeleton-line-placeholder-sm mt-4 w-2/5 skeleton-animate"
          />
        </div>
        <div className="course-overlay__skeleton-body-wrapper mt-8 px-3 lg:px-0">
          <div
            className="course-overlay__skeleton-line-placeholder-sm mt-4 w-3/4 skeleton-animate"
          />
          <div className="course-overlay__skeleton-line-placeholder-sm mt-4 skeleton-animate" />
          <div
            className="course-overlay__skeleton-line-placeholder-sm mt-4 w-3/4 skeleton-animate"
          />
        </div>
      </div>
    }}
  </div>
}
