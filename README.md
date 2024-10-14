# Terrafuck

An optimizing (ᵇᵒᵘⁿᵈᵉᵈ) Brainfuck interpreter that works in pure Terraform (no `local-exec` cheap-outs or anything).

*Disclaimer: the Haskell CLI is there solely for code generation; it does not perform any of the actual Brainfuck
code interpretation nor optimzation; all of that is done within Terraform itself.*

## How it works

blood, sweat, and magical tears.

also some light (heavy) code generation (see the `example` directory for the successor to `node_modules`).

### It's quite simple, actually

It's like a basic Brainfuck interpreter, except instead of a arbitrarily-terminating while loop, it's an extermely
long unrolled set of instructions, where each next step of the interpreter is represented by a new local variable
which references the local variable of the previous step.

It's easier to show than tell though. Check out the `example` and `templates` directories for the praxis.

### Optimizations

Now, of course, this leads to a LOT of code, and a LOT of local variables created, which can lead to
increasingly long interpretation times, which is why the Terrafuck intepreter itself (not the CLI) performs
some basic initial optimizations to cut down on the number of "steps" that need to be taken.

From my (extremely basic and naive) testing, I believe what is by far the largest bottleneck for performance is
the number of local variables created, I imagine probably because of the internal dependency chain Terraform has
to manage?  Whatever the reason, the main goal is to chop down on the # of "steps" taken, no matter what.

#### Non-code regex filtering

All chars not part of Brainfuck instruction set (`+-<>,.[]`) are filtered out using regex to minimize any
steps that would be wasted stepping through comments

#### Bracket LUT generation

Before any actual interpretation is performed, a bidirectional LUT for the bracket indices is generated to
make loop jumping extremely efficient

#### Consecutive instruction fusion

All consecutive instructions (aside from brackets, of course) are fused into single "steps".

For example: `>>>++[[-]]....` is (basically) transformed into `>3+2[[-1]].4`

#### Simple zeroing loops optimization

Basic zeroing loops (i.e. `[-]` and `[+]`) will just directly set the memory cell to `0` rather than
having to waste many, many instructions on looping and decrementing.

### Huh. Isn't this technically cheating?

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
- `max-iteration-steps`: The number of "steps" the interpreter may take
  - Note that this is NOT 1:1 with the interpreted instructions themselves
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
