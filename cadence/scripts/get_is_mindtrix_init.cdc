import MetadataViews from 0x1d7e57aa55817448
import Mindtrix from 0xf8d6e0586b0a20c7
import FungibleToken from 0xf233dcee88fe0abe

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
