# IPCTransit v0.0.1
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
> message = IPCTransit.receive('qname' => 'somewhere_else')
```

## Concept
System V IPC message queues are a very old but under-used feature of all
modern UNIX operating systems.

Message queueing is all the rage, and has been for a long time.

The idea is simple: use SysV IPC to have the kernel act as our queue manager.
So, for all on-box delivery, there is no server or broker process to deal
with.

## Goals
* Brokerless
* High throughput
* Usually low latency
* Relatively good reliability
* CPU and memory efficient
* Cross UNIX implementation
* Multiple language implementations
* Very few module dependencies
* Feature stack is modular and optional

## Anti-goals
* Guaranteed delivery

## Implementations
Ruby - the first and reference implementation
Python - TODO
Perl - TODO

## TODO
* Cross box delivery (reference implementation)
* Crypto


