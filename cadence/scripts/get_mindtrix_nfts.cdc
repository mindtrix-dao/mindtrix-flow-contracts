import Mindtrix from 0xf8d6e0586b0a20c7
import MetadataViews from 0x1d7e57aa55817448

pub struct NFT {
    pub let name: String
    pub let description: String
    pub let thumbnail: String
    pub let mintedTime: UFix64
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
        mintedTime: UFix64,
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
        self.mintedTime = mintedTime
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
        let displayView = MetadataViews.getDisplay(nft)!
        // Get the royalty information for the given NFT
        let royaltiesView = MetadataViews.getRoyalties(nft)!

        let externalURLView = MetadataViews.getExternalURL(nft)!

        let collectionDisplayView = MetadataViews.getNFTCollectionDisplay(nft)!
        let nftCollectionView = MetadataViews.getNFTCollectionData(nft)!

        let nftEditionView = MetadataViews.getEditions(nft)!
        let serialNumberView = MetadataViews.getSerial(nft)!

        let traitsView = MetadataViews.getTraits(nft)!
        let licenseView = MetadataViews.getLicense(nft)!

        let serialGenuses = nft.resolveView(Type<Mindtrix.SerialGenuses>())! as! [Mindtrix.SerialGenus]
        let audioEssence = nft.resolveView(Type<Mindtrix.AudioEssence>())! as! Mindtrix.AudioEssence

        let serialString = nft.resolveView(Type<Mindtrix.SerialString>())! as! Mindtrix.SerialString

        let ipfsBaseUrl = "https://ipfs.infura.io/ipfs/"
        let ipfsFileView = nft.resolveView(Type<MetadataViews.IPFSFile>())! as! MetadataViews.IPFSFile
        let ipfsDirectory = (ipfsFileView.path?.length ?? 0) > 0 ? ipfsFileView.path?.concat("/") ?? "" : ""
        let ipfsUrl = ipfsBaseUrl.concat(ipfsDirectory).concat(ipfsFileView.cid)

        let owner: Address = nft.owner!.address!
        let nftType = nft.getType()

        let collectionSocialDic: {String: String} = {}
        for key in collectionDisplayView.socials.keys {
            collectionSocialDic[key] = collectionDisplayView.socials[key]!.url
        }
        var mintedTime = UFix64(0.0)
        let traitDic: {String: AnyStruct} = {}
        for ele in traitsView.traits {
            let key = ele.name
            traitDic[key] = ele
            let isKeyEqualsMintedTime = key == "mintedTime"
            if isKeyEqualsMintedTime {
                let trait =  (traitDic[key]!) as! MetadataViews.Trait
                mintedTime = trait.value as? UFix64 ?? mintedTime
            }
        }
        nfts.append(NFT(
            name: displayView.name,
            description: displayView.description,
            thumbnail: displayView.thumbnail.uri(),
            mintedTime: mintedTime,
            ipfsUrl: ipfsUrl,
            ipfsFile: ipfsFileView,
            edition: nftEditionView.infoList[0],
            serialString: serialString.str,
            serialGenuses: serialGenuses,
            audioEssence: audioEssence,
            owner: owner,
            nftType: nftType.identifier,
            royalties: royaltiesView.getRoyalties(),
            collectionName: collectionDisplayView.name,
            collectionDescription: collectionDisplayView.description,
            collectionExternalURL: collectionDisplayView.externalURL.url,
            collectionSquareImage: collectionDisplayView.squareImage.file.uri(),
            collectionBannerImage: collectionDisplayView.bannerImage.file.uri(),
            collectionSocials: collectionSocialDic,
            license: licenseView.spdxIdentifier
         ))
    }

    return nfts
}
