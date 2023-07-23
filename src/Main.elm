module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, scope, style)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Svg exposing (path, svg)
import Svg.Attributes as SvgAttr exposing (d, viewBox)


type alias RepositoryStat =
    { id : String
    , name : String
    , isPrivate : Bool
    , isFork : Bool
    , isArchived : Bool
    , isTemplate : Bool
    , diskUsage : Int
    , stargazerCount : Int
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


type SortItem
    = Name
    | Commit
    | PushedAt


type SortOrder
    = Asc
    | Desc


type Msg
    = Init (Result Http.Error (List RepositoryStat))
    | Sort SortItem SortOrder



-- <div class="flex justify-center items-center w-5 h-5 border border-gray-200 group-hover:bg-gray-200 text-gray-400 rounded dark:border-gray-700 dark:group-hover:bg-gray-700 dark:text-gray-400">
--                                               <svg class="w-2.5 h-2.5" width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
--                                                 <path d="M7.55921 0.287451C7.86808 -0.0958171 8.40096 -0.0958167 8.70982 0.287451L12.9295 5.52367C13.3857 6.08979 13.031 7 12.3542 7H3.91488C3.23806 7 2.88336 6.08979 3.33957 5.52367L7.55921 0.287451Z" fill="currentColor"></path>
--                                                 <path d="M8.70983 15.7125C8.40096 16.0958 7.86808 16.0958 7.55921 15.7125L3.33957 10.4763C2.88336 9.9102 3.23806 9 3.91488 9H12.3542C13.031 9 13.3857 9.9102 12.9295 10.4763L8.70983 15.7125Z" fill="currentColor"></path>
--                                               </svg>
--                                             </div>


renderSortIcon : Html Msg
renderSortIcon =
    span [ class "w-5 h-5 border border-gray-200 group-hover:bg-gray-200 text-gray-400 rounded dark:border-gray-700 dark:group-hover:bg-gray-700 dark:text-gray-400 inline-block" ]
        [ text "A"
        ]


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
        |> required "stargazer_count" Decode.int
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
        (List.sort topics)


renderLanguages : List RepositoryLanguage -> List (Html Msg)
renderLanguages langs =
    List.map
        (\l ->
            span [ class "inline-flex items-center gap-1.5 py-0.5 px-2 mx-0.5 text-xs font-medium text-gray-600" ]
                [ span
                    [ class "lang-circle"
                    , style "background-color" l.color
                    , style "border-color" l.color
                    ]
                    []
                , span [] [ text l.name ]
                ]
        )
        (List.sortBy .size langs)
        |> List.reverse


renderStarIcon : Html Msg
renderStarIcon =
    svg
        [ viewBox "0 0 16 16"
        , SvgAttr.width "16"
        , SvgAttr.height "16"
        , SvgAttr.class "star"
        ]
        [ path [ d "M8 .25a.75.75 0 0 1 .673.418l1.882 3.815 4.21.612a.75.75 0 0 1 .416 1.279l-3.046 2.97.719 4.192a.751.751 0 0 1-1.088.791L8 12.347l-3.766 1.98a.75.75 0 0 1-1.088-.79l.72-4.194L.818 6.374a.75.75 0 0 1 .416-1.28l4.21-.611L7.327.668A.75.75 0 0 1 8 .25Zm0 2.445L6.615 5.5a.75.75 0 0 1-.564.41l-3.097.45 2.24 2.184a.75.75 0 0 1 .216.664l-.528 3.084 2.769-1.456a.75.75 0 0 1 .698 0l2.77 1.456-.53-3.084a.75.75 0 0 1 .216-.664l2.24-2.183-3.096-.45a.75.75 0 0 1-.564-.41L8 2.694Z" ] [] ]


renderTable : List RepositoryStat -> Html Msg
renderTable repositoryStats =
    div [ class "max-w-[85rem] px-4 py-10 sm:px-6 lg:px-8 lg:py-14 mx-auto" ]
        [ div [ class "flex flex-col" ]
            [ div [ class "-m-1.5 overflow-x-auto" ]
                [ div [ class "p-1.5 min-w-full inline-block align-middle" ]
                    [ div [ class "bg-white border border-gray-200 rounded-xl shadow-sm dark:bg-slate-900 dark:border-gray-700 h-96 overflow-y-auto" ]
                        [ div [ class "px-6 py-4 grid gap-3 md:flex md:justify-between md:items-center border-b border-gray-200 dark:border-gray-700" ]
                            [ div []
                                [ h2 [ class "text-xl font-semibold text-gray-800 dark:text-gray-200" ] [ text "GitHub Repositories" ]
                                , p [ class "text-sm text-gray-600 dark:text-gray-400" ] [ text ("count: " ++ (repositoryStats |> List.length |> String.fromInt)) ]
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
                                            [ span [ class "text-xs font-semibold tracking-wide text-gray-800 dark:text-gray-200" ] [ text "Name", renderSortIcon ]
                                            ]
                                        ]
                                    , th [ scope "col", class "pl-6 py-3 text-left" ]
                                        [ div [ class "flex items-center gap-x-2" ]
                                            [ span [ class "text-xs font-semibold tracking-wide text-gray-800 dark:text-gray-200" ] [ text "Types" ]
                                            ]
                                        ]
                                    , th [ scope "col", class "pl-6 py-3 text-left" ]
                                        [ div [ class "flex items-center gap-x-2" ]
                                            [ span [ class "text-xs font-semibold tracking-wide text-gray-800 dark:text-gray-200" ] [ text "Commit", renderSortIcon ]
                                            ]
                                        ]
                                    , th [ scope "col", class "pl-6 py-3 text-left" ]
                                        [ div [ class "flex items-center gap-x-2" ]
                                            [ span [ class "text-xs font-semibold tracking-wide text-gray-800 dark:text-gray-200" ] [ text "Pushed At" ]
                                            ]
                                        ]
                                    ]
                                ]
                            , tbody [ class "divide-y divide-gray-200 dark:divide-gray-700" ]
                                (List.map
                                    (\r ->
                                        let
                                            template =
                                                if r.isTemplate then
                                                    [ span [ class "inline-flex items-center gap-1.5 py-0.5 px-2 mx-3 text-xs font-medium bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200" ] [ text "template" ] ]

                                                else
                                                    []

                                            archived =
                                                if r.isArchived then
                                                    [ span [ class "inline-flex items-center gap-1.5 py-0.5 px-2 mx-3 text-xs font-medium bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200" ] [ text "archived" ] ]

                                                else
                                                    []
                                        in
                                        tr []
                                            [ td [ class "h-px w-px whitespace-nowrap" ]
                                                [ div [ class "px-6 py-3" ]
                                                    ([ span [ class "block text-sm font-semibold text-gray-800 dark:text-gray-200" ] [ text r.name ]
                                                     , span [ class "text-xs text-gray-500 mx-1" ] [ renderStarIcon, text (r.stargazerCount |> String.fromInt) ]
                                                     , span [ class "text-xs text-gray-500" ] [ text (" disk size: " ++ (r.diskUsage |> String.fromInt) ++ "KB") ]
                                                     ]
                                                        ++ template
                                                        ++ archived
                                                    )
                                                ]
                                            , td [ class "h-px w-px whitespace-nowrap" ]
                                                [ div [ class "px-6 py-3" ]
                                                    [ div [] (span [ class "text-xs font-normal text-gray-600" ] [ text "Languages: " ] :: renderLanguages r.languages)
                                                    , div [] (span [ class "text-xs font-normal text-gray-600 mr-8 inline-block" ] [ text "Topics: " ] :: renderTopics r.topics)
                                                    ]
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


createCustomSort : (RepositoryStat -> RepositoryStat -> Order) -> (RepositoryStat -> RepositoryStat -> Order)
createCustomSort customSort =
    \a b ->
        let
            ord =
                customSort a b
        in
        case ord of
            EQ ->
                sortStatsByDefault a b

            _ ->
                ord


getCustomSort : SortItem -> SortOrder -> (RepositoryStat -> RepositoryStat -> Order)
getCustomSort item order =
    let
        nameAsc =
            \a b -> compare a.name b.name

        nameDesc =
            \a b -> compare b.name a.name

        commitAsc =
            \a b -> compare a.totalCommitCount b.totalCommitCount

        commitDesc =
            \a b -> compare b.totalCommitCount a.totalCommitCount

        pushedAsc =
            \a b -> compare a.pushedAt b.pushedAt

        pushedDesc =
            \a b -> compare b.pushedAt a.pushedAt
    in
    case ( item, order ) of
        ( Name, Asc ) ->
            \a b -> createCustomSort nameAsc a b

        ( Name, Desc ) ->
            \a b -> createCustomSort nameDesc a b

        ( Commit, Asc ) ->
            \a b -> createCustomSort commitAsc a b

        ( Commit, Desc ) ->
            \a b -> createCustomSort commitDesc a b

        ( PushedAt, Asc ) ->
            \a b -> createCustomSort pushedAsc a b

        ( PushedAt, Desc ) ->
            \a b -> createCustomSort pushedDesc a b


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init result ->
            case result of
                Ok initialData ->
                    ( { model | stats = Just (List.sortWith model.sortStats initialData) }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        Sort item order ->
            case model.stats of
                Just stats ->
                    ( { model | sortStats = getCustomSort item order, stats = Just (List.sortWith (getCustomSort item order) stats) }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
