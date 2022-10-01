# Agulator

This is a calculator written in Agda.

```shell
> echo '11+210;3+4' | ./Calc
result: 221, result: 7
```

This is my brain now, it doesn't work so good:

![agulator](https://cdn.drawception.com/drawings/MjWfbBamq9.png)

## Build

To build the Agda version:

```bash
> cd agda
> agda -c ./Calc.agda
```

This will compile to a binary executable at `agda/Calc`.

To build the Typescript version:

```bash
> typescript
> $(yarn bin)/tsc
```

This will compile to a JS module at `typescript/out/Calc.js`.
