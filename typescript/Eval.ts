import { BinExpr, emitBack, emitCont, isCont, result, Result } from './Parse.js';

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
          return emitCont(br.lhs.val / br.rhs.val, b.rem);
        default:
          return emitBack(b.rem);
      }
    }
  }

  return emitBack(b.rem);
}