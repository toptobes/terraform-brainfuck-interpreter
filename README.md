# Terrafuck

A (ᵇᵒᵘⁿᵈᵉᵈ) Brainfuck interpreter that works in pure Terraform (no `local-exec` cheap-outs or anything).

## How it works

blood, sweat, and magical tears.

also some light code generation.

(todo: actually add how it works lol, for now you can check out the `example` directory for an idea)

### Isn't this technically cheating?

The short answer is yes. For a longer answer, you can click on the dropdown below though.

<details>
<summary>Click for the longer answer</summary>
<br>
yes, but shut up.
</details>

But this is the best we can do given that Terraform doesn't support mutable state or provide any
native mechanism to replicate it through some ad-hoc fixed-point combinator or something.

And, of course, I refuse to depart from my principles by executing some cheap trick like having terraform
execute a bash script to perform the interpretation or something.

so, uh, yeah...

[![you get what you get and you don't throw a fit](https://img.youtube.com/vi/b7OWjCaW-mw/0.jpg)](https://www.youtube.com/watch?v=b7OWjCaW-mw)

## Trying it for yourself

### Using the premade example

The `example` folder created a pre-generated Terrafuck module generated using the command

```sh
terrafuck -i 2000 -g 10
```

which means the Terraform script can handle up to 5 pairs of `[]`s and execute up to 2000 commands/steps.

The example folder also contains a `.tfvars` file with the following variables set if you want some Brainfuck code to Terrafuck around with.

```tfvars
# Prints "A"
code = ">+[+[<]>>+<+]>."

# Adds 2+5, then prints "7"
# code = "++>+++++[<+>-]++++++++[<++++++>-]<."

# Basic tape with 10 cells (you don't really need more in most cases)
tape = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
```

You can run the program like so (after `cd`-ing into the `example` directory):

```sh
terraform apply -var-file=.tfvars -auto-approve
```

It may take a minute or two to run on default max-iteration settings.

### Using the CLI for yourself

There's two different ways to use the CLI (do `terrafuck --help` for all possible options):

```sh
cabal run terrafuck -- [-i|--max-iteration-steps N] [-l|--max-lut-gen-steps N] [-t|--default-tape-size N]
```

This will generate the terrafuck interpreter using the explict parameters you provide it:
- `max-iteration-steps`: The number of "steps", or "instructions" the interpreter may take
- `max-lut-gen-steps`: The number of steps the bracket LUT generator may take
  - Equiv. to the number of `[]` pairs in the BF code * 2 
  - (e.g. `>[+]`) would need `2` steps
- `default-tape-size`: The default length of the memory tape to use
  - If provided, it'll be a list of zeros of length `N`
  - If not provided, you'll manually need to pass in a tape when running the terrafuck interpreter

```sh
cabal run terrafuck -- <-c|--code BRAINFUCK_CODE> [-i|--input BRAINFUCK_INPUT]
```

This will automagically find the exact numbers for each of the aftermentioned parameters to provide
a terrafuck interpreter best suited for the specific piece of Brainfuck code you used to generate it.

If you use this method, the variables will all be set to suitable defaults, so all you have to do is
`terraform plan`, and it'll use the code & input you provided to the `terrafuck` CLI (though you can
still override them as normal using normal Terraform input variables)
