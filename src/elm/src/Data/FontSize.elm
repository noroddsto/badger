module Data.FontSize exposing (FontSize, toInt, toPx, toValueString)


type FontSize
    = Px Int


toPx : Int -> FontSize
toPx size =
    Px size


toValueString : FontSize -> String
toValueString (Px size) =
    String.fromInt size


toInt : FontSize -> Int
toInt (Px size) =
    size
