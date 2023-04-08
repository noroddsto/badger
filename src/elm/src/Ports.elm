port module Ports exposing (..)

import Json.Encode as JE


port openDialog : String -> Cmd msg


port closeDialog : String -> Cmd msg


port downloadSvg : { domId : String, fileName : String } -> Cmd msg


port log : JE.Value -> Cmd msg


port savePreset : JE.Value -> Cmd msg


port savePresetResponse : (JE.Value -> msg) -> Sub msg


port loadPreset : String -> Cmd msg


port loadPresetResponse : (JE.Value -> msg) -> Sub msg


port deletePreset : String -> Cmd msg


port deletePresetResponse : (JE.Value -> msg) -> Sub msg
