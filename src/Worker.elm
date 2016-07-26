module Worker exposing (programWithFlags, program)

{-| Start Elm applications without a view

@docs programWithFlags, program
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


{-| Start a worker program with flags from the outside world, including extra
Cmds to wrap init and update in case you want to include port calls on every
Msg.

In your Elm program

    port modelOut : Model -> Cmd msg

    main : Program { userId: String, token : String }
    main =
        Worker.workerWithFlags modelOut
            { init = \{ userId, token } -> init userId token
            , update = update
            , subscriptions = subscriptions
            }

In JavaScript

    var app = Elm.MyApp.worker({
        userId: 'Tom',
        token: '12345'
    });
-}
programWithFlags :
    (model -> Cmd msg)
    -> { init : flags -> ( model, Cmd msg )
       , update : msg -> model -> ( model, Cmd msg )
       , subscriptions : model -> Sub msg
       }
    -> Program flags
programWithFlags extraCmds { init, update, subscriptions } =
    VirtualDom.programWithFlags
        { init = wrapInit extraCmds init
        , update = wrapUpdate extraCmds update
        , subscriptions = subscriptions
        , view = \_ -> VirtualDom.text ""
        }


{-| Start a worker program, including extra Cmds to wrap init and update in case
you want to include port calls on every Msg.

    port modelOut : Model -> Cmd msg

    main : Program Never
    main =
        Worker.worker modelOut
            { init = init
            , update = update
            , subscriptions = subscriptions
            }
-}
program :
    (model -> Cmd msg)
    -> { init : ( model, Cmd msg )
       , update : msg -> model -> ( model, Cmd msg )
       , subscriptions : model -> Sub msg
       }
    -> Program Never
program extraCmds { init, update, subscriptions } =
    programWithFlags extraCmds
        { init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
