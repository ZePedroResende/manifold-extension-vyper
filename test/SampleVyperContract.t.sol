// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {Test} from "forge-std/Test.sol";

interface SampleContract {

    function func1(uint256 num) external ;

    function func2(uint256 num) external ;
}


contract SampleVyperContractTest is Test{
    string constant vyperArtifact = "vyper/build/contracts/SampleContract.json";

    SampleContract sampleContract;
    function setUp() public {

        address sampleContractAddress = deployCode(
            vyperArtifact,
            abi.encode()
        );
        sampleContract = SampleContract(sampleContractAddress);
    }

    function testFunc1() public {
        sampleContract.func1(1337);
    }

    function testFunc2() public {
        sampleContract.func2(1337);
    }
}
