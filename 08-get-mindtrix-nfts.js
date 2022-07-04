import path from 'path';
import {
  deployContractByName,
  emulator,
  executeScript,
  getAccountAddress,
  init,
  sendTransaction,
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

  const args = [Alice];

  const [setupNftCollectionResult] = await sendTransaction({
    name: 'setup_nft_collection',
    signers: [Alice],
    args: [],
  });

  console.log({ setupNftCollectionResult });

  const [getMindtrixNfts] = await executeScript({
    name: 'get_mindtrix_nfts',
    args,
  });
  console.log({ getMindtrixNfts });

  await emulator.stop();
})();
