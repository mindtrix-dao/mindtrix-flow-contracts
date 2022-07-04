import path from 'path';
import {
  deployContractByName,
  emulator,
  getContractAddress,
  init,
} from 'flow-js-testing';

(async () => {
  try {
    const basePath = path.resolve(__dirname, './cadence');
    await init(basePath);
    await emulator.start();

    await deployContractByName({ name: 'FungibleToken' });
    await deployContractByName({ name: 'NonFungibleToken' });
    await deployContractByName({ name: 'MetadataViews' });
    await deployContractByName({ name: 'Mindtrix' });

    const contractAddress = await getContractAddress('Mindtrix');
    console.log({ contractAddress });

    await emulator.stop();
  } catch (e) {
    console.error(e);
  }
})();
