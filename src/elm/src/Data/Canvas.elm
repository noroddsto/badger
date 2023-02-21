module Data.Canvas exposing
    ( Canvas
    , Direction
    , Element
    , IconPresentation
    , Size
    , TextPresentation
    , addElement
    , alignCenter
    , alignContentHorizontal
    , alignContentVertical
    , alignEnd
    , alignItems
    , alignStart
    , iconElement
    , layoutHorizontal
    , layoutVertical
    , newCanvas
    , textElement
    , toSvg
    )

import Data.Color as Color
import Data.Font as Font
import Data.FontSize as FontSize
import Data.FontWeight as FontWeight
import Data.Percentage as Percentage
import Helper.Svg
import Svg
import Svg.Attributes as SA
import VirtualDom


type Direction
    = Vertical
    | Horizontal


layoutVertical : Direction
layoutVertical =
    Vertical


layoutHorizontal : Direction
layoutHorizontal =
    Horizontal


type Align
    = Start
    | Center
    | End


alignStart : Align
alignStart =
    Start


alignCenter : Align
alignCenter =
    Center


alignEnd : Align
alignEnd =
    End


type alias Size =
    { height : Float, width : Float }


type alias Position =
    { x : Float, y : Float }


type Element msg
    = Text Size Position TextPresentation
    | Icon Size Position (IconPresentation msg)


type alias IconPresentation msg =
    { fill : Color.Hex
    , opacity : Percentage.Percentage
    , domId : String
    , svg : Svg.Svg msg
    }


type alias TextPresentation =
    { fill : Color.Hex
    , font : Font.Font
    , opacity : Percentage.Percentage
    , value : String
    , weight : FontWeight.FontWeight
    , fontSize : FontSize.FontSize
    }


type alias Canvas msg =
    { elements : List (Element msg)
    , spacing : Float
    , canvas : Size
    , backgroundColor : Color.Hex
    , direction : Direction
    }


newCanvas : Float -> Size -> Color.Hex -> Direction -> Canvas msg
newCanvas =
    Canvas []


newSize : Size
newSize =
    Size 0 0


updatePosition : (Size -> Position -> Position) -> Element msg -> Element msg
updatePosition updPos element =
    case element of
        Text size pos value ->
            Text size (updPos size pos) value

        Icon size pos value ->
            Icon size (updPos size pos) value


getSize : Element msg -> Size
getSize element =
    case element of
        Text size _ _ ->
            size

        Icon size _ _ ->
            size


getContentSize : Canvas msg -> Size
getContentSize { elements, direction, spacing } =
    elements
        |> List.indexedMap (\index item -> ( index, item ))
        |> List.foldl
            (\( index, element ) size ->
                let
                    elementSize =
                        getSize element

                    addSpacing =
                        if index > 0 then
                            spacing

                        else
                            0
                in
                case direction of
                    Vertical ->
                        { size
                            | width = max elementSize.width size.width
                            , height = elementSize.height + addSpacing + size.height
                        }

                    Horizontal ->
                        { size
                            | height = max elementSize.height size.height
                            , width = elementSize.width + addSpacing + size.width
                        }
            )
            newSize


addElement : Element msg -> Canvas msg -> Canvas msg
addElement element canvas =
    let
        contentSize =
            getContentSize canvas

        spacing =
            if List.length canvas.elements > 0 then
                canvas.spacing

            else
                0

        updElement =
            element
                |> updatePosition
                    (\_ { x, y } ->
                        case canvas.direction of
                            Vertical ->
                                { x = x, y = contentSize.height + spacing + y }

                            Horizontal ->
                                { x = contentSize.width + spacing + x, y = y }
                    )
    in
    { canvas | elements = canvas.elements ++ [ updElement ] }


textElement : TextPresentation -> Size -> Element msg
textElement attrs textBoxSize =
    let
        fontOffsetY =
            Font.getCapHeight attrs.font * textBoxSize.height
    in
    Text { textBoxSize | height = fontOffsetY } { x = 0, y = fontOffsetY } attrs


iconElement : IconPresentation msg -> Size -> Element msg
iconElement attrs iconSize =
    Icon iconSize { x = 0, y = 0 } attrs


alignItems : Align -> Canvas msg -> Canvas msg
alignItems alignment canvas =
    let
        content =
            getContentSize canvas
    in
    case canvas.direction of
        Vertical ->
            case alignment of
                Start ->
                    canvas

                Center ->
                    { canvas
                        | elements =
                            canvas.elements
                                |> List.map
                                    (\element ->
                                        element
                                            |> updatePosition
                                                (\size pos ->
                                                    { pos
                                                        | x = pos.x + (content.width / 2) - (size.width / 2)
                                                    }
                                                )
                                    )
                    }

                End ->
                    { canvas
                        | elements =
                            canvas.elements
                                |> List.map
                                    (\element ->
                                        element
                                            |> updatePosition
                                                (\size pos ->
                                                    { pos
                                                        | x = pos.x + content.width - size.width
                                                    }
                                                )
                                    )
                    }

        Horizontal ->
            case alignment of
                Start ->
                    canvas

                Center ->
                    canvas
                        |> updateElementsPosition
                            (\size pos ->
                                { pos
                                    | y = pos.y + (content.height / 2) - (size.height / 2)
                                }
                            )

                End ->
                    canvas
                        |> updateElementsPosition
                            (\size pos ->
                                { pos
                                    | y = pos.y + content.height - size.height
                                }
                            )


