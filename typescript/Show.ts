import { SymbolJust } from './Maybe.js';
import { isCont, Result } from './Parse.js';

/**
 * functional wrapper for `number -> string`
 */
export function show(n: number): string {
  return n.toString();
}

/**
 * print a list
 */
export function showList<T>(f: (t: T) => string, arr: ReadonlyArray<T>): string {
  return arr.map(f).join(', ');
}

/**
 * print a result and its value or remainder
 */
export function showResult<T>(f: (t: T) => string, r: Result<T>): string {
  if (isCont(r)) {
    return 'result: ' + f(r.res[SymbolJust]);
  } else {
    return 'remainder: ' + r.rem.join('');
  }
}
