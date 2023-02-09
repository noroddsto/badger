module Data.Percentage exposing (Percentage, fromInt, toDecimals, toInt, toString, toValueString)


type Percentage
    = Pct Int


fromInt : Int -> Percentage
fromInt value =
    if value < 0 then
        Pct 0

    else if value > 100 then
        Pct 100

    else
        Pct value


toValueString : Percentage -> String
toValueString (Pct val) =
    String.fromInt val


toString : Percentage -> String
toString (Pct val) =
    String.fromInt val ++ " %"


toInt : Percentage -> Int
toInt (Pct size) =
    size


toDecimals : Percentage -> Float
toDecimals (Pct size) =
    toFloat size / 100
