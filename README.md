# Terrafuck

A (ˡᶦᵐᶦᵗᵉᵈ) Brainfuck interpreter that works in pure Terraform (no local-exec cheap-outs or anything).

## How it works

blood, sweat, and magical tears.

(todo: actually add how it works lol)

## Is this technically cheating?

The short answer is yes. For a more long-winded explaination, you can click on the dropdown below though.

<details>
<summary>Click for the long answer</summary>
<br>
yeah.
</details>

But this is the best we can do given that Terraform doesn't support mutable state or provide any
native mechanism to replicate it through some ad-hoc fixed-point combinator or something.

And, of course, I refuse to depart from my principles by executing some cheap trick like having terraform
execute a bash script to perform the interpretation or something.

so, uh, yeah...

[![you get what you get and you don't throw a fit](https://img.youtube.com/vi/b7OWjCaW-mw/0.jpg)](https://www.youtube.com/watch?v=b7OWjCaW-mw)
