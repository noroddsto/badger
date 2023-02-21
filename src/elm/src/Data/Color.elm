module Data.Color exposing (Hex, Rgb, black, contrast, fromString, toHexString, toRgb, transparentColorToRgb, white)

import Data.Percentage as Percentage
import Hex
import Regex
import Result


type Hex
    = Hex String


{-| Convert HEX color to string.

    toHexString (Hex # FFFFFF) == "#FFFFFF"

-}
toHexString : Hex -> String
toHexString (Hex hex) =
    hex


{-| Calculates the actual RGB color when a foreground color with opacity is layered on top of a colored background.

    transparentColorToRgb (Rgb 181 26 0) (Rgb 255 255 255) (Percentage 50) == Rgb 218 141 128

-}
transparentColorToRgb : Rgb -> Rgb -> Percentage.Percentage -> Rgb
transparentColorToRgb background foreground opacity =
    let
        (Rgb bR bG bB) =
            background |> Debug.log "BG"

        (Rgb fR fG fB) =
            foreground |> Debug.log "FG"

        alpha =
            Percentage.toDecimals opacity

        target =
            { r = (((1 - alpha) * toFloat bR) + (alpha * toFloat fR)) |> round
            , g = (((1 - alpha) * toFloat bG) + (alpha * toFloat fG)) |> round
            , b = (((1 - alpha) * toFloat bB) + (alpha * toFloat fB)) |> round
            }
    in
    Rgb target.r target.g target.b |> Debug.log "Res"


{-| Parse string into Hex

    fromString "#FFFFFF" == Ok (Hex "#FFFFFF")

    fromString "#FFF" == Ok (Hex "#FFFFFF")

    fromString "nocolor" == Err "Invalid format"

-}
fromString : String -> Result String Hex
fromString hexStr =
    let
        prefixedHex =
            ensurePrefix hexStr
    in
    if Regex.contains validHexRegex prefixedHex then
        hexStr
            |> expandHexShorthand
            |> Hex
            |> Ok

    else
        Err "Invalid format"


validHexRegex : Regex.Regex
validHexRegex =
    "^#(?:[0-9a-fA-F]{3}){1,2}$"
        |> Regex.fromStringWith { caseInsensitive = False, multiline = False }
        |> Maybe.withDefault Regex.never


hexShorthandRegex : Regex.Regex
hexShorthandRegex =
    "^#?([a-f\\d])([a-f\\d])([a-f\\d])$"
        |> Regex.fromStringWith { caseInsensitive = True, multiline = False }
        |> Maybe.withDefault Regex.never


hexPartsRegex : Regex.Regex
hexPartsRegex =
    "^#?([a-f\\d]{2})([a-f\\d]{2})([a-f\\d]{2})$"
        |> Regex.fromStringWith { caseInsensitive = True, multiline = False }
        |> Maybe.withDefault Regex.never


ensurePrefix : String -> String
ensurePrefix newVal =
    if String.left 1 newVal == "#" then
        newVal

    else
        "#" ++ newVal


white : Hex
white =
    Hex "#ffffff"


black : Hex
black =
    Hex "#000000"


expandHexShorthand : String -> String
expandHexShorthand hexCode =
    hexCode
        |> Regex.replace hexShorthandRegex
            (\{ submatches } ->
                case submatches of
                    [ Just r, Just g, Just b ] ->
                        [ "#", r, r, g, g, b, b ] |> String.join ""

                    _ ->
                        hexCode
            )


type Rgb
    = Rgb Int Int Int


{-| Convert Hex to Rgb

    toRgb (Hex # FFFFFF) == RGB 255 255 255

-}
toRgb : Hex -> Maybe Rgb
toRgb (Hex hexCode) =
    hexCode
        |> String.toLower
        |> Regex.find hexPartsRegex
        |> List.head
        |> Maybe.andThen
            (\{ submatches } ->
                case submatches of
                    [ Just rh, Just gh, Just bh ] ->
                        Result.map3
                            (\r g b ->
                                Rgb r g b
                            )
                            (Hex.fromString rh)
                            (Hex.fromString gh)
                            (Hex.fromString bh)
                            |> Result.toMaybe

                    _ ->
                        Nothing
            )


luminance : Rgb -> Float
luminance (Rgb r g b) =
    List.map2
        (\v f ->
            let
                v1 =
                    toFloat v / 255.0
            in
            if v1 < 0.03928 then
                (v1 / 12.92) * f

            else
                (((v1 + 0.055) / 1.055) ^ 2.4) * f
        )
        [ r, g, b ]
        [ 0.2126, 0.7152, 0.0722 ]
        |> List.sum


{-| Calculate the contrast ratio between two RGB colors.
-}
contrast : Rgb -> Rgb -> Float
contrast color1 color2 =
    let
        l1 =
            0.05 + luminance color1

        l2 =
            0.05 + luminance color2
    in
    if l1 > l2 then
        l1 / l2

    else
        l2 / l1
