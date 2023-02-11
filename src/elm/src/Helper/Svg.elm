module Helper.Svg exposing (viewBox)

import Svg
import Svg.Attributes as SA


viewBox : Int -> Int -> Svg.Attribute msg
viewBox width height =
    SA.viewBox ("0 0 " ++ String.fromInt width ++ " " ++ String.fromInt height)
