module App exposing (..)

import Browser
import Browser.Dom
import Component.Modal as Modal
import Data.Canvas as Canvas
import Data.Color as Color
import Data.Font as Font
import Data.FontSize as FontSize
import Data.FontWeight as FontWeight
import Data.Percentage as Percentage
import Helper.ColorPicker as ColorPicker
import Helper.Contrast as Contrast
import Helper.Form as HF
import Helper.SegmentButton as SB
import Helper.Style as Style
import Helper.SvgInput as IconInput
import Helper.Update exposing (noCmd, parseInt, withCmd)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Icon.UI as UI
import Ports
import Random
import Random.Char
import Random.String
import SvgParser
import Task



-- INIT


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init () =
    ( { size = Percentage.fromInt 25
      , svgInput = Nothing
      , confirmedSvg = Nothing
      , svgColor = ColorPicker.init Color.black
      , textBoxSize = { width = 0, height = 0 }
      , width = 200
      , height = 100
      , backgroundColor = ColorPicker.init Color.white
      , layoutDirection = TopToBottom
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


type LayoutDirection
    = TopToBottom
    | BottomToTop
    | LeftToRight
    | RightToLeft


type VerticalAlign
    = Vcenter


type alias Model =
    { width : Int
    , height : Int
    , backgroundColor : ColorPicker.ColorInput
    , layoutDirection : LayoutDirection
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
    }



-- UPDATE


type Msg
    = NoOp
    | SetWidth String
    | SetHeight String
    | SetSpaceBetween String
    | SetLayoutDirection LayoutDirection
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


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetWidth newValue ->
            { model | width = parseInt newValue }
                |> noCmd

        SetHeight newValue ->
            { model | height = parseInt newValue }
                |> noCmd

        SetSpaceBetween newValue ->
            { model | spaceBetween = parseInt newValue }
                |> noCmd

        SetLayoutDirection newValue ->
            { model | layoutDirection = newValue }
                |> noCmd

        SetMainText newValue ->
            { model | mainText = newValue }
                |> withCmd getTextboxDimension

        SetFontSize newValue ->
            { model | fontSize = FontSize.toPx << parseInt <| newValue }
                |> withCmd getTextboxDimension

        SetFontWeight value ->
            { model | fontWeight = FontWeight.fromString value |> Maybe.withDefault model.fontWeight }
                |> noCmd

        SetSvgSize newValue ->
            { model
                | size =
                    Percentage.fromInt
                        (newValue
                            |> String.toInt
                            |> Maybe.withDefault 0
                        )
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
                        { model | confirmedSvg = Just element, svgInput = Nothing }
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
            }
                |> noCmd

        DownloadSvg ->
            ( model, Ports.downloadSvg { domId = model.svgDomId, fileName = "Result" } )

        ToggleMenu ->
            ( { model | menuToggled = not model.menuToggled }, Cmd.none )

        SetBackgroundColor color ->
            ( { model | backgroundColor = color }, Cmd.none )

        SetSvgColor color ->
            ( { model | svgColor = color }, Cmd.none )

        SetTextColor color ->
            ( { model | textColor = color }, Cmd.none )

        SetIconDomId newId ->
            ( { model | iconDomId = "icon-" ++ newId }, Cmd.none )

        SetSvgDomId newId ->
            ( { model | svgDomId = "svg-" ++ newId }, Cmd.none )

        SetHorizontalAlign align ->
            ( { model | alignHorizontal = align }, Cmd.none )

        SetVerticalAlign align ->
            ( { model | alignVertical = align }, Cmd.none )


getTextboxDimension : Cmd Msg
getTextboxDimension =
    Browser.Dom.getElement "svg-text"
        |> Task.attempt SetTextboxSize



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Badger"
    , body =
        [ H.main_ [ HA.class "h-screen" ]
            [ H.h1 [ HA.class "sr-only" ] [ H.text "Create badges" ]
            , H.div [ HA.class "h-full flex bg-gray-100" ]
                [ H.div [ HA.class "flex-auto p-4 relative bg-grid" ]
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
                        , HA.class "absolute right-6 bottom-6 bg-blue-700 hover:bg-blue-800 active:scale-95 hover:scale-105 transition-all fill-white rounded-full shadow-5xl p-2"
                        ]
                        [ UI.download 36, H.span [ HA.class "sr-only" ] [ H.text "Download svg" ] ]
                    ]
                , vSettingsForm model
                ]
            ]
        ]
    }


vSettingsForm : Model -> H.Html Msg
vSettingsForm model =
    H.div
        [ HA.classList [ ( "translate-x-full", not model.menuToggled ) ]
        , HA.classList [ ( "translate-x-0", model.menuToggled ) ]
        , HA.class
            "fixed right-0 top-0 bottom-0 p-4 bg-white overflow-x-auto drop-shadow-[-2px_-2px_5px_rgba(0,0,0,0.15)] lg:relative lg:min-w-[380px] lg:inset-auto lg:flex-shrink-0 lg:block ease-in-out transition-all duration-300 lg:transform-none"
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
                    [ HA.class "flex gap-3 items-center fill-blue-700 text-blue-700 hover:text-blue-800 hover:fill-blue-800 hover:underline"
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
                            [ SB.optionIcon TopToBottom "Top to bottom" UI.arrowDown
                            , SB.optionIcon LeftToRight "Left to right" UI.arrowRight
                            , SB.optionIcon BottomToTop "Bottom to top" UI.arrowUp
                            , SB.optionIcon RightToLeft "Right to left" UI.arrowLeft
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
                , H.form [ HA.class "flex flex-col h-full", HE.onSubmit ConfirmIconInput ]
                    [ H.div [ Style.field, HA.class "grow" ]
                        [ HF.labelFor "icon-svg-input" "Paste svg"
                        , H.textarea [ HA.id "icon-svg-input", HA.value <| IconInput.getValue input, HE.onInput SetIconInput, Style.input, HA.class "grow" ] []
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
                |> Canvas.newCanvas model.svgDomId (toFloat model.spaceBetween)

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


sortCanvasElements : LayoutDirection -> List (Canvas.Element msg) -> ( Canvas.Direction, List (Canvas.Element msg) )
sortCanvasElements direction elements =
    case direction of
        BottomToTop ->
            ( Canvas.layoutVertical, List.reverse elements )

        RightToLeft ->
            ( Canvas.layoutHorizontal, List.reverse elements )

        TopToBottom ->
            ( Canvas.layoutVertical, elements )

        LeftToRight ->
            ( Canvas.layoutHorizontal, elements )
