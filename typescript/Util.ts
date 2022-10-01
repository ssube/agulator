export function map<T, R>(f: (t: T) => R, arr: Array<T>): Array<R> {
  return arr.map(f);
}

export function split<T>(cs: Array<T>, xs: Array<T>): Array<Array<T>> {
  const acl: Array<Array<T>> = [];
  let acc: Array<T> = [];

  for (const x of xs) {
    if (cs.includes(x)) {
      acl.push(acc);
      acc = [];
    } else {
      acc.push(x);
    }
  }

  if (acc.length > 0) {
    acl.push(acc);
  }

  return acl;
}

export function primStringToList(s: string): Array<string> {
  return s.split('');
}
