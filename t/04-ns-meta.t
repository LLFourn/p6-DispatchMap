use DispatchMap;
use Test;
plan 6;

{
    my $parent = DispatchMap.new(
        foo => (
            (Real,Str) => "real str",
            (Int,Str) => "int str",
        ),
        bar => ((Int,Int) => "int int")
    ).compose;

    $parent.ns-meta('foo')<bar> = "baz";
    is $parent.ns-meta('foo')<bar>,"baz";
    my $child =
    DispatchMap.new()
    .add-parent($parent)
    .compose;

    is $child.get('bar',1,2),"int int","bar didn't get overridden";
    is $child.ns-meta('foo')<bar>,"baz";

    my $override = DispatchMap.new()
    .add-parent($child)
    .override(
        foo => (
            (Int,Int) => "int int",
            (42,Str)  => "42 str",
        ));

    is $override.get('bar',1,2),"int int","bar didn't get overridden";
    nok $override.ns-meta('foo')<bar>,'override cancels parent ns-meta';
    is $override.get('foo',1,"bar"),Nil,"override cancels parent candidates";
}
