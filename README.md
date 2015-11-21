DarwinWrapper
Hoon H.

A wrappers around some Darwin (BSD layer of OS X) features that deals with some hard situations. 


- `EEDWSubprocess` -- Replacement for `NSTask`. `NSTask` works well, but I discovered that Rust `cargo` and `rustc`
  crashes when it is being executed by `NSTask` under Xcode debugging context. This is a kind of workaround.





License: MIT License