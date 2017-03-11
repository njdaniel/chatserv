{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module Main where

import Prelude hiding (lookup)
import Network.Wai.Handler.Warp
import Network.WebSockets
import Network.Wai
import Network.Wai.Handler.WebSockets
import Data.Aeson
import GHC.Generics
import Data.Maybe
import Data.Map.Strict
import Data.IORef
import Data.Text (Text)
import Control.Exception (bracket)
import Control.Monad (mapM_)
import ChatServ.Common

chatApp :: IORef [ChatMessage] -> IORef (Map Integer Connection) -> IORef Integer -> Application
chatApp chatlogRef connsRef counterRef = websocketsOr defaultConnectionOptions wsApp backupApp where
  wsApp :: ServerApp
  wsApp pending_conn = do
    bracket
      (do
        conn <- acceptRequest pending_conn
        next <- atomicModifyIORef counterRef (\i -> (i+1, i))
        atomicModifyIORef connsRef (\conns -> (insert next conn conns, ()))
        return (next, conn))
      (\(next, _) ->
        atomicModifyIORef connsRef (\conns -> (delete next conns, ())))
      (\(_, conn) -> do
        msgs <- readIORef chatlogRef
        sendTextDatas conn msgs
        worker conn)
  worker :: Connection -> IO ()
  worker conn = do
    cm <- receiveData conn
    atomicModifyIORef chatlogRef (\chatlog-> (chatlog ++ [cm], ()))
    sendUpdates cm
    worker conn
  sendUpdates :: ChatMessage -> IO ()
  sendUpdates cm = do
    conns <- readIORef connsRef
    mapM_ (\conn -> sendTextData conn cm) (elems conns)
  backupApp :: Application
  backupApp = error "error"

main :: IO ()
main = do
  chatlogRef <- newIORef []
  connsRef <- newIORef empty
  counterRef <- newIORef 0
  run 8000 (chatApp chatlogRef connsRef counterRef)
