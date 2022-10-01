import { mustExist } from './Maybe.js';

/**
 * functional wrapper for Array.map
 */
export function map<T, R>(f: (t: T) => R, arr: ReadonlyArray<T>): ReadonlyArray<R> {
  return arr.map(f);
}

/**
 * split an array into a list of arrays based on a set of delimiters.
 */
export function split<T>(cs: ReadonlyArray<T>, xs: ReadonlyArray<T>): ReadonlyArray<ReadonlyArray<T>> {
  const acl: Array<Array<T>> = [];
  const rem = Array.from(xs);

  function go(): number {
    const acc: Array<T> = [];

    while (rem.length > 0) {
      const x = mustExist(rem.shift());

      if (cs.includes(x)) {
        acl.push(acc);

        return acc.length;
      } else {
        acc.push(x);
      }
    }

    if (acc.length > 0) {
      acl.push(acc);
    }

    return acc.length;
  }

  while (go() > 0) {
    // keep going
  }

  return acl;
}

/**
 * split a string into a list of individual characters.
 *
 * equivalent to https://agda.github.io/agda-stdlib/Agda.Builtin.String.html#454
 */
export function primStringToList(s: string): ReadonlyArray<string> {
  return s.split('');
}

export function primStringFromList(s: ReadonlyArray<string>): string {
  return s.join('');
}