updateElementsPosition : (Size -> Position -> Position) -> Canvas msg -> Canvas msg
updateElementsPosition updFn canvas =
    { canvas
        | elements =
            canvas.elements
                |> List.map
                    (\element ->
                        element
                            |> updatePosition updFn
                    )
    }


alignContentVertical : Align -> Canvas msg -> Canvas msg
alignContentVertical alignment canvas =
    let
        content =
            getContentSize canvas
    in
    case alignment of
        Start ->
            canvas

        Center ->
            let
                offsetY =
                    canvas.canvas.height
                        / 2
                        - (content.height / 2)
            in
            canvas
                |> updateElementsPosition
                    (\_ pos ->
                        { pos
                            | y = pos.y + offsetY
                        }
                    )

        End ->
            let
                offsetY =
                    canvas.canvas.height - content.height
            in
            canvas
                |> updateElementsPosition
                    (\_ pos ->
                        { pos
                            | y = pos.y + offsetY
                        }
                    )


alignContentHorizontal : Align -> Canvas msg -> Canvas msg
alignContentHorizontal alignment canvas =
    let
        content =
            getContentSize canvas
    in
    case alignment of
        Start ->
            canvas

        Center ->
            let
                offsetX =
                    (canvas.canvas.width - content.width) / 2
            in
            canvas
                |> updateElementsPosition
                    (\_ pos ->
                        { pos
                            | x = pos.x + offsetX
                        }
                    )

        End ->
            let
                offsetX =
                    canvas.canvas.width - content.width
            in
            canvas
                |> updateElementsPosition
                    (\_ pos ->
                        { pos
                            | x = pos.x + offsetX
                        }
                    )



{-
   newCanvas Vertical 10.0
   |> addIcon
   |> addText
   |> alignItems Center
   |> alignContentHorizontal Center
   |> alignContentVertical Center
-}


toSvg : Canvas msg -> Svg.Svg msg
toSvg canvas =
    let
        width =
            floor canvas.canvas.width

        height =
            floor canvas.canvas.height
    in
    Svg.svg
        [ SA.width (String.fromInt width)
        , SA.height (String.fromInt height)
        , VirtualDom.attribute "xmlns" "http://www.w3.org/2000/svg"
        , VirtualDom.attribute "xmlns:xlink" "http://www.w3.org/1999/xlink"
        , Helper.Svg.viewBox width height
        , SA.id "generated-svg"
        , VirtualDom.attribute "aria-label" "User generated svg image"
        , SA.version "1.1"
        ]
        [ defs canvas
        , Svg.rect
            [ SA.width (String.fromInt width)
            , SA.height (String.fromInt height)
            , SA.fill (Color.toHexString canvas.backgroundColor)
            ]
            []
        , Svg.g [] (List.map renderElement canvas.elements)
        ]


renderElement : Element msg -> Svg.Svg msg
renderElement element =
    case element of
        Icon size position attrs ->
            Svg.use
                [ VirtualDom.attribute "href" attrs.domId
                , VirtualDom.attribute "xlink:href" attrs.domId
                , SA.width (String.fromFloat size.width)
                , SA.height (String.fromFloat size.height)
                , SA.x (String.fromFloat position.x)
                , SA.y (String.fromFloat position.y)
                , SA.fill (attrs.fill |> Color.toHexString)
                , SA.opacity (String.fromFloat <| Percentage.toDecimals attrs.opacity)
                ]
                []

        Text _ position attrs ->
            Svg.text_
                [ SA.fontWeight (FontWeight.toString attrs.weight)
                , SA.id "svg-text"
                , SA.fontSize (FontSize.toValueString attrs.fontSize)
                , SA.x (String.fromFloat position.x)
                , SA.y (String.fromFloat position.y)
                , SA.fill (Color.toHexString attrs.fill)
                , SA.fontFamily (Font.getName attrs.font)
                , SA.fillOpacity (attrs.opacity |> Percentage.toDecimals |> String.fromFloat)
                ]
                [ Svg.text attrs.value ]


defs : Canvas msg -> Svg.Svg msg
defs canvas =
    canvas.elements
        |> List.filterMap
            (\element ->
                case element of
                    Icon _ _ { svg } ->
                        Just svg

                    _ ->
                        Nothing
            )
        |> Svg.defs []
