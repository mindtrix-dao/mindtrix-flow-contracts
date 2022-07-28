# Mindtrix
Mindtrix is a podcast DAO on Flow. 🎙  
A community derives from podcasters, listeners, and collectors.
We're building a one-stop minting tool to bring the podcast ecosystem into the web3 world!

## Contract
The contracts aim to build a minting tool for podcasters to mint their podcast NFTs with ease. The graph provides a basic explanation of the usage scenario and hopes it helps when reviewing the code. 🙂

|Network|Address|
|-------|-------|
|testnet|[0xc5fdca10cd1aada3](https://flow-view-source.com/testnet/account/0xc5fdca10cd1aada3/contract/Mindtrix)|

![mindtrix_contract_architecture](https://i.imgur.com/o8dnuR9.png)

 - Mindtrix.cdc 
   - It represents the core functionalities of NFTs. Podcasters can mint the two kinds of NFTs, Audio 
and Image Essence, based on their podcast episodes. Collectors can buy the NFTs from podcasters' public sales or secondary market on Flow.

 - Essence.cdc 
   - An Essence is a segment in one episode of a podcast show. One episode may have multiple essences.
   
 - Verifier.cdc
   - A Verifier is the minting restrictions made by podcasters.
One essence may have multiple verifiers. It is inspired by `FLOATVerifiers.cdc` of Emerald City. (we always learn from Jacob 🤓)
   
 - Brand.cdc
   - A Brand is a podcast show and it is the top level category. One podcaster may host multiple shows.

For now, we just finished `Mindtrix.cdc`, and it would be helpful if you have the advice to improve the contract.🙏

## Unit Test
In this folder, you can find a `run.js` file which will allow you to easily run any of the provided tests.
Simply run `node run {fullFileName | number}` like this:
```shell
node run 01
```
and Node will run the script for you.
If argument you provided will not hit any files, tool will give you a handy list of available examples.

## Demo Video
https://youtu.be/4jP7c6nNrOs


## Community Campaigns 🎉
  1. [Get Qualification](https://discord.com/channels/950891440207192084/968770674602704896)
   - Your identity qualification is the first step in Mindtrix. It is essential for joining voting campaigns because we must ensure you are not a bot. 🤖🚫
   - After getting a qualification, you can go ahead to nominate your favorite podcaster, and we will send you a [FLOAT NFT](https://floats.city/0xee9ea27a81a8a9ec/event/365796839) as proof of your qualification!! 🎁

  2. [Nominate Podcasters](https://discord.com/channels/950891440207192084/968770674602704896)
   - Mindtrix is a DAO, so everyone can nominate their favorite podcasts in Discord. Mindtrix will invite the top 5 votes podcasts to join.


