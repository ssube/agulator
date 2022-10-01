export const SymbolNothing = Symbol.for('nothing');
export const SymbolJust = Symbol.for('just');

export type Nothing = {
  [SymbolNothing]: null;
}

export type Just<T> = {
  [SymbolJust]: T;
}

export type Maybe<T> = Nothing | Just<T>;

export const Nothing: Nothing = {
  [SymbolNothing]: null,
};

export function just<T>(val: T): Just<T> {
  return {
    [SymbolJust]: val,
  };
}

export function nothing(): Nothing {
  return Nothing;
}

export function isJust<T>(m: Maybe<T>): m is Just<T> {
  return Object.getOwnPropertyDescriptor(m, SymbolJust) !== undefined;
}

export function isNothing<T>(m: Maybe<T>): m is Nothing {
  return Object.getOwnPropertyDescriptor(m, SymbolNothing) !== undefined;
}
