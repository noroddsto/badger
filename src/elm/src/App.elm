module App exposing (..)

import Browser
import Browser.Dom
import Component.Modal as Modal
import Data.Canvas as Canvas
import Data.Color as Color
import Data.Font as Font
import Data.FontSize as FontSize
import Data.FontWeight as FontWeight
import Data.LayoutDirection as Layout
import Data.Percentage as Percentage
import Helper.ColorPicker as ColorPicker
import Helper.Contrast as Contrast
import Helper.Form as HF
import Helper.Html as HH
import Helper.Preset as Preset
import Helper.SegmentButton as SB
import Helper.Style as Style
import Helper.SvgInput as IconInput
import Helper.Update exposing (noCmd, parseInt, withCmd)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Icon.UI as UI
import Json.Decode as JD
import Json.Encode as JE
import Ports
import Random
import Random.Char
import Random.String
import SvgParser
import Task



-- INIT


type alias Flags =
    { supportLocalStorage : Bool
    , presetList : List String
    }


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init { supportLocalStorage, presetList } =
    ( { size = Percentage.fromInt 25
      , svgInput = Nothing
      , confirmedSvg = Nothing
      , svgColor = ColorPicker.init Color.black
      , textBoxSize = { width = 0, height = 0 }
      , width = 200
      , height = 100
      , backgroundColor = ColorPicker.init Color.white
      , layoutDirection = Layout.topToBottom
      , spaceBetween = 0
      , fontSize = FontSize.toPx 24
      , fontFamily = Font.default
      , mainText = "Example"
      , textColor = ColorPicker.init Color.black
      , fontWeight = FontWeight.normal
      , availableFonts = Font.availableFonts
      , textOpacity = Percentage.fromInt 100
      , iconOpacity = Percentage.fromInt 100
      , menuToggled = False
      , iconDomId = "icon"
      , svgDomId = "generated-svg"
      , alignHorizontal = Canvas.alignCenter
      , alignVertical = Canvas.alignCenter
      , padding = 0
      , currentPreset = Preset.noPreset
      , editPresetName = Nothing
      , presetList =
            if supportLocalStorage then
                Just presetList

            else
                Nothing
      , showSelectPresetDialog = False
      , askToDeletePreset = Nothing
      }
    , Cmd.batch
        [ getTextboxDimension
        , Random.String.string 10 Random.Char.english |> Random.generate SetIconDomId
        , Random.String.string 10 Random.Char.english |> Random.generate SetSvgDomId
        ]
    )


type alias ElementSize =
    { height : Float, width : Float }



-- MODEL


type alias Model =
    { width : Int
    , height : Int
    , backgroundColor : ColorPicker.ColorInput
    , layoutDirection : Layout.LayoutDirection
    , spaceBetween : Int
    , fontFamily : Font.Font
    , fontSize : FontSize.FontSize
    , mainText : String
    , textColor : ColorPicker.ColorInput
    , fontWeight : FontWeight.FontWeight
    , size : Percentage.Percentage
    , svgInput : Maybe IconInput.Input
    , confirmedSvg : Maybe SvgParser.Element
    , svgColor : ColorPicker.ColorInput
    , textBoxSize : ElementSize
    , availableFonts : Font.FontList
    , textOpacity : Percentage.Percentage
    , iconOpacity : Percentage.Percentage
    , menuToggled : Bool
    , iconDomId : String
    , svgDomId : String
    , alignHorizontal : Canvas.Align
    , alignVertical : Canvas.Align
    , padding : Int
    , currentPreset : Preset.PresetState
    , editPresetName : Maybe String
    , presetList : Maybe (List String)
    , showSelectPresetDialog : Bool
    , askToDeletePreset : Maybe String
    }



-- UPDATE


type Msg
    = NoOp
    | SetWidth String
    | SetHeight String
    | SetSpaceBetween String
    | SetLayoutDirection Layout.LayoutDirection
    | SetBackgroundColor ColorPicker.ColorInput
    | SetMainText String
    | SetFontSize String
    | SetSvgSize String
    | SetTextColor ColorPicker.ColorInput
    | AddSvg
    | SetSvgColor ColorPicker.ColorInput
    | ModalClicked String Modal.Position
    | CloseModal String
    | IconInputWasClosed
    | SetIconInput String
    | ConfirmIconInput
    | DeleteSvg
    | SetFontWeight String
    | SetTextboxSize (Result Browser.Dom.Error Browser.Dom.Element)
    | SetFont String
    | SetTextOpacity String
    | SetIconOpacity String
    | DownloadSvg
    | ToggleMenu
    | SetIconDomId String
    | SetSvgDomId String
    | SetVerticalAlign Canvas.Align
    | SetHorizontalAlign Canvas.Align
    | SetPadding String
    | LogJson JE.Value
    | SavePreset
    | SetPresetName String
    | EditPresetName
    | EditPresetWasCancelled
    | SavePresetResponse (Result JD.Error String)
    | LoadPreset String
    | LoadPresetResult (Result JD.Error Preset.Preset)
    | PresetModalWasClosed
    | SavePresetSameName
    | OpenPresetDialog
    | DeletePreset String
    | DeletePresetResponse (Result JD.Error String)
    | AskToDeletePreset String
    | CancelDeletePreset


