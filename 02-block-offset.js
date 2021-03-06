import path from 'path';
import {
  builtInMethods,
  emulator,
  executeScript,
  getBlockOffset,
  init,
  setBlockOffset,
} from 'flow-js-testing';

(async () => {
  const basePath = path.resolve(__dirname, './cadence');

  await init(basePath);
  await emulator.start();

  const [initialBlockOffset] = await getBlockOffset();
  console.log({ initialBlockOffset });

  // "getCurrentBlock().height" in your Cadence code will be replaced by Manager to a mocked value
  const code = `
    pub fun main(): UInt64 {
      return getCurrentBlock().height
    }
  `;

  // We can check that non-transformed code still works just fine
  const [normalResult] = await executeScript({ code });
  console.log({ normalResult });

  // Offset current block height by 42
  await setBlockOffset(42);
  // Let's check that offset value on Manager is actually changed to 42
  const [blockOffset] = await getBlockOffset();
  console.log({ blockOffset });

  // "transformers" field expects array of functions to operate update the code.
  // We will pass single operator "builtInMethods" provided by the framework to alter how getCurrentBlock().height is calculated
  const transformers = [builtInMethods];
  const [transformedResult] = await executeScript({ code, transformers });
  console.log({ transformedResult });

  // Stop the emulator
  await emulator.stop();
})();
