module Data.FontWeight exposing (FontWeight, bold, fromString, isBold, normal, toString)


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