savePresetModalConfig : Modal.DialogConfig Msg
savePresetModalConfig =
    { id = "save-preset", closeDialog = ModalClicked, dialogWasClosed = EditPresetWasCancelled }


loadPresetModalConfig : Modal.DialogConfig Msg
loadPresetModalConfig =
    { id = "load-preset", closeDialog = ModalClicked, dialogWasClosed = PresetModalWasClosed }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Preset.savePresetResponse SavePresetResponse
        , Preset.loadPresetResponse LoadPresetResult
        , Preset.deletePresetResponse DeletePresetResponse
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetWidth newValue ->
            { model | width = parseInt newValue, currentPreset = Preset.changed model.currentPreset }
                |> noCmd

        SetHeight newValue ->
            { model | height = parseInt newValue, currentPreset = Preset.changed model.currentPreset }
                |> noCmd

        SetSpaceBetween newValue ->
            { model | spaceBetween = parseInt newValue, currentPreset = Preset.changed model.currentPreset }
                |> noCmd

        SetLayoutDirection newValue ->
            { model | layoutDirection = newValue, currentPreset = Preset.changed model.currentPreset }
                |> noCmd

        SetMainText newValue ->
            { model | mainText = newValue }
                |> withCmd getTextboxDimension

        SetFontSize newValue ->
            { model | fontSize = FontSize.toPx << parseInt <| newValue, currentPreset = Preset.changed model.currentPreset }
                |> withCmd getTextboxDimension

        SetFontWeight value ->
            { model | fontWeight = FontWeight.fromString value |> Maybe.withDefault model.fontWeight, currentPreset = Preset.changed model.currentPreset }
                |> noCmd

        SetSvgSize newValue ->
            { model
                | size =
                    Percentage.fromInt
                        (newValue
                            |> String.toInt
                            |> Maybe.withDefault 0
                        )
                , currentPreset = Preset.changed model.currentPreset
            }
                |> noCmd

        AddSvg ->
            { model | svgInput = Just <| IconInput.setValue "" }
                |> withCmd (Ports.openDialog customSvgModalConfig.id)

        ModalClicked domId pos ->
            ( model
            , Modal.modalWasClicked domId pos CloseModal NoOp
            )

        CloseModal domId ->
            ( model, Ports.closeDialog domId )

        IconInputWasClosed ->
            { model | svgInput = Nothing }
                |> noCmd

        SetIconInput newValue ->
            { model | svgInput = Just <| IconInput.setValue newValue }
                |> noCmd

        ConfirmIconInput ->
            model.svgInput
                |> Maybe.andThen IconInput.getElement
                |> Maybe.map
                    (\element ->
                        { model
                            | confirmedSvg = Just element
                            , svgInput = Nothing
                            , currentPreset = Preset.changed model.currentPreset
                        }
                    )
                |> Maybe.withDefault model
                |> noCmd

        DeleteSvg ->
            { model | confirmedSvg = Nothing }
                |> noCmd

        SetTextboxSize (Ok { element }) ->
            { model | textBoxSize = { height = element.height, width = element.width } }
                |> noCmd

        SetTextboxSize _ ->
            ( model, Cmd.none )

        SetFont newFontKey ->
            ( { model
                | fontFamily =
                    Font.getFont newFontKey model.availableFonts
                        |> Maybe.withDefault model.fontFamily
                , currentPreset = Preset.changed model.currentPreset
              }
            , getTextboxDimension
            )

        SetTextOpacity newValue ->
            { model
                | textOpacity =
                    Percentage.fromInt
                        (newValue
                            |> String.toInt
                            |> Maybe.withDefault 0
                        )
                , currentPreset = Preset.changed model.currentPreset
            }
                |> noCmd

        SetIconOpacity newValue ->
            { model
                | iconOpacity =
                    Percentage.fromInt
                        (newValue
                            |> String.toInt
                            |> Maybe.withDefault 0
                        )
                , currentPreset = Preset.changed model.currentPreset
            }
                |> noCmd

        DownloadSvg ->
            ( model, Ports.downloadSvg { domId = model.svgDomId, fileName = "Result" } )

        ToggleMenu ->
            ( { model | menuToggled = not model.menuToggled }, Cmd.none )

        SetBackgroundColor color ->
            ( { model | backgroundColor = color, currentPreset = Preset.changed model.currentPreset }, Cmd.none )

        SetSvgColor color ->
            ( { model | svgColor = color, currentPreset = Preset.changed model.currentPreset }, Cmd.none )

        SetTextColor color ->
            ( { model | textColor = color, currentPreset = Preset.changed model.currentPreset }, Cmd.none )

        SetIconDomId newId ->
            ( { model | iconDomId = "icon-" ++ newId }, Cmd.none )

        SetSvgDomId newId ->
            ( { model | svgDomId = "svg-" ++ newId }, Cmd.none )

        SetHorizontalAlign align ->
            ( { model | alignHorizontal = align, currentPreset = Preset.changed model.currentPreset }, Cmd.none )

        SetVerticalAlign align ->
            ( { model | alignVertical = align, currentPreset = Preset.changed model.currentPreset }, Cmd.none )

        SetPadding newValue ->
            { model | padding = parseInt newValue, currentPreset = Preset.changed model.currentPreset }
                |> noCmd

        LogJson json ->
            ( model, Ports.log json )

        SavePreset ->
            case model.editPresetName of
                Just "" ->
                    ( { model | currentPreset = Preset.noPreset, editPresetName = Nothing }, Cmd.none )

                Just name ->
                    let
                        preset =
                            { key = name, payload = modelToPresetPayload model }
                    in
                    ( { model | currentPreset = Preset.saving name, editPresetName = Nothing }, Ports.savePreset (Preset.toJson preset) )

                Nothing ->
                    ( model, Cmd.none )

        SetPresetName newName ->
            model.editPresetName
                |> Maybe.map
                    (\_ ->
                        ( { model | editPresetName = Just newName }, Cmd.none )
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        EditPresetName ->
            let
                presetName =
                    Preset.getName model.currentPreset
                        |> Maybe.withDefault ""
            in
            ( { model | editPresetName = Just presetName }
            , Ports.openDialog savePresetModalConfig.id
            )

        EditPresetWasCancelled ->
            { model | editPresetName = Nothing }
                |> noCmd

        SavePresetSameName ->
            case Preset.getName model.currentPreset of
                Just name ->
                    let
                        preset =
                            { key = name, payload = modelToPresetPayload model }
                    in
                    ( { model | currentPreset = Preset.saving name, editPresetName = Nothing }
                    , Ports.savePreset (Preset.toJson preset)
                    )

                Nothing ->
                    update EditPresetName model

        SavePresetResponse (Ok presetName) ->
            ( { model
                | currentPreset = Preset.saved presetName
                , presetList =
                    model.presetList
                        |> Maybe.map
                            (\items ->
                                if List.member presetName items then
                                    items

                                else
                                    presetName :: items
                            )
              }
            , Cmd.none
            )

        SavePresetResponse (Err err) ->
            ( { model | currentPreset = Preset.failed (JD.errorToString err) }, Cmd.none )

        OpenPresetDialog ->
            ( { model | showSelectPresetDialog = True }, Ports.openDialog loadPresetModalConfig.id )

        LoadPreset presetName ->
            ( model, Ports.loadPreset presetName )

        LoadPresetResult (Ok preset) ->
            ( model |> applyPreset preset, Cmd.batch [ Ports.closeDialog loadPresetModalConfig.id, getTextboxDimension ] )

        LoadPresetResult (Err e) ->
            ( { model | currentPreset = Preset.failed (JD.errorToString e) }, Cmd.none )

        PresetModalWasClosed ->
            ( { model | showSelectPresetDialog = False, askToDeletePreset = Nothing }, Cmd.none )

        DeletePreset name ->
            ( model, Ports.deletePreset name )

        DeletePresetResponse (Ok name) ->
            ( { model
                | presetList =
                    model.presetList
                        |> Maybe.map
                            (\items ->
                                items
                                    |> List.filter (\i -> i /= name)
                            )
                , currentPreset =
                    if Preset.getName model.currentPreset == Just name then
                        Preset.noPreset

                    else
                        model.currentPreset
                , askToDeletePreset = Nothing
              }
            , Cmd.none
            )

        DeletePresetResponse (Err _) ->
            ( model, Cmd.none )

        AskToDeletePreset name ->
            ( { model | askToDeletePreset = Just name }, Cmd.none )

        CancelDeletePreset ->
            ( { model | askToDeletePreset = Nothing }, Cmd.none )


applyPreset : Preset.Preset -> Model -> Model
applyPreset { key, payload } model =
    { model
        | currentPreset = Preset.saved key
        , fontSize = payload.fontSize
        , height = payload.height
        , width = payload.width
        , size = payload.size
        , backgroundColor = ColorPicker.init payload.backgroundColor
        , spaceBetween = payload.spaceBetween
        , fontFamily = payload.fontFamily
        , textColor = ColorPicker.init payload.textColor
        , fontWeight = payload.fontWeight
        , svgColor = ColorPicker.init payload.svgColor
        , textOpacity = payload.textOpacity
        , iconOpacity = payload.iconOpacity
        , padding = payload.padding
        , alignHorizontal = payload.alignHorizontal
        , alignVertical = payload.alignVertical
        , layoutDirection = payload.layoutDirection
    }


modelToPresetPayload : Model -> Preset.Payload
modelToPresetPayload model =
    { fontSize = model.fontSize
    , height = model.height
    , width = model.width
    , size = model.size
    , backgroundColor = ColorPicker.getColor model.backgroundColor
    , spaceBetween = model.spaceBetween
    , fontFamily = model.fontFamily
    , textColor = ColorPicker.getColor model.textColor
    , fontWeight = model.fontWeight
    , svgColor = ColorPicker.getColor model.svgColor
    , textOpacity = model.textOpacity
    , iconOpacity = model.iconOpacity
    , padding = model.padding
    , alignHorizontal = model.alignHorizontal
    , alignVertical = model.alignVertical
    , layoutDirection = model.layoutDirection
    }


getTextboxDimension : Cmd Msg
getTextboxDimension =
    Browser.Dom.getElement "svg-text"
        |> Task.attempt SetTextboxSize



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Badger"
    , body =
        [ H.main_ [ HA.class "h-screen", closeMenuOnClick model.menuToggled ]
            [ H.h1 [ HA.class "sr-only" ] [ H.text "Create badges" ]
            , H.div [ HA.class "h-full flex flex-col bg-gray-100 lg:grid lg:[grid-template-areas:'topbar_topbar'_'canvas_sidebar'] lg:grid-cols-[1fr_auto] lg:grid-rows-[auto_1fr]" ]
                [ vTopbar model.currentPreset
                , vCanvas model
                , vSettingsForm model
                ]
            , vSavePresetModal model.editPresetName
            , vLoadPresetModal model.showSelectPresetDialog model.askToDeletePreset model.presetList
            ]
        ]
    }


