port module Ports exposing (..)


port openDialog : String -> Cmd msg


port closeDialog : String -> Cmd msg


port downloadSvg : { domId : String, fileName : String } -> Cmd msg
