module App exposing (..)

import Browser
import Browser.Dom
import Component.Modal as Modal
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
import Helper.Svg
import Helper.SvgInput as IconInput
import Helper.Update exposing (noCmd, parseInt, withCmd)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Icon.UI as UI
import Ports
import Svg
import Svg.Attributes as SA
import SvgParser
import Task
import VirtualDom



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
      }
    , getTextboxDimension
    )


type alias ElementSize =
    { height : Float, width : Float }



-- MODEL


type LayoutDirection
    = TopToBottom
    | BottomToTop
    | LeftToRight
    | RightToLeft


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
    | SetFontWeight FontWeight.FontWeight
    | SetTextboxSize (Result Browser.Dom.Error Browser.Dom.Element)
    | SetFont String
    | SetTextOpacity String
    | SetIconOpacity String
    | DownloadSvg
    | ToggleMenu


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

        SetFontWeight newWeight ->
            { model | fontWeight = newWeight }
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
            ( model, Ports.downloadSvg { domId = "generated-svg", fileName = "Result" } )

        ToggleMenu ->
            ( { model | menuToggled = not model.menuToggled }, Cmd.none )

        SetBackgroundColor color ->
            ( { model | backgroundColor = color }, Cmd.none )

        SetSvgColor color ->
            ( { model | svgColor = color }, Cmd.none )

        SetTextColor color ->
            ( { model | textColor = color }, Cmd.none )


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
        [ H.h2 [ Style.h2, HA.class "sr-only" ] [ H.text "Settings" ]
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
    H.section [ HA.class "bg-white p-4 mb-6 " ]
        [ H.h3 [ Style.h3 ] [ H.text "Text settings" ]
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
        , SB.fieldSet "Font weight"
            [ SB.optionList
                { name = "font-weight"
                , options =
                    [ SB.option FontWeight.normal "Normal"
                    , SB.option FontWeight.bold "Bold"
                    ]
                , selected = model.fontWeight
                , onSelect = SetFontWeight
                }
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
    H.section [ HA.class "bg-white p-4" ]
        (case model.confirmedSvg of
            Nothing ->
                [ H.h3 [ Style.h3 ] [ H.text "Icon settings" ]
                , H.button
                    [ HA.class "flex gap-3 items-center fill-blue-700 text-blue-700 hover:text-blue-800 hover:fill-blue-800 hover:underline"
                    , HE.onClick AddSvg
                    ]
                    [ UI.addIcon 18, H.span [ HA.class "block" ] [ H.text "Add icon" ] ]
                ]

            Just _ ->
                [ H.h3 [ Style.h3 ] [ H.text "Icon settings" ]
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
    H.section [ HA.class "p-4 bg-white mb-6" ]
        [ H.h3 [ Style.h3 ] [ H.text "Canvas settings" ]
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
    case model.confirmedSvg of
        Just svgElement ->
            rSvgTextAndIcon
                { width = model.width
                , height = model.height
                , backgroundColor = model.backgroundColor |> ColorPicker.getColor
                , layoutDirection = model.layoutDirection
                , spaceBetween = model.spaceBetween
                , fontFamily = model.fontFamily
                , fontSize = model.fontSize
                , mainText = model.mainText
                , textColor = model.textColor |> ColorPicker.getColor
                , fontWeight = model.fontWeight
                , size = model.size
                , confirmedSvg = svgElement
                , svgColor = model.svgColor |> ColorPicker.getColor
                , textBoxSize = model.textBoxSize
                , textOpacity = model.textOpacity
                , iconOpacity = model.iconOpacity
                }

        Nothing ->
            rSvgTextOnly
                { width = model.width
                , height = model.height
                , backgroundColor = model.backgroundColor |> ColorPicker.getColor
                , fontFamily = model.fontFamily
                , fontSize = model.fontSize
                , mainText = model.mainText
                , textColor = model.textColor |> ColorPicker.getColor
                , fontWeight = model.fontWeight
                , textBoxSize = model.textBoxSize
                , textOpacity = model.textOpacity
                }


type alias SvgTextAndIconConfig =
    { width : Int
    , height : Int
    , backgroundColor : Color.Hex
    , layoutDirection : LayoutDirection
    , spaceBetween : Int
    , fontFamily : Font.Font
    , fontSize : FontSize.FontSize
    , mainText : String
    , textColor : Color.Hex
    , fontWeight : FontWeight.FontWeight
    , size : Percentage.Percentage
    , confirmedSvg : SvgParser.Element
    , svgColor : Color.Hex
    , textBoxSize : ElementSize
    , textOpacity : Percentage.Percentage
    , iconOpacity : Percentage.Percentage
    }


rSvgTextOnly : SvgTextOnlyConfig -> H.Html msg
rSvgTextOnly model =
    let
        textPosition =
            { x = toFloat model.width / 2
            , y = toFloat model.height / 2
            , dominantBaseline = "middle"
            , textAnchor = "middle"
            }
    in
    rSvgBody model.width
        model.height
        model.backgroundColor
        [ rText model.mainText model.fontFamily model.fontWeight model.fontSize model.textColor model.textOpacity textPosition
        ]


rSvgTextAndIcon : SvgTextAndIconConfig -> H.Html msg
rSvgTextAndIcon model =
    let
        canvas =
            { width = toFloat model.width, height = toFloat model.height }

        iconOutput =
            IconInput.toSvg model.confirmedSvg

        iconSize =
            calculateIconSize canvas model.size iconOutput.aspectRatio

        { iconPosition, textPosition } =
            calculateTextAndIconPositions model.layoutDirection canvas iconSize model.textBoxSize model.spaceBetween
    in
    rSvgBody model.width
        model.height
        model.backgroundColor
        [ Svg.defs []
            [ iconOutput.svg
            ]
        , Svg.use
            [ VirtualDom.attribute "href" "#icon"
            , SA.width (String.fromFloat iconSize.width)
            , SA.height (String.fromFloat iconSize.height)
            , SA.x (String.fromFloat iconPosition.x)
            , SA.y (String.fromFloat iconPosition.y)
            , SA.fill (model.svgColor |> Color.toHexString)
            , SA.opacity (String.fromFloat <| Percentage.toDecimals model.iconOpacity)
            ]
            []
        , rText model.mainText model.fontFamily model.fontWeight model.fontSize model.textColor model.textOpacity textPosition
        ]


type alias SvgTextOnlyConfig =
    { width : Int
    , height : Int
    , backgroundColor : Color.Hex
    , fontFamily : Font.Font
    , fontSize : FontSize.FontSize
    , mainText : String
    , textColor : Color.Hex
    , fontWeight : FontWeight.FontWeight
    , textBoxSize : ElementSize
    , textOpacity : Percentage.Percentage
    }


rSvgBody : Int -> Int -> Color.Hex -> List (Svg.Svg msg) -> Svg.Svg msg
rSvgBody width height bgColor content =
    Svg.svg
        [ SA.width (String.fromInt width)
        , SA.height (String.fromInt height)
        , VirtualDom.attribute "xmlns" "http://www.w3.org/2000/svg"
        , Helper.Svg.viewBox width height
        , SA.id "generated-svg"
        , VirtualDom.attribute "aria-label" "Result of calculation. This image can be downloaded."
        ]
        (Svg.rect
            [ SA.width (String.fromInt width)
            , SA.height (String.fromInt height)
            , SA.fill (Color.toHexString bgColor)
            ]
            []
            :: content
        )


rText : String -> Font.Font -> FontWeight.FontWeight -> FontSize.FontSize -> Color.Hex -> Percentage.Percentage -> TextPosition -> Svg.Svg msg
rText value font fontWeight fontSize color opacity textPosition =
    Svg.text_
        [ SA.fontWeight (FontWeight.toString fontWeight)
        , SA.id "svg-text"
        , SA.dominantBaseline textPosition.dominantBaseline
        , SA.textAnchor textPosition.textAnchor
        , SA.fontSize (FontSize.toValueString fontSize)
        , SA.x (String.fromFloat textPosition.x)
        , SA.y (String.fromFloat textPosition.y)
        , SA.fill (Color.toHexString color)
        , SA.fontFamily (font |> Font.getName)
        , SA.fillOpacity (String.fromFloat <| Percentage.toDecimals opacity)
        ]
        [ Svg.text value ]


type alias IconPosition =
    { x : Float, y : Float }


type alias TextPosition =
    { x : Float, y : Float, dominantBaseline : String, textAnchor : String }


calculateTextAndIconPositions : LayoutDirection -> ElementSize -> ElementSize -> ElementSize -> Int -> { iconPosition : IconPosition, textPosition : TextPosition }
calculateTextAndIconPositions layoutDirection canvas icon text spacing =
    case layoutDirection of
        TopToBottom ->
            let
                totalHeight =
                    icon.height + text.height + toFloat spacing

                iconY =
                    (canvas.height - totalHeight) / 2

                iconX =
                    (canvas.width - icon.width) / 2

                textY =
                    iconY + icon.height + toFloat spacing

                textX =
                    canvas.width / 2
            in
            { iconPosition = { x = iconX, y = iconY }, textPosition = { x = textX, y = textY, dominantBaseline = "hanging", textAnchor = "middle" } }

        BottomToTop ->
            let
                totalHeight =
                    icon.height + text.height + toFloat spacing

                textY =
                    (canvas.height - totalHeight) / 2

                textX =
                    canvas.width / 2

                iconX =
                    (canvas.width - icon.width) / 2

                iconY =
                    textY + text.height + toFloat spacing
            in
            { iconPosition = { x = iconX, y = iconY }, textPosition = { x = textX, y = textY, dominantBaseline = "hanging", textAnchor = "middle" } }

        LeftToRight ->
            let
                totalWidth =
                    icon.width + text.width + toFloat spacing

                iconX =
                    (canvas.width - totalWidth) / 2

                iconY =
                    (canvas.height - icon.height) / 2

                textX =
                    (iconX + toFloat spacing) + icon.width

                textY =
                    canvas.height / 2
            in
            { iconPosition = { x = iconX, y = iconY }, textPosition = { x = textX, y = textY, dominantBaseline = "middle", textAnchor = "start" } }

        RightToLeft ->
            let
                totalWidth =
                    icon.width + text.width + toFloat spacing

                textX =
                    ((canvas.width - totalWidth) / 2) + text.width

                iconX =
                    textX + toFloat spacing

                iconY =
                    (canvas.height - icon.height) / 2

                textY =
                    canvas.height / 2
            in
            { iconPosition = { x = iconX, y = iconY }, textPosition = { x = textX, y = textY, dominantBaseline = "middle", textAnchor = "end" } }


calculateIconSize : ElementSize -> Percentage.Percentage -> Float -> ElementSize
calculateIconSize canvas iconSizePct aspectRatio =
    { width =
        (canvas.height * (toFloat (Percentage.toInt iconSizePct) / 100.0))
            * aspectRatio
    , height =
        canvas.height * (toFloat (Percentage.toInt iconSizePct) / 100.0)
    }
