module Helper.Html exposing (emptyAttribute, renderIf)

import Html as H
import Html.Attributes as HA


renderIf : Bool -> H.Html msg -> H.Html msg
renderIf condition content =
    if condition then
        content

    else
        empty


empty : H.Html msg
empty =
    H.text ""


emptyAttribute : H.Attribute msg
emptyAttribute =
    HA.classList []
