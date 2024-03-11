# Hello World

This is a simple hello-world example using Idris 0.7, taken from the [Getting Started Guide](https://idris2.readthedocs.io/en/latest/tutorial/starting.html).

To start, open the example folder in vscode and run `Reopen in Container` from the command palette.

Once the container is running, you can play with Idris2!

```bash
$ idris2 hello.idr
     ____    __     _         ___
    /  _/___/ /____(_)____   |__ \
    / // __  / ___/ / ___/   __/ /     Version 0.7.0
  _/ // /_/ / /  / (__  )   / __/      https://www.idris-lang.org
 /___/\__,_/_/  /_/____/   /____/      Type :? for help

Welcome to Idris 2.  Enjoy yourself!
Main> :t main
Main.main : IO ()
Main> :c hello main
File build/exec/hello written
Main> :q
Bye for now!
```