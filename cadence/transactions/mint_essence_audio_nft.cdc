import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import MetadataViews from 0x1d7e57aa55817448
import FlowToken from 0x1654653399040a61
import Mindtrix from 0xf8d6e0586b0a20c7

transaction(
    recipient: Address,
    name: [String],
    description: [String],
    thumbnail: [String],
    ipfsCid: [String],
    ipfsDirectory: [String],
    royaltyDictionary: {Address: [AnyStruct]},
    collectionName: String,
    collectionDescription: String,
    collectionExternalURL: String,
    collectionSquareImageUrl: String,
    collectionSquareImageType: String,
    collectionSocials: {String: String},
    licenseIdentifier: String,
    firstSerial: UInt16,
    secondSerial: UInt16,
    thirdSerial: UInt16,
    fourthSerial: UInt32,
    fifthSerial: [UInt16],
    editionQuantity: [UInt64],
    extraMetadata: [{String: AnyStruct}]
) {

    // local variable for storing the minter reference
    let minter: &Mindtrix.NFTMinter

    let royalties: [MetadataViews.Royalty]

    let royaltyReceiverPublicPath: PublicPath

    prepare(signer: AuthAccount) {
        self.royaltyReceiverPublicPath = /public/flowTokenReceiver
        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&Mindtrix.NFTMinter>(from: Mindtrix.MinterStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")

        var count = 0
        self.royalties = []

        for key in royaltyDictionary.keys {
          let beneficiaryCapability = getAccount(key)
             .getCapability<&{FungibleToken.Receiver}>(self.royaltyReceiverPublicPath)
          if !beneficiaryCapability.check() { panic("Beneficiary capability is not valid!") }

          let nestedDictionary = royaltyDictionary[key] ?? [0.0, ""]
          let cut = nestedDictionary[0] as? UFix64!
          let description = nestedDictionary[1] as? String!

          self.royalties.append(
            MetadataViews.Royalty(
                receiver: beneficiaryCapability,
                cut: cut,
                description: description,
            )
          )
        }
    }

    execute {
        log("recipient")
        log(recipient)
        // Borrow the recipient's public NFT collection reference
        let receiver = getAccount(recipient)
            .getCapability(Mindtrix.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        let len = UInt64(ipfsCid.length);
        var i: UInt64 = 0
        while i < len {

            // Mint the NFT and deposit it to the recipient's collection
            self.minter.batchMintNFT(
                recipient: receiver,
                name: name[i],
                description: description[i],
                thumbnail: thumbnail[i],
                ipfsCid: ipfsCid[i],
                ipfsDirectory: ipfsDirectory[i],
                royalties: self.royalties,
                collectionName: collectionName,
                collectionDescription: collectionDescription,
                collectionExternalURL: collectionExternalURL,
                collectionSquareImageUrl: collectionSquareImageUrl,
                collectionSquareImageType: collectionSquareImageType,
                collectionSocials: collectionSocials,
                licenseIdentifier: licenseIdentifier,
                firstSerial: firstSerial,
                secondSerial: secondSerial,
                thirdSerial: thirdSerial,
                fourthSerial: fourthSerial,
                fifthSerial: fifthSerial[i],
                editionQuantity: editionQuantity[i],
                extraMetadata: extraMetadata[i]
            )
            i = i + UInt64(1)
        }
    }
}
