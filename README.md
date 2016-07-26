# Worker

Start Elm apps without views

### Example


**Main.elm**
```elm
port module Main exposing (..)

import Worker

{-| We'll receive messages from the world in the form of strings here -}
port messagesIn : (String -> msg) -> Sub msg

{-| This port will send our counter back out to the world -}
port modelOut : Model -> Cmd msg


type alias Model =
    Int


init : (Model, Cmd Msg)
init =
    (0, Cmd.none)


type Msg
    = Increment
    | NoOp


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            model + 1

        NoOp ->
            model


{-| In this function we define `parse` in order to go from
the strings that the outside world sends us to the messages our
program knows about. We then pass `parse` to `messagesIn` to get
a subscription that can update our program from things that happen
in JavaScript-land
-}
subscriptions : Model -> Sub Msg
subscriptions _ =
    let
        parse value =
            case value of
                "Increment" ->
                    Increment

                _ ->
                    NoOp
    in
        messagesIn parse


{-| The first argument to Worker.worker lets us wrap our update
function with additional Cmds to execute on every change. In this
case we want to send our model out to JS on every update so we
pass it our `modelOut` port. We are already receiving messages from
our `messagesIn` port via `subscriptions` so now we're fully connected
to the JavaScript side of the application!
-}
main : Program Never
main =
    Worker.program modelOut
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
```


**app.js**
```javascript
window.addEventListener('loaded', function () {
  var app = Elm.Main.worker()

  app.ports.modelOut.subscribe(function (model) {
    document.getElementById('count').innerHTML = model;
  })

  document
    .getElementById('incrementButton')
    .addEventListener('click', function () {
      app.ports.messagesIn.send('Increment')
    })
})
```


**index.html**
```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
  </head>
  <body>
    <div id="count"></div>
    <div>
      <button id="incrementButton">+ 1</button>
    </div>
    <script src="elm-compiler-output.js"></script>
    <script src="app.js"></script>
  </body>
</html>
```
