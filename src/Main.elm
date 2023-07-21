module Main exposing (..)

import Browser
import Html exposing (Html, div, text)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Svg exposing (rect, svg)
import Svg.Attributes exposing (..)


type alias Person =
    { name : String
    , age : Int
    }


type alias RepositoryStat =
    { id : String
    , name : String
    , isPrivate : Bool
    , isFork : Bool
    , isArchived : Bool
    , isTemplate : Bool
    , diskUsage : Int
    , pushedAt : String
    , topics : List String
    , languages : List RepositoryLanguage
    , totalCommitCount : Int
    , periodCommitCount : Int
    }


repositoryStatDecoder : Decoder RepositoryStat
repositoryStatDecoder =
    Decode.succeed RepositoryStat
        |> required "id" Decode.string
        |> required "name" Decode.string
        |> required "isPrivate" Decode.bool
        |> required "isFork" Decode.bool
        |> required "isArchived" Decode.bool
        |> required "isTemplate" Decode.bool
        |> required "diskUsage" Decode.int
        |> required "pushedAt" Decode.string
        |> required "topics" (Decode.list Decode.string)
        |> required "languages" (Decode.list repositoryLanguageDecoder)
        |> required "totalCommitCount" Decode.int
        |> required "periodCommitCount" Decode.int


repositoryStatListDecoder : Decoder (List RepositoryStat)
repositoryStatListDecoder =
    Decode.list repositoryStatDecoder


type alias RepositoryLanguage =
    { name : String
    , color : String
    , size : Int
    }


repositoryLanguageDecoder : Decoder RepositoryLanguage
repositoryLanguageDecoder =
    Decode.succeed RepositoryLanguage
        |> required "name" Decode.string
        |> required "color" Decode.string
        |> required "size" Decode.int


type alias Model =
    Maybe Person


type Msg
    = GotPerson (Result Http.Error Person)


personDecoder : Decode.Decoder Person
personDecoder =
    Decode.map2 Person
        (Decode.field "name" Decode.string)
        (Decode.field "age" Decode.int)


dog : String -> Int -> { name : String, age : Int }
dog name age =
    { name = name, age = age }


dogDecoder =
    Decode.succeed dog
        |> required "name" Decode.string
        |> required "age" Decode.int


getPerson : Cmd Msg
getPerson =
    Http.get
        { url = "/data/github_stats.json"
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
        , drawRectangle 10 10 50 50
        ]


drawRectangle : Float -> Float -> Float -> Float -> Html.Html msg
drawRectangle posX posY rectWidth rectHeight =
    svg [ viewBox "0 0 200 200", width "100%", height "100%" ]
        [ rect
            [ x (String.fromFloat posX)
            , y (String.fromFloat posY)
            , width (String.fromFloat rectWidth)
            , height (String.fromFloat rectHeight)
            , fill "blue"
            ]
            []
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
