# Worker

## This package is deprecated as of Elm 0.18 and the addition of `Platform.program`.

The example below explains how to use `Platform.program` to provide the
functionality you might have used this package for prior to 0.18.

### Example

**Main.elm**
```elm
port module Main exposing (..)

import Platform

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


{-| This update will send a Cmd to send the model out over a port on every msg. This
can be abstracted into a separate function as your app becomes larger and your
updates become more complicated.
-}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    let
        (nextModel, nextCmd) =
            case msg of
                Increment ->
                    (model + 1, Cmd.none)

                NoOp ->
                    (model, Cmd.none)
    in
      ( nextModel
      , Cmd.batch
          [ nextCmd
          , modelOut nextModel
          ]
      )


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


main : Program Never
main =
    Platform.program
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
