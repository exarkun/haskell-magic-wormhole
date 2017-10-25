module Rendezvous (tests) where

import Protolude

import Data.Aeson (encode, decode)
import Hedgehog (MonadGen(..), forAll, property, tripping)
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.Hedgehog (testProperty)

import MagicWormhole.Internal.Rendezvous
  ( ClientMessage(..)
  , ServerMessage(..)
  , AppID(..)
  , Side(..)
  )

tests :: IO TestTree
tests = pure $ testGroup "Rendezvous"
  [ testProperty "client messages roundtrip" $ property $ do
      x <- forAll clientMessages
      tripping x encode decode
  , testProperty "server messages roundtrip" $ property $ do
      x <- forAll serverMessages
      tripping x encode decode
  ]

clientMessages :: MonadGen m => m ClientMessage
clientMessages = Gen.choice
  [ Ping <$> Gen.int (Range.linear (-1000) 1000)
  , Bind <$> appIDs <*> sides
  ]

appIDs :: MonadGen m => m AppID
appIDs = AppID <$> Gen.text (Range.linear 0 100) Gen.unicode

sides :: MonadGen m => m Side
sides = Side <$> Gen.text (Range.linear 0 10) Gen.hexit

serverMessages :: MonadGen m => m ServerMessage
serverMessages = Gen.choice
  [ Welcome <$> Gen.maybe (Gen.text (Range.linear 0 1024) Gen.unicode) <*> Gen.maybe (Gen.text (Range.linear 0 1024) Gen.unicode)
  , Pong <$> Gen.int (Range.linear (-1000) 1000)
  , Error <$> Gen.text (Range.linear 0 100) Gen.unicode <*> clientMessages
  , pure Ack
  ]
