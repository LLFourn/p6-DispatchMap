# DispatchMap

A map that uses Perl 6 multi dispatch to link keys to values

## Synopsis

``` perl6
need DispatchMap;

my $map = DispatchMap.new:
             (Int) =>  "an Int!",
             (subset :: of Int:D where * > 5) => "Wow, an Int greater than 5",
             ("foo")           => "A literal foo",
             (π)               => "pi",
             (Str)             => "one string",
             (Stringy)         => "something stringy",
             (Str,Str)         => "two strings",
             (Any:U) => { "Not sure what this is: {.gist}" };


say $map.get(2); #-> an Int!
say $map.get(6); #-> Wow, an Int greater than 5
say $map.get("foo"); #-> A literal foo;
say $map.get-all("foo") ~~ ("A literal foo","one string","something stringy");
say $map.get(π); #-> pi
say $map.get("foo","bar"); #-> two strings
say $map.get(Perl); # get the Block;
say $map.dispatch(Perl); # get AND invoke the code block

```

## Description

**warning** this is module is experimental and subject to change

**warning** this module uses unspec'd raged internals and could break without warning

Perl 6 has a very sophisticated routine dispatch system based on
finding the candidate that matches the call's arguments most
narrowly. Unfortunately there is no way (yet) to make use of the
dispatching logic outside of routine calls.

This module exposes that logic in a map like interface.

## Methods

### new(**@args)

```perl6
my $map = DispatchMap.new( (Int,Array) => "Foo", (Cool) => "Bar" );
#or
my $map = DispatchMap.new( (Int,Array),"Foo",(Cool),"Bar" );
#or
my $map = DispatchMap.new( [(Int,Array),"Foo",(Cool),"Bar"] );
```

Makes a new DispatchMap from args in the same way.

### keys

```perl6
my $map = DispatchMap.new( (Int,Array) => "Foo", (Cool) => "Bar" );
say $map.keys; #-> (Int,Array),(Cool)
```

Gets the keys as a list of lists (each key is a list).

### values

```perl6
my $map = DispatchMap.new( (Int,Array) => "Foo", (Cool) => "Bar" );
say $map.values; #-> (Int,Array),(Cool)
```

Gets the values in the map as a list.

### pairs

```perl6
my $map = DispatchMap.new( (Int,Array) => "Foo", (Cool) => "Bar" );
say $map.pairs; #-> (Int,Array) => "Foo",(Cool) => "Bar"
```

Returns the map as a list of pairs.

### list

```perl6
my $map = DispatchMap.new( (Int,Array) => "Foo", (Cool) => "Bar" );
say $map.pairs; #-> (Int,Array),"Foo",(Cool),"Bar"
```
Returns the map a list of keys and values

### get(|c)

``` perl6
my $map = DispatchMap.new( (Int,Array) => "Foo", (Cool) => "Bar" );
say $map.get(1,["one","two"]); #-> Foo
```

Gets a single value from the map. The Capture of the arguments to get
are used as the key.

### get-all(|c)

``` perl6
my $map = DispatchMap.new( Numeric => "A number",
                           Real => "A real number",
                           Int => "An int",
                           (π)  => "pi" );
say $map.get-all(π); # "pi", "Real", "Numeric";
```

Gets all the values that match the argument in order of narrowness
(internally uses [cando](https://docs.perl6.org/type/Routine#method_cando))

### append(**@args)
``` perl6
my $map = DispatchMap.new( (Int,Array) => "Foo", (Cool) => "Bar" );
$map.set((Real,Real) => "Super Real!");
say $map.get(π,τ); #-> Super Real!
```

Sets some values of maps. Takes the arguments in the same format as `.new`.

### dispatch(|c)

``` perl6
my $map = DispatchMap.new(
        (Str:D,Str:D) => { $^a ~ $^b },
        (Iterable:D,Iterable:D) => { |$^a,|$^b },
        (Numeric:D,Numeric:D) => { $^a + $^b }
    );

say $map.dispatch("foo","bar"),"foobar"; #-> foobar
say $map.dispatch(<one two>,<three four>); #-> one two three four
say $map.dispatch(1,2); #-> 3
```

`.dispatch` works like `.get` except the if the result is a `Callable`
it will invoke it.
