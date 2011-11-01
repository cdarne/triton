Triton
======

Description
-----------
Triton is an implementation of the event/listener pattern like EventEmitter on Node.js.

Installation
------------
    gem install triton

Example
-------
    require 'triton'
    Triton::Messenger.on(:alert) { puts "alert!" }
    Triton::Messenger.emit(:alert)
        # -> alert!

License
-------
Released under the MIT License.  See the [LICENSE][license] file for further details.

[license]: https://github.com/cdarne/triton/blob/master/LICENSE.md