module Helper.Contrast exposing (ContrastResult, vIconContrast, vTextContrast)

import Data.Color as Color
import Data.FontSize as FontSize
import Data.FontWeight as FontWeight
import Data.Percentage as Percentage
import Helper.Style as Style
import Html as H
import Html.Attributes as HA
import Icon.UI as Icon


minimumContrastLevel : { aa : { largeText : Float, smallText : Float }, aaa : { largeText : Float, smallText : Float } }
minimumContrastLevel =
    { aa = { largeText = 3.0, smallText = 4.5 }
    , aaa = { largeText = 4.5, smallText = 7.0 }
    }


type alias Opacity =
    Percentage.Percentage


type alias ContrastResult =
    { requirement : String, result : Bool }


checkContrast : Color.Hex -> Color.Hex -> Opacity -> Result String Float
checkContrast backgroundColor foregroundColor foregroundOpacity =
    Maybe.map2
        (\c1 c2 ->
            Color.contrast c1 (Color.transparentColorToRgb c1 c2 foregroundOpacity)
        )
        (Color.toRgb backgroundColor)
        (Color.toRgb foregroundColor)
        |> Result.fromMaybe "Unable to convert HEX to RGB"


checkTextContrast : Color.Hex -> Color.Hex -> Percentage.Percentage -> FontSize.FontSize -> FontWeight.FontWeight -> Result String (List ContrastResult)
checkTextContrast backgroundColor textColor textOpacity fontSize fontWeight =
    checkContrast backgroundColor textColor textOpacity
        |> Result.map
            (\contrast ->
                let
                    fontSizeInPx =
                        FontSize.toInt fontSize

                    isBold =
                        FontWeight.isBold fontWeight

                    textIsConsideredLarge =
                        fontSizeInPx >= 18 || (fontSizeInPx >= 14 && isBold)

                    ( aa, aaa ) =
                        if textIsConsideredLarge then
                            ( minimumContrastLevel.aa.largeText, minimumContrastLevel.aaa.largeText )

                        else
                            ( minimumContrastLevel.aa.smallText, minimumContrastLevel.aaa.smallText )
                in
                [ ContrastResult "AA" (contrast > aa)
                , ContrastResult "AAA" (contrast > aaa)
                ]
            )


checkIconContrast : Color.Hex -> Color.Hex -> Percentage.Percentage -> Result String (List ContrastResult)
checkIconContrast backgroundColor iconColor iconOpacity =
    checkContrast backgroundColor iconColor iconOpacity
        |> Result.map
            (\contrast ->
                [ ContrastResult "AA" (contrast > minimumContrastLevel.aa.smallText)
                ]
            )


vTextContrast : Color.Hex -> Color.Hex -> Percentage.Percentage -> FontSize.FontSize -> FontWeight.FontWeight -> H.Html msg
vTextContrast backgroundColor textColor textOpacity fontSize fontWeight =
    checkTextContrast backgroundColor textColor textOpacity fontSize fontWeight
        |> Result.map vTestResult
        |> Result.withDefault (H.text "")


vIconContrast : Color.Hex -> Color.Hex -> Percentage.Percentage -> H.Html msg
vIconContrast backgroundColor iconColor iconOpacity =
    checkIconContrast backgroundColor iconColor iconOpacity
        |> Result.map vTestResult
        |> Result.withDefault (H.text "")


vTestResult : List ContrastResult -> H.Html msg
vTestResult items =
    H.div []
        [ H.span [ Style.label ]
            [ H.text "Contrast level" ]
        , H.div
            [ HA.class "flex gap-4 rounded py-2" ]
            (items |> List.map vTestResultItem)
        ]


vTestResultItem : ContrastResult -> H.Html msg
vTestResultItem { requirement, result } =
    H.div [ HA.class "flex gap-2 items-center  text-slate-800 border-slate-200 border rounded px-2" ]
        [ H.span [ HA.class "block text-sm" ] [ H.text requirement ]
        , vTestIcon result
        ]


vTestIcon : Bool -> H.Html msg
vTestIcon testPassed =
    if testPassed then
        H.div []
            [ H.span [ HA.class "fill-green-700" ] [ Icon.check 36 ]
            , H.span [ HA.class "sr-only" ] [ H.text "Passed" ]
            ]

    else
        H.div []
            [ H.span [ HA.class "fill-red-700" ] [ Icon.close 36 ]
            , H.span [ HA.class "sr-only" ] [ H.text "Failed" ]
            ]
