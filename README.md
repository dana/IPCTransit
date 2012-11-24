# IPCTransit v0.0.3
A high-performance, brokerless, cross-platform message queue system.

## Dependencies
* JSON
* System V IPC

## Usage
Ruby example:

```ruby
require 'ipc_transit'
IPCTransit.send(
    'message' => { 'something' => { 'very' => ['interesting']}},
    'qname' => 'somewhere_else')
```

Elsewhere on this box:

```ruby
message = IPCTransit.receive('qname' => 'somewhere_else')
```

```ruby
require 'ipc_transit'
IPCTransit.send(
    'message' => { 'something' => { 'very' => ['interesting']}},
    'qname' => 'somewhere_else',
    'destination' => 'some.remote.host',
    'compression' => 'zlib',
    'encoding' => 'json')  #json is the default; YAML is also supported
```

On 'some.remote.host':

```ruby
message = IPCTransit.receive('qname' => 'somewhere_else')
```

In order to do remote send, on the sending box, run bin/transitd, and
on the remote box, run bin/trserver.

## Concept
System V IPC message queues are a very old but under-used feature of all
modern UNIX operating systems.

Message queueing is all the rage, and has been for a long time.

The idea is simple: use SysV IPC to have the kernel act as our queue manager.
So, for all on-box delivery, there is no server or broker process to deal
with.

## Goals
* Brokerless for on-box queue
* High throughput
* Usually low latency
* High reliability
* CPU and memory efficient
* Cross UNIX compatable
* Multiple language implementations
* Very few module dependencies
* Feature stack is modular and optional

## Anti-goals
* Guaranteed delivery

## Implementations
* Ruby - the first and reference implementation
* Python - TODO
* Perl - TODO

## TODO
* Far more robust testing
* Exception handling is exceptionally poor
* Specific Exception: Queue full write
* Specific Exception: Message too large for queue
* Local (in-process) delivery
* Serialization and compression modules should be loaded only as needed
* Allow user-specified masks for transit config files
* Allow user-specified path for transit config files
* Allow custom config directory path
* Handle large messages
* A lot more documentation
* Perl implementation
* Python implementation
* Plugable compression (partial: zlib implemented at this time; need to make it class-based)
* Plugable encoding (partial: json and yaml implemented; need to make it class based)
* Crypto: message signing and verification
* Crypto: message encryption and validation

## BUGS
### Ruby
* Blocking receive on empty queue requires kill -9
* The created configuration directory's permissions are not wide-open
