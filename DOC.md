# POSIX Arrays Documentation

This documents how to use the various functions provided by this project. Any
function not documented here is supposed to be a function internal to the
library, and it isn't recommended that you use it.

Note that array names (just like variable names) cannot have spaces in them.

Document format:

```markdown
## Feature
#### `function`
Description
```

## Initialize

#### `array_init ARRAY`

Initialize an array of name `ARRAY`. Sets its size and iterator to -1.

## Write

#### `array_set ARRAY INDEX VALUE`

Assign the VALUE at the specified INDEX in ARRAY.

#### `array_append ARRAY VALUE [...]`

Append every given VALUE to ARRAY.

## Read

#### `array_get ARRAY INDEX`

Retrieve the value from ARRAY at INDEX.

## Iterate

#### `array_itr_init ARRAY`

Set the iterator to -1.

#### `array_itr_next ARRAY`

Move ARRAY's iterator to the next value. If there is no next value, return error code 1.

#### `array_itr_prev ARRAY`

Move ARRAY's iterator to the previous value. If there is no previous value, return error code 1.

#### `array_get_here ARRAY`

Returns the value at the position of the iterator in ARRAY.

#### `array_set_here ARRAY VALUE`

Set the value at the iterator in ARRAY to VALUE.

## Get Attribute

#### `array_attr_size ARRAY`

Prints the size of ARRAY. -1 means an empty array.

#### `array_attr_itr ARRAY`

Prints ARRAY's iterator value.

## utility

#### `array_print_esc ARRAY`

Prints the variables that make up ARRAY, each variable is quoted, like so:

```bash
"$my_awesome_array_0" "$my_awesome_array_1" "$my_awesome_array_2"
```

Use this in combination with an `eval` to pass the array as arguments:

```bash
eval "printf '%s\n' $(array_print_esc my_awesome_array)"
```
