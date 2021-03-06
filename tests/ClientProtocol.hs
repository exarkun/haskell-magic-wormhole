-- | Tests for the "client protocol".
module ClientProtocol (tests) where

import Protolude

import Hedgehog (forAll, property, (===))
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.Hedgehog (testProperty)

import qualified MagicWormhole.Internal.ClientProtocol as ClientProtocol


tests :: IO TestTree
tests = pure $ testGroup "ClientProtocol"
  [ testProperty "SecretBox encryption roundtrips" $ property $ do
      purpose <- forAll $ Gen.bytes (Range.linear 0 10)
      secret <- forAll $ Gen.bytes (Range.linear 0 10)
      let key = ClientProtocol.deriveKey (ClientProtocol.SessionKey secret) purpose
      plaintext <- forAll $ Gen.bytes (Range.linear 1 256)
      ciphertext <- liftIO $ ClientProtocol.encrypt key (ClientProtocol.PlainText plaintext)
      let decrypted = ClientProtocol.decrypt key ciphertext
      decrypted === Right (ClientProtocol.PlainText plaintext)
  ]
