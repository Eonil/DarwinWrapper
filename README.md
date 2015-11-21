


ARCHIVED BECAUSE THE SOURCE PROBLEM HAS BEEN DISAPPEARED

The problem related to Rust execution was not a problem of `NSTask`. It was because of `LD_LIBRARY_PATH` that was 
set by Xcode 7. So this project will be archived until another issue arises.


DarwinWrapper
Hoon H.

A wrappers around some Darwin (BSD layer of OS X) features that deals with some hard situations. 


- `EEDWSubprocess` -- Replacement for `NSTask`. `NSTask` works well, but I discovered that Rust `cargo` and `rustc`
  crashes when it is being executed by `NSTask` under Xcode debugging context. This is a kind of workaround.





License: MIT License