/*
REQUIRED_ARGS: -de -wo
TEST_OUTPUT:
---
fail_compilation/dip1000_deprecation.d(20): Deprecation: `@safe` function `main` calling `inferred`
fail_compilation/dip1000_deprecation.d(28):        which wouldn't be `@safe` because of:
fail_compilation/dip1000_deprecation.d(28):        scope variable `x0` may not be returned
fail_compilation/dip1000_deprecation.d(22): Deprecation: `@safe` function `main` calling `inferredC`
fail_compilation/dip1000_deprecation.d(39):        which calls `dip1000_deprecation.inferred`
fail_compilation/dip1000_deprecation.d(28):        which wouldn't be `@safe` because of:
fail_compilation/dip1000_deprecation.d(28):        scope variable `x0` may not be returned
fail_compilation/dip1000_deprecation.d(54): Warning: escaping reference to stack allocated value returned by `S(null)`
fail_compilation/dip1000_deprecation.d(55): Warning: escaping reference to stack allocated value returned by `createS()`
fail_compilation/dip1000_deprecation.d(58): Warning: returning `s.incorrectReturnRef()` escapes a reference to local variable `s`
---
*/

void main() @safe
{
    cast(void)inferred();
    cast(void)inferredB(); // no deprecation, trusted
    cast(void)inferredC(); // nested deprecation
}

auto inferred()
{
    scope int* x0;
    return x0;
}

auto inferredB() @trusted
{
    scope int* x1;
    return x1;
}

auto inferredC()
{
    return inferred(); // no deprecation, inferredC is not explicit `@safe`
}

@safe:

struct S
{
    int* ptr;
    int* incorrectReturnRef() scope return @trusted {return ptr;}
}

S createS() { return S.init; }

int* escape(int i)
{
    if (i) return S().incorrectReturnRef();
    if (i) return createS().incorrectReturnRef();

    S s;
    return s.incorrectReturnRef();
}
