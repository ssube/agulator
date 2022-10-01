import { Buffer } from 'node:buffer';
import { stdin, stdout } from 'node:process';

export async function getLine(): Promise<string> {
  return new Promise((res, rej) => {
    const chunks: Array<Buffer> = [];

    const onData = (chunk: Buffer) => {
      chunks.push(chunk);
    };

    const onEnd = () => {
      res(chunks.join(''));
    };

    const onError = (err: Error) => {
      rej(err);
    }

    stdin.on('end', onEnd);
    stdin.on('error', onError);
    stdin.on('data', onData);
  });
}

export async function putStrLn(ln: string): Promise<void> {
  stdout.write(ln + '\n');
}
