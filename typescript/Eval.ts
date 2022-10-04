import { emitBack, emitCont, Expr, isCont, Result, result } from './Parse.js';

/**
 * evaluate a binary expression of the form `Oper o -> Digit a -> Digit b`
 */
export function evalTree(b: Result<Expr>): Result<number> {
  if (isCont(b)) {
    const br = result(b);

    if (br.type === 'digit') {
      return emitCont(br.val, b.rem);
    }

    if (br.type === 'bin' && br.oper.type === 'oper') {
      const lhs = evalTree(emitCont(br.lhs, b.rem));
      const rhs = evalTree(emitCont(br.rhs, b.rem));

      if (isCont(lhs) && isCont(rhs)) {
        switch (br.oper.val) {
          case '+':
            return emitCont(result(lhs) + result(rhs), b.rem);
          case '-':
            return emitCont(result(lhs) - result(rhs), b.rem);
          case '*':
            return emitCont(result(lhs) * result(rhs), b.rem);
          case '/':
            if (result(rhs) === 0) {
              return emitBack(b.rem);
            } else {
              return emitCont(result(lhs) / result(rhs), b.rem);
            }
          default:
            return emitBack(b.rem);
        }
      }
    }
  }

  return emitBack(b.rem);
}
