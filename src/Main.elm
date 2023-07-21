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
        |> required "is_private" Decode.bool
        |> required "is_fork" Decode.bool
        |> required "is_archived" Decode.bool
        |> required "is_template" Decode.bool
        |> required "disk_usage" Decode.int
        |> required "pushed_at" Decode.string
        |> required "topics" (Decode.list Decode.string)
        |> required "languages" (Decode.list repositoryLanguageDecoder)
        |> required "total_commit_count" Decode.int
        |> required "period_commit_count" Decode.int


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
    Maybe (List RepositoryStat)


type Msg
    = Init (Result Http.Error (List RepositoryStat))


loadJson : Cmd Msg
loadJson =
    Http.get
        { url = "/data/github_stats.json"
        , expect = Http.expectJson Init repositoryStatListDecoder
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Nothing, loadJson )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init result ->
            case result of
                Ok initialData ->
                    ( Just initialData, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ case model of
            Just repositoryStats ->
                div []
                    [ text ("Repository size: " ++ String.fromInt (List.length repositoryStats)) ]

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
