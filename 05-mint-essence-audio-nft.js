import path from 'path';
import {
  deployContractByName,
  emulator,
  getAccountAddress,
  getContractAddress,
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

    const contractAddress = await getContractAddress('Mindtrix');
    console.log({ contractAddress });

    const recipientAddress = await getAccountAddress('Alice');
    const authenticatorAddress = '0xf8d6e0586b0a20c7';

    const [setupNftCollectionResult] = await sendTransaction({
      name: 'setup_nft_collection',
      signers: [recipientAddress],
      args: [],
    });

    console.log({ setupNftCollectionResult });

    const extraMetadatas = [];

    const argObj = {
      recipientAddress,
      nftNames: ['S1EP0 | 00:00-00:05', 'S1EP0 | 00:05-00:10'],
      nftDescriptions: [
        'The first segment of the audio(00:00-00:05).',
        'The second segment of the audio(00:05-00:10).',
      ],
      nftThumbnails: [
        'https://files.soundon.fm/1632757564413-ae3e4e01-ea9b-4e86-a669-f60b9a4af778.jpeg',
        'https://files.soundon.fm/1632757564413-ae3e4e01-ea9b-4e86-a669-f60b9a4af778.jpeg',
      ],
      ipfsCids: ['result-000000-000005.mp3', 'result-000005-000010.mp3'],
      ipfsDirectories: [
        'QmQXuLcBrJtGk84skPCfN6y3XqjUMk3XPsEJa7KVZPuKKN/result-000000-000005',
        'QmQXuLcBrJtGk84skPCfN6y3XqjUMk3XPsEJa7KVZPuKKN/result-000005-000010',
      ],
      nftRoyaltyDictionaries: {
        [recipientAddress]: [0.1, "The creator's royalty"],
        [authenticatorAddress]: [0.02, 'The DAO royalty'],
      },
      collectionName: 'S1EP0 | Sound Track Test',
      collectionDescription: 'A test MP3 for the sound track.',
      collectionExternalURL:
        'https://filesb.soundon.fm/file/filesb/a06a2104-9530-44c1-8ab2-2210fcb0f339.mp3',
      collectionSquareImageUrl:
        'https://files.soundon.fm/1632757564413-ae3e4e01-ea9b-4e86-a669-f60b9a4af778.jpeg',
      collectionSquareImageType: 'image/jpeg',
      collectionSocials: { twitter: 'none' },
      licenseIdentifier: 'CC-BY-NC-3.0',
      // nftRealm e.g. the Podcast, Literature, or Video
      firstSerial: 1,
      // nftEnum e.g. audio = 0 + 1 = 1 in Serial, 0 is a reserved number
      secondSerial: 1,
      // nftFirstSet e.g. the first podcast show of a creator is 1
      thirdSerial: 1,
      // nftSecondSet e.g. the first episode of a podcast show
      fourthSerial: 1,
      // nftThirdSet e.g. the serial of the first and second segments of an episode.
      fifthSerials: [1, 2],
      // the edition quantity corresponds to the first and second segments of an episode.
      editionQuantities: [10, 15],
      audioEssence: [{key: "nft1", value: [0.0, 5.0, 1140.0]}, {key: "nft2", value: [0.0, 10.0, 1140.0]}],
      extraMetadatas,
    };

    const args = Object.keys(argObj).map((k) => argObj[k]);
    const name = 'mint_essence_audio_nft';
    const [txFileResult] = await sendTransaction({
      name,
      signers: [authenticatorAddress],
      args,
    });
    console.log('txFileResult["mint_essence_audio_nft"]:', txFileResult);
  } catch (e) {
    console.log('error:', e);
  } finally {
    await emulator.stop();
  }
})();
