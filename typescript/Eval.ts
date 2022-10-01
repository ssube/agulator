import { BinExpr, emitCont, Result } from './Parse.js';

export function evalBin(b: Result<BinExpr>): Result<number> {
  return emitCont(0, b.rem); // TODO
}