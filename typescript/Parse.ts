import { isJust, isNothing, Just, just, Maybe, Nothing, nothing } from './Maybe.js';
import { map, split } from './Util.js';

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

export interface BinExpr {
  oper: Token;
  lhs: Token;
  rhs: Token;
}

export interface Result<T, R = Maybe<T>> {
  res: R;
  rem: Array<string>;
}

export function emitCont<T>(val: T, rem: Array<string>): Result<T> {
  return {
    res: just(val),
    rem,
  };
}

export function emitBack<T>(rem: Array<string>): Result<T> {
  return {
    res: nothing(),
    rem,
  };
}

export function isCont<T>(r: Result<T>): r is Result<T, Just<T>> {
  return isJust(r.res);
}

export function isBack<T>(r: Result<T>): r is Result<T, Nothing> {
  return isNothing(r.res);
}

export function takeCons(cs: Array<string>, xs: Array<string>): Result<Array<string>> {
  return emitBack([]); // TODO
}

export function ignoreConst(cs: Array<string>, xs: Array<string>): Array<string> {
  return xs; // TODO
}

export function parseChar(): Result<Token> {
  return emitBack([]); // TODO
}

export function parseNat(): Result<number> {
  return emitBack([]); // TODO
}

export function takeNat(): Result<number> {
  return emitBack([]); // TODO
}

export function parseOper() {}

export function takeOper(): Result<Token> {
  return emitBack([]); // TODO
}

export function takeBin(): Result<BinExpr> {
  return emitBack([]); // TODO
}

export function takeLine(c: Array<string>): Array<Result<BinExpr>> {
  return map(takeBin, split([';'], c));
}
