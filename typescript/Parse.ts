import { isJust, isNothing, Just, just, Maybe, mustExist, Nothing, nothing, SymbolJust } from './Maybe.js';
import { map, primStringToList, split } from './Util.js';

export type Token = {
  type: 'digit';
  val: number;
} | {
  type: 'delim';
  val: string;
} | {
  type: 'oper';
  val: string;
} | {
  type: 'skip';
  val: string;
} | {
  type: 'term';
};

export function digit(val: number): Token {
  return {
    type: 'digit',
    val,
  };
}

export function oper(val: string): Token {
  return {
    type: 'oper',
    val,
  };
}

export function skip(val: string): Token {
  return {
    type: 'skip',
    val,
  };
}

export function term(): Token {
  return {
    type: 'term',
  };
}

export interface BinExpr {
  oper: Token;
  lhs: Token;
  rhs: Token;
}

export interface Result<T, R = Maybe<T>> {
  res: R;
  rem: ReadonlyArray<string>;
}

export const DIGITS = primStringToList("0123456789");
export const OPERS = primStringToList("-+*/");
export const SKIPS = primStringToList(" ");

export function emit<T>(val: Maybe<T>, rem: ReadonlyArray<string>): Result<T> {
  return {
    res: val,
    rem,
  };
}

export function emitBack<T>(rem: ReadonlyArray<string>): Result<T> {
  return {
    res: nothing(),
    rem,
  };
}

export function emitCont<T>(val: T, rem: ReadonlyArray<string>): Result<T> {
  return {
    res: just(val),
    rem,
  };
}

export function result<T>(r: Result<T, Just<T>>): T {
  return r.res[SymbolJust];
}

export function isCont<T>(r: Result<T>): r is Result<T, Just<T>> {
  return isJust(r.res);
}

export function isBack<T>(r: Result<T>): r is Result<T, Nothing> {
  return isNothing(r.res);
}

export function takeCons(cs: ReadonlyArray<string>, xs: ReadonlyArray<string>): Result<ReadonlyArray<string>> {
  const acc: Array<string> = [];
  const rem = Array.from(xs);

  while (cs.includes(rem[0])) {
    acc.push(mustExist(rem.shift()));
  }

  return emitCont(acc, rem)
}

export function ignoreCons(cs: ReadonlyArray<string>, xs: ReadonlyArray<string>): ReadonlyArray<string> {
  const rem = Array.from(xs);

  while (cs.includes(rem[0])) {
    rem.shift();
  }

  return rem;
}

export function parseChar(c: string): Token {
  switch (c) {
    case '0':
      return digit(0);
    case '1':
      return digit(1);
    case '2':
      return digit(2);
    case '3':
      return digit(3);
    case '4':
      return digit(4);
    case '5':
      return digit(5);
    case '6':
      return digit(6);
    case '7':
      return digit(7);
    case '8':
      return digit(8);
    case '9':
      return digit(9);
    case '+':
    case '-':
    case '*':
    case '/':
      return oper(c);
    case ' ':
      return skip(c);
    default:
      return {
        type: 'term',
      };
  }
}

export function parseNat(a: Maybe<number>, cs: ReadonlyArray<string>): Result<number> {
  if (cs.length === 0) {
    return emit(a, []);
  }

  const [x, ...xs] = cs;
  const t = parseChar(x);

  if (t.type === 'digit') {
    return emitCont(t.val, xs)
  } else {
    return emitBack(cs);
  }
}

export function takeNat(s: ReadonlyArray<string>): Result<number> {
  const cs = takeCons(DIGITS, s);

  if (isCont(cs)) {
    const n = parseNat(nothing(), result(cs));

    if (isCont(n)) {
      return emitCont(result(n), cs.rem);
    }
  }

  return emitBack(cs.rem);
}

export function parseOper(s: ReadonlyArray<string>): Result<Token> {
  if (s.length === 0) {
    return emitBack([]);
  }

  const [x, ...xs] = s;
  const o = parseChar(x);

  if (o.type === 'oper') {
    return emitCont(o, xs);
  } else {
    return emitBack(xs);
  }
}

export function takeOper(s: ReadonlyArray<string>): Result<Token> {
  return parseOper(s);
}

export function takeBin(s: ReadonlyArray<string>): Result<BinExpr> {
  const lhs = takeNat(ignoreCons(SKIPS, s));

  if (isCont(lhs)) {
    const oper = takeOper(ignoreCons(SKIPS, lhs.rem));

    if (isCont(oper)) {
      const rhs = takeNat(ignoreCons(SKIPS, oper.rem));

      if (isCont(rhs)) {
        const bin: BinExpr = {
          lhs: digit(result(lhs)),
          rhs: digit(result(rhs)),
          oper: result(oper),
        };

        return emitCont(bin, rhs.rem);
      }
    }
  }

  return emitBack(s);
}

export function takeLine(c: Array<string>): Array<Result<BinExpr>> {
  return map(takeBin, split([';'], c));
}
