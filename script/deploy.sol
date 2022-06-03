// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

interface IERC721Creator {
    function registerExtension(address extension, string calldata baseURI) external;
}

interface ISaleExtension {
    function mint() external payable;

    function setBaseTokenURI(string calldata uri) external;

    function withdraw() external;
}

contract Deploy is Test {
    IERC721Creator public creator;
    ISaleExtension public extension;
    address extensionAddress;
    string constant vyperArtifact = "SaleExtension.json";

    function run() public returns (address) {
        vm.startBroadcast();
        address creatorAddress = 0xBDC105c068715D57860702Da9fa0c5EAd11fbA51;
        creator = IERC721Creator(creatorAddress);

        extensionAddress = deployCode(vyperArtifact, abi.encode(101, creatorAddress));

        creator.registerExtension(
            extensionAddress,
            "https://ipfs.io/ipfs/bafybeichnqc4nsgq632q4lzkw7niefhhlkx6uyunjpqfipibuqk6fivuoe/"
        );
        return extensionAddress;
    }
}
