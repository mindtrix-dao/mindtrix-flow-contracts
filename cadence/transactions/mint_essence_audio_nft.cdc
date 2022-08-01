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
    audioEssenceDictionary: {String: [UFix64]},
    metadata: [{String: AnyStruct}]
) {
    // local variable for storing the minter reference
    let minter: &Mindtrix.NFTMinter

    /// Reference to the receiver's collection
    let recipientCollectionRef: &{NonFungibleToken.CollectionPublic}

    /// Previous NFT ID before the transaction executes
    let mintingIDBefore: UInt64

    var totalEditionQuantity: UInt64

    prepare(signer: AuthAccount) {
        self.mintingIDBefore = Mindtrix.totalSupply
        // Borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&Mindtrix.NFTMinter>(from: Mindtrix.MinterStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")

        // Borrow the recipient's public NFT collection reference
        self.recipientCollectionRef = getAccount(recipient)
            .getCapability(Mindtrix.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        self.totalEditionQuantity = 0
    }

    execute {

        var royalties: [MetadataViews.Royalty] = []
        var audioEssences: [Mindtrix.AudioEssence] = []
        let royaltyReceiverPublicPath: PublicPath = /public/flowTokenReceiver

        for key in royaltyDictionary.keys {
          let beneficiaryCapability = getAccount(key)
             .getCapability<&{FungibleToken.Receiver}>(royaltyReceiverPublicPath)
          if !beneficiaryCapability.check() { panic("Beneficiary capability is not valid!") }

          let nestedDictionary = royaltyDictionary[key] ?? [0.0, ""]
          let cut = nestedDictionary[0] as? UFix64!
          let description = nestedDictionary[1] as? String!

          assert(cut != nil && description != nil, message: "Both the cut and description should be mappable and not be nil.")

          royalties.append(
            MetadataViews.Royalty(
                receiver: beneficiaryCapability,
                cut: cut,
                description: description,
            )
          )
        }

        for key in audioEssenceDictionary.keys {
          let nestedDictionary = audioEssenceDictionary[key] ?? [0.0, 0.0, 0.0]
          let startTime = nestedDictionary[0] as? UFix64
          let endTime = nestedDictionary[1] as? UFix64
          let fullEpisodeDuration = nestedDictionary[2] as? UFix64

          audioEssences.append(
            Mindtrix.AudioEssence(
                startTime: startTime,
                endTime: endTime,
                fullEpisodeDuration: fullEpisodeDuration,
            )
          )
        }

        let len = UInt64(ipfsCid.length);
        var i: UInt64 = 0
        while i < len {

            let metadata = metadata[i] as {String: AnyStruct}
            let audioEssence = audioEssences[i]
            self.totalEditionQuantity = self.totalEditionQuantity + editionQuantity[i]
            // Mint the NFT and deposit it to the recipient's collection
            self.minter.batchMintNFT(
                recipient: self.recipientCollectionRef,
                name: name[i],
                description: description[i],
                thumbnail: thumbnail[i],
                ipfsCid: ipfsCid[i],
                ipfsDirectory: ipfsDirectory[i],
                royalties: royalties,
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
                audioEssence: audioEssence,
                metadata: metadata
            )
            i = i + UInt64(1)
        }
    }

    post {
        Mindtrix.totalSupply == self.mintingIDBefore + self.totalEditionQuantity:
        "The total supply should have been increased by the given edition:".concat(self.totalEditionQuantity.toString())
    }
}
