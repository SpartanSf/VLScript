# vlscript
Compiled imperative lisp-like language for the obeliskVM

## Installation
Run `https://raw.githubusercontent.com/SpartanSf/vlscript/main/install.lua`

Install [obeliskVM](https://github.com/SpartanSf/obeliskVM)

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
