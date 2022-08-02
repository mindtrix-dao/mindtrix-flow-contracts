import MetadataViews from 0x631e88ae7f1d7c20
import Mindtrix from 0xb719296f75147461

pub struct NFT {
    pub let name: String
    pub let description: String
    pub let thumbnail: String
    pub let ipfsUrl: String
    pub let ipfsFile: MetadataViews.IPFSFile
    pub let owner: Address
    pub let type: String
    pub let royalties: [MetadataViews.Royalty]
    pub let serialNumber: UInt64
    pub let collectionPublicPath: PublicPath
    pub let collectionStoragePath: StoragePath
    pub let collectionProviderPath: PrivatePath
    pub let collectionPublic: String
    pub let collectionPublicLinkedType: String
    pub let collectionProviderLinkedType: String
    pub let collectionName: String
    pub let collectionDescription: String
    pub let collectionExternalURL: String
    pub let collectionSquareImage: String
    pub let collectionBannerImage: String
    pub let collectionSocials: {String: String}
    pub let edition: MetadataViews.Edition
    pub let license: String

    init(
        name: String,
        description: String,
        thumbnail: String,
        ipfsUrl: String,
        ipfsFile: MetadataViews.IPFSFile,
        owner: Address,
        nftType: String,
        royalties: [MetadataViews.Royalty],
        serialNumber: UInt64,
        collectionPublicPath: PublicPath,
        collectionStoragePath: StoragePath,
        collectionProviderPath: PrivatePath,
        collectionPublic: String,
        collectionPublicLinkedType: String,
        collectionProviderLinkedType: String,
        collectionName: String,
        collectionDescription: String,
        collectionExternalURL: String,
        collectionSquareImage: String,
        collectionBannerImage: String,
        collectionSocials: {String: String},
        edition: MetadataViews.Edition,
        license: String
    ) {
        self.name = name
        self.description = description
        self.thumbnail = thumbnail
        self.ipfsUrl = ipfsUrl
        self.ipfsFile = ipfsFile
        self.owner = owner
        self.type = nftType
        self.royalties = royalties
        self.serialNumber = serialNumber
        self.collectionPublicPath = collectionPublicPath
        self.collectionStoragePath = collectionStoragePath
        self.collectionProviderPath = collectionProviderPath
        self.collectionPublic = collectionPublic
        self.collectionPublicLinkedType = collectionPublicLinkedType
        self.collectionProviderLinkedType = collectionProviderLinkedType
        self.collectionName = collectionName
        self.collectionDescription = collectionDescription
        self.collectionExternalURL = collectionExternalURL
        self.collectionSquareImage = collectionSquareImage
        self.collectionBannerImage = collectionBannerImage
        self.collectionSocials = collectionSocials
        self.edition = edition
        self.license = license
    }
}

pub fun main(address: Address, id: UInt64): NFT {
    let account = getAccount(address)

    let collection = account
        .getCapability(Mindtrix.CollectionPublicPath)
        .borrow<&{Mindtrix.MindtrixCollectionPublic}>()
        ?? panic("Could not borrow a reference to the collection")

    let nft = collection.borrowMindtrix(id: id)!

    // Get the basic display information for this NFT
    let view = nft.resolveView(Type<MetadataViews.Display>())!

    // Get the royalty information for the given NFT
    let expectedRoyaltyView = nft.resolveView(Type<MetadataViews.Royalties>())!

    let royaltyView = expectedRoyaltyView as! MetadataViews.Royalties

    let display = view as! MetadataViews.Display

    let collectionDisplay = nft.resolveView(Type<MetadataViews.NFTCollectionDisplay>())! as! MetadataViews.NFTCollectionDisplay
    let nftCollectionView = nft.resolveView(Type<MetadataViews.NFTCollectionData>())! as! MetadataViews.NFTCollectionData
    let ipfsBaseUrl = "https://ipfs.infura.io/ipfs/"
    let ipfsFileView = nft.resolveView(Type<MetadataViews.IPFSFile>())! as! MetadataViews.IPFSFile
    let ipfsDirectory = (ipfsFileView.path?.length ?? 0) > 0 ? ipfsFileView.path?.concat("/") ?? "" : ""
    let ipfsUrl = ipfsBaseUrl.concat(ipfsDirectory).concat(ipfsFileView.cid)
    let nftEditionView = nft.resolveView(Type<MetadataViews.Editions>())! as! MetadataViews.Editions

    let serialNumberView = nft.resolveView(Type<MetadataViews.Serial>())! as! MetadataViews.Serial

    let licenseView = nft.resolveView(Type<MetadataViews.License>()) ! as! MetadataViews.License

    let owner: Address = nft.owner!.address!
    let nftType = nft.getType()

    let collectionSocials: {String: String} = {}
    for key in collectionDisplay.socials.keys {
        collectionSocials[key] = collectionDisplay.socials[key]!.url
    }

    return NFT(
        name: display.name,
        description: display.description,
        thumbnail: display.thumbnail.uri(),
        ipfsUrl: ipfsUrl,
        ipfsFile: ipfsFileView,
        owner: owner,
        nftType: nftType.identifier,
        royalties: royaltyView.getRoyalties(),
        serialNumber: serialNumberView.number,
        collectionPublicPath: nftCollectionView.publicPath,
        collectionStoragePath: nftCollectionView.storagePath,
        collectionProviderPath: nftCollectionView.providerPath,
        collectionPublic: nftCollectionView.publicCollection.identifier,
        collectionPublicLinkedType: nftCollectionView.publicLinkedType.identifier,
        collectionProviderLinkedType: nftCollectionView.providerLinkedType.identifier,
        collectionName: collectionDisplay.name,
        collectionDescription: collectionDisplay.description,
        collectionExternalURL: collectionDisplay.externalURL.url,
        collectionSquareImage: collectionDisplay.squareImage.file.uri(),
        collectionBannerImage: collectionDisplay.bannerImage.file.uri(),
        collectionSocials: collectionSocials,
        edition: nftEditionView.infoList[0],
        license: licenseView.spdxIdentifier
    )
}
