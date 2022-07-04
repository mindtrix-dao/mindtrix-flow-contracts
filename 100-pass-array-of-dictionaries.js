import path from 'path';
import { emulator, executeScript, init } from 'flow-js-testing';

(async () => {
  const basePath = path.resolve(__dirname, './cadence');

  await init(basePath);
  await emulator.start();

  const code = `
    pub fun main(meta: [{String:String}], key: String): String?{
      return meta[0]![key]
    }
  `;
  const args = [
    [
      {
        name: 'Giovanni Giorgio',
        nickname: 'Giorgio',
      },
    ],
    'name',
  ];

  const result = await executeScript({ code, args });
  console.log({ result });

  // Stop the emulator
  await emulator.stop();
})();
