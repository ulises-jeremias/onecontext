<div align="center">
<h1>One Context</h1>

[vlang.io](https://vlang.io) |
[Docs](https://ulises-jeremias.github.io/onecontext) |
[Changelog](#) |
[Contributing](https://github.com/ulises-jeremias/onecontext/blob/main/CONTRIBUTING.md)

</div>
<div align="center">

[![Build Status][workflowbadge]][workflowurl]
[![Docs Validation][validatedocsbadge]][validatedocsurl]
[![License: MIT][licensebadge]][licenseurl]

</div>

A library to merge existing V contexts

## Overview

Have you ever faced the situation where you have to merge multiple existing contexts?
If not, then you might, eventually.

For example, we can face the situation where we are building an application using a library that gives us a global context.
This context expires once the application is stopped.

Meanwhile, we are exposing a service like this:

```v nofmt
fn (f Foo) get(ctx context.Context, bar Bar) ?Baz {
	. . .
}
```

Here, we receive another context provided by the service.

Then, in the `get` implementation, we want for example to query a database and we must provide a context for that.

Ideally, we would like to provide a merged context that would expire either:

- When the application is stopped
- Or when the received service context expires

This is exactly the purpose of this library.

In our case, we can now merge the two contexts in a single one like this:

```v nofmt
ctx := onecontext.merge(ctx1, ctx2)
```

This returns a merged context that we can now propagate.

### Install onecontext

**Via vpm**

```sh
$ v install ulises-jeremias.onecontext
```

**Via [vpkg](https://github.com/v-pkg/vpkg)**

```sh
$ vpkg get https://github.com/ulises-jeremias/onecontext
```

Done. Installation completed.

## Testing

To test the module, just type the following command:

```sh
$ ./bin/test # execute `./bin/test -h` to know more about the test command
```

[workflowbadge]: https://github.com/ulises-jeremias/onecontext/workflows/Build%20and%20Test%20with%20deps/badge.svg
[validatedocsbadge]: https://github.com/ulises-jeremias/onecontext/workflows/Validate%20Docs/badge.svg
[licensebadge]: https://img.shields.io/badge/License-MIT-blue.svg
[workflowurl]: https://github.com/ulises-jeremias/onecontext/commits/main
[validatedocsurl]: https://github.com/ulises-jeremias/onecontext/commits/main
[licenseurl]: https://github.com/ulises-jeremias/onecontext/blob/main/LICENSE
