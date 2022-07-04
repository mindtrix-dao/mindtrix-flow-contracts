import Mindtrix from 0xf8d6e0586b0a20c7
import MetadataViews from 0x1d7e57aa55817448

pub struct NFT {
    pub let name: String
    pub let description: String
    pub let thumbnail: String
    pub let ipfsUrl: String
    pub let ipfsFile: MetadataViews.IPFSFile
    pub let edition: MetadataViews.Edition
    pub let serialString: String
    pub let serialGenuses: [Mindtrix.SerialGenus]
    pub let audioEssence: Mindtrix.AudioEssence
    pub let owner: Address
    pub let type: String
    pub let royalties: [MetadataViews.Royalty]
    pub let collectionName: String
    pub let collectionDescription: String
    pub let collectionExternalURL: String
    pub let collectionSquareImage: String
    pub let collectionBannerImage: String
    pub let collectionSocials: {String: String}
    pub let license: String

    init(
        name: String,
        description: String,
        thumbnail: String,
        ipfsUrl: String,
        ipfsFile: MetadataViews.IPFSFile,
        edition: MetadataViews.Edition,
        serialString: String,
        serialGenuses: [Mindtrix.SerialGenus],
        audioEssence: Mindtrix.AudioEssence,
        owner: Address,
        nftType: String,
        royalties: [MetadataViews.Royalty],
        collectionName: String,
        collectionDescription: String,
        collectionExternalURL: String,
        collectionSquareImage: String,
        collectionBannerImage: String,
        collectionSocials: {String: String},
        license: String
    ) {
        self.name = name
        self.description = description
        self.thumbnail = thumbnail
        self.ipfsUrl = ipfsUrl
        self.ipfsFile = ipfsFile
        self.edition = edition
        self.serialString = serialString
        self.serialGenuses = serialGenuses
        self.audioEssence = audioEssence
        self.owner = owner
        self.type = nftType
        self.royalties = royalties
        self.collectionName = collectionName
        self.collectionDescription = collectionDescription
        self.collectionExternalURL = collectionExternalURL
        self.collectionSquareImage = collectionSquareImage
        self.collectionBannerImage = collectionBannerImage
        self.collectionSocials = collectionSocials
        self.license = license
    }
}

pub fun main(address: Address): [NFT] {
    let account = getAccount(address)
    let nfts: [NFT] = []

    let collection = account
        .getCapability(Mindtrix.CollectionPublicPath)
        .borrow<&{Mindtrix.MindtrixCollectionPublic}>()
        ?? panic("Could not borrow a reference to the collection")
    let nftIds = collection.getIDs();

    for id in nftIds {
        let nft = collection.borrowMindtrix(id: id)!
        // Get the basic display information for this NFT
        let view = nft.resolveView(Type<MetadataViews.Display>())!

        // Get the royalty information for the given NFT
        let expectedRoyaltyView = nft.resolveView(Type<MetadataViews.Royalties>())!

        let royaltyView = expectedRoyaltyView as! MetadataViews.Royalties

        let display = view as! MetadataViews.Display

        let collectionDisplay = nft.resolveView(Type<MetadataViews.NFTCollectionDisplay>())! as! MetadataViews.NFTCollectionDisplay
        let ipfsBaseUrl = "https://ipfs.infura.io/ipfs/"
        let ipfsFileView = nft.resolveView(Type<MetadataViews.IPFSFile>())! as! MetadataViews.IPFSFile
        let ipfsDirectory = (ipfsFileView.path?.length ?? 0) > 0 ? ipfsFileView.path?.concat("/") ?? "" : ""
        let ipfsUrl = ipfsBaseUrl.concat(ipfsDirectory).concat(ipfsFileView.cid)
        let nftEditionView = nft.resolveView(Type<MetadataViews.Editions>())! as! MetadataViews.Editions
        let serialGenuses = nft.resolveView(Type<Mindtrix.SerialGenuses>())! as! [Mindtrix.SerialGenus]
        let audioEssence = nft.resolveView(Type<Mindtrix.AudioEssence>())! as! Mindtrix.AudioEssence
        let serialString = nft.resolveView(Type<Mindtrix.SerialString>())! as! Mindtrix.SerialString

        let licenseView = nft.resolveView(Type<MetadataViews.License>()) ! as! MetadataViews.License

        let owner: Address = nft.owner!.address!
        let nftType = nft.getType()

        let collectionSocials: {String: String} = {}
        for key in collectionDisplay.socials.keys {
            collectionSocials[key] = collectionDisplay.socials[key]!.url
        }
        nfts.append(NFT(
            name: display.name,
            description: display.description,
            thumbnail: display.thumbnail.uri(),
            ipfsUrl: ipfsUrl,
            ipfsFile: ipfsFileView,
            edition: nftEditionView.infoList[0],
            serialString: serialString.str,
            serialGenuses: serialGenuses,
            audioEssence: audioEssence,
            owner: owner,
            nftType: nftType.identifier,
            royalties: royaltyView.getRoyalties(),
            collectionName: collectionDisplay.name,
            collectionDescription: collectionDisplay.description,
            collectionExternalURL: collectionDisplay.externalURL.url,
            collectionSquareImage: collectionDisplay.squareImage.file.uri(),
            collectionBannerImage: collectionDisplay.bannerImage.file.uri(),
            collectionSocials: collectionSocials,
            license: licenseView.spdxIdentifier
         ))
    }

    return nfts
}
