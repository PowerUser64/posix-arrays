# POSIX Arrays

Ditch colon-separated lists and start using real arrays to store and access
data in your shell scripts!

POSIX shell script is awesome, but it has a small problem that keeps many
people using `bash`: no arrays! Well, not any more! This project lets you
easily create, access, and iterate through arrays, with no limitations on what
characters are allowed to be used, no character escaping required. If you can
store it in an environment variable, you can store it in a POSIX array.

## Usage

General usage is to just source `posix-arrays.sh` in your script, However, you
can also use this library by downloading it on the fly with `curl` or by
copy/pasting it into your script.

## Examples

These examples are all written assuming that you have initialized the array
with the code in the first example. If you want, try running these examples in
a strictly POSIX-complaint shell (for example, `bash --posix`).

Note: arrays are zero-indexed and array names cannot have spaces

- Create an array called `my_awesome_array` and put some data into it

```bash
array_init my_awesome_array ':' "'" '"' '$USER' "$USER"
```

- Print the data from the array

```bash
eval "printf '%s\n' $(array_print_esc my_awesome_array)"
```

- Iterate through the array

```bash
while array_itr_next my_awesome_array; do
   i=$((i+1))
   array_set_here $i
   printf '%s ' "$(array_get_here my_awesome_array)"
done && printf '\n'
```

For more usage, check [the documentation](./DOC.md).

### 2D arrays

Dimensional arrays are also possible with this library. Check
[`./tests.sh`](./tests.sh) for an example of how to create, access, and iterate
through a 2D array. Do note that adding dimensions to your array will increase
the access time of the array. Only use this technique if there isn't another
way to do what you're trying to do and you don't need lightening fast
performance. If you're okay with slower access times, this technique should
work well for most applications.

## How does this work?

The basic idea is the fact we can use the `eval` keyword to write code with
code. What inspired this was realizing that the `eval` keyword could be used to
declare a variable with a custom name, like this:

```bash
my_var=hello
eval "$my_var=world"
echo $hello
# prints "world"
```

This library uses this ability to create variables with names like
`my_awesome_array_0` to store the data at index 0 and `my_awesome_array_size`
to store the array's size. In a broad sense, this library is abstraction of
this idea.

## Contributing

First off, thank you for taking the time to contribute! Contributions are more
than welcome, and there is even a top-secret commented out TODO list below this
paragraph if you're looking for something to do. Otherwise, if you want to
contribute a bug fix, feel free to patch and submit a pull request with your
changes. If you want to contribute a feature, do note that this project is
intended to stay somewhat simple, and all of the base functionality has been
implemented. If you come up with a feature you think is missing or would fit
well here, please open an issue to ask about it so I can provide feedback
before you go through the work of implementing it.

You can test your changes with the tests in `./tests.sh`. If you add a feature,
please add a test for it.

<!--
## TODO

1. Make a dependency graph so users can find out what functions they
   specifically need if they don't want to include the whole project.
2. Maybe make a dimensional array library at some point.

-->
