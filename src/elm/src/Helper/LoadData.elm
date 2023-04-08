module Helper.LoadData exposing (Data, error, loading, mapReady, notLoaded, ready, withDefault)


type Data e a
    = NotLoaded
    | Loading
    | Ready a
    | Error e


notLoaded : Data e a
notLoaded =
    NotLoaded


loading : Data e a
loading =
    Loading


ready : a -> Data e a
ready =
    Ready


error : e -> Data e a
error =
    Error


mapReady : (a -> n) -> Data e a -> Data e n
mapReady handler loadData =
    case loadData of
        Ready data ->
            Ready (handler data)

        NotLoaded ->
            NotLoaded

        Loading ->
            Loading

        Error e ->
            Error e


withDefault : a -> Data e a -> a
withDefault default loadData =
    case loadData of
        Ready data ->
            data

        _ ->
            default
