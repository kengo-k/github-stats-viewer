module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, scope)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


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


type alias RepositoryLanguage =
    { name : String
    , color : String
    , size : Int
    }


type alias Model =
    { stats : Maybe (List RepositoryStat)
    , sortStats : RepositoryStat -> RepositoryStat -> Order
    }


type Msg
    = Init (Result Http.Error (List RepositoryStat))


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


renderTopics : List String -> List (Html Msg)
renderTopics topics =
    List.map
        (\t ->
            span [ class "inline-flex items-center gap-1.5 py-0.5 px-2 mx-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200" ] [ text t ]
        )
        topics


renderTable : List RepositoryStat -> Html Msg
renderTable repositoryStats =
    div [ class "max-w-[85rem] px-4 py-10 sm:px-6 lg:px-8 lg:py-14 mx-auto" ]
        [ div [ class "flex flex-col" ]
            [ div [ class "-m-1.5 overflow-x-auto" ]
                [ div [ class "p-1.5 min-w-full inline-block align-middle" ]
                    [ div [ class "bg-white border border-gray-200 rounded-xl shadow-sm dark:bg-slate-900 dark:border-gray-700 h-96 overflow-y-auto" ]
                        [ div [ class "px-6 py-4 grid gap-3 md:flex md:justify-between md:items-center border-b border-gray-200 dark:border-gray-700" ]
                            [ div []
                                [ h2 [ class "text-xl font-semibold text-gray-800 dark:text-gray-200" ] [ text "Repositories" ]
                                ]
                            , div []
                                [ div [] []
                                ]
                            ]
                        , table [ class "min-w-full divide-y divide-gray-200 dark:divide-gray-700" ]
                            [ thead [ class "bg-gray-50 dark:bg-slate-800 sticky top-0" ]
                                [ tr [ class "" ]
                                    [ th [ scope "col", class "pl-6 py-3 text-left" ]
                                        [ div [ class "flex items-center gap-x-2" ]
                                            [ span [ class "text-xs font-semibold uppercase tracking-wide text-gray-800 dark:text-gray-200" ] [ text "Name" ]
                                            ]
                                        ]
                                    , th [ scope "col", class "pl-6 py-3 text-left" ]
                                        [ div [ class "flex items-center gap-x-2" ]
                                            [ span [ class "text-xs font-semibold uppercase tracking-wide text-gray-800 dark:text-gray-200" ] [ text "Topics" ]
                                            ]
                                        ]
                                    , th [ scope "col", class "pl-6 py-3 text-left" ]
                                        [ div [ class "flex items-center gap-x-2" ]
                                            [ span [ class "text-xs font-semibold uppercase tracking-wide text-gray-800 dark:text-gray-200" ] [ text "Commit" ]
                                            ]
                                        ]
                                    , th [ scope "col", class "pl-6 py-3 text-left" ]
                                        [ div [ class "flex items-center gap-x-2" ]
                                            [ span [ class "text-xs font-semibold uppercase tracking-wide text-gray-800 dark:text-gray-200" ] [ text "Pushed_At" ]
                                            ]
                                        ]
                                    ]
                                ]
                            , tbody [ class "divide-y divide-gray-200 dark:divide-gray-700" ]
                                (List.map
                                    (\r ->
                                        tr []
                                            [ td [ class "h-px w-px whitespace-nowrap" ]
                                                [ div [ class "px-6 py-3" ]
                                                    [ span [ class "block text-sm font-semibold text-gray-800 dark:text-gray-200" ] [ text r.name ]
                                                    , span [ class "block text-xs text-gray-500" ] [ text ((r.diskUsage |> String.fromInt) ++ "KB") ]
                                                    ]
                                                ]
                                            , td [ class "h-px w-px whitespace-nowrap" ]
                                                [ div [ class "px-6 py-3" ]
                                                    (renderTopics r.topics)
                                                ]
                                            , td [ class "h-px w-px whitespace-nowrap" ]
                                                [ div [ class "px-6 py-3" ]
                                                    [ span [ class "block text-sm font-semibold text-gray-800 dark:text-gray-200" ] [ text (r.totalCommitCount |> String.fromInt) ]
                                                    ]
                                                ]
                                            , td [ class "h-px w-px whitespace-nowrap" ]
                                                [ div [ class "px-6 py-3" ]
                                                    [ span [ class "block text-sm font-semibold text-gray-800 dark:text-gray-200" ] [ text (r.pushedAt |> String.left 10) ]
                                                    ]
                                                ]
                                            ]
                                    )
                                    repositoryStats
                                )
                            ]
                        ]
                    ]
                ]
            ]
        ]


repositoryStatListDecoder : Decoder (List RepositoryStat)
repositoryStatListDecoder =
    Decode.list repositoryStatDecoder


repositoryLanguageDecoder : Decoder RepositoryLanguage
repositoryLanguageDecoder =
    Decode.succeed RepositoryLanguage
        |> required "name" Decode.string
        |> required "color" Decode.string
        |> required "size" Decode.int


loadJson : Cmd Msg
loadJson =
    Http.get
        { url = "/data/github_stats.json"
        , expect = Http.expectJson Init repositoryStatListDecoder
        }


sortStatsByDefault : RepositoryStat -> RepositoryStat -> Order
sortStatsByDefault a b =
    let
        period =
            compare b.periodCommitCount a.periodCommitCount

        pushed =
            compare b.pushedAt a.pushedAt

        total =
            compare b.totalCommitCount a.periodCommitCount
    in
    if period /= EQ then
        period

    else if pushed /= EQ then
        pushed

    else
        total


init : () -> ( Model, Cmd Msg )
init _ =
    ( { stats = Nothing, sortStats = sortStatsByDefault }, loadJson )


view : Model -> Html Msg
view model =
    div []
        [ case model.stats of
            Just repositoryStats ->
                div []
                    [ renderTable repositoryStats ]

            Nothing ->
                text "Loading..."
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init result ->
            case result of
                Ok initialData ->
                    ( { model | stats = Just (List.sortWith model.sortStats initialData) }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
