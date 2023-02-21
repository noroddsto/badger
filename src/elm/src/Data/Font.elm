module Data.Font exposing (Font, FontData, FontList, availableFonts, default, getData, getFont, getName, heightInsideEmBox)


type Font
    = Font String String Float


type alias FontData =
    { key : String, name : String, emSize : Float }


type alias FontList =
    List Font


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


getFont : String -> FontList -> Maybe Font
getFont searchKey fontList =
    fontList
        |> List.filter
            (\(Font key _ _) ->
                key == searchKey
            )
        |> List.head


getName : Font -> String
getName (Font _ name _) =
    name


heightInsideEmBox : Font -> Float
heightInsideEmBox (Font _ _ emSize) =
    emSize
