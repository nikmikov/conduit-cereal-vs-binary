# conduit-cereal vs conduit-binary

Given [[Int64]] represented as a text stream where each line is [Int64], encoded first into binary string and then into text using base64 encoding. There is no line break at the end of the stream (this is important!)

When decoding text.

# Build
Run stack build

# Run
$ stack exec conduit-binary-run
Expected:
12502500
11200080000
12800320000
Actual:
12502500
11200080000
12800320000

$ stack exec conduit-cereal-run
Expected:
12502500
11200080000
12800320000
Actual:
12502500
11200080000


As you can see the last chunk was not yield with conduit-cereal, but did with conduit-binary