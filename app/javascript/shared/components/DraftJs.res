type inlineStyle =
  | Bold
  | Italic
  | Code
  | Strikethrough

let inlineStyleString = (inlineStyle) =>
  switch inlineStyle {
  | Bold => "BOLD"
  | Italic => "ITALIC"
  | Code => "CODE"
  | Strikethrough => "STRIKETHROUGH"
  }

let parseInlineStyle = (code: string) =>
  switch code {
  | "BOLD" => Some(Bold)
  | "ITALIC" => Some(Italic)
  | "CODE" => Some(Code)
  | "STRIKETHROUGH" => Some(Strikethrough)
  | _ => None
  }

type blockType =
  | Unstyled
  | Paragraph
  | H1
  | H2
  | H3
  | H4
  | H5
  | H6
  | Blockquote
  | UL
  | OL
  | CodeBlock

let blockTypeString = (blockType) =>
  switch blockType {
  | Unstyled => "unstyled"
  | Paragraph => "paragraph"
  | H1 => "header-one"
  | H2 => "header-two"
  | H3 => "header-three"
  | H4 => "header-four"
  | H5 => "header-five"
  | H6 => "header-six"
  | Blockquote => "blockquote"
  | UL => "unordered-list-item"
  | OL => "ordered-list-item"
  | CodeBlock => "code-block"
  }

let parseBlockType = (code: string) =>
  switch code {
  | "unstyled" => Some(Unstyled)
  | "paragraph" => Some(Paragraph)
  | "header-one" => Some(H1)
  | "header-two" => Some(H2)
  | "header-three" => Some(H3)
  | "header-four" => Some(H4)
  | "header-five" => Some(H5)
  | "header-six" => Some(H6)
  | "blockquote" => Some(Blockquote)
  | "unordered-list-item" => Some(UL)
  | "ordered-list-item" => Some(OL)
  | "code-block" => Some(CodeBlock)
  | _ => None
  }

module ContentBlock = {
  type t = Js.t<{.}>

  @bs.send external getType: (t) => string = "getType"
  let getType = (block: t) => parseBlockType(getType(block))

  @bs.send external findEntityRanges: (t, 'a, 'a) => unit = "findEntityRanges"
  let findEntityRanges = (block: t, filterFn, callback) => findEntityRanges(block, filterFn, callback)

  @bs.send external getEntityAt: (t, int) => Js.Nullable.t<string> = "getEntityAt"
  let getEntityAt = (block: t, offset: int) => getEntityAt(block, offset)->Js.Nullable.toOption
}

module DraftEntityInstance = {
  type t = Js.t<{.}>
  type data = {
    url: string,
  }

  @bs.send external getData: (t) => data = "getData"
  let getData = (entity: t) => getData(entity)

  @bs.send external getType: (t) => string = "getType"
  let getType = (entity: t) => getType(entity)
}

module CharacterMetadata = {
  type t = Js.t<{.}>

  @bs.send external getEntity: (t) => Js.Nullable.t<string> = "getEntity"
  let getEntity = (state: t) => getEntity(state)->Js.Nullable.toOption
}

module SelectionState = {
  type t = {
    anchorKey: string,
    anchorOffset: int,
    focusKey: string,
    focusOffset: int,
    isBackward: bool,
    hasFocus: bool,
  }

  @bs.module("draft-js") @bs.new external create: 'a => t = "SelectionState"

  @bs.send external getStartKey: (t) => string = "getStartKey"
  let getStartKey = (selection: t) => getStartKey(selection)

  @bs.send external getAnchorOffset: (t) => int = "getAnchorOffset"
  let getAnchorOffset = (selection: t) => getAnchorOffset(selection)

  @bs.send external getAnchorKey: (t) => string = "getAnchorKey"
  let getAnchorKey = (selection: t) => getAnchorKey(selection)
}

module ContentState = {
  type t = Js.t<{.}>

  @bs.send external getBlockForKey: (t, string) => ContentBlock.t = "getBlockForKey"
  let getBlockForKey = (state: t, key: string) => getBlockForKey(state, key)

  @bs.send external getEntity: (t, string) => DraftEntityInstance.t = "getEntity"
  let getEntity = (state: t, key: string) => getEntity(state, key)

