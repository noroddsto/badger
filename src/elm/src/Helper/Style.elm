module Helper.Style exposing (..)

import Html as H
import Html.Attributes as HA


colorPicker : H.Attribute msg
colorPicker =
    HA.class "w-full h-10 border rounded border-slate-200"


label : H.Attribute msg
label =
    HA.class "font-bold variant-caps-all-small-caps text-slate-700 ml-[1px]"


input : H.Attribute msg
input =
    HA.class "px-2 py-2 rounded border-slate-200 border text-sm text-slate-900"


dropdown : H.Attribute msg
dropdown =
    HA.class "appearance-none px-2 py-2 rounded border-slate-200 border text-sm text-slate-900 bg-white"


field : H.Attribute msg
field =
    HA.class "flex flex-col mb-6 last:mb-0"


primaryButton : H.Attribute msg
primaryButton =
    HA.class "bg-blue-700 rounded transition hover:bg-blue-800 active:bg-blue-900 disabled:bg-gray-400 disabled:shadow-none disabled:cursor-not-allowed text-white p-3 shadow-md active:shadow-sm font-bold variant-caps-all-small-caps"


secondaryButton : H.Attribute msg
secondaryButton =
    HA.class "rounded transition border border-blue-600 hover:bg-slate-50 hover:text-blue-700 hover:border-blue-700 text-blue-600 disabled:bg-gray-400  disabled:cursor-not-allowed p-3 font-bold variant-caps-all-small-caps"


deleteButton : H.Attribute msg
deleteButton =
    HA.class "rounded transition border border-red-700 bg-red-700 text-white hover:bg-red-800  hover:border-red-800 disabled:bg-red-800:50 disabled:cursor-not-allowed py-2 px-3 shadow-md active:shadow-sm text-sm font-bold variant-caps-all-small-caps"


smallSecondaryButton : H.Attribute msg
smallSecondaryButton =
    HA.class "rounded transition border border-blue-600 hover:bg-slate-50 hover:text-blue-700 hover:border-blue-700 text-blue-600 disabled:bg-gray-400  disabled:cursor-not-allowed py-2 px-3 shadow-md active:shadow-sm text-sm font-bold variant-caps-all-small-caps"


h2 : H.Attribute msg
h2 =
    HA.class "font-baijamjuree text-3xl mb-8 text-slate-800"


h3 : H.Attribute msg
h3 =
    HA.class "font-baijamjuree font-medium text-lg mb-3 text-cyan-800"


topbarButton : H.Attribute msg
topbarButton =
    HA.class "font-bold variant-caps-all-small-caps text-base px-4 py-2 rounded-lg border-1 text-md  disabled:cursor-not-allowed hover:disabled:bg-white disabled:text-gray-400 hover:bg-purple-50 text-purple-700 hover:text-purple-800"


iconButton : H.Attribute msg
iconButton =
    HA.class "p-4 rounded-full block border-1 text-md hover:disabled:bg-white disabled:cursor-not-allowed disabled:fill-gray-400 hover:bg-purple-50 fill-purple-700 hover:fill-purple-800"