vLoadPresetModal : Bool -> Maybe String -> Maybe (List String) -> H.Html Msg
vLoadPresetModal showDialog askToDeletePreset ldItems =
    if showDialog then
        Modal.dialog loadPresetModalConfig
            [ H.header [ HA.class "mb-6" ] [ H.h2 [ HA.class "text-2xl" ] [ H.text "My presets" ] ]
            , (ldItems
                |> Maybe.map
                    (\items ->
                        case items of
                            [] ->
                                H.p [ HA.class "text-gray-600 text-sm" ] [ H.text "You haven't saved any presets yet :-/" ]

                            _ ->
                                H.ul [ HA.class "overflow-scroll max-h-[30vh]" ]
                                    (List.map (vPresetListItem askToDeletePreset) items)
                    )
              )
                |> Maybe.withDefault (H.text "")
            ]

    else
        H.text ""


vPresetListItem : Maybe String -> String -> H.Html Msg
vPresetListItem askToDeleteItem itemName =
    let
        askToDelete =
            askToDeleteItem == Just itemName
    in
    H.li [ HA.class "flex border-b gap-2 pr-4 items-center" ]
        [ H.button
            [ HE.onClick (LoadPreset itemName)
            , HA.class "flex-1 px-4 py-2 flex items-center gap-2 hover:bg-slate-50"
            ]
            [ H.span [ HA.class "fill-gray-400" ] [ UI.file 48 ]
            , H.span [ HA.class "text-gray-800 text-sm" ] [ H.text itemName ]
            ]
        , if askToDelete then
            H.div [ HA.class "flex items-center gap-3 px-4 py-3" ]
                [ H.span [] [ H.text "Delete this item?" ]
                , H.button [ Style.deleteButton, HE.onClick (DeletePreset itemName) ]
                    [ H.text "Yes"
                    ]
                , H.button [ Style.smallSecondaryButton, HE.onClick CancelDeletePreset ]
                    [ H.text "No"
                    ]
                ]

          else
            H.button [ Style.iconButton, HE.onClick (AskToDeletePreset itemName) ]
                [ UI.delete 24
                , H.span [ HA.class "sr-only" ]
                    [ H.text "Delete" ]
                ]
        ]


