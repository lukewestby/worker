# Worker

Start Elm apps without views

### Example

```elm
port module Main exposing (..)

import Worker
import Time

type alias Model =
    Int

init : (Model, Cmd Msg)
init =
    (0, Cmd.none)


type Msg
    = Increment


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            model + 1


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every (1 * Time.second) (\_ -> Increment)


port modelOut : Model -> Cmd msg


main : Program Never
main =
    Worker.worker modelOut
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
```


```javascript
var app = Elm.Main.worker()
app.ports.modelOut.subscribe(function (model) {
  document.getElementById('seconds').innerHTML = model.toString()
})
```
