module Data.Font exposing (Font, FontData, FontList, availableFonts, default, getData, getFont, getName)


type Font
    = Font String String


type alias FontData =
    { key : String, name : String }


type alias FontList =
    List Font


default : Font
default =
    Font "arial" "Arial"


availableFonts : FontList
availableFonts =
    [ default
    , Font "arialblack" "Arial Black"
    , Font "veranda" "Veranda"
    , Font "tahoma" "Tahoma"
    , Font "trebuchetms" "Trebuchet MS"
    , Font "timesnewroman" "Times New Roman"
    , Font "georgia" "Georgia"
    , Font "garamond" "Garamond"
    , Font "couriernew" "Courier New"
    , Font "brushscriptmt" "Brush Script MT"
    ]
        |> List.sortBy (\(Font _ v) -> v)


getData : Font -> FontData
getData (Font key value) =
    FontData key value


getFont : String -> FontList -> Maybe Font
getFont searchKey fontList =
    fontList
        |> List.filter
            (\(Font key _) ->
                key == searchKey
            )
        |> List.head


getName : Font -> String
getName (Font _ name) =
    name
