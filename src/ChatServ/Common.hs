{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module ChatServ.Common where

import Prelude hiding (lookup)
import Network.WebSockets
import Data.Aeson
import GHC.Generics
import Data.Maybe
import Data.Map.Strict
import Data.IORef
import Data.Text (Text)
import Control.Exception (bracket)
import Control.Monad (mapM_)

data ChatMessage = ChatMessage {
    user_name :: Text,
    user_text :: Text
  } deriving (Generic)

instance FromJSON ChatMessage
instance ToJSON ChatMessage

instance WebSocketsData ChatMessage where
  fromLazyByteString bs =
    fromMaybe (error "error") (decode bs)
  toLazyByteString = encode
