module Component.Modal exposing (..)

import Browser.Dom as Dom
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Icon.UI as Icon
import Json.Decode as JD
import Task


type alias DialogConfig msg =
    { id : String
    , closeDialog : String -> Position -> msg
    , dialogWasClosed : msg
    }


dialog : DialogConfig msg -> List (H.Html msg) -> H.Html msg
dialog { id, closeDialog, dialogWasClosed } content =
    H.node "dialog"
        [ HA.id id
        , HE.on "click" (toEvent (closeDialog id))
        , HE.on "close" (JD.succeed dialogWasClosed)
        , HA.class "min-w-[40vw] max-h-[70vh] shadow-lg p-8 relative"
        ]
        (H.button [ HA.class "absolute top-4 right-4", HE.onClick dialogWasClosed ]
            [ Icon.close 24
            , H.span [ HA.class "sr-only" ] [ H.text "Close" ]
            ]
            :: content
        )


type alias Position =
    { x : Float, y : Float, tagName : String }


toEvent : (Position -> msg) -> JD.Decoder msg
toEvent msg =
    JD.map3 Position
        (JD.at [ "clientX" ] JD.float)
        (JD.at [ "clientY" ] JD.float)
        (JD.at [ "target", "tagName" ] JD.string)
        |> JD.andThen
            (\p ->
                JD.succeed (msg p)
            )


modalWasClicked : String -> Position -> (String -> msg) -> msg -> Cmd msg
modalWasClicked domId pos whenClickOutside whenClickInside =
    Dom.getElement domId
        |> Task.andThen
            (\{ element } ->
                let
                    isInDialog =
                        element.y
                            <= pos.y
                            && pos.y
                            <= element.y
                            + element.height
                            && element.x
                            <= pos.x
                            && pos.x
                            <= element.x
                            + element.width
                in
                Task.succeed isInDialog
            )
        |> Task.attempt
            (\result ->
                case result of
                    Ok False ->
                        whenClickOutside domId

                    _ ->
                        whenClickInside
            )
