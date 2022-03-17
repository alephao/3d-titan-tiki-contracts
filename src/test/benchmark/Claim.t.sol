// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {TitanTiki3D} from "$/TitanTiki3D.sol";
import {Errors} from "$/test/utils/Errors.sol";

// solhint-disable func-name-mixedcase
contract TitanTiki3DClaimFromZeroBenchmarkTest is DSTest {
    // solhint-disable-next-line var-name-mixedcase
    Vm internal HEVM = Vm(HEVM_ADDRESS);

    // ==== Mock merkle tree

    /// @dev 0x5707eef4a3c8520b02c3cfe7a12ba7832d373cd4
    address internal allowed1 =
        address(uint160(uint256(keccak256("allowed1"))));
    uint8 internal allowed1Limit = 1;
    bytes32[] internal allowed1Proof;

    /// @dev 0xb555165e30f7a7e5259b1733d2acf995ad95095d
    address internal allowed2 =
        address(uint160(uint256(keccak256("allowed2"))));
    uint8 internal allowed2Limit = 2;
    bytes32[] internal allowed2Proof;

    // ==== Contract constructor arguments

    address internal payoutAddress =
        address(uint160(uint256(keccak256("payout"))));
    string internal uri = "https://example.com/{id}";

    /// @dev the merkle root of the leaves:
    ///      0x5707eef4a3c8520b02c3cfe7a12ba7832d373cd4:1
    ///      0xb555165e30f7a7e5259b1733d2acf995ad95095d:2
    bytes32 internal merkleRoot =
        0x02acbcc3e51f13eb86976c3de4b7b55d3b0e7b1e4b58e48ccf7a1543b4cc1d9d;

    // ==== Other addresses

    address internal usr = address(uint160(uint256(keccak256("usr"))));
    address internal owner = address(uint160(uint256(keccak256("owner"))));

    TitanTiki3D internal tiki;

    function setUp() public {
        allowed1Proof = new bytes32[](1);
        allowed1Proof[
            0
        ] = 0x9dee6b23288982da686b23468461af8596280f702b398b0ceb2b132c28476353;

        allowed2Proof = new bytes32[](1);
        allowed2Proof[
            0
        ] = 0x77b27a60a64c6b822ff4babf4d16448d692d643178dd5be076b94804ff9aca15;

        tiki = new TitanTiki3D(payoutAddress, uri, merkleRoot);
        tiki.setIsPresaleActive(true);
    }

    function test_claim_1() public {
        HEVM.prank(allowed2);
        tiki.claim(1, allowed2Limit, allowed2Proof);
    }
}

// solhint-disable func-name-mixedcase
contract TitanTiki3DClaimFromOneBenchmarkTest is DSTest {
    // solhint-disable-next-line var-name-mixedcase
    Vm internal HEVM = Vm(HEVM_ADDRESS);

    // ==== Mock merkle tree

    /// @dev 0x5707eef4a3c8520b02c3cfe7a12ba7832d373cd4
    address internal allowed1 =
        address(uint160(uint256(keccak256("allowed1"))));
    uint8 internal allowed1Limit = 1;
    bytes32[] internal allowed1Proof;

    /// @dev 0xb555165e30f7a7e5259b1733d2acf995ad95095d
    address internal allowed2 =
        address(uint160(uint256(keccak256("allowed2"))));
    uint8 internal allowed2Limit = 2;
    bytes32[] internal allowed2Proof;

    // ==== Contract constructor arguments

    address internal payoutAddress =
        address(uint160(uint256(keccak256("payout"))));
    string internal uri = "https://example.com/{id}";

    /// @dev the merkle root of the leaves:
    ///      0x5707eef4a3c8520b02c3cfe7a12ba7832d373cd4:1
    ///      0xb555165e30f7a7e5259b1733d2acf995ad95095d:2
    bytes32 internal merkleRoot =
        0x02acbcc3e51f13eb86976c3de4b7b55d3b0e7b1e4b58e48ccf7a1543b4cc1d9d;

    // ==== Other addresses

    address internal usr = address(uint160(uint256(keccak256("usr"))));
    address internal owner = address(uint160(uint256(keccak256("owner"))));

    TitanTiki3D internal tiki;

    function setUp() public {
        allowed1Proof = new bytes32[](1);
        allowed1Proof[
            0
        ] = 0x9dee6b23288982da686b23468461af8596280f702b398b0ceb2b132c28476353;

        allowed2Proof = new bytes32[](1);
        allowed2Proof[
            0
        ] = 0x77b27a60a64c6b822ff4babf4d16448d692d643178dd5be076b94804ff9aca15;

        tiki = new TitanTiki3D(payoutAddress, uri, merkleRoot);
        tiki.setIsPresaleActive(true);

        HEVM.prank(allowed2);
        tiki.claim(1, allowed2Limit, allowed2Proof);
    }

    function test_claim_1() public {
        HEVM.prank(allowed2);
        tiki.claim(1, allowed2Limit, allowed2Proof);
    }
}
