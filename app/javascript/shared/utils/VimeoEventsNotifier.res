type rec iframe = {
  id: string,
  src: string
}

@module("../vimeoPlayer.js")
external initPlayer: (iframe, string, (string, string, string)=> unit) => _ = "initPlayer"

let init = (targetId) => {
  let iframes = %bs.raw(`Array.from(document.querySelectorAll('iframe'))`)

  if (iframes) {
    let vimeoFrames = %bs.raw(`Array.from(iframes).filter((iframe) => /player\.vimeo/.test(iframe.src))`)
    let notify = NotifyStudentVideoEvent.notifyEvent
    Belt.Array.forEach(vimeoFrames, iframe => {
      initPlayer(iframe, targetId, notify)
    })
  }
}
