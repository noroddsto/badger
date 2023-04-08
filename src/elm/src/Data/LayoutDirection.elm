module Data.LayoutDirection exposing (LayoutDirection, bottomToTop, layoutDirectionDecoder, layoutDirectionEncoder, leftToRight, rightToLeft, stacked, topToBottom, when)

import Json.Decode as JD
import Json.Encode as JE


type LayoutDirection
    = TopToBottom
    | BottomToTop
    | LeftToRight
    | RightToLeft
    | Stacked


topToBottom : LayoutDirection
topToBottom =
    TopToBottom


bottomToTop : LayoutDirection
bottomToTop =
    BottomToTop


leftToRight : LayoutDirection
leftToRight =
    LeftToRight


rightToLeft : LayoutDirection
rightToLeft =
    RightToLeft


stacked : LayoutDirection
stacked =
    Stacked


fromString : String -> Maybe LayoutDirection
fromString str =
    case str of
        "topToBottom" ->
            Just TopToBottom

        "bottomToTop" ->
            Just BottomToTop

        "leftToRight" ->
            Just LeftToRight

        "rightToLeft" ->
            Just RightToLeft

        "stacked" ->
            Just Stacked

        _ ->
            Nothing


toString : LayoutDirection -> String
toString direction =
    case direction of
        TopToBottom ->
            "topToBottom"

        BottomToTop ->
            "bottomToTop"

        LeftToRight ->
            "leftToRight"

        RightToLeft ->
            "rightToLeft"

        Stacked ->
            "stacked"


layoutDirectionDecoder : JD.Decoder LayoutDirection
layoutDirectionDecoder =
    JD.string
        |> JD.andThen
            (\str ->
                case fromString str of
                    Just direction ->
                        JD.succeed direction

                    Nothing ->
                        JD.fail "Invalid direction"
            )


layoutDirectionEncoder : LayoutDirection -> JE.Value
layoutDirectionEncoder =
    JE.string << toString


type alias Handler a =
    { whenBottomToTop : () -> a
    , whenRightToLeft : () -> a
    , whenTopToBottom : () -> a
    , whenLeftToRight : () -> a
    , whenStacked : () -> a
    }


when : Handler a -> LayoutDirection -> a
when { whenBottomToTop, whenRightToLeft, whenTopToBottom, whenLeftToRight, whenStacked } layoutDirection =
    case layoutDirection of
        TopToBottom ->
            whenTopToBottom ()

        BottomToTop ->
            whenBottomToTop ()

        LeftToRight ->
            whenLeftToRight ()

        RightToLeft ->
            whenRightToLeft ()

        Stacked ->
            whenStacked ()
