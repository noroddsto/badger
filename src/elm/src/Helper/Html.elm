module Helper.Html exposing (empty, renderIf)

import Html as H


renderIf : Bool -> H.Html msg -> H.Html msg
renderIf condition content =
    if condition then
        content

    else
        empty


empty : H.Html msg
empty =
    H.text ""
