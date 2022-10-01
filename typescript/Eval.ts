import { BinExpr, emitBack, emitCont, isCont, result, Result } from './Parse.js';

/**
 * evaluate a binary expression of the form `Oper o -> Digit a -> Digit b`
 */
export function evalBin(b: Result<BinExpr>): Result<number> {
  if (isCont(b)) {
    const br = result(b);

    if (br.lhs.type === 'digit' && br.oper.type === 'oper' && br.rhs.type === 'digit') {
      switch (br.oper.val) {
        case '+':
          return emitCont(br.lhs.val + br.rhs.val, b.rem);
        case '-':
          return emitCont(br.lhs.val - br.rhs.val, b.rem);
        case '*':
          return emitCont(br.lhs.val * br.rhs.val, b.rem);
        case '/':
          if (br.rhs.val === 0) {
            return emitBack(b.rem);
          } else {
            return emitCont(br.lhs.val / br.rhs.val, b.rem);
          }
        default:
          return emitBack(b.rem);
      }
    }
  }

  return emitBack(b.rem);
}