import path from 'path';
import { emulator, getAccountAddress, init } from 'flow-js-testing';

(async () => {
  const basePath = path.resolve(__dirname, './cadence');

  await init(basePath);
  await emulator.start();

  const Alice = await getAccountAddress('Alice');
  console.log({ Alice });

  await emulator.stop();
})();