vTopbar : Preset.PresetState -> H.Html Msg
vTopbar currentPreset =
    H.div [ HA.class "[grid-area:topbar] min-h-[40px] p-2 bg-white drop-shadow-[2px_2px_4px_rgba(0,0,0,0.15)] px-8 z-10 grid grid-cols-[1fr_auto_1fr] text-sm text-gray-800" ]
        [ H.span [ HA.class "self-center font-bold text-gray-600" ] [ H.text "Badger" ]
        , topbarPresetName currentPreset
        , H.button [ HA.class "justify-self-end", Style.topbarButton, HE.onClick OpenPresetDialog ] [ H.text "My presets" ]
        ]


topbarPresetName : Preset.PresetState -> H.Html Msg
topbarPresetName presetState =
    presetState
        |> Preset.render
            { whenNoPreset =
                \() ->
                    H.div [ HA.class "flex gap-2" ]
                        [ H.button [ HA.class "py-2 px-4 border-b", HE.onClick EditPresetName ] [ H.text ("* " ++ "Untitled") ]
                        , H.button [ HE.onClick SavePresetSameName, Style.topbarButton ] [ H.text "Save" ]
                        ]
            , whenSaving =
                \name ->
                    H.text ("Saving: " ++ name)
            , whenSaved =
                \name didChange ->
                    let
                        viewName =
                            if didChange then
                                "* " ++ name

                            else
                                name
                    in
                    H.div [ HA.class "flex gap-2" ]
                        [ H.button [ HA.class "py-2 px-4 border-b", HE.onClick EditPresetName ] [ H.text viewName ]
                        , H.button [ HE.onClick SavePresetSameName, Style.topbarButton, HA.disabled (not didChange) ] [ H.text "Save" ]
                        ]
            , whenFailed =
                \_ ->
                    H.text ""
            }


