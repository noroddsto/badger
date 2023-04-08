module Data.Percentage exposing (Percentage, fromInt, percentageDecoder, percentageEncoder, toFloat_, toString, toValueString)

import Json.Decode as JD
import Json.Encode as JE


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


toFloat_ : Percentage -> Float
toFloat_ (Pct size) =
    toFloat size / 100


percentageDecoder : JD.Decoder Percentage
percentageDecoder =
    JD.int |> JD.map fromInt


percentageEncoder : Percentage -> JE.Value
percentageEncoder (Pct pct) =
    JE.int pct
