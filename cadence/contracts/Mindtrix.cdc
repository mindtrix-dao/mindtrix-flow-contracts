/*

============================================================
Name: NFT Contract for Mindtrix
Author: AS
============================================================

Mindtrix is a decentralized podcast community on Flow.
A community derives from podcasters, listeners, and collectors.

Mindtrix aims to provide a better revenue stream for podcasters
and build a value-oriented NFT for collectors to support their
favorite podcasters easily. :)

The contract represents the core functionalities of Mindtrix
NFTs. Podcasters can mint the two kinds of NFTs, Essence Audio
and Essence Image, based on their podcast episodes. Collectors
can buy the NFTs from podcasters' public sales or secondary
market on Flow.

Besides implementing the MetadataViews(thanks for the strong
community to build this standard), we also add some structure
to encapsulate the view objects. For example, the SerialGenus
categorize NFTs in a hierarchical genus structure, explaining
the NFT's origin from a specific episode under a show. You can
check the detailed definition in the resolveView function of
the SerialGenuses type.

Mindtrix's vision is to create long-term value for NFTs.
If more collectors are willing to get meaningful ones, it
would also bring a new revenue stream for creators.
Therefore, more people would embrace the crypto world!

To flow into the Mindtrix forest, please check:
https://www.mindtrix.xyz

============================================================

*/

import FungibleToken from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20

