import path from 'path';
import {
  deployContractByName,
  emulator,
  executeScript,
  getAccountAddress,
  init,
} from 'flow-js-testing';

(async () => {
  const basePath = path.resolve(__dirname, './cadence');

  await init(basePath);
  await emulator.start();

  await deployContractByName({ name: 'FungibleToken' });
  await deployContractByName({ name: 'NonFungibleToken' });
  await deployContractByName({ name: 'MetadataViews' });
  await deployContractByName({ name: 'Mindtrix' });

  const Alice = await getAccountAddress('Alice');

  const argsCollector = [Alice];
  const argsMinter = ['0xf8d6e0586b0a20c7'];
  const name = 'get_is_mindtrix_init';

  const [fromFileByCollector] = await executeScript({
    name,
    args: argsCollector,
  });
  console.log({ fromFileByCollector });

  const [fromFileByMinter] = await executeScript({ name, args: argsMinter });
  console.log({ fromFileByMinter });

  await emulator.stop();
})();
