module Worker exposing (workerWithFlags, worker)

{-| Start Elm applications without a view

@docs workerWithFlags, worker
-}

import VirtualDom


{-| Start a worker program with flags from the outside world

    ```javascript
    // Program { userId : String, token : String }

    var app = Elm.MyApp.worker({
        userId: 'Tom',
        token: '12345'
    });
    ```
-}
workerWithFlags :
    { init : flags -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    }
    -> Program flags
workerWithFlags stuff =
    VirtualDom.programWithFlags
        { init = stuff.init
        , update = stuff.update
        , subscriptions = stuff.subscriptions
        , view = \_ -> VirtualDom.text ""
        }


{-| Start a worker program
-}
worker :
    { init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    }
    -> Program Never
worker stuff =
    workerWithFlags
        { init = \_ -> stuff.init
        , update = stuff.update
        , subscriptions = stuff.subscriptions
        }
