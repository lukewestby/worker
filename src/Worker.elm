module Worker exposing (workerWithFlags, worker, beginnerWorker)

{-| Start Elm applications without a view

@docs workerWithFlags, worker, beginnerWorker
-}

import VirtualDom


wrapUpdate :
    (model -> Cmd msg)
    -> (msg -> model -> ( model, Cmd msg ))
    -> (msg -> model -> ( model, Cmd msg ))
wrapUpdate extraCmds innerUpdate =
    \msg model ->
        let
            ( nextModel, nextCmd ) =
                innerUpdate msg model
        in
            ( nextModel
            , Cmd.batch [ nextCmd, extraCmds nextModel ]
            )


wrapInit :
    (model -> Cmd msg)
    -> (flags -> ( model, Cmd msg ))
    -> (flags -> ( model, Cmd msg ))
wrapInit extraCmds innerInit =
    \flags ->
        let
            ( nextModel, nextCmd ) =
                innerInit flags
        in
            ( nextModel
            , Cmd.batch [ nextCmd, extraCmds nextModel ]
            )


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
    (model -> Cmd msg)
    -> { init : flags -> ( model, Cmd msg )
       , update : msg -> model -> ( model, Cmd msg )
       , subscriptions : model -> Sub msg
       }
    -> Program flags
workerWithFlags extraCmds { init, update, subscriptions } =
    VirtualDom.programWithFlags
        { init = wrapInit extraCmds init
        , update = wrapUpdate extraCmds update
        , subscriptions = subscriptions
        , view = \_ -> VirtualDom.text ""
        }


{-| Start a worker program
-}
worker :
    (model -> Cmd msg)
    -> { init : ( model, Cmd msg )
       , update : msg -> model -> ( model, Cmd msg )
       , subscriptions : model -> Sub msg
       }
    -> Program Never
worker extraCmds { init, update, subscriptions } =
    workerWithFlags extraCmds
        { init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }


{-| Start a worker program with just a model a simpler update function
-}
beginnerWorker :
    (model -> Cmd msg)
    -> { model : model
       , update : msg -> model -> model
       }
    -> Program Never
beginnerWorker extraCmds { model, update } =
    worker extraCmds
        { init = ( model, Cmd.none )
        , update = \msg model -> ( update msg model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
