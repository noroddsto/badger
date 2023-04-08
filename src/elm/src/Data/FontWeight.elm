module Data.FontWeight exposing (FontWeight, bold, fontWeightDecoder, fontWeightEncoder, fromString, isBold, normal, toString)

import Json.Decode as JD
import Json.Encode as JE


type FontWeight
    = Normal
    | Bold


normal : FontWeight
normal =
    Normal


bold : FontWeight
bold =
    Bold


toString : FontWeight -> String
toString fontWeight =
    case fontWeight of
        Normal ->
            "normal"

        Bold ->
            "bold"


isBold : FontWeight -> Bool
isBold weight =
    weight == Bold


fromString : String -> Maybe FontWeight
fromString fontWeight =
    case fontWeight of
        "normal" ->
            Just Normal

        "bold" ->
            Just Bold

        _ ->
            Nothing


fontWeightDecoder : JD.Decoder FontWeight
fontWeightDecoder =
    JD.string
        |> JD.andThen
            (\fwTxt ->
                case fromString fwTxt of
                    Just fontWeight ->
                        JD.succeed fontWeight

                    Nothing ->
                        JD.fail "Invalid font weight"
            )


fontWeightEncoder : FontWeight -> JE.Value
fontWeightEncoder =
    JE.string << toString
