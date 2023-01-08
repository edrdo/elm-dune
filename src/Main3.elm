module Main3 exposing (..)

import Browser
import Html exposing (Html)
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

type Status =
    Failure 
  | Loading
  | Loaded

type alias Model = 
    { status: Status
    , address: String
    , request_time: Int
    , json: String
    , msgs: List (IMC.Header, IMC.Message) } 

 
default_address : String
default_address = "http://127.0.0.1:8888"

init : () -> (Model, Cmd Msg)
init _ =
  let s = { status=Loading, address=default_address, request_time=0, json="", msgs=[] } in 
    (s, fetch_data s.address)
 
fetch_data : String -> Cmd Msg
fetch_data address = 
    Http.get { url = address ++ "/dune/state/toJSON" 
            , expect = Http.expectString ServerData }


-- UPDATE


type Msg
  = ServerData (Result Http.Error String) 
  | Tick Time.Posix


update : Msg -> Model -> (Model, Cmd Msg)
update msg m =
  case msg of
    ServerData sd ->
      case sd of
        Ok data ->
          ({ m | status=Loaded, json=data, msgs=IMC.decode data }
          , Cmd.none)
        Err _ ->
          ({ m | status=Failure, json="", msgs=[] }
          , Cmd.none)
    Tick t -> 
      ({ m | status = Loading, request_time=Time.posixToMillis t }
      , fetch_data m.address)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Time.every 1000 Tick

-- VIEW 
view : Model -> Html Msg
view m =
  Html.div [] 
      [ Debug.toString m.status |> Html.text |> section "Status" 
      , m.address |> Html.text |> section "Address"
      , String.fromInt m.request_time |> Html.text |> section "Request time" 
      , Html.pre [] [ Html.text m.json ] |> section "JSON"
      , List.map header m.msgs |> Html.ol [] |> section "IMC" ]

section : String -> Html msg -> Html msg
section desc data = 
    Html.div [] 
      [ Html.b [] [ Html.text (desc ++ ": ")]
      , data ]

toString: a -> String
toString x =
  Debug.toString x 
  |> String.replace "{" "{<br/>\n&nbsp&nbsp;"
  |> String.replace "]" "{<br/>\n"
  |> String.replace "]" "{<br/>\n"

header: (IMC.Header,IMC.Message) -> Html Msg
header (h,m) = 
  Html.li [] 
    [ Debug.toString h |> Html.text |> section "Header"
    , Debug.toString m |> Html.text |> section "Message" ]  

  
   

