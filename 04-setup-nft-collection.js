import path from 'path';
import {
  deployContractByName,
  emulator,
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
  const Bob = await getAccountAddress('Bob');

  const code = `
    transaction(message: String){
      prepare(first: AuthAccount, second: AuthAccount){
          log(message)
          log(first.address)
          log(second.address)
      }
    }
  `;
  const signers = [Alice, Bob];
  const args = ['Hello from Cadence'];
  const [txInlineResult] = await sendTransaction({ code, signers, args });
  console.log('txInlineResult["example_code"]', txInlineResult);

  const signers2 = ['0xf8d6e0586b0a20c7'];
  const args2 = [];
  const name = 'setup_nft_collection';
  const [txFileResult] = await sendTransaction({
    name,
    signers: signers2,
    args: args2,
  });
  console.log('txFileResult["setup_nft_collection"]:', txFileResult);

  await emulator.stop();
})();
