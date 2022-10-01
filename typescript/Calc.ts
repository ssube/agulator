import { getLine, putStrLn } from './IO.js';

import { evalBin } from './Eval.js';
import { takeLine } from './Parse.js';
import { show, showList, showResult } from './Show.js';
import { map, primStringToList } from './Util.js';

export function main(): Promise<void> {
  return getLine().then(c => putStrLn(showList((showResult<number>).bind(null, show), map(evalBin, takeLine(primStringToList(c))))));
}

main().catch(err => {
  console.error(err);
});