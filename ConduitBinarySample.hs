{-# LANGUAGE OverloadedStrings #-}
module Main where

import Data.Int
import Data.Binary
import Data.Binary.Put
import Data.Binary.Get
import qualified Data.ByteString.Base64 as B64
import Data.ByteString.Lazy(fromStrict, toStrict)
import qualified Data.ByteString as BS
import qualified Data.Text as T
import Data.Text.Encoding(decodeUtf8, encodeUtf8)
import Control.Applicative

import Data.Conduit( ($$),(=$=) )
import qualified Data.Conduit.Binary as CB
import qualified Data.Conduit.Combinators as CC
import Data.Conduit.Serialization.Binary(conduitGet)

example :: [[Int64]]
example = [ [1..5000], [10000..150000], [300000..340000] ]

-- | serialize lists of 64-bit integers into base64 encoded strings delimited with \0 byte
--   !! there is no \0 byte after last element
encodeExample :: [[Int64]] -> BS.ByteString
encodeExample = encodeUtf8 . T.intercalate "\0"
                . map ( (decodeUtf8 . B64.encode) . toStrict . runPut . put)

-- | decode \0 terminated bytestring
decodeNul :: Get BS.ByteString
decodeNul = go []
    where go xs = do
            b <- getWord8
            if b == 0
            then return $ BS.pack $ reverse xs
            else go (b:xs)

-- | consume all remaining input and return it as a bytestring
decodeRem :: Get BS.ByteString
decodeRem = remaining >>= getBytes . fromIntegral

decodeWithCereal :: Get BS.ByteString
decodeWithCereal = decodeNul <|> decodeRem

main :: IO()
main = do
  let ex = encodeExample example
  putStrLn "Expected:"
  mapM_ (print . sum) example
  putStrLn "Actual:"
  CB.sourceLbs (fromStrict ex)
        $$ conduitGet decodeWithCereal
        =$= CC.decodeBase64
        =$= conduitGet (get::Get [Int64])
        =$= CC.mapM_ ( print . sum )
