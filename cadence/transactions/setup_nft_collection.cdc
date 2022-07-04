import FungibleToken from 0xf233dcee88fe0abe
import NonFungibleToken from 0x1d7e57aa55817448
import MetadataViews from 0x1d7e57aa55817448
import Mindtrix from 0xf8d6e0586b0a20c7
import FlowToken from 0x1654653399040a61

transaction {

    prepare(signer: AuthAccount) {
        log("setup start.")
        if signer.borrow<&Mindtrix.Collection>(from: Mindtrix.CollectionStoragePath) == nil {
            // Create a new empty collection
            let collection <- Mindtrix.createEmptyCollection()

            // save it to the account
            signer.save(<-collection, to: Mindtrix.CollectionStoragePath)

            // create a public capability for the collection
            signer.link<&{NonFungibleToken.CollectionPublic, Mindtrix.MindtrixCollectionPublic, MetadataViews.ResolverCollection}>(
                Mindtrix.CollectionPublicPath,
                target: Mindtrix.CollectionStoragePath
            )
            log("Init Mindtirx collection successful.")
        } else {
           log("Collection Storage has already existed!")
        }

        //==== setup FLOW vault
        // Return early if FungibleToken Vault already exist
        if signer.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault) == nil {
            let flowToken <- FlowToken.createEmptyVault()
            signer.save(<-flowToken, to: /storage/flowTokenVault)

            // Create a public capability to the Vault that only exposes
            // the deposit function through the Receiver interface
            let capability = signer.link<&{FungibleToken.Receiver, FungibleToken.Balance}>(
                MetadataViews.getRoyaltyReceiverPublicPath(),
                target: /storage/flowTokenVault
            )!

            // Make sure the capability is valid
            if !capability.check() { panic("Beneficiary capability is not valid!") }

            log("Init Flow Vault successful.")
        } else {
            log("FlowToken Storage has already existed!")
        }

    }
}
