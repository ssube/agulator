import { defaultTo, isJust, isNothing, Just, just, Maybe, mustExist, Nothing, nothing, SymbolJust } from './Maybe.js';
import { map, primStringToList, split } from './Util.js';

export const DIGITS = primStringToList("0123456789");
export const OPERS = primStringToList("-+*/");
export const SKIPS = primStringToList(" ");

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
  type: 'bin';
  oper: Token;
  lhs: Expr;
  rhs: Expr;
}

export type Expr = BinExpr | Token;

export function bin(oper: Token, lhs: Expr, rhs: Expr): BinExpr {
  return {
    type: 'bin',
    oper,
    lhs,
    rhs,
  };
}

export interface Result<T, R = Maybe<T>> {
  res: R;
  rem: ReadonlyArray<string>;
}

/**
 * emit the Result of some attempt to parse T.
 */
export function emit<T>(val: Maybe<T>, rem: ReadonlyArray<string>): Result<T> {
  return {
    res: val,
    rem,
  };
}

/**
 * emit a failed result and backtrack.
 */
export function emitBack<T>(rem: ReadonlyArray<string>): Result<T> {
  return {
    res: nothing(),
    rem,
  };
}

/**
 * emit a filled result and continue parsing.
 */
export function emitCont<T>(val: T, rem: ReadonlyArray<string>): Result<T> {
  return {
    res: just(val),
    rem,
  };
}

export function remain<T>(r: Result<T>): ReadonlyArray<string> {
  return r.rem;
}

/**
 * get the value from a result.
 */
export function result<T>(r: Result<T, Just<T>>): T {
  return r.res[SymbolJust];
}

/**
 * typeguard for filled results.
 */
export function isCont<T>(r: Result<T>): r is Result<T, Just<T>> {
  return isJust(r.res);
}

/**
 * typeguard for failed results.
 */
export function isBack<T>(r: Result<T>): r is Result<T, Nothing> {
  return isNothing(r.res);
}

type Parser<T> = (s: ReadonlyArray<string>) => Result<T>;

/**
 * take consecutive characters that match the given character set.
 */
export function takeCons(cs: ReadonlyArray<string>, xs: ReadonlyArray<string>): Result<ReadonlyArray<string>> {
  if (cs.length === 0 || xs.length === 0) {
    return emitBack(xs);
  }

  const acc: Array<string> = [];
  const rem = Array.from(xs);

  while (cs.includes(rem[0])) {
    acc.push(mustExist(rem.shift()));
  }

  if (acc.length > 0) {
    return emitCont(acc, rem)
  }

  return emitBack(xs);
}

export function takeOnce(cs: ReadonlyArray<string>, xs: ReadonlyArray<string>): Result<string> {
  if (cs.length === 0 || xs.length === 0) {
    return emitBack(xs);
  }

  const [x, ...xr] = xs;
  if (cs.includes(x)) {
    return emitCont(x, xr);
  }

  return emitBack(xs);
}

/**
 * ignore consecutive characters that match the given character set.
 */
export function ignoreCons(cs: ReadonlyArray<string>, xs: ReadonlyArray<string>): ReadonlyArray<string> {
  const rem = Array.from(xs);

  while (cs.includes(rem[0])) {
    rem.shift();
  }

  return rem;
}

/**
 * parse a character into a Token.
 */
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

/**
 * parse a natural number from a list of digit tokens.
 */
export function parseNat(a: Maybe<number>, cs: ReadonlyArray<string>): Result<number> {
  if (cs.length === 0) {
    return emit(a, []);
  }

  const [x, ...xs] = cs;
  const n = parseChar(x);

  if (n.type === 'digit') {
    const na = (defaultTo(0, a) * 10) + n.val;
    return parseNat(just(na), xs);
  }

  return emitBack(cs);
}

/**
 * attempt to take a natural number from a stream.
 */
export function takeNat(s: ReadonlyArray<string>): Result<Token> {
  const cs = takeCons(DIGITS, s);

  if (isCont(cs)) {
    const n = parseNat(nothing(), result(cs));

    if (isCont(n)) {
      return emitCont(digit(result(n)), remain(cs));
    }
  }

  return emitBack(s);
}

/**
 * parse an operator from a list of operator tokens.
 */
export function parseOper(s: ReadonlyArray<string>): Result<Token> {
  if (s.length === 0) {
    return emitBack([]);
  }

  const [x, ...xs] = s;
  const o = parseChar(x);

  if (o.type === 'oper') {
    return emitCont(o, xs);
  }

  return emitBack(s);
}

/**
 * attempt to take an operator from a stream.
 */
export function takeOper(s: ReadonlyArray<string>): Result<Token> {
  return parseOper(s);
}

/**
 * attempt to take a binary expression from a stream.
 */
export function takeBin(s: ReadonlyArray<string>): Result<Expr> {
  const lhs = takeStarter(ignoreCons(SKIPS, s));

  if (isCont(lhs)) {
    const oper = takeOper(ignoreCons(SKIPS, remain(lhs)));

    if (isCont(oper)) {
      const rhs = takeAny(ignoreCons(SKIPS, remain(oper)));

      if (isCont(rhs)) {
        return emitCont(bin(result(oper), result(lhs), result(rhs)), remain(rhs));
      }
    }
  }

  return emitBack(s);
}

/**
 * attempt to take a rule surrounded by parenthesis.
 */
export function takeGroup<T>(f: Parser<T>, s: ReadonlyArray<string>): Result<T> {
  const a = takeOnce(['('], s);

  if (isCont(a)) {
    const b = f(remain(a));

    if (isCont(b)) {
      const c = takeOnce([')'], remain(b));

      if (isCont(c)) {
        return emit(b.res, remain(c));
      }
    }
  }

  return emitBack(s);
}

/**
 * attempt to take the first rule. if that fails, attempt to take the second.
 */
export function takeAlt<TA, TB = TA>(a: Parser<TA>, b: Parser<TB>, s: ReadonlyArray<string>): Result<TA | TB> {
  const ra = a(s);
  if (isCont(ra)) {
    return ra;
  }

  const rb = b(s);
  if (isCont(rb)) {
    return rb;
  }

  return emitBack(s);
}

/**
 * split a string into expressions and parse them
 */
export function takeLine(c: ReadonlyArray<string>): ReadonlyArray<Result<Expr>> {
  return map(takeAny, split([';'], c));
}

export const takeBinGroup: Parser<Expr> = (takeGroup<Expr>).bind(nothing(), takeBin);
export const takeBinAltGroup: Parser<Expr> = (takeAlt<Expr>).bind(nothing(), takeBinGroup, takeBin);
export const takeAny: Parser<Expr> = (takeAlt<Expr>).bind(nothing(), takeBinAltGroup, takeNat);

// limit the first half of binary expressions to a group or number, removing the option for an immediately nested bin
export const takeStarter: Parser<Expr> = (takeAlt<Expr>).bind(nothing(), takeBinGroup, takeNat);