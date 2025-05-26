# vlscript
Compiled imperative lisp-like language for the obeliskVM

## Installation
Copy `vlscript.lua` and the required installation files for [obeliskVM](https://github.com/SpartanSf/obeliskVM)

## Example
Try the demo found in `demo.lua` for a working example of the language.

```lisp
define main {
    let x 5

    define loop {
        sub x x 1
        if = x 0 {
            halt
        }
        jump loop
    }
}
```
