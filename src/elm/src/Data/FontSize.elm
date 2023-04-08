module Data.FontSize exposing (FontSize, fontSizeDecoder, fontSizeEncoder, toInt, toPx, toValueString)

import Json.Decode as JD
import Json.Encode as JE


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


fontSizeDecoder : JD.Decoder FontSize
fontSizeDecoder =
    JD.int |> JD.map toPx


fontSizeEncoder : FontSize -> JE.Value
fontSizeEncoder =
    JE.int << toInt
