// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

import {Errors} from "$/test/utils/Errors.sol";
import {TitanTiki3D} from "$/TitanTiki3D.sol";
import {TitanTiki3DTestBase} from "./TitanTiki3DTestBase.sol";

// solhint-disable func-name-mixedcase
contract TitanTiki3DClaimUnitTest is TitanTiki3DTestBase {
    function setUp() public override {
        super.setUp();
        _merkleRoot = 0x1012932b5e7975480732d479fe7b267c7c82b3d9d8b491e34a3239c5b2371abd;
        HEVM.startPrank(owner);
        tiki = new TitanTiki3D(_payoutAddress, _uri, _merkleRoot);
        tiki.setIsPresaleActive(true);
        HEVM.stopPrank();
    }

    function test_claim() public {
        bytes32[] memory proof = new bytes32[](2);
        proof[
            0
        ] = 0xcf323e50586090d5226ff55bc1ade190aa417be442fdc5ac9c60434f24b3894f;
        proof[
            1
        ] = 0xdc986e7ab00b000435af571b7e06a503c6e86a86126a3bcc341f516ee0d62c09;

        address claimer = 0x0000000000000000000000000000000000000001;

        HEVM.prank(claimer);
        tiki.claim(1, 2, proof);

        assertEq(tiki.balanceOf(claimer, 1), 1);
        assertEq(tiki.totalSupply(), 1);
    }

    function test_claim_PresaleNotActive() public {
        HEVM.prank(owner);
        tiki.setIsPresaleActive(false);

        bytes32[] memory proof = new bytes32[](2);
        proof[
            0
        ] = 0xcf323e50586090d5226ff55bc1ade190aa417be442fdc5ac9c60434f24b3894f;
        proof[
            1
        ] = 0xdc986e7ab00b000435af571b7e06a503c6e86a86126a3bcc341f516ee0d62c09;

        address claimer = 0x0000000000000000000000000000000000000001;

        HEVM.prank(claimer);
        HEVM.expectRevert(Errors.NotActive());
        tiki.claim(1, 2, proof);
    }

    function test_claim_InvalidProof() public {
        bytes32[] memory proof = new bytes32[](2);
        proof[
            0
        ] = 0xcf323e50586090d5226ff55bc1ade190aa417be442fdc5ac9c60434f24b3894f;
        proof[
            1
        ] = 0x1111111111111111111111111111111111111111111111111111111111111111;

        address claimer = 0x0000000000000000000000000000000000000001;

        HEVM.prank(claimer);
        HEVM.expectRevert(Errors.InvalidMerkleProof());
        tiki.claim(1, 2, proof);
    }

    function test_claim_InvalidProofTotalAmount() public {
        bytes32[] memory proof = new bytes32[](2);
        proof[
            0
        ] = 0xcf323e50586090d5226ff55bc1ade190aa417be442fdc5ac9c60434f24b3894f;
        proof[
            1
        ] = 0xdc986e7ab00b000435af571b7e06a503c6e86a86126a3bcc341f516ee0d62c09;

        address claimer = 0x0000000000000000000000000000000000000001;

        HEVM.prank(claimer);
        HEVM.expectRevert(Errors.InvalidMerkleProof());
        tiki.claim(1, 3, proof);
    }

    function test_claim_InvalidProofAddress() public {
        bytes32[] memory proof = new bytes32[](2);
        proof[
            0
        ] = 0xcf323e50586090d5226ff55bc1ade190aa417be442fdc5ac9c60434f24b3894f;
        proof[
            1
        ] = 0xdc986e7ab00b000435af571b7e06a503c6e86a86126a3bcc341f516ee0d62c09;

        address claimer = 0x0000000000000000000000000000000000000002;

        HEVM.prank(claimer);
        HEVM.expectRevert(Errors.InvalidMerkleProof());
        tiki.claim(1, 2, proof);
    }

    function test_claim_MoreThanAvailable() public {
        bytes32[] memory proof = new bytes32[](2);
        proof[
            0
        ] = 0xcf323e50586090d5226ff55bc1ade190aa417be442fdc5ac9c60434f24b3894f;
        proof[
            1
        ] = 0xdc986e7ab00b000435af571b7e06a503c6e86a86126a3bcc341f516ee0d62c09;
        address claimer = 0x0000000000000000000000000000000000000001;

        HEVM.startPrank(claimer);
        tiki.claim(2, 2, proof);
        assertEq(tiki.balanceOf(claimer, 1), 1);
        assertEq(tiki.balanceOf(claimer, 2), 1);
        assertEq(tiki.totalSupply(), 2);

        HEVM.expectRevert(Errors.InvalidClaimAmount());
        tiki.claim(1, 2, proof);
        HEVM.stopPrank();
    }
}
