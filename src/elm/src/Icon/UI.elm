module Icon.UI exposing
    ( Icon
    , addIcon
    , arrowDown
    , arrowLeft
    , arrowRight
    , arrowUp
    , check
    , close
    , delete
    , download
    , menu
    )

import Svg exposing (path, svg)
import Svg.Attributes as SA
import VirtualDom


type alias Icon msg =
    Int -> Svg.Svg msg


icon : Int -> List (Svg.Svg msg) -> Svg.Svg msg
icon size =
    svg
        [ SA.height (String.fromInt size)
        , SA.width (String.fromInt size)
        , SA.viewBox "0 0 48 48"
        , VirtualDom.attribute "aria-hidden" "true"
        ]


close : Int -> Svg.Svg msg
close size =
    icon size
        [ path
            [ SA.d "m12.45 37.95-2.4-2.4L21.6 24 10.05 12.45l2.4-2.4L24 21.6l11.55-11.55 2.4 2.4L26.4 24l11.55 11.55-2.4 2.4L24 26.4Z"
            ]
            []
        ]


check : Int -> Svg.Svg msg
check size =
    icon size
        [ path
            [ SA.d "M18.9 36.4 7 24.5l2.9-2.85 9 9L38.05 11.5l2.9 2.85Z"
            ]
            []
        ]


arrowLeft : Int -> Svg.Svg msg
arrowLeft size =
    icon size
        [ Svg.path
            [ SA.d "M24 40.15 7.85 24 24 7.85l2.4 2.4L14.35 22.3h25.8v3.4h-25.8L26.4 37.75Z"
            ]
            []
        ]


arrowRight : Int -> Svg.Svg msg
arrowRight size =
    icon size
        [ Svg.path
            [ SA.d "m24 40.15-2.4-2.45 12-12H7.85v-3.4H33.6l-12-12L24 7.85 40.15 24Z"
            ]
            []
        ]


arrowUp : Int -> Svg.Svg msg
arrowUp size =
    icon size
        [ Svg.path
            [ SA.d "M22.3 40.15v-25.8L10.25 26.4 7.85 24 24 7.85 40.15 24l-2.4 2.4L25.7 14.35v25.8Z"
            ]
            []
        ]


arrowDown : Int -> Svg.Svg msg
arrowDown size =
    icon size
        [ Svg.path
            [ SA.d "M24 40.15 7.85 24l2.4-2.4L22.3 33.65V7.85h3.4v25.8L37.75 21.6l2.4 2.4Z"
            ]
            []
        ]


menu : Int -> Svg.Svg msg
menu size =
    icon size
        [ Svg.path
            [ SA.d "M5.5 36.8v-3.95h37v3.95Zm0-10.8v-4h37v4Zm0-10.85V11.2h37v3.95Z"
            ]
            []
        ]


addIcon : Int -> Svg.Svg msg
addIcon size =
    icon size
        [ Svg.path
            [ SA.d "M22 38.5V26H9.5v-4H22V9.5h4V22h12.5v4H26v12.5Z"
            ]
            []
        ]


delete : Int -> Svg.Svg msg
delete size =
    icon size
        [ Svg.path
            [ SA.d "M13.05 42q-1.25 0-2.125-.875T10.05 39V10.5H8v-3h9.4V6h13.2v1.5H40v3h-2.05V39q0 1.2-.9 2.1-.9.9-2.1.9Zm21.9-31.5h-21.9V39h21.9Zm-16.6 24.2h3V14.75h-3Zm8.3 0h3V14.75h-3Zm-13.6-24.2V39Z"
            ]
            []
        ]


download : Int -> Svg.Svg msg
download size =
    icon size
        [ Svg.path
            [ SA.d "M10.6 41.35q-1.65 0-2.825-1.175Q6.6 39 6.6 37.35v-8.4h4v8.4h26.8v-8.4h3.95v8.4q0 1.65-1.175 2.825Q39 41.35 37.4 41.35Zm13.4-9.6L13.35 21.1l2.85-2.8 5.8 5.85V6h4v18.15l5.8-5.85 2.85 2.8Z"
            ]
            []
        ]
