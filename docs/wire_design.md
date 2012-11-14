# Wire Protocol
## Goals
* Simple
* Universal encoding
* Create very simple, custom protocol
* Each implementation can easily re-create
* Allows the message to remain encoded as long as possible
* Will allow cross-box routing without opening the message
* Allows arbitrary encoding standards
* Allows arbitrary compression
* Allows additional, future meta-data
* Uses very little space in the average case
* Put as little in the wire protocol as possible

## Anti-Goals
* Anything that doesn't absolutely have to be in the wire protocol
* I think none of the crypto stuff has to go into the wire protocol

## Details
* Prefix is an ASCII Integer followed by a colon (:)
* This is how many bytes are in the header
* The prefix is not part of the header
* Abstract Example:
> 35:key1=value1,key2=value2,key3=value3{"json":"encoded","in":"this example"}

* The header is 35 bytes in length.

### Wire keys
* e - encoding type (json, yaml, dumper (Perl Data::Dumper),
  native (Whatever your current language prefers)
* c - compression type (zlib, snappy, none)

* Encoding defaults to JSON
* Compression defaults to none

> 0:{"json":"encoded","in":"this example"}

> 8:e=dumper{foo=>'bar'}

> 13:e=yaml,c=zlib"Compressed Crap"

> 14:ip=10.99.88.12{"foo":"bar"}

