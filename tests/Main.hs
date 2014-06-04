{-# LANGUAGE
    DeriveGeneric
  , OverloadedStrings
  , TemplateHaskell
  , TypeFamilies
  #-}
module Main (main) where

import Data.Aeson hiding (Result)
import Data.Aeson.Parser
import Data.Attoparsec.Lazy
import Data.List (intersperse)
import GHC.Generics (Generic)
import Generics.Generic.Aeson
import Test.HUnit
import qualified Data.Aeson.Types as A
import Data.ByteString.Lazy (ByteString)

data A = A deriving (Generic, Show, Eq)
instance ToJSON   A where toJSON    = gtoJson
instance FromJSON A where parseJSON = gparseJson
testA :: (Value, Either String A)
testA = (toJSON A, i A)

data B = B { b :: Int } deriving (Generic, Show, Eq)
instance ToJSON   B where toJSON    = gtoJson
instance FromJSON B where parseJSON = gparseJson
testB :: (Value, Either String B)
testB = (toJSON B { b = 1 }, i B { b = 1 })

data D = D { d1 :: Int, d2 :: String } deriving (Generic, Show, Eq)
instance ToJSON   D where toJSON = gtoJson
instance FromJSON D where parseJSON = gparseJson
testD :: (Value, Either String D)
testD = (toJSON D { d1 = 1, d2 = "aap" }, i D { d1 = 1, d2 = "aap" })

data E = E Int deriving (Generic, Show, Eq)
instance ToJSON   E where toJSON = gtoJson
instance FromJSON E where parseJSON = gparseJson
testE :: (Value, Either String E)
testE = (toJSON (E 1), i (E 1))

data F = F Int String deriving (Generic, Show, Eq)
instance ToJSON   F where toJSON = gtoJson
instance FromJSON F where parseJSON = gparseJson
testF :: (Value, Either String F)
testF = (toJSON (F 1 "aap"), i (F 1 "aap"))

data G = G1 Int | G2 String deriving (Generic, Show, Eq)
instance ToJSON   G where toJSON = gtoJson
instance FromJSON G where parseJSON = gparseJson
testG :: (Value, Value, Either String G, Either String G)
testG = (toJSON (G1 1), toJSON (G2 "aap"), i (G1 1), i (G2 "aap"))

data H = H1 { h1 :: Int } | H2 { h2 :: String } deriving (Generic, Show, Eq)
instance ToJSON   H where toJSON = gtoJson
instance FromJSON H where parseJSON = gparseJson
testH :: (Value, Value, Either String H, Either String H)
testH = (toJSON (H1 1), toJSON (H2 "aap"), i (H1 1), i (H2 "aap"))

data J = J1 { j1 :: Int, j2 :: String } | J2 deriving (Generic, Show, Eq)
instance ToJSON   J where toJSON = gtoJson
instance FromJSON J where parseJSON = gparseJson
testJ :: (Value, Value, Either String J, Either String J)
testJ = (toJSON (J1 1 "aap"), toJSON J2, i (J1 1 "aap"), i J2)

data L = L1 | L2 Int String deriving (Generic, Show, Eq)
instance ToJSON   L where toJSON = gtoJson
instance FromJSON L where parseJSON = gparseJson
testL :: (Value, Value, Either String L, Either String L)
testL = (toJSON L1, toJSON (L2 1 "aap"), i L1, i (L2 1 "aap"))

data M = M1 | M2 Int M deriving (Generic, Show, Eq)
instance ToJSON   M where toJSON = gtoJson
instance FromJSON M where parseJSON = gparseJson
testM :: (Value, Value, Value, Either String M, Either String M, Either String M)
testM = (toJSON M1, toJSON (M2 1 M1), toJSON (M2 1 (M2 2 M1)), i M1, i (M2 1 M1), i (M2 1 (M2 2 M1)))

data N = N1 | N2 { n1 :: Int, n2 :: N } deriving (Generic, Show, Eq)
instance ToJSON   N where toJSON = gtoJson
instance FromJSON N where parseJSON = gparseJson
testN :: (Value, Value, Value, Either String N, Either String N, Either String N)
testN = (toJSON N1, toJSON (N2 1 N1), toJSON (N2 1 (N2 2 N1)), i N1, i (N2 1 N1), i (N2 1 (N2 2 N1)))

data O = O { o :: [Int] } deriving (Generic, Show, Eq)
instance ToJSON   O where toJSON = gtoJson
instance FromJSON O where parseJSON = gparseJson
testO :: (Value, Either String O)
testO = (toJSON (O [1,2,3]), i (O [1,2,3]))

data P = P [Int] deriving (Generic, Show, Eq)
instance ToJSON   P where toJSON = gtoJson
instance FromJSON P where parseJSON = gparseJson
testP :: (Value, Either String P)
testP = (toJSON (P [1,2,3]), i (P [1,2,3]))

data Q = Q Int Int Int deriving (Generic, Show, Eq)
instance ToJSON   Q where toJSON = gtoJson
instance FromJSON Q where parseJSON = gparseJson
testQ :: (Value, Either String Q)
testQ = (toJSON (Q 1 2 3), i (Q 1 2 3))

data T = T { r1 :: Maybe Int } deriving (Generic, Show, Eq)
instance ToJSON   T where toJSON = gtoJson
instance FromJSON T where parseJSON = gparseJson
testT :: (Value, Value, Either String T, Either String T)
testT = (toJSON (T Nothing), toJSON (T (Just 1)), i (T Nothing), i (T (Just 1)))

data V = V1 | V2 | V3 deriving (Generic, Show, Eq)
instance ToJSON   V where toJSON = gtoJson
instance FromJSON V where parseJSON = gparseJson
testV :: (Value, Value, Either String V, Either String V)
testV = (toJSON V1, toJSON V2, i V1, i V2)

data W = W { underscore1_ :: Int, _underscore2 :: Int } deriving (Generic, Show, Eq)
instance ToJSON   W where toJSON = gtoJson
instance FromJSON W where parseJSON = gparseJson
testW :: (Value, Either String W)
testW = (toJSON (W 1 2), i (W 1 2))

data X = X (Maybe Int) deriving (Generic, Show, Eq)
instance ToJSON   X where toJSON = gtoJson
instance FromJSON X where parseJSON = gparseJson
testX :: (Value, Value, Either String X, Either String X)
testX = (toJSON (X Nothing), toJSON (X (Just 1)), i (X Nothing), i (X (Just 1)))

i :: (FromJSON a, ToJSON a) => a -> Either String a
i a = case (parse value . encode) a of
  Done _ r -> case fromJSON r of A.Success v -> Right v; Error s -> Left $ "fromJSON r=" ++ show r ++ ", s=" ++ s
  Fail _ ss e -> Left . concat $ intersperse "," (ss ++ [e])

tests :: Test
tests = TestList
  [ TestCase $ assertEqual "testA" (f "\"a\"",Right A) testA
  , TestCase $ assertEqual "testB" (f "{\"b\":1}",Right (B {b = 1})) testB
  , TestCase $ assertEqual "testD" (f "{\"d1\":1,\"d2\":\"aap\"}",Right (D {d1 = 1, d2 = "aap"})) testD
  , TestCase $ assertEqual "testE" (f "1",Right (E 1)) testE
  , TestCase $ assertEqual "testF" (f "[1,\"aap\"]",Right (F 1 "aap")) testF
  , TestCase $ assertEqual "testG" (f "{\"g1\":1}",f "{\"g2\":\"aap\"}",Right (G1 1),Right (G2 "aap")) testG
  , TestCase $ assertEqual "testH" (f "{\"h1\":{\"h1\":1}}",f "{\"h2\":{\"h2\":\"aap\"}}",Right (H1 {h1 = 1}),Right (H2 {h2 = "aap"})) testH
  , TestCase $ assertEqual "testJ" (f "{\"j1\":{\"j1\":1,\"j2\":\"aap\"}}",f "{\"j2\":{}}",Right (J1 {j1 = 1, j2 = "aap"}),Right J2) testJ
  , TestCase $ assertEqual "testL" (f "{\"l1\":{}}",f "{\"l2\":[1,\"aap\"]}",Right L1,Right (L2 1 "aap")) testL
  , TestCase $ assertEqual "testM" (f "{\"m1\":{}}",f "{\"m2\":[1,{\"m1\":{}}]}",f "{\"m2\":[1,{\"m2\":[2,{\"m1\":{}}]}]}",Right M1,Right (M2 1 M1),Right (M2 1 (M2 2 M1))) testM
  , TestCase $ assertEqual "testN" (f "{\"n1\":{}}",f "{\"n2\":{\"n2\":{\"n1\":{}},\"n1\":1}}",f "{\"n2\":{\"n1\":1,\"n2\":{\"n2\":{\"n1\":2,\"n2\":{\"n1\":{}}}}}}",Right N1,Right (N2 {n1 = 1, n2 = N1}),Right (N2 {n1 = 1, n2 = N2 {n1 = 2, n2 = N1}})) testN
  , TestCase $ assertEqual "testO" (f "{\"o\":[1,2,3]}",Right (O {o = [1,2,3]})) testO
  , TestCase $ assertEqual "testP" (f "[1,2,3]",Right (P [1,2,3])) testP
  , TestCase $ assertEqual "testQ" (f "[1,2,3]",Right (Q 1 2 3)) testQ
  , TestCase $ assertEqual "testT" (f "{}", f "{\"r1\":1}",Right (T {r1 = Nothing}),Right (T {r1 = Just 1})) testT
  , TestCase $ assertEqual "testV" (f "\"v1\"",f "\"v2\"",Right V1,Right V2) testV
  , TestCase $ assertEqual "testW" (f "{\"underscore1\":1,\"underscore2\":2}",Right (W {underscore1_ = 1, _underscore2 = 2})) testW
--  , TestCase $ assertEqual "testX" (f "null", f "1", Right (X Nothing), Right (X (Just 1))) testX
  ]
  where
  f :: ByteString -> Value
  f = fromResult . parse value
  fromResult (Done _ r) = r
  fromResult _ = error "Boo"

main :: IO Counts
main = runTestTT tests