  @bs.send external createEntity: (t, string, string, 'a) => t = "createEntity"
  let createEntity = (state: t, entityType: string, mutability: string, data) => createEntity(state, entityType, mutability, data)

  @bs.send external getLastCreatedEntityKey: (t) => string = "getLastCreatedEntityKey"
  let getLastCreatedEntityKey = (state: t) => getLastCreatedEntityKey(state)

  @bs.send external getSelectionAfter: (t) => SelectionState.t = "getSelectionAfter"
  let getSelectionAfter = (state: t) => getSelectionAfter(state)
}

module Modifier = {
  @bs.module("draft-js") @bs.scope("Modifier") external applyEntity: (ContentState.t, SelectionState.t, string) => ContentState.t = "applyEntity"
  let applyEntity = (contentState: ContentState.t, selectionState: SelectionState.t, entityKey: string) => applyEntity(contentState, selectionState, entityKey)

  @bs.module("draft-js") @bs.scope("Modifier") external insertText: (ContentState.t, SelectionState.t, string) => ContentState.t = "insertText"
  let insertText = (contentState: ContentState.t, targetRange: SelectionState.t, text: string) => insertText(contentState, targetRange, text)
}

module DraftInlineStyle = {
  type t = Js.t<{.}>

  @bs.send external has: (t, string) => bool = "has"
  let has = (styleSet: t, style: inlineStyle) => has(styleSet, inlineStyleString(style))
}

module EditorState = {
  type t = Js.t<{.}>

  @bs.module("draft-js") @bs.scope("EditorState") external createEmpty: () => t = "createEmpty"
  let createEmpty = createEmpty()
  @bs.module("draft-js") @bs.scope("EditorState") external createWithContent: (ContentState.t) => t = "createWithContent"
  let createWithContent = (raw) => createWithContent(raw)
  @bs.module("draft-js") @bs.scope("EditorState") external set: (t, 'a) => t = "set"
  let set = (editorState: t, contentState: ContentState.t) => set(editorState, {"currentContent": contentState})
  @bs.module("draft-js") @bs.scope("EditorState") external push: (t, ContentState.t, string) => t = "push"
  let push = (editorState: t, contentState: ContentState.t, changeType: string) => push(editorState, contentState, changeType)
  @bs.module("draft-js") @bs.scope("EditorState") external forceSelection: (t, SelectionState.t) => t = "forceSelection"
  let forceSelection = (editorState: t, selection: SelectionState.t) => forceSelection(editorState, selection)

  @bs.send external getCurrentContent: (t) => ContentState.t = "getCurrentContent"
  let getCurrentContent = (state: t) => getCurrentContent(state)

  @bs.send external getSelection: (t) => SelectionState.t = "getSelection"
  let getSelection = (state: t) => getSelection(state)

  @bs.send external getCurrentInlineStyle: (t) => DraftInlineStyle.t = "getCurrentInlineStyle"
  let getCurrentInlineStyle = (state: t) => getCurrentInlineStyle(state)

  @bs.module("draft-js") @bs.scope("AtomicBlockUtils") external insertAtomicBlock: (t, string, string) => t = "insertAtomicBlock"
  let insertAtomicBlock = (state: t, entityKey: string, character: string) => insertAtomicBlock(state, entityKey, character)

  let insertLink = (state: t, text: string, url: string) => {
    let contentState = getCurrentContent(state)
    let selection = getSelection(state)
    // create new content with text
    let newContent = Modifier.insertText(
      contentState,
      selection,
      text,
    )
    // create new link entity
    let newContentWithEntity = ContentState.createEntity(newContent,
      "LINK",
      "MUTABLE",
      {"url": url},
    )
    let entityKey = ContentState.getLastCreatedEntityKey(newContentWithEntity)
    // create new selection with the inserted text
    let anchorOffset = SelectionState.getAnchorOffset(selection)
    let anchorKey = SelectionState.getAnchorKey(selection)
    let textLength = Js.String.length(text)
    let newSelection = SelectionState.create({
      "anchorKey": anchorKey,
      "anchorOffset": anchorOffset,
      "focusKey": anchorKey,
      "focusOffset": anchorOffset + textLength,
    });
    // and aply link entity to the inserted text
    let newContentWithLink = Modifier.applyEntity(
      newContentWithEntity,
      newSelection,
      entityKey,
    );
    // create new state with link text
    let withLinkText = push(
      state,
      newContentWithLink,
      "insert-characters",
    );
    // now lets add cursor right after the inserted link
    let selectionAfter = ContentState.getSelectionAfter(newContent)
    forceSelection(withLinkText, selectionAfter)
  };
}

module RawDraftContentState = {
  type t = Js.t<{.}>
}

module RichUtils = {
  @bs.module("draft-js") @bs.scope("RichUtils") external handleKeyCommand: (EditorState.t, string) => Js.Nullable.t<EditorState.t> = "handleKeyCommand"
  let handleKeyCommand = (state, command) => handleKeyCommand(state, command)->Js.Nullable.toOption

