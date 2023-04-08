module Helper.Preset exposing
    ( Payload
    , Preset
    , PresetState
    , changed
    , failed
    , getName
    , listPresetsResponse
    , loadPresetResponse
    , noPreset
    , render
    , savePresetResponse
    , saved
    , saving
    , toJson
    )

import Data.Canvas exposing (Align)
import Data.Color
import Data.Font exposing (Font)
import Data.FontSize as FontSize
import Data.FontWeight exposing (FontWeight)
import Data.LayoutDirection exposing (LayoutDirection)
import Data.Percentage exposing (Percentage)
import Html as H
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Encode as JE
import Ports


type PresetState
    = Saving String
    | Saved String
    | Changed String
    | NoPreset
    | Failed String


noPreset : PresetState
noPreset =
    NoPreset


saving : String -> PresetState
saving =
    Saving


saved : String -> PresetState
saved =
    Saved


failed : String -> PresetState
failed =
    Failed


changed : PresetState -> PresetState
changed state =
    case state of
        Saved name ->
            Changed name

        _ ->
            state


getName : PresetState -> Maybe String
getName presetState =
    case presetState of
        Saving name ->
            Just name

        Saved name ->
            Just name

        Changed name ->
            Just name

        NoPreset ->
            Nothing

        Failed _ ->
            Nothing


type alias Payload =
    { fontSize : FontSize.FontSize
    , width : Int
    , height : Int
    , size : Percentage
    , backgroundColor : Data.Color.Hex
    , spaceBetween : Int
    , fontFamily : Font
    , textColor : Data.Color.Hex
    , fontWeight : FontWeight
    , svgColor : Data.Color.Hex
    , textOpacity : Percentage
    , iconOpacity : Percentage
    , padding : Int
    , alignHorizontal : Align
    , alignVertical : Align
    , layoutDirection : LayoutDirection
    }


type alias Preset =
    { key : String
    , payload : Payload
    }


toJson : Preset -> JE.Value
toJson preset =
    JE.object
        [ ( "key", JE.string preset.key )
        , ( "payload", encodePayload preset.payload )
        ]


encodePayload : Payload -> JE.Value
encodePayload payload =
    JE.object
        [ ( "fontSize", FontSize.fontSizeEncoder payload.fontSize )
        , ( "width", JE.int payload.width )
        , ( "height", JE.int payload.height )
        , ( "size", Data.Percentage.percentageEncoder payload.size )
        , ( "backgroundColor", Data.Color.colorEncoder payload.backgroundColor )
        , ( "spaceBetween", JE.int payload.spaceBetween )
        , ( "fontFamily", Data.Font.fontEncoder payload.fontFamily )
        , ( "textColor", Data.Color.colorEncoder payload.textColor )
        , ( "fontWeight", Data.FontWeight.fontWeightEncoder payload.fontWeight )
        , ( "svgColor", Data.Color.colorEncoder payload.svgColor )
        , ( "textOpacity", Data.Percentage.percentageEncoder payload.textOpacity )
        , ( "iconOpacity", Data.Percentage.percentageEncoder payload.iconOpacity )
        , ( "padding", JE.int payload.padding )
        , ( "alignHorizontal", Data.Canvas.alignmentEncoder payload.alignHorizontal )
        , ( "alignVertical", Data.Canvas.alignmentEncoder payload.alignVertical )
        , ( "layoutDirection", Data.LayoutDirection.layoutDirectionEncoder payload.layoutDirection )

        -- SVG as string
        ]


savePresetResponse : (Result JD.Error String -> msg) -> Sub msg
savePresetResponse msg =
    Ports.savePresetResponse (msg << JD.decodeValue decodeResponse)


decodeResponse : JD.Decoder String
decodeResponse =
    JD.oneOf
        [ JD.at [ "data" ] JD.string
        , JD.at [ "error" ] JD.string |> JD.andThen JD.fail
        ]


listPresetsResponse : (Result JD.Error (List String) -> msg) -> Sub msg
listPresetsResponse msg =
    Ports.listPresetsResponse (msg << JD.decodeValue decodePresetList)


decodePresetList : JD.Decoder (List String)
decodePresetList =
    JD.oneOf
        [ JD.at [ "data" ] (JD.list JD.string)
        , JD.at [ "error" ] JD.string |> JD.andThen JD.fail
        ]


loadPresetResponse : (Result JD.Error Preset -> msg) -> Sub msg
loadPresetResponse msg =
    Ports.loadPresetResponse (msg << JD.decodeValue decodePresetResponse)


decodePresetResponse : JD.Decoder Preset
decodePresetResponse =
    JD.oneOf
        [ JD.at [ "data" ] decodePreset
        , JD.at [ "error" ] JD.string |> JD.andThen JD.fail
        ]


decodePreset : JD.Decoder Preset
decodePreset =
    JD.map2 Preset
        (JD.field "key" JD.string)
        (JD.field "payload" decodePresetPayload)


decodePresetPayload : JD.Decoder Payload
decodePresetPayload =
    JD.succeed Payload
        |> JDE.andMap (JD.field "fontSize" FontSize.fontSizeDecoder)
        |> JDE.andMap (JD.field "width" JD.int)
        |> JDE.andMap (JD.field "height" JD.int)
        |> JDE.andMap (JD.field "size" Data.Percentage.percentageDecoder)
        |> JDE.andMap (JD.field "backgroundColor" Data.Color.colorDecoder)
        |> JDE.andMap (JD.field "spaceBetween" JD.int)
        |> JDE.andMap (JD.field "fontFamily" Data.Font.fontDecoder)
        |> JDE.andMap (JD.field "textColor" Data.Color.colorDecoder)
        |> JDE.andMap (JD.field "fontWeight" Data.FontWeight.fontWeightDecoder)
        |> JDE.andMap (JD.field "svgColor" Data.Color.colorDecoder)
        |> JDE.andMap (JD.field "textOpacity" Data.Percentage.percentageDecoder)
        |> JDE.andMap (JD.field "iconOpacity" Data.Percentage.percentageDecoder)
        |> JDE.andMap (JD.field "padding" JD.int)
        |> JDE.andMap (JD.field "alignHorizontal" Data.Canvas.alignmentDecoder)
        |> JDE.andMap (JD.field "alignVertical" Data.Canvas.alignmentDecoder)
        |> JDE.andMap (JD.field "layoutDirection" Data.LayoutDirection.layoutDirectionDecoder)


type alias PresetRender msg =
    { whenSaving : String -> H.Html msg
    , whenSaved : String -> Bool -> H.Html msg
    , whenFailed : String -> H.Html msg
    , whenNoPreset : () -> H.Html msg
    }


render : PresetRender msg -> PresetState -> H.Html msg
render { whenSaving, whenSaved, whenFailed, whenNoPreset } presetState =
    case presetState of
        Saving name ->
            whenSaving name

        Saved name ->
            whenSaved name False

        Changed name ->
            whenSaved name True

        NoPreset ->
            whenNoPreset ()

        Failed error ->
            whenFailed error