vCanvas : Model -> H.Html Msg
vCanvas model =
    H.div [ HA.class "flex-auto p-4 relative bg-grid lg:[grid-area:canvas]" ]
        [ H.div [ HA.class "absolute top-0 bottom-0 left-0 right-0 overflow-auto flex items-center justify-center" ]
            [ H.div [] [ rSvg model ]
            ]
        , H.button
            [ HE.onClick ToggleMenu
            , HA.class "absolute right-6 top-6 lg:hidden"
            , HA.classList [ ( "hidden", model.menuToggled ) ]
            ]
            [ UI.menu 24
            , H.span [ HA.class "sr-only" ] [ H.text "Open settings menu" ]
            ]
        , H.button
            [ HE.onClick DownloadSvg
            , HA.class "absolute right-6 bottom-6 bg-indigo-700 hover:bg-indigo-800 active:scale-95 hover:scale-105 transition-all fill-white rounded-full shadow-5xl p-2"
            ]
            [ UI.download 36, H.span [ HA.class "sr-only" ] [ H.text "Download svg" ] ]
        ]


closeMenuOnClick : Bool -> H.Attribute Msg
closeMenuOnClick menuToggled =
    if menuToggled then
        HE.onClick ToggleMenu

    else
        HH.emptyAttribute


stopPropagationOnClick : Bool -> H.Attribute Msg
stopPropagationOnClick menuToggled =
    HE.stopPropagationOn "click" (JD.succeed ( NoOp, menuToggled ))


vSettingsForm : Model -> H.Html Msg
vSettingsForm model =
    H.div
        [ HA.classList [ ( "translate-x-full", not model.menuToggled ) ]
        , HA.classList [ ( "translate-x-0", model.menuToggled ) ]
        , stopPropagationOnClick model.menuToggled
        , HA.class
            "fixed right-0 top-0 bottom-0 p-4 bg-white z-20 lg:z-0 overflow-x-auto drop-shadow-[-2px_2px_5px_rgba(0,0,0,0.15)] ease-in-out transition-all duration-300 lg:relative lg:min-w-[380px] lg:inset-auto lg:block lg:transform-none lg:[grid-area:sidebar] lg:drop-shadow-[-1px_1px_2px_rgba(0,0,0,0.15)] "
        ]
        [ H.h2 [ Style.h2 ] [ H.text "Settings" ]
        , H.button
            [ HE.onClick ToggleMenu
            , HA.class "absolute right-6 top-6 lg:hidden"
            , HA.classList [ ( "hidden", not model.menuToggled ) ]
            ]
            [ UI.close 24
            , H.span [ HA.class "sr-only" ] [ H.text "Close settings menu" ]
            ]
        , vCanvasFields model
        , vTextFields model
        , vIconFields model
        , vIconInputModal model.svgInput
        ]


