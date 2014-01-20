module Apotiki.Tar (getControl, getStrictControl) where
import qualified Data.Map as M
import qualified Codec.Archive.Tar as Tar
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Lazy.Char8 as BC
import qualified Codec.Compression.GZip as Z

tarEntryList :: Tar.Entries Tar.FormatError -> [Tar.Entry] -> [Tar.Entry]
tarEntryList entries outlist =
  case entries of
    Tar.Next entry (more) -> (tarEntryList more (entry:outlist))
    _ -> outlist

tarEntryPayload :: Tar.EntryContent -> String
tarEntryPayload (Tar.NormalFile payload size) = BC.unpack payload

getStrictControl :: BS.ByteString -> String
getStrictControl content =
  getControl $ B.fromChunks [content]

getControl :: B.ByteString -> String
getControl content =
  tarEntryPayload $ Tar.entryContent entry
    where unzipped = Z.decompress content
          entries = tarEntryList (Tar.read unzipped) []
          entry = head $ filter ((== "./control") . Tar.entryPath) entries

test :: String -> IO ()
test path = do
  content <- B.readFile path
  putStrLn $ getControl content
