module Helper.SegmentButton exposing (fieldSet, optionIcon, optionList)

import Helper.Style as Style
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Icon.UI as UI


optionIcon : a -> String -> UI.Icon msg -> Option a msg
optionIcon item label icon =
    Option item label (Just icon)


type Option a msg
    = Option a String (Maybe (UI.Icon msg))


type alias SegmentButtonConfig a msg =
    { name : String
    , selected : a
    , options : List (Option a msg)
    , onSelect : a -> msg
    }


fieldSet : String -> List (H.Html msg) -> H.Html msg
fieldSet label innerContent =
    H.div [ Style.field ]
        [ H.fieldset [ HA.class "h-auto relative" ]
            (H.legend
                [ Style.label, HA.class "float-left w-full" ]
                [ H.text label ]
                :: innerContent
            )
        ]


optionList : SegmentButtonConfig a msg -> H.Html msg
optionList { name, selected, options, onSelect } =
    H.div [ HA.class "bg-gray-100 rounded-md flex p-1 shadow-inset-sm-c gap-1" ]
        (options
            |> List.indexedMap (\i o -> ( i, o ))
            |> List.map
                (\( index, Option item optionLabel mbIcon ) ->
                    let
                        value =
                            String.fromInt index

                        id =
                            name ++ "-" ++ value

                        isChecked =
                            item == selected
                    in
                    H.div [ HA.class "grow" ]
                        [ H.input
                            [ HA.id id
                            , HA.value value
                            , HA.type_ "radio"
                            , HA.name name
                            , HA.checked isChecked
                            , HA.class "sr-only peer/radio"
                            , HE.onInput (\_ -> onSelect item)
                            ]
                            []
                        , H.label
                            [ HA.for id
                            , HA.class
                                "text-slate-600 hover:text-slate-800 transition duration-150 hover:bg-white/50 peer-checked/radio:bg-white  peer-checked/radio:shadow-sm-c cursor-pointer p-2 block rounded-md font-bold variant-caps-all-small-caps text-center"
                            ]
                            (case mbIcon of
                                Just icon ->
                                    [ H.span [ HA.class "[&>svg]:w-4 [&>svg]:h-4 flex justify-center" ] [ icon 16 ]
                                    , H.span [ HA.class "sr-only" ]
                                        [ H.text optionLabel
                                        ]
                                    ]

                                Nothing ->
                                    [ H.text optionLabel ]
                            )
                        ]
                )
        )