vTextFields : Model -> H.Html Msg
vTextFields model =
    H.section [ HA.class "bg-white py-4 mb-6 " ]
        [ H.h3 [ Style.h3, HA.class "sr-only" ] [ H.text "Text" ]
        , HF.inputField
            { id = "text-main-text"
            , label = "Text"
            , inputType = "text"
            , value = model.mainText
            , onInput = SetMainText
            }
        , HF.inputField
            { id = "text-font-size"
            , label = "Font size (px)"
            , inputType = "number"
            , value = FontSize.toValueString model.fontSize
            , onInput = SetFontSize
            }
        , HF.field
            [ H.label [ HA.for "text-font-family", Style.label ] [ H.text "Font family" ]
            , H.select [ HA.id "text-font-family", Style.dropdown, HA.class "select", HE.onInput SetFont ]
                (vFontOptions model.availableFonts model.fontFamily)
            ]
        , HF.field
            [ H.label [ HA.for "text-font-weight", Style.label ] [ H.text "Weight" ]
            , H.select [ HA.id "text-font-weight", Style.dropdown, HA.class "select", HE.onInput SetFontWeight ]
                [ H.option [ HA.value "normal", HA.selected (model.fontWeight == FontWeight.normal) ] [ H.text "Normal" ]
                , H.option [ HA.value "bold", HA.selected (model.fontWeight == FontWeight.bold) ] [ H.text "Bold" ]
                ]
            ]
        , ColorPicker.colorPicker
            { id = "text-color"
            , label = "Color"
            , onChange = SetTextColor
            , value = model.textColor
            }
        , HF.field
            [ HF.labelFor "text-opacity" "Opacity"
            , H.div [ HA.class "flex gap-3 items-center" ]
                [ H.input
                    [ HA.id "text-opacity"
                    , HA.type_ "range"
                    , HA.min "0"
                    , HA.max "100"
                    , HE.onInput SetTextOpacity
                    , HA.value (model.textOpacity |> Percentage.toValueString)
                    , HA.class "slider"
                    ]
                    []
                , H.output
                    [ HA.for "text-opacity"
                    , HA.class "w-[8ch] text-xs text-right"
                    ]
                    [ H.text (Percentage.toString model.textOpacity) ]
                ]
            ]
        , HF.field
            [ Contrast.vTextContrast (ColorPicker.getColor model.backgroundColor)
                (ColorPicker.getColor model.textColor)
                model.textOpacity
                model.fontSize
                model.fontWeight
            ]
        ]


vFontOptions : Font.FontList -> Font.Font -> List (H.Html msg)
vFontOptions fontList selectedFont =
    let
        selectedFontData =
            Font.getData selectedFont
    in
    fontList
        |> List.map Font.getData
        |> List.map
            (\{ key, name } ->
                H.option [ HA.selected (selectedFontData.key == key), HA.value key ] [ H.text name ]
            )


