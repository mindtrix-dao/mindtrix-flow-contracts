import path from 'path';
import {
  deployContractByName,
  emulator,
  getAccountAddress,
  init,
  sendTransaction,
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

    const recipientAddress = await getAccountAddress('Alice');
    const authenticatorAddress = '0xf8d6e0586b0a20c7';
    const extraMetadatas = {
      audioEssenceStartTime: '0',
    };

    const argObj = {
      recipientAddress,
      nftNames: 'S1EP0 | Cover Image',
      nftDescriptions: 'The Cover Image of the episode.',
      nftThumbnails:
        'https://files.soundon.fm/1632757564413-ae3e4e01-ea9b-4e86-a669-f60b9a4af778.jpeg',
      ipfsCid: 'QmawrE1YjHdXhkaSfPGdL9dTR9v7VFz1kwbPpWBkKovQUW',
      ipfsDirectories: '',
      nftRoyaltyDictionaries: {
        [recipientAddress]: [0.1, "The creator's royalty"],
        [authenticatorAddress]: [0.02, 'The DAO royalty'],
      },
      collectionName: 'S1EP0 | Sound Track Test',
      collectionDescription: 'A test MP3 for the sound track.',
      collectionExternalURL:
        'https://player.soundon.fm/p/f46c8367-d50d-444f-878b-be18aec92494/episodes/ea4ad414-2709-4ad5-a0ce-728508b60bb3',
      collectionSquareImageUrl:
        'https://files.soundon.fm/1632757564413-ae3e4e01-ea9b-4e86-a669-f60b9a4af778.jpeg',
      collectionSquareImageType: 'image/jpeg',
      collectionSocials: { twitter: 'none' },
      licenseIdentifier: 'CC-BY-NC-3.0',
      // nftRealm e.g. the Podcast, Literature, or Video
      firstSerial: 1,
      // nftEnum e.g. audio = 0 + 1 = 1 in Serial, 0 is a reserved number
      secondSerial: 2,
      // nftFirstSet e.g. the first podcast show of a creator is 1
      thirdSerial: 1,
      // nftSecondSet e.g. the first episode of a podcast show
      fourthSerial: 11,
      // nftThirdSet e.g. the serial of the first and second segments of an episode.
      fifthSerials: 1,
      // the edition quantity corresponds to the first and second segments of an episode.
      editionQuantities: 15,
      audioEssence: [[0.0, 0.0, 0.0]],
      extraMetadatas,
    };

    const args = Object.keys(argObj).map((k) => argObj[k]);
    const name = 'mint_essence_image_nft';
    const [txFileResult] = await sendTransaction({
      name,
      signers: [authenticatorAddress],
      args,
    });
    console.log('txFileResult["mint_essence_image_nft"]:', txFileResult);
  } catch (e) {
    console.log('error:', e);
  } finally {
    await emulator.stop();
  }
})();
