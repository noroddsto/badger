module Helper.SvgInput exposing (Input, ParsedSvg, getElement, getValue, isValid, setValue, toSvg)

import Dict
import Svg
import Svg.Attributes as SA
import SvgParser


type Input
    = Invalid String
    | Valid String SvgParser.Element


isValid : Input -> Bool
isValid input =
    case input of
        Invalid _ ->
            False

        Valid _ _ ->
            True


setValue : String -> Input
setValue newValue =
    Invalid newValue
        |> validate


getValue : Input -> String
getValue input =
    case input of
        Invalid val ->
            val

        Valid val _ ->
            val


getElement : Input -> Maybe SvgParser.Element
getElement input =
    case input of
        Valid _ element ->
            if element.name == "svg" then
                Just element

            else
                Nothing

        Invalid _ ->
            Nothing


validate : Input -> Input
validate input =
    let
        value =
            getValue input
    in
    value
        |> SvgParser.parseToNode
        |> Result.toMaybe
        |> Maybe.andThen
            (\result ->
                case result of
                    SvgParser.SvgElement element ->
                        Just element

                    _ ->
                        Nothing
            )
        |> Maybe.map (Valid value)
        |> Maybe.withDefault (Invalid value)


type alias ParsedSvg msg =
    { svg : Svg.Svg msg
    , aspectRatio : Float
    }


toSvg : SvgParser.Element -> String -> ParsedSvg msg
toSvg { name, attributes, children } domId =
    let
        attrs =
            attributes
                |> setViewBox

        aspectRatio =
            getAspectRatio attrs

        attrs2 =
            attrs |> List.map SvgParser.toAttribute
    in
    { svg = Svg.node name (SA.id domId :: attrs2) (children |> List.map SvgParser.nodeToSvg), aspectRatio = aspectRatio }


getAspectRatio : List SvgParser.SvgAttribute -> Float
getAspectRatio attributes =
    Dict.fromList attributes
        |> Dict.get "viewBox"
        |> Maybe.map (String.split " ")
        |> Maybe.andThen
            (\viewBox ->
                case viewBox of
                    [ _, _, wStr, hStr ] ->
                        case ( String.toInt wStr, String.toInt hStr ) of
                            ( Just w, Just h ) ->
                                Just (toFloat w / toFloat h)

                            _ ->
                                Nothing

                    _ ->
                        Nothing
            )
        |> Maybe.withDefault 1.0


setViewBox : List SvgParser.SvgAttribute -> List SvgParser.SvgAttribute
setViewBox attributes =
    let
        attrs =
            Dict.fromList attributes
                |> Dict.insert "aria-label" "Icon uploaded by user"
    in
    case Dict.get "viewBox" attrs of
        Just _ ->
            attrs
                |> Dict.remove "height"
                |> Dict.remove "width"
                |> Dict.toList

        Nothing ->
            let
                mbHeight =
                    attrs |> Dict.get "height" |> Maybe.andThen String.toInt

                mbWidth =
                    attrs |> Dict.get "width" |> Maybe.andThen String.toInt

                nextAttrs =
                    attrs
                        |> Dict.remove "height"
                        |> Dict.remove "width"
            in
            case ( mbHeight, mbWidth ) of
                ( Just h, Just w ) ->
                    nextAttrs
                        |> Dict.insert "viewBox" ("0 0 " ++ String.fromInt w ++ " " ++ String.fromInt h)
                        |> Dict.toList

                _ ->
                    nextAttrs
                        |> Dict.toList
