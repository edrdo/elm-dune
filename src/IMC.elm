module IMC exposing(decodeDbg,decode,Header,Message)

import Json.Decode as D
import Json.Decode exposing(Decoder)
import Json.Decode.Pipeline as DP
import Dict exposing(Dict)

-- Utility functions
strconv : (String -> Maybe a) -> String -> Decoder a
strconv f str= 
    let v = (f (String.filter (\c -> c /= '\"') str)) in case v of
            Just x -> 
                D.succeed x
            Nothing ->
                D.fail ("Invalid value: \"" ++ str ++ "\"")

conv: (String -> Maybe a) -> Decoder a
conv f = D.string |> D.andThen (strconv f)

int_ : Decoder Int
int_ = conv String.toInt

float_ : Decoder Float
float_ = conv String.toFloat

decodeDbg: String -> String --Result Error (List (Dict String String))abbrev
decodeDbg str =
    case D.decodeString (D.list (D.dict D.string)) str of
        Ok v -> 
            Debug.toString v
        Err e ->
            Debug.toString e

-- IMC definitions
type alias Header = 
    { abbrev: String
    , timestamp: Float
    , src: Int
    , src_ent: Int
    , dst: Int
    , dst_ent: Int
    }

imc_header_decoder: Decoder Header
imc_header_decoder = 
    D.succeed Header
    |> DP.required "abbrev" D.string
    |> DP.required "timestamp" float_
    |> DP.required "src" int_
    |> DP.required "src_ent" int_
    |> DP.required "dst" int_
    |> DP.required "dst_ent" int_

type alias AnnounceFields = 
  { sys_name: String
  , sys_type: Int
  , owner: Int
  , lat: Float
  , lon: Float
  , height: Float
  , services: String }

type alias EntityStateFields = 
  { state: Int 
  , flags: Int
  , description: String } 
type alias CpuUsageFields = { value : Int }

type alias EstimatedStateFields = 
   { lat: Float
   , lon: Float
   , height: Float
   , x: Float
   , y: Float
   , z: Float
   , phi: Float
   , theta: Float
   , psi: Float
   , u: Float
   , v: Float
   , w: Float
   , vx: Float
   , vy: Float
   , vz: Float
   , p: Float
   , q: Float
   , r: Float
   , depth: Float
   , alt : Float }

type Message = 
      Announce AnnounceFields
    | CpuUsage CpuUsageFields  
    | EntityState EntityStateFields 
    | EstimatedState EstimatedStateFields 
    | Heartbeat 
    | UnparsedMessage 

imc_decoder_map: Dict String (Decoder Message)
imc_decoder_map = Dict.fromList 
    [("Announce",
    D.map Announce (
        D.succeed AnnounceFields
        |> DP.required "sys_name" D.string
        |> DP.required "sys_type" int_
        |> DP.required "owner" int_
        |> DP.required "lat" float_
        |> DP.required "lon" float_
        |> DP.required "height" float_
        |> DP.required "services" D.string ))
    ,("CpuUsage", 
    D.map CpuUsage (
        D.succeed CpuUsageFields 
        |> DP.required "value" int_))
   ,("EstimatedState",     
    D.map EstimatedState (
        D.succeed EstimatedStateFields
        |> DP.required "lat" float_
        |> DP.required "lon" float_
        |> DP.required "height" float_ 
        |> DP.required "x" float_
        |> DP.required "y" float_
        |> DP.required "z" float_  
        |> DP.required "phi" float_
        |> DP.required "theta" float_
        |> DP.required "psi" float_        
        |> DP.required "u" float_
        |> DP.required "v" float_
        |> DP.required "w" float_  
        |> DP.required "vx" float_
        |> DP.required "vy" float_
        |> DP.required "vz" float_      
        |> DP.required "p" float_
        |> DP.required "q" float_
        |> DP.required "r" float_       
        |> DP.required "depth" float_
        |> DP.required "alt" float_  
        ))
    ,("EntityState",     
    D.map EntityState (
        D.succeed EntityStateFields
        |> DP.required "state" int_
        |> DP.required "flags" int_
        |> DP.required "description" D.string ))
    ,("Heartbeat",
    D.succeed Heartbeat)]

imc_payload_decoder : Header -> Decoder (Header, Message)
imc_payload_decoder h = 
    D.map2 Tuple.pair (D.succeed h) (
        case Dict.get h.abbrev imc_decoder_map of
            Just d -> d
            Nothing -> D.succeed UnparsedMessage
    )

imc_decoder: Decoder (Header,Message)
imc_decoder=
    imc_header_decoder 
    |> D.andThen imc_payload_decoder
    

decode: String -> List (Header,Message)
decode json =
    case D.decodeString (D.list imc_decoder) json of
        Ok v -> 
            v
        Err _ ->
            []