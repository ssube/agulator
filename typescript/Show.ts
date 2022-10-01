import { SymbolJust } from './Maybe.js';
import { isCont, Result } from './Parse.js';

export function show(n: number): string {
  return n.toString();
}

export function showList<T>(f: (t: T) => string, arr: Array<T>): string {
  return arr.map(f).join(', ');
}

export function showResult<T>(f: (t: T) => string, r: Result<T>): string {
  if (isCont(r)) {
    return f(r.res[SymbolJust]);
  } else {
    return r.rem.join('');
  }
}