vIconFields : Model -> H.Html Msg
vIconFields model =
    H.section [ HA.class "bg-white py-4" ]
        (case model.confirmedSvg of
            Nothing ->
                [ H.h3 [ Style.h3, HA.class "sr-only" ] [ H.text "Icon" ]
                , H.button
                    [ HA.class "flex gap-3 items-center fill-indigo-700 text-indigo-700 hover:text-indigo-800 hover:fill-indigo-800 hover:underline"
                    , HE.onClick AddSvg
                    ]
                    [ UI.addIcon 18, H.span [ HA.class "block" ] [ H.text "Add icon" ] ]
                ]

            Just _ ->
                [ H.h3 [ Style.h3, HA.class "sr-only" ] [ H.text "Icon" ]
                , SB.fieldSet "Layout direction"
                    [ SB.optionList
                        { name = "layout_direction"
                        , options =
                            [ SB.optionIcon Layout.topToBottom "Top to bottom" UI.arrowDown
                            , SB.optionIcon Layout.leftToRight "Left to right" UI.arrowRight
                            , SB.optionIcon Layout.bottomToTop "Bottom to top" UI.arrowUp
                            , SB.optionIcon Layout.rightToLeft "Right to left" UI.arrowLeft
                            , SB.optionIcon Layout.stacked "Stacked" UI.background
                            ]
                        , selected = model.layoutDirection
                        , onSelect = SetLayoutDirection
                        }
                    ]
                , HF.field
                    [ HF.labelFor "icon-size" "Icon size"
                    , H.div [ HA.class "flex gap-3 items-center" ]
                        [ H.input
                            [ HA.id "icon-size"
                            , HA.type_ "range"
                            , HA.min "0"
                            , HA.max "100"
                            , HE.onInput SetSvgSize
                            , HA.value (model.size |> Percentage.toValueString)
                            , HA.class "slider"
                            ]
                            []
                        , H.output [ HA.for "icon-size", HA.class "w-[8ch] text-xs text-right" ] [ H.text (Percentage.toString model.size) ]
                        ]
                    ]
                , HF.inputField
                    { id = "space-between"
                    , label = "Space between"
                    , inputType = "number"
                    , value = String.fromInt model.spaceBetween
                    , onInput = SetSpaceBetween
                    }
                    |> HH.renderIf (model.layoutDirection /= Layout.stacked)
                , ColorPicker.colorPicker
                    { id = "icon-color"
                    , label = "Color"
                    , onChange = SetSvgColor
                    , value = model.svgColor
                    }
                , HF.field
                    [ HF.labelFor "icon-opacity" "Opacity"
                    , H.div [ HA.class "flex gap-3 items-center" ]
                        [ H.input
                            [ HA.id "icon-opacity"
                            , HA.type_ "range"
                            , HA.min "0"
                            , HA.max "100"
                            , HE.onInput SetIconOpacity
                            , HA.value (model.iconOpacity |> Percentage.toValueString)
                            , HA.class "slider"
                            ]
                            []
                        , H.output [ HA.for "icon-opacity", HA.class "w-[8ch] text-xs text-right" ] [ H.text (Percentage.toString model.iconOpacity) ]
                        ]
                    ]
                , HF.field
                    [ Contrast.vIconContrast
                        (ColorPicker.getColor model.backgroundColor)
                        (ColorPicker.getColor model.svgColor)
                        model.iconOpacity
                    ]
                    |> HH.renderIf (model.layoutDirection /= Layout.stacked)
                , H.button
                    [ Style.deleteButton, HA.class "flex gap-2 items-center fill-white", HE.onClick DeleteSvg ]
                    [ UI.delete 18, H.span [ HA.class "block" ] [ H.text "Remove icon" ] ]
                ]
        )


vCanvasFields : Model -> H.Html Msg
vCanvasFields model =
    H.section [ HA.class "py-4 bg-white mb-6" ]
        [ H.h3 [ Style.h3, HA.class "sr-only" ] [ H.text "Canvas" ]
        , HF.field
            [ HF.labelFor "canvas-width" "Width (px)"
            , H.input
                [ HA.id "canvas-width"
                , Style.input
                , HA.type_ "number"
                , HE.onInput SetWidth
                , HA.value (String.fromInt model.width)
                ]
                []
            ]
        , HF.field
            [ HF.labelFor "canvas-height" "Height (px)"
            , H.input
                [ HA.id "canvas-height"
                , Style.input
                , HA.type_ "number"
                , HE.onInput SetHeight
                , HA.value (String.fromInt model.height)
                ]
                []
            ]
        , HF.field
            [ HF.labelFor "canvas-padding" "Padding (px)"
            , H.input
                [ HA.id "canvas-padding"
                , Style.input
                , HA.type_ "number"
                , HE.onInput SetPadding
                , HA.value (String.fromInt model.padding)
                ]
                []
            ]
        , ColorPicker.colorPicker
            { id = "background-color"
            , label = "Background color"
            , onChange = SetBackgroundColor
            , value = model.backgroundColor
            }
        , SB.fieldSet "Vertical align"
            [ SB.optionList
                { name = "vertical_align"
                , options =
                    [ SB.optionIcon Canvas.alignStart "Top" UI.alignVerticalTop
                    , SB.optionIcon Canvas.alignCenter "Center" UI.alignVerticalCenter
                    , SB.optionIcon Canvas.alignEnd "Bottom" UI.alignVerticalBottom
                    ]
                , selected = model.alignVertical
                , onSelect = SetVerticalAlign
                }
            ]
        , SB.fieldSet "Horizontal align"
            [ SB.optionList
                { name = "horizontal_align"
                , options =
                    [ SB.optionIcon Canvas.alignStart "Left" UI.alignHorizontalLeft
                    , SB.optionIcon Canvas.alignCenter "Center" UI.alignHorizontalCenter
                    , SB.optionIcon Canvas.alignEnd "Right" UI.alignHorizontalRight
                    ]
                , selected = model.alignHorizontal
                , onSelect = SetHorizontalAlign
                }
            ]
        ]


customSvgModalConfig : Modal.DialogConfig Msg
customSvgModalConfig =
    { id = "dialog", closeDialog = ModalClicked, dialogWasClosed = IconInputWasClosed }


