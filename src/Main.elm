module Main exposing (..)

import Browser
import Html exposing (Html, div, text)
import Http
import Json.Decode as Decode exposing (Decoder)


type alias Person =
    { name : String
    , age : Int
    }


type alias Model =
    Maybe Person


type Msg
    = GotPerson (Result Http.Error Person)


personDecoder : Decoder Person
personDecoder =
    Decode.map2 Person
        (Decode.field "name" Decode.string)
        (Decode.field "age" Decode.int)


getPerson : Cmd Msg
getPerson =
    Http.get
        { url = "/data.json"
        , expect = Http.expectJson GotPerson personDecoder
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Nothing, getPerson )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotPerson result ->
            case result of
                Ok person ->
                    ( Just person, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ case model of
            Just person ->
                div []
                    [ text ("Name: " ++ person.name)
                    , text ("Age: " ++ String.fromInt person.age)
                    ]

            Nothing ->
                text "Loading..."
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
