module Main2 exposing (..)

import Browser
import Html exposing (Html, text, pre)
import Http
import IMC
import Time


-- MAIN


main : Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }



-- MODEL


type Model
  = Failure
  | Loading
  | Success String


init : () -> (Model, Cmd Msg)
init _ =
  ( Loading
  , fetch_data
  )

fetch_data : Cmd Msg
fetch_data = Http.get
      { url = "http://127.0.0.1:8888/dune/state/toJSON" -- "https://gutenberg.org/files/69641/69641-0.txt" -- url = "https://elm-lang.org/assets/public-opinion.txt"
      , expect = Http.expectString GotText
      }


-- UPDATE


type Msg
  = GotText (Result Http.Error String) 
  | Tick Time.Posix


update : Msg -> Model -> (Model, Cmd Msg)
update msg _ =
  case msg of
    GotText result ->
      case result of
        Ok fullText ->
          (Success ( Debug.toString (IMC.decode fullText)), Cmd.none)
        Err _ ->
          (Failure, Cmd.none)
    Tick _ -> 
        (Loading, fetch_data)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Time.every 1000 Tick



-- VIEW


view : Model -> Html Msg
view model =
  case model of
    Failure ->
      text "I was unable to load your book."

    Loading ->
      text "Loading..."

    Success fullText ->
      pre [] [ text fullText ]