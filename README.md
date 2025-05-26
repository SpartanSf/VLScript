# VLScript
Compiled imperative lisp-like language for the obeliskVM

## Installation
Run `wget run https://raw.githubusercontent.com/SpartanSf/vlscript/main/install.lua`

Install [obeliskVM](https://github.com/SpartanSf/obeliskVM)

## Example
Try the demo found in `demo.lua` for a working example of the language.

```lisp
define main {
    let x 5000000000
    let f #'loop
    call f
    halt
}

define loop {
    - x x 1
    if = x 0 {
        return
    }
    jump f
}
```