  @bs.module("draft-js") @bs.scope("RichUtils") external toggleInlineStyle: (EditorState.t, string) => EditorState.t = "toggleInlineStyle"
  let toggleInlineStyle = (state, inlineStyle) => toggleInlineStyle(state, inlineStyleString(inlineStyle))

  @bs.module("draft-js") @bs.scope("RichUtils") external toggleBlockType: (EditorState.t, string) => EditorState.t = "toggleBlockType"
  let toggleBlockType = (state, blockType) => toggleBlockType(state, blockTypeString(blockType))

  @bs.module("draft-js") @bs.scope("RichUtils") external getCurrentBlockType: (EditorState.t) => string = "getCurrentBlockType"
  let getCurrentBlockType = (state) => parseBlockType(getCurrentBlockType(state))

  @bs.module("draft-js") @bs.scope("RichUtils") external currentBlockContainsLink: (EditorState.t) => bool = "currentBlockContainsLink"
  let currentBlockContainsLink = (editorState: EditorState.t) => currentBlockContainsLink(editorState)
}

@bs.module("draft-js") external convertToRaw: (ContentState.t) => RawDraftContentState.t = "convertToRaw"
let convertToRaw = (value) => convertToRaw(value)

@bs.module("draft-js") external convertFromRaw: (RawDraftContentState.t) => ContentState.t = "convertFromRaw"
let convertFromRaw  = (value) => convertFromRaw(value)


module Markdown = {
  let draftToMarkdownOptions = ()

  @bs.module("markdown-draft-js") external draftToMarkdown: (RawDraftContentState.t, 'a) => string = "draftToMarkdown"
  let draftToMarkdown  = (value, options) => draftToMarkdown(value, options)

  let markdownToDraftOptions = {
    "blockStyles": {
      "del_open": "STRIKETHROUGH",
    },
    "remarkablePreset": "commonmark",
    "remarkableOptions": {
      "enable": {
        "core":  ["abbr"],
        "block": "table",
        "inline": ["links", "emphasis", "del"],
      }
    }
  }
  @bs.module("markdown-draft-js") external markdownToDraft: (string, 'a) => RawDraftContentState.t = "markdownToDraft"
  let markdownToDraft  = (value, options) => markdownToDraft(value, options)
}

module Plugins = {
  @bs.module("draft-js-linkify-plugin") external createLinkifyPlugin: () => Js.t<{.}> = "default"
  @bs.module("draft-js-markdown-shortcuts-plugin") external createMarkdownShortcutsPlugin: () => Js.t<{.}> = "default"
  @bs.module("draft-js-block-breakout-plugin") external createBlockBreakoutPlugin: () => Js.t<{.}> = "default"
  @bs.module("draft-js-prism-plugin") external createPrismPlugin: ('a) => Js.t<{.}> = "default"
  @bs.module external prism: Js.t<{.}> = "prismjs"

  let setup = [
    createLinkifyPlugin(),
    createMarkdownShortcutsPlugin(),
    createBlockBreakoutPlugin(),
    createPrismPlugin({"prism": prism}),
  ]
}

module Editor = {
  module Utils = {
    let getCurrentEntityKey = (state: EditorState.t) => {
      let selection = EditorState.getSelection(state)
      let anchorKey = SelectionState.getAnchorKey(selection)
      let contentState = EditorState.getCurrentContent(state)
      let anchorBlock = ContentState.getBlockForKey(contentState, anchorKey)
      let offset = selection.anchorOffset
      let index = selection.isBackward ? offset - 1 : offset
      ContentBlock.getEntityAt(anchorBlock, index)
    }

    let getCurrentEntity = (state: EditorState.t) => {
      let contentState = EditorState.getCurrentContent(state)
      let entityKey = getCurrentEntityKey(state)
      switch entityKey {
      | Some(key) => Some(ContentState.getEntity(contentState, key))
      | None => None
      }
    }
  }

  module JsEditor = {
    @bs.module("draft-js-plugins-editor") @react.component
    external make: (
      ~id: string=?,
      ~editorState: EditorState.t=?,
      ~handleKeyCommand: string => bool,
      ~onChange: Js.t<{.}> => unit,
      ~ariaLabel: string=?,
      ~tabIndex: int=?,
      ~placeholder: string=?,
      ~plugins: array<'a>,
    ) => React.element = "default";
  }

  @react.component
  let make =
      (
        ~id,
        ~editorState,
        ~handleKeyCommand,
        ~onChange,
        ~ariaLabel,
        ~tabIndex=?,
        ~placeholder=?,
        ~plugins,
      ) =>  {
    <JsEditor
      id
      editorState
      handleKeyCommand
      onChange
      ariaLabel
      ?tabIndex
      ?placeholder
      plugins
    />
  }
}