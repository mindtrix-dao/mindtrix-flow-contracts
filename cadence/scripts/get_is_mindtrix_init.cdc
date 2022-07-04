import MetadataViews from 0x1d7e57aa55817448
import Mindtrix from 0xf8d6e0586b0a20c7
import FungibleToken from 0xf233dcee88fe0abe

// import MetadataViews from 0x631e88ae7f1d7c20
// import Mindtrix from 0x739dbfea743996c3
// import FungibleToken from 0x9a0766d93b6608b7

pub fun main(address: Address): Bool {
    let account = getAccount(address)
    let isMindtrixCollectionInited = account
        .getCapability(Mindtrix.CollectionPublicPath)
        .borrow<&{Mindtrix.MindtrixCollectionPublic}>() != nil
    let flowTokenReceiverPublic = /public/flowTokenReceiver
    let isFlowVaultInited = account
        .getCapability(flowTokenReceiverPublic)
        .borrow<&{FungibleToken.Receiver}>() != nil
    let isInit = isMindtrixCollectionInited && isFlowVaultInited
    log("isInit:")
    log(isInit)
    return isInit
}
