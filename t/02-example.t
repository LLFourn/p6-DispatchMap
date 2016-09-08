use DispatchMap;
use Test;

plan 11;

{
    my $map = DispatchMap.new:
        (Int) =>  "an Int!",
        (subset :: of Int:D where * > 5) => "Wow, an Int greater than 5",
        ("foo")           => "A literal foo",
        (Str)             => "one string",
        (Stringy)         => "something stringy",
        (Str,Str)         => "two strings",
        (Any:U) => { "Not sure what this is: {.gist}" };


    is $map.get(2),'an Int!';
    is $map.get(6),'Wow, an Int greater than 5';
    is $map.get("foo"),'A literal foo';
    $map.append((π) => "pi",(τ) => "tau");
    is $map.get(τ),"tau";
    ok $map.get-all("foo") ~~ ("A literal foo","one string","something stringy");
    is $map.get("foo","bar"),'two strings';
    ok $map.get(Perl),Block;
    is $map.dispatch(Perl),"Not sure what this is: {Perl.gist}";
}

{
    my $map = DispatchMap.new(
        (Str:D,Str:D) => { $^a ~ $^b },
        (Iterable:D,Iterable:D) => { |$^a,|$^b },
        (Numeric:D,Numeric:D) => { $^a + $^b }
    );

    is $map.dispatch("foo","bar"),"foobar";
    is-deeply $map.dispatch(<one two>,<three four>),<one two three four>;
    is $map.dispatch(1,2),3;
}
