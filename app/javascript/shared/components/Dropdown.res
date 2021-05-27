open Webapi.Dom

let onWindowClick = (showDropdown, setShowDropdown, _event) =>
  if showDropdown {
    setShowDropdown(_ => false)
  } else {
    ()
  }

let toggleDropdown = (setShowDropdown, event) => {
  event |> ReactEvent.Mouse.stopPropagation
  setShowDropdown(showDropdown => !showDropdown)
}

let containerClasses = className => {
  "dropdown inline-block relative text-sm " ++ className
}

@react.component
let make = (~selected, ~contents, ~right=false, ~className="w-full md:w-auto") => {
  let (showDropdown, setShowDropdown) = React.useState(() => false)

  React.useEffect1(() => {
    let curriedFunction = onWindowClick(showDropdown, setShowDropdown)

    let removeEventListener = () => Window.removeEventListener("click", curriedFunction, window)

    if showDropdown {
      Window.addEventListener("click", curriedFunction, window)
      Some(removeEventListener)
    } else {
      removeEventListener()
      None
    }
  }, [showDropdown])

  <div className={containerClasses(className)} onClick={toggleDropdown(setShowDropdown)}>
    selected
    {showDropdown
      ? <div
          className={"dropdown__list bg-white shadow-lg rounded-lg mt-4 border border-gray-400 absolute overflow-x-hidden z-30 py-4 " ++ (
            right ? "right-0" : "left-0"
          )}>
          {contents
          |> Array.mapi((index, content) =>
            <div
              key={"dropdown-" ++ (index |> string_of_int)}
              className="cursor-pointer block text-lg font-semibold text-siliconBlue-900 bg-white hover:text-preciseBlue md:whitespace-no-wrap ">
              content
            </div>
          )
          |> React.array}
        </div>
      : React.null}
  </div>
}