vIconInputModal : Maybe IconInput.Input -> H.Html Msg
vIconInputModal mbInput =
    case mbInput of
        Just input ->
            Modal.dialog customSvgModalConfig
                [ H.header [ HA.class "mb-6" ] [ H.h2 [ HA.class "text-2xl" ] [ H.text "Add custom SVG" ] ]
                , H.form [ HA.class "flex flex-col", HE.onSubmit ConfirmIconInput ]
                    [ H.div [ Style.field, HA.class "grow" ]
                        [ HF.labelFor "icon-svg-input" "Paste svg"
                        , H.textarea
                            [ HA.id "icon-svg-input"
                            , HA.value <| IconInput.getValue input
                            , HE.onInput SetIconInput
                            , Style.input
                            , HA.class "h-[30vh]"
                            ]
                            []
                        ]
                    , H.button
                        [ Style.primaryButton
                        , HA.class "self-end px-8"
                        , HA.disabled (not (IconInput.isValid input))
                        , HE.onClick ConfirmIconInput
                        ]
                        [ H.text "Save icon" ]
                    ]
                ]

        Nothing ->
            H.text ""


vSavePresetModal : Maybe String -> H.Html Msg
vSavePresetModal mbEditPresetName =
    case mbEditPresetName of
        Just name ->
            Modal.dialog savePresetModalConfig
                [ H.header [ HA.class "mb-6" ] [ H.h2 [ HA.class "text-2xl" ] [ H.text "Give your preset a name" ] ]
                , H.form [ HA.class "flex flex-col", HE.onSubmit SavePreset ]
                    [ HF.field
                        [ HF.labelFor "preset-name" "Name"
                        , H.input
                            [ Style.input
                            , HA.type_ "text"
                            , HA.value name
                            , HA.id "preset-name"
                            , HE.onInput SetPresetName
                            , HA.required True
                            ]
                            []
                        ]
                    , H.button
                        [ Style.primaryButton
                        , HA.class "self-start px-8"
                        ]
                        [ H.text "Save preset" ]
                    ]
                ]

        Nothing ->
            H.text ""



-- SVG rendering


rSvg : Model -> H.Html msg
rSvg model =
    model
        |> toCanvas
        |> Canvas.toSvg


toCanvas : Model -> Canvas.Canvas msg
toCanvas model =
    let
        canvas =
            { height = toFloat model.height, width = toFloat model.width }
                |> Canvas.newCanvas model.svgDomId (toFloat model.spaceBetween) (toFloat model.padding)

        ( layoutDirection, elements ) =
            []
                |> addTextElement model
                |> addIconElement model
                |> sortCanvasElements model.layoutDirection
    in
    elements
        |> List.foldl
            (\element cv ->
                Canvas.addElement element cv
            )
            (canvas (ColorPicker.getColor model.backgroundColor) layoutDirection)
        |> Canvas.alignItems model.alignHorizontal model.alignVertical
        |> Canvas.alignContentHorizontal model.alignHorizontal
        |> Canvas.alignContentVertical model.alignVertical


addTextElement : Model -> List (Canvas.Element msg) -> List (Canvas.Element msg)
addTextElement model elements =
    Canvas.textElement
        { fill = ColorPicker.getColor model.textColor
        , font = model.fontFamily
        , opacity = model.textOpacity
        , value = model.mainText
        , weight = model.fontWeight
        , fontSize = model.fontSize
        }
        model.textBoxSize
        :: elements


addIconElement : Model -> List (Canvas.Element msg) -> List (Canvas.Element msg)
addIconElement model elements =
    case model.confirmedSvg of
        Nothing ->
            elements

        Just iconElement ->
            let
                { svg, aspectRatio } =
                    IconInput.toSvg iconElement model.iconDomId

                iconSize =
                    { width =
                        (toFloat model.height * Percentage.toFloat_ model.size)
                            * aspectRatio
                    , height =
                        toFloat model.height * Percentage.toFloat_ model.size
                    }
            in
            Canvas.iconElement
                { fill = ColorPicker.getColor model.textColor
                , opacity = model.iconOpacity
                , domId = "#" ++ model.iconDomId
                , svg = svg
                }
                iconSize
                :: elements


sortCanvasElements : Layout.LayoutDirection -> List (Canvas.Element msg) -> ( Canvas.Direction, List (Canvas.Element msg) )
sortCanvasElements direction elements =
    direction
        |> Layout.when
            { whenBottomToTop = \() -> ( Canvas.layoutVertical, List.reverse elements )
            , whenRightToLeft = \() -> ( Canvas.layoutHorizontal, List.reverse elements )
            , whenTopToBottom = \() -> ( Canvas.layoutVertical, elements )
            , whenLeftToRight = \() -> ( Canvas.layoutHorizontal, elements )
            , whenStacked = \() -> ( Canvas.layoutStacked, elements )
            }
