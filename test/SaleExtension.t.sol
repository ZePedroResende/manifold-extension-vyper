// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import {ERC721Creator} from "@manifoldxyz/creator-core-solidity/contracts/ERC721Creator.sol";

import {Test} from "forge-std/Test.sol";

contract ERC721CreatorMock is ERC721Creator {
    constructor() ERC721Creator("MyToken", "MTK") {}

    function mintBaseMock(address to, string memory uri) public returns (uint256) {
        return ERC721Creator._mintBase(to, uri);
    }
}

interface ISaleExtension {
    function mint() external payable;

    function setBaseTokenURI(string calldata uri) external;

    function withdraw() external;
}

contract SaleExtensionTest is Test {
    address constant bob = address(0xB0B);
    address constant alice = address(0xBAD);
    address constant eve = address(0xE5E);

    ERC721CreatorMock public token;
    ISaleExtension public extension;
    address extensionAddress;
    string constant vyperArtifact = "vyper/build/contracts/SaleExtension.json";

    function setUp() public {
        token = new ERC721CreatorMock();

        vm.startPrank(alice);
        extensionAddress = deployCode(vyperArtifact, abi.encode(101, address(token)));
        vm.stopPrank();

        extension = ISaleExtension(extensionAddress);

        token.registerExtension(extensionAddress, "uri/");
    }

    function testMint() public {
        uint256 amount = 101;
        vm.startPrank(bob);
        for (uint256 i = 0; i < amount; ++i) {
            if (i >= 101) {
                vm.expectRevert();
            }
            extension.mint();
        }
        vm.stopPrank();

        if (amount < 101) {
            assertEq(token.balanceOf(bob), amount);
            assertEq(token.ownerOf(amount), bob);
        } else {
            assertEq(token.balanceOf(bob), 101);
            assertEq(token.ownerOf(101), bob);
        }
    }

    function testMintMaxSupply() public {
        uint256 amount = 101;
        vm.startPrank(bob);
        for (uint256 i = 0; i < amount; ++i) {
            if (i >= 101) {
                vm.expectRevert();
            }
            extension.mint();
        }
        vm.stopPrank();

        vm.startPrank(alice);
        if (amount >= 101) {
            vm.expectRevert();
        }
        extension.mint();
        vm.stopPrank();

        if (amount >= 101) {
            assertEq(token.balanceOf(bob), 101);

            if (amount >= 1) {
                assertEq(token.ownerOf(1), bob);
                assertEq(token.ownerOf(101), bob);
            }
        } else {
            assertEq(token.balanceOf(bob), amount);
            assertEq(token.balanceOf(alice), 1);

            if (amount >= 1) {
                assertEq(token.ownerOf(1), bob);
                assertEq(token.ownerOf(amount), bob);
            }
        }
    }

    function testSetBaseTokenURI(string calldata uri) public {
        vm.prank(bob);
        extension.mint();

        if (bytes(uri).length > 1024) {
            vm.expectRevert();
        }

        vm.prank(alice);
        extension.setBaseTokenURI(uri);

        vm.prank(bob);
        vm.expectRevert();
        extension.setBaseTokenURI("notallowed");

        assertEq(token.ownerOf(1), bob);

        if (bytes(uri).length > 1024) {
            assertEq(token.tokenURI(1), "uri/1");
        } else {
            assertEq(token.tokenURI(1), string(abi.encodePacked(uri, "1")));
        }
    }

    function testWithdraw(uint256 amount) public {
        vm.deal(bob, amount);

        vm.startPrank(bob);

        extension.mint{value: amount}();
        vm.expectRevert();
        extension.withdraw();

        vm.stopPrank();

        assertEq(address(extension).balance, amount);

        vm.startPrank(alice);

        extension.withdraw();

        vm.stopPrank();

        assertEq(address(extension).balance, 0);
        assertEq(address(alice).balance, amount);
    }
}
