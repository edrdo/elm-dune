module Main0 exposing (..)-- Make a GET request to load a book called "Public Opinion"
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/http.html
--

import Browser
import Html exposing (Html, text, pre)
import Http



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
  = Failure Http.Error
  | Loading
  | Success String


init : () -> (Model, Cmd Msg)
init _ =
  ( Loading
  , Http.request
      { method = "GET"
      , headers = [ Http.header "Access-Control-Allow-Origin" "*"]
      , url = "http://192.168.86.65:8080/index.html"
      , expect = Http.expectString GotText
      , body = Http.emptyBody
      , timeout = Nothing
      , tracker = Nothing }
  )



-- UPDATE


type Msg
  = GotText (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg _ =
  case msg of
    GotText result ->
      case result of
        Ok fullText ->
          (Success fullText, Cmd.none)

        Err e ->
          (Failure e, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  case model of
    Failure (Http.NetworkError) -> 
      text "I was unable to load your book. 000"
    Failure _ ->
      text "I was unable to load your book."

    Loading ->
      text "Loading..."

    Success fullText ->
      pre [] [ text fullText ]