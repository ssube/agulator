export const SymbolNothing = Symbol.for('nothing');
export const SymbolJust = Symbol.for('just');

export type Nothing = {
  [SymbolNothing]: null;
}

export type Just<T> = {
  [SymbolJust]: T;
}

export type Maybe<T> = Nothing | Just<T>;

/**
 * singleton value of Nothing.
 *
 * equivalent to https://agda.github.io/agda-stdlib/Agda.Builtin.Maybe.html#195
 */
export const Nothing: Nothing = {
  [SymbolNothing]: null,
};

/**
 * constructor for populated Maybes.
 *
 * equivalent to https://agda.github.io/agda-stdlib/Agda.Builtin.Maybe.html#174
 */
export function just<T>(val: T): Just<T> {
  return {
    [SymbolJust]: val,
  };
}

/**
 * constructor for empty Maybes.
 *
 * equivalent to https://agda.github.io/agda-stdlib/Agda.Builtin.Maybe.html#195
 */
export function nothing(): Nothing {
  return Nothing;
}

/**
 * typeguard for populated Maybes.
 */
export function isJust<T>(m: Maybe<T>): m is Just<T> {
  return Object.getOwnPropertyDescriptor(m, SymbolJust) !== undefined;
}

/**
 * typeguard for empty Maybes.
 */
export function isNothing<T>(m: Maybe<T>): m is Nothing {
  return Object.getOwnPropertyDescriptor(m, SymbolNothing) !== undefined;
}

/**
 * assertion to remove undefined from types.
 *
 * this only exists because the JS stdlib leaks undefined in pop, shift, etc.
 */
export function mustExist<T>(m: T | undefined): T {
  if (m === undefined) {
    throw new Error('this is where things start to go wrong');
  } else {
    return m;
  }
}

/**
 * return the value from a Maybe, if populated, otherwise return a default value.
 */
export function defaultTo<T>(d: T, m: Maybe<T>): T {
  if (isJust(m)) {
    return m[SymbolJust];
  } else {
    return d;
  }
}
