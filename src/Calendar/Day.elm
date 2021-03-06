module Calendar.Day exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Date exposing (Date)
import Date.Extra
import Config exposing (ViewConfig)
import Helpers
import Calendar.Msg exposing (Msg(..))
import Json.Decode as Json
import Mouse
import Calendar.Event as Event exposing (rangeDescription)


view : ViewConfig event -> List event -> Date -> Html Msg
view config events day =
    div [ class "elm-calendar--day" ]
        [ viewDayHeader day
        , div [ class "elm-calendar--day-content" ]
            [ viewTimeGutter day
            , viewDaySlot config events day
            ]
        ]


viewDate : Date -> Html Msg
viewDate day =
    let
        title day =
            Date.Extra.toFormattedString "EE M/d" day
    in
        div [ class "elm-calendar--date-header" ]
            [ a [ class "elm-calendar--date", href "#" ] [ text <| title day ] ]


viewDayHeader : Date -> Html Msg
viewDayHeader day =
    div [ class "elm-calendar--day-header" ]
        [ viewTimeGutterHeader
        , viewDate day
        ]


viewTimeGutter : Date -> Html Msg
viewTimeGutter date =
    Helpers.hours date
        |> List.map viewTimeSlotGroup
        |> div [ class "elm-calendar--time-gutter" ]


viewTimeGutterHeader : Html Msg
viewTimeGutterHeader =
    div [ class "elm-calendar--time-gutter-header" ] []


viewTimeSlotGroup : Date -> Html Msg
viewTimeSlotGroup date =
    div [ class "elm-calendar--time-slot-group" ]
        [ viewHourSlot date
        , div [ class "elm-calendar--time-slot" ] []
        ]


viewHourSlot : Date -> Html Msg
viewHourSlot date =
    div [ class "elm-calendar--hour-slot" ]
        [ span [ class "elm-calendar--time-slot-text" ] [ text <| Helpers.hourString date ] ]


viewDaySlot : ViewConfig event -> List event -> Date -> Html Msg
viewDaySlot config events day =
    Helpers.hours day
        |> List.map viewDaySlotGroup
        |> (flip (++)) (viewDayEvents config events day)
        |> div [ class "elm-calendar--day-slot" ]


viewDaySlotGroup : Date -> Html Msg
viewDaySlotGroup date =
    div [ class "elm-calendar--time-slot-group" ]
        [ viewTimeSlot date
        , viewTimeSlot date
        ]


viewTimeSlot : Date -> Html Msg
viewTimeSlot date =
    div
        [ class "elm-calendar--time-slot"
        , onClick (TimeSlotClick date)
        , onMouseEnter (TimeSlotMouseEnter date)
        , onMouseLeave (TimeSlotMouseLeave date)
        , on "mousedown" (Json.map (TimeSlotDragStart date) Mouse.position)
        ]
        []


viewDayEvents : ViewConfig event -> List event -> Date -> List (Html Msg)
viewDayEvents config events day =
    List.filterMap (viewDayEvent config day) events


viewDayEvent : ViewConfig event -> Date -> event -> Maybe (Html Msg)
viewDayEvent config day event =
    let
        eventRange =
            rangeDescription (config.start event) (config.end event) Date.Extra.Day day
    in
        Event.maybeViewDayEvent config event eventRange


viewAllDayCell : List Date -> Html Msg
viewAllDayCell days =
    let
        viewAllDayText =
            div [ class "elm-calendar--all-day-text" ] [ text "All day" ]

        viewAllDay day =
            div [ class "elm-calendar--all-day" ]
                []
    in
        div [ class "elm-calendar--all-day-cell" ]
            (viewAllDayText :: List.map viewAllDay days)
