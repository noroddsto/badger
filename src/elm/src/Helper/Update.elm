module Helper.Update exposing (noCmd, parseInt, withCmd)


parseInt : String -> Int
parseInt newVal =
    case String.toInt newVal of
        Just value ->
            value

        Nothing ->
            0


noCmd : model -> ( model, Cmd msg )
noCmd model =
    ( model, Cmd.none )


withCmd : Cmd msg -> model -> ( model, Cmd msg )
withCmd cmd model =
    ( model, cmd )
