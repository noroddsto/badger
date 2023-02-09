module Helper.ColorPicker exposing (..)

import Data.Color as Color
import Helper.Form as HF
import Helper.Style as Style
import Html as H
import Html.Attributes as HA
import Html.Events as HE


init : Color.Hex -> ColorInput
init initialColor =
    Selected initialColor


type ColorInput
    = Selected Color.Hex
    | Typing Color.Hex String


type alias InputConfig msg =
    { id : String
    , label : String
    , value : ColorInput
    , onChange : ColorInput -> msg
    }


getColor : ColorInput -> Color.Hex
getColor colorInput =
    case colorInput of
        Selected color ->
            color

        Typing color _ ->
            color


getInputValue : ColorInput -> String
getInputValue colorInput =
    case colorInput of
        Selected color ->
            Color.toHexString color

        Typing _ value ->
            value


setInputValue : ColorInput -> String -> ColorInput
setInputValue colorInput val =
    case Color.fromString val of
        Ok newColor ->
            Typing newColor val

        Err _ ->
            Typing (getColor colorInput) val


setPickedColor : ColorInput -> String -> ColorInput
setPickedColor colorInput val =
    case Color.fromString val of
        Ok newColor ->
            Selected newColor

        Err _ ->
            Selected (getColor colorInput)


setInputComplete : ColorInput -> ColorInput
setInputComplete colorInput =
    case colorInput of
        Selected color ->
            Selected color

        Typing color _ ->
            Selected color


colorPicker : InputConfig msg -> H.Html msg
colorPicker { id, label, value, onChange } =
    HF.field
        [ HF.labelFor id label
        , H.div [ HA.class "grid grid-cols-[1fr_25%] gap-3" ]
            [ H.input
                [ Style.colorPicker
                , HA.id id
                , HA.type_ "color"
                , HA.value (Color.toHexString (getColor value))
                , HE.onInput (onChange << setPickedColor value)
                ]
                []
            , H.label [ HA.for (id ++ "-hex"), HA.class "sr-only" ] [ H.text (label ++ " HEX value") ]
            , H.input
                [ Style.input
                , HA.id (id ++ "-hex")
                , HA.type_ "text"
                , HA.value (getInputValue value)
                , HE.onInput (onChange << setInputValue value)
                , HE.onBlur (onChange (setInputComplete value))
                ]
                []
            ]
        ]
