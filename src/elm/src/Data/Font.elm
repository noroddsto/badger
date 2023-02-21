module Data.Font exposing (Font, FontData, FontList, availableFonts, default, getCapHeight, getData, getFont, getName)

import Svg.Attributes exposing (capHeight)


type Font
    = Font String String Float


type alias FontData =
    { key : String, name : String, capHeight : Float }


type alias FontList =
    List Font


{-| The default font
-}
default : Font
default =
    Font "arial" "Arial" 0.64


availableFonts : FontList
availableFonts =
    [ default
    , Font "arialblack" "Arial Black" 0.49
    , Font "veranda" "Veranda" 0.75
    , Font "tahoma" "Tahoma" 0.6
    , Font "trebuchetms" "Trebuchet MS" 0.67
    , Font "timesnewroman" "Times New Roman" 0.87
    , Font "georgia" "Georgia" 0.8
    , Font "garamond" "Garamond" 0.57
    , Font "couriernew" "Courier New" 0.5
    , Font "brushscriptmt" "Brush Script MT" 0.5
    ]
        |> List.sortBy (\(Font _ v _) -> v)


getData : Font -> FontData
getData (Font key value emSize) =
    FontData key value emSize


{-| Gets font from fontlist by name

    getFont "arial" [ Font "arial" "Arial" 0.64 ] == Font "arial" "Arial" 0.64

-}
getFont : String -> FontList -> Maybe Font
getFont searchKey fontList =
    fontList
        |> List.filter
            (\(Font key _ _) ->
                key == searchKey
            )
        |> List.head


{-| Get name from font

    getName (Font "arial" "Arial" 0.64) == "Arial"

-}
getName : Font -> String
getName (Font _ name _) =
    name


{-| Get cap height from font.

    getName (Font "arial" "Arial" 0.64) == 0.64

-}
getCapHeight : Font -> Float
getCapHeight (Font _ _ capHeight) =
    capHeight