pub contract Mindtrix: NonFungibleToken {


 // ========================================================
 //                          PATH
 // ========================================================

    pub let RoyaltyReceiverPublicPath: PublicPath
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

 // ========================================================
 //                          EVENT
 // ========================================================

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)

 // ========================================================
 //                       MUTABLE STATE
 // ========================================================

    pub var totalSupply: UInt64

 // ========================================================
 //                      IMMUTABLE STATE
 // ========================================================

    pub let AdminAddress: Address

 // ========================================================
 //                           ENUM
 // ========================================================

    pub enum FirstSerial: UInt8 {
        pub case voice
    }

    pub enum VoiceSerial: UInt8 {
        // audio = 0 + 1 = 1 in Serial, 0 is a reserved number
        pub case audio
        // image = 1 + 1 = 2 in Serial
        pub case image
        // quest = 2 + 1 = 3 in Serial
        pub case quest
    }

 // ========================================================
 //               COMPOSITE TYPES: STRUCTURE
 // ========================================================

    pub struct SerialGenuses {
        pub let infoList: [SerialGenus]

        init(infoList: [SerialGenus]) {
            self.infoList = infoList
        }
    }

    // SerialGenus aims to breakdown an NFT's genus
    pub struct SerialGenus  {
        // number 1 here is defined as the top tier
        pub let tier: UInt8
        pub let name: String
        pub let description: String?
        pub let number: Number

        init(tier: UInt8,number: Number, name: String, description: String?) {
            self.tier = tier
            self.number = number
            self.name = name
            self.description = description
        }
    }

    // AudioEssence is optional and only exists when an NFT is a VoiceSerial.audio.
    pub struct AudioEssence  {
        // The UFix64 type is to support the time in milliseconds, e.g. startTime = 96.0 = 00:01:36
        pub let startTime: UFix64?
        // The UFix64 type is to support the time in milliseconds, e.g. endTime = 365.0 = 00:06:05
        pub let endTime: UFix64?
        // The UFix64 type is to support the time in milliseconds, e.g. fullEpisodeDuration = 1864.0 = 00:31:04
        pub let fullEpisodeDuration: UFix64?

        init(startTime: UFix64?, endTime: UFix64?, fullEpisodeDuration: UFix64?) {
            self.startTime = startTime
            self.endTime = endTime
            self.fullEpisodeDuration = fullEpisodeDuration
        }
    }

    // SerialString represents a searching purpose to discern the NFTs genus.
    pub struct SerialString {
        pub let str: String

        init(str: String) {
            self.str = str
        }
    }

 // ========================================================
 //               COMPOSITE TYPES: RESOURCE
 // ========================================================

    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
        pub let id: UInt64

        pub let name: String
        pub let description: String
        pub let thumbnail: String
        pub let ipfsCid: String
        pub let ipfsDirectory: String
        access(self) let royalties: [MetadataViews.Royalty]
        access(self) let metadata: {String: AnyStruct}

        pub let collectionName: String
        pub let collectionDescription: String
        pub let collectionExternalURL: String
        pub let collectionSquareImageUrl: String
        pub let collectionSquareImageType: String
        pub let collectionSocials: {String: String}

        pub let firstSerial: UInt16
        pub let secondSerial: UInt16
        pub let thirdSerial: UInt16
        pub let fourthSerial: UInt32
        pub let fifthSerial: UInt16

        pub let editionNumber: UInt64
        pub let editionQuantity: UInt64

        pub let licenseIdentifier: String

        init(
            id: UInt64,
            name: String,
            description: String,
            thumbnail: String,
            ipfsCid: String,
            ipfsDirectory: String,
            royalties: [MetadataViews.Royalty],
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
            fifthSerial: UInt16,
            editionNumber: UInt64,
            editionQuantity: UInt64,
            metadata: {String: AnyStruct}
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.thumbnail = thumbnail
            self.ipfsCid = ipfsCid
            self.ipfsDirectory = ipfsDirectory
            self.royalties = royalties
            self.collectionName = collectionName
            self.collectionDescription = collectionDescription
            self.collectionExternalURL = collectionExternalURL
            self.collectionSquareImageUrl = collectionSquareImageUrl
            self.collectionSquareImageType = collectionSquareImageType
            self.collectionSocials = collectionSocials
            self.licenseIdentifier = licenseIdentifier
            self.firstSerial = firstSerial
            self.secondSerial = secondSerial
            self.thirdSerial = thirdSerial
            self.fourthSerial = fourthSerial
            self.fifthSerial = fifthSerial
            self.editionNumber = editionNumber
            self.editionQuantity = editionQuantity
            self.metadata = metadata
        }

        pub fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.Serial>(),
                Type<MetadataViews.ExternalURL>(),
                Type<MetadataViews.Editions>(),
                Type<MetadataViews.Royalties>(),
                Type<MetadataViews.License>(),
                Type<MetadataViews.NFTCollectionData>(),
                Type<MetadataViews.NFTCollectionDisplay>(),
                Type<MetadataViews.Traits>(),
                Type<Mindtrix.SerialString>(),
                Type<Mindtrix.SerialGenuses>()
            ]
        }

        pub fun getSerialNumber(): UInt64 {
            assert(self.firstSerial <= 18, message: "The first serial number should not be over 18 because the serial is an UInt64 number.")
            let fullSerial = UInt64(self.firstSerial) * 1000000000000000000 +
                UInt64(self.secondSerial) * 10000000000000000 +
                UInt64(self.thirdSerial) * 10000000000000 +
                UInt64(self.fourthSerial) * 100000000 +
                UInt64(self.fifthSerial) * 100000 +
                UInt64(self.editionNumber)

            return fullSerial;
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: self.name,
                        description: self.description,
                        thumbnail: MetadataViews.HTTPFile(
                            url: self.thumbnail
                        )
                    )
                case Type<MetadataViews.ExternalURL>():
                    // the URL will be replaced with a gallery link in the future.
                    return MetadataViews.ExternalURL(self.collectionExternalURL)
                case Type<MetadataViews.Editions>():
                    // There is no max number of NFTs that can be minted from this contract
                    // so the max edition field value is set to nil
                    let editionInfo = MetadataViews.Edition(name: self.collectionName, number: self.editionNumber, max: self.editionQuantity)
                    let editionList: [MetadataViews.Edition] = [editionInfo]
                    return MetadataViews.Editions(
                        editionList
                    )
                case Type<MetadataViews.Serial>():
                    return MetadataViews.Serial(self.getSerialNumber())
                case Type<Mindtrix.SerialString>():
                    return Mindtrix.SerialString(self.getSerialNumber().toString())
                case Type<Mindtrix.SerialGenuses>():
                    let first = Mindtrix.SerialGenus(tier: 1, number: self.firstSerial, name: "nftRealm", description: "e.g. the Podcast, Literature, or Video")
                    let second = Mindtrix.SerialGenus(tier: 2, number: self.secondSerial, name: "nftEnum", description: "e.g. the Audio, Image, or Quest in a Podcast Show")
                    let third = Mindtrix.SerialGenus(tier: 3, number: self.thirdSerial, name: "nftFirstSet", description: "e.g. the 2nd podcast show of a creator")
                    let fourth = Mindtrix.SerialGenus(tier: 4, number: self.fourthSerial, name: "nftSecondSet", description: "e.g. the 18th episode of a podcast show")
                    let fifth = Mindtrix.SerialGenus(tier: 5, number: self.fifthSerial, name: "nftThirdSet", description: "e.g. the 10th essence of an episode")
                    let sixth = Mindtrix.SerialGenus(tier: 6, number: self.editionNumber, name: "nftEdtionNumber", description: "e.g. the 100th edition of a essence")
                    let genusList: [Mindtrix.SerialGenus] = [first, second, third, fourth, fifth, sixth]
                    return genusList
                case Type<Mindtrix.AudioEssence>():
                    return self.metadata["audioEssence"] ?? Mindtrix.AudioEssence(startTime: 0.0, endTime: 0.0, fullEpisodeDuration: 0.0)
                case Type<MetadataViews.Royalties>():
                    return MetadataViews.Royalties(
                        self.royalties
                    )
                case Type<MetadataViews.IPFSFile>():
                    return MetadataViews.IPFSFile(
                        cid: self.ipfsCid,
                        path: self.ipfsDirectory
                    )
                case Type<MetadataViews.License>():
                    return MetadataViews.License(self.licenseIdentifier)
                case Type<MetadataViews.NFTCollectionData>():
                    return MetadataViews.NFTCollectionData(
                        storagePath: Mindtrix.CollectionStoragePath,
                        publicPath: Mindtrix.CollectionPublicPath,
                        providerPath: /private/MindtrixCollection,
                        publicCollection: Type<&Mindtrix.Collection{Mindtrix.MindtrixCollectionPublic}>(),
                        publicLinkedType: Type<&Mindtrix.Collection{Mindtrix.MindtrixCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(),
                        providerLinkedType: Type<&Mindtrix.Collection{Mindtrix.MindtrixCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Provider,MetadataViews.ResolverCollection}>(),
                        createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {return <-Mindtrix.createEmptyCollection()})
                    )
                case Type<MetadataViews.NFTCollectionDisplay>():
                    let media = MetadataViews.Media(
                        file: MetadataViews.HTTPFile(url: self.collectionSquareImageUrl),
                        mediaType: self.collectionSquareImageType
                    )
                    var socials = {} as {String: MetadataViews.ExternalURL }
                    for key in self.collectionSocials.keys {
                        let socialUrl = self.collectionSocials[key]!
                        socials.insert(key: key, MetadataViews.ExternalURL(socialUrl))
                    }
                    return MetadataViews.NFTCollectionDisplay(
                        name: self.collectionName,
                        description: self.collectionDescription,
                        externalURL: MetadataViews.ExternalURL(self.collectionExternalURL),
                        squareImage: media,
                        bannerImage: media,
                        socials: socials
                    )
                case Type<MetadataViews.Traits>():
                    // exclude the following fields to show other uses of Traits
                    let excludedTraits = ["mintedTime", "mintedBlock", "minter", "audioEssenceStartTime", "audioEssenceEndTime", "fullEpisodeDuration"]
                    let traitsView = MetadataViews.dictToTraits(dict: self.metadata, excludedNames: excludedTraits)

                    // mintedTime is a unix timestamp, we mark it with a Date displayType so platforms know how to show it.
                    let mintedTimeTrait = MetadataViews.Trait(name: "mintedTime", value: self.metadata["mintedTime"]!, displayType: "Date", rarity: nil)
                    let audioEssenceStartTimeTrait = MetadataViews.Trait(name: "audioEssenceStartTime", value: self.metadata["audioEssenceStartTime"] ?? 0.0, displayType: "Time", rarity: nil)
                    let audioEssenceEndTimeTrait = MetadataViews.Trait(name: "audioEssenceEndTime", value: self.metadata["audioEssenceEndTime"]?? 0.0, displayType: "Time", rarity: nil)
                    let fullEpisodeDurationTrait = MetadataViews.Trait(name: "fullEpisodeDuration", value: self.metadata["fullEpisodeDuration"]?? 0.0, displayType: "Time", rarity: nil)

                    traitsView.addTrait(mintedTimeTrait)
                    traitsView.addTrait(audioEssenceStartTimeTrait)
                    traitsView.addTrait(audioEssenceEndTimeTrait)
                    traitsView.addTrait(fullEpisodeDurationTrait)

                    return traitsView
            }
            return nil
        }
    }

    pub resource interface MindtrixCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowMindtrix(id: UInt64): &Mindtrix.NFT? {
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow Mindtrix reference: the ID of the returned reference is incorrect"
            }
        }
    }

    pub resource Collection: MindtrixCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init () {
            self.ownedNFTs <- {}
        }

        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {

            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @Mindtrix.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }

        pub fun borrowMindtrix(id: UInt64): &Mindtrix.NFT? {
            let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
            return ref as! &Mindtrix.NFT
        }

        pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
            let nft = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
            let Mindtrix = nft as! &Mindtrix.NFT
            return Mindtrix as &AnyResource{MetadataViews.Resolver}
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    // Resource that an admin or something similar would own to be
    // able to mint new NFTs
    //
    pub resource NFTMinter {

        // mintNFT mints a new NFT with a new ID
        // and deposit it in the recipients collection using their collection reference
        pub fun mintNFT(
            recipient: &{NonFungibleToken.CollectionPublic},
            name: String,
            description: String,
            thumbnail: String,
            ipfsCid: String,
            ipfsDirectory: String,
            royalties: [MetadataViews.Royalty],
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
            fifthSerial: UInt16,
            editionNumber: UInt64,
            editionQuantity: UInt64,
            audioEssence: AudioEssence,
            metadata: {String: AnyStruct}
        ) {
            let currentBlock = getCurrentBlock()
            // general metadata that every NFT would include
            metadata["mintedBlock"] = currentBlock.height
            metadata["mintedTime"] = currentBlock.timestamp
            metadata["minter"] = recipient.owner!.address
            // only exist in audioEssence
            metadata["audioEssence"] = audioEssence

            // create a new NFT
            var newNFT <- create NFT(
                id: Mindtrix.totalSupply,
                name: name,
                description: description,
                thumbnail: thumbnail,
                ipfsCid: ipfsCid,
                ipfsDirectory: ipfsDirectory,
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
                fifthSerial: fifthSerial,
                editionNumber: editionNumber,
                editionQuantity: editionQuantity,
                metadata: metadata
            )

            // deposit it in the recipient's account using their reference
            recipient.deposit(token: <-newNFT)

            Mindtrix.totalSupply = Mindtrix.totalSupply + UInt64(1)
        }

        pub fun batchMintNFT(
            recipient: &{NonFungibleToken.CollectionPublic},
            name: String,
            description: String,
            thumbnail: String,
            ipfsCid: String,
            ipfsDirectory: String,
            royalties: [MetadataViews.Royalty],
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
            fifthSerial: UInt16,
            editionQuantity: UInt64,
            audioEssence: AudioEssence,
            metadata: {String: AnyStruct}
            ) {

            var i: UInt64 = 0
            while i < editionQuantity {
                // we'll put most params into structs to cut down the numbers of params in the next stage
                self.mintNFT(
                    recipient: recipient,
                    name: name,
                    description: description,
                    thumbnail: thumbnail,
                    ipfsCid: ipfsCid,
                    ipfsDirectory: ipfsDirectory,
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
                    fifthSerial: fifthSerial,
                    editionNumber: UInt64(i),
                    editionQuantity: editionQuantity,
                    audioEssence: audioEssence,
                    metadata: metadata
                )
                i = i + UInt64(1)
            }
        }
    }

 // ========================================================
 //                         FUNCTION
 // ========================================================

    // public function that anyone can call to create a new empty collection
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

 // ========================================================
 //                       CONTRACT INIT
 // ========================================================

    init() {
        self.totalSupply = 0
        self.AdminAddress = self.account.address
        self.RoyaltyReceiverPublicPath = /public/flowTokenReceiver
        self.CollectionStoragePath = /storage/MindtrixCollection
        self.CollectionPublicPath = /public/MindtrixCollection
        self.MinterStoragePath = /storage/MindtrixMinter

        self.account.save(<-create Collection(), to: self.CollectionStoragePath)
        self.account.link<&Mindtrix.Collection{NonFungibleToken.CollectionPublic, Mindtrix.MindtrixCollectionPublic, MetadataViews.ResolverCollection}>(
            self.CollectionPublicPath,
            target: self.CollectionStoragePath
        )

        self.account.save(<- create NFTMinter(), to: self.MinterStoragePath)

        emit ContractInitialized()
    }
}
