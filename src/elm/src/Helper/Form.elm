module Helper.Form exposing (InputConfig, field, inputField, labelFor)

import Helper.Style as Style
import Html as H
import Html.Attributes as HA
import Html.Events as HE


field : List (H.Html msg) -> H.Html msg
field =
    H.div [ Style.field ]


labelFor : String -> String -> H.Html msg
labelFor domId labelText =
    H.label [ HA.for domId, Style.label ] [ H.text labelText ]


type alias InputConfig msg =
    { id : String, inputType : String, label : String, value : String, onInput : String -> msg }


inputField : InputConfig msg -> H.Html msg
inputField { id, inputType, label, value, onInput } =
    field
        [ labelFor id label
        , H.input
            [ HA.id id
            , HA.type_ inputType
            , internalInputStyle inputType
            , HA.value value
            , HE.onInput onInput
            ]
            []
        ]


internalInputStyle : String -> H.Attribute msg
internalInputStyle inputType =
    case inputType of
        "color" ->
            Style.colorPicker

        _ ->
            Style.input
