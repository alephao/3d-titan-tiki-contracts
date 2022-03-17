// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {TitanTiki3D} from "$/TitanTiki3D.sol";
import {Errors} from "$/test/utils/Errors.sol";

// solhint-disable func-name-mixedcase
contract TitanTiki3DE2ETest is DSTest {
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

    function setUp() public {
        allowed1Proof = new bytes32[](1);
        allowed1Proof[
            0
        ] = 0x9dee6b23288982da686b23468461af8596280f702b398b0ceb2b132c28476353;

        allowed2Proof = new bytes32[](1);
        allowed2Proof[
            0
        ] = 0x77b27a60a64c6b822ff4babf4d16448d692d643178dd5be076b94804ff9aca15;
    }

    // A test to simulate a real scenario
    function test_e2e() public {
        // Owner creates contract
        HEVM.prank(owner);
        TitanTiki3D tiki = new TitanTiki3D(payoutAddress, uri, merkleRoot);

        uint256 unitPrice = tiki.UNIT_PRICE();
        uint256 priceFor10 = unitPrice * 10;

        // Owner reserves 222 nfts for itself
        HEVM.prank(owner);
        tiki.reserve(owner, 222);
        assertEq(tiki.totalSupply(), 222); // assert current supply is 222
        unchecked {
            // assert owner owns all nfts from 1 to 222
            for (uint256 i = 1; i < 223; i++) {
                assertEq(tiki.balanceOf(owner, i), 1);
            }
        }

        // Allowed 1 tries to claim but presale has not started yet
        HEVM.prank(allowed1);
        HEVM.expectRevert(Errors.NotActive());
        tiki.claim(allowed1Limit, allowed1Limit, allowed1Proof);

        // Owner starts presale
        HEVM.prank(owner);
        tiki.setIsPresaleActive(true);
        assertTrue(tiki.isPresaleActive());

        // Allowed 1 tries to claim again, successfully
        HEVM.prank(allowed1);
        tiki.claim(allowed1Limit, allowed1Limit, allowed1Proof);
        assertEq(tiki.totalSupply(), 223);
        assertEq(tiki.balanceOf(allowed1, 223), 1);

        // Allowed 1 tries claiming again, but it fails cuz they already claimed all they could
        HEVM.prank(allowed1);
        HEVM.expectRevert(Errors.InvalidClaimAmount());
        tiki.claim(allowed1Limit, allowed1Limit, allowed1Proof);

        // Allowed 2 claims one of their two
        HEVM.prank(allowed2);
        tiki.claim(allowed2Limit - 1, allowed2Limit, allowed2Proof);
        assertEq(tiki.totalSupply(), 224);
        assertEq(tiki.balanceOf(allowed2, 224), 1);

        // User tries to mint, but regular sale is off
        HEVM.prank(usr);
        HEVM.expectRevert(Errors.NotActive());
        tiki.mint(10);

        // Owner starts sale
        HEVM.prank(owner);
        tiki.setIsSaleActive(true);
        assertTrue(tiki.isSaleActive());

        // Gibe many plz I report u hu3hu3
        HEVM.deal(usr, priceFor10 + unitPrice);

        // User tries to mint again, but more than amount allowed per tx
        HEVM.prank(usr);
        HEVM.expectRevert(Errors.InvalidAmount());
        tiki.mint(11);

        // User tries to mint again, with amount = 0
        HEVM.prank(usr);
        HEVM.expectRevert(Errors.InvalidAmount());
        tiki.mint(0);

        // User tries to mint again, with a valid amount, but paying a lower price
        HEVM.prank(usr);
        HEVM.expectRevert(Errors.WrongValue());
        tiki.mint{value: unitPrice}(10);

        // User tries to mint again, with a valid amount, but paying a higher price
        HEVM.prank(usr);
        HEVM.expectRevert(Errors.WrongValue());
        tiki.mint{value: priceFor10 + unitPrice}(10);

        // User tries to mint again, with a valid amount this time
        HEVM.prank(usr);
        tiki.mint{value: priceFor10}(10);
        assertEq(tiki.totalSupply(), 234); // assert current supply is 234
        unchecked {
            // assert usr owns all nfts from 225 to 234
            for (uint256 i = 225; i < 235; i++) {
                assertEq(tiki.balanceOf(usr, i), 1);
            }
        }

        // Allowed 2 claims their last one
        HEVM.prank(allowed2);
        tiki.claim(1, allowed2Limit, allowed2Proof);
        assertEq(tiki.totalSupply(), 235);
        assertEq(tiki.balanceOf(allowed2, 235), 1);

        // User claims the 1787 left
        HEVM.startPrank(usr); // --------------------- Start Prank
        unchecked {
            // Claim 1780
            for (uint256 i = 0; i < 178; i++) {
                HEVM.deal(usr, priceFor10);
                tiki.mint{value: priceFor10}(10);
            }
        }
        HEVM.deal(usr, unitPrice * 7);
        tiki.mint{value: unitPrice * 7}(7); // claim the 7 left
        assertEq(tiki.totalSupply(), 2022); // assert current supply is 2022
        unchecked {
            // assert owner owns all nfts from 236 to 2022
            for (uint256 i = 236; i < 2023; i++) {
                assertEq(tiki.balanceOf(usr, i), 1);
            }
        }

        // Try minting one more (more than limit)
        HEVM.deal(usr, unitPrice);
        HEVM.expectRevert(Errors.MaxSupply());
        tiki.mint{value: unitPrice}(1);
        HEVM.stopPrank(); // ------------------------- Stop Prank

        // Ether is withdrawn from the contract
        HEVM.prank(owner);
        tiki.withdraw();
        assertEq(payable(payoutAddress).balance, 179.7 ether);
    }
}
