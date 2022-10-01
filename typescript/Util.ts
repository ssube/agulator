import { mustExist } from './Maybe.js';

export function map<T, R>(f: (t: T) => R, arr: Array<T>): Array<R> {
  return arr.map(f);
}

export function split<T>(cs: Array<T>, xs: Array<T>): Array<Array<T>> {
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

export function primStringToList(s: string): Array<string> {
  return s.split('');
}
