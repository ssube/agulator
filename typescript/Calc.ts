import { evalTree } from './Eval.js';
import { getLine, putStrLn } from './IO.js';
import { nothing } from './Maybe.js';
import { takeLine } from './Parse.js';
import { show, showList, showResult } from './Show.js';
import { map, primStringToList } from './Util.js';

export function main(): Promise<void> {
  return getLine().then(c => putStrLn(showList((showResult<number>).bind(nothing(), show), map(evalTree, takeLine(primStringToList(c))))));
}

main().catch(err => {
  console.error(err);
});