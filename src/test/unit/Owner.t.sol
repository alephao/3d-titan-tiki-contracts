// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

import {Errors} from "$/test/utils/Errors.sol";
import {TitanTiki3DTestBase} from "./TitanTiki3DTestBase.sol";

// solhint-disable func-name-mixedcase
contract TitanTiki3DOwnerUnitTest is TitanTiki3DTestBase {
    function test_InitialState() public {
        assertTrue(!tiki.isSaleActive());
        assertEq(tiki.totalSupply(), 0);
    }

    function test_setURI() public {
        string memory newURI = "https://newuri.com/{id}";
        HEVM.prank(owner);
        tiki.setURI(newURI);
        assertEq(tiki.uri(0), newURI);
    }

    function test_setURI_AsNotOwner() public {
        string memory newURI = "https://newuri.com/{id}";
        HEVM.prank(usr);
        HEVM.expectRevert("Ownable: caller is not the owner");
        tiki.setURI(newURI);
    }

    function test_setIsSaleActive() public {
        HEVM.startPrank(owner);

        tiki.setIsSaleActive(true);
        assertTrue(tiki.isSaleActive());

        tiki.setIsSaleActive(false);
        assertTrue(!tiki.isSaleActive());
        HEVM.stopPrank();
    }

    function test_setIsSaleActive_AsNotOwner() public {
        HEVM.prank(usr);
        HEVM.expectRevert("Ownable: caller is not the owner");
        tiki.setIsSaleActive(true);
    }

    function test_setIsPresaleActive() public {
        HEVM.startPrank(owner);

        tiki.setIsPresaleActive(true);
        assertTrue(tiki.isPresaleActive());

        tiki.setIsPresaleActive(false);
        assertTrue(!tiki.isPresaleActive());
        HEVM.stopPrank();
    }

    function test_setIsPresaleActive_AsNotOwner() public {
        HEVM.prank(usr);
        HEVM.expectRevert("Ownable: caller is not the owner");
        tiki.setIsPresaleActive(true);
    }

    function test_withdraw() public {
        uint256 balance = 1 ether;
        HEVM.prank(owner);
        HEVM.deal(address(tiki), balance);

        tiki.withdraw();

        assertEq(_payoutAddress.balance, balance);
    }

    function test_withdraw_AsNotOwner() public {
        HEVM.prank(usr);
        HEVM.expectRevert("Ownable: caller is not the owner");
        tiki.withdraw();
    }

    function test_reserve() public {
        HEVM.prank(owner);
        tiki.reserve(usr, 2022);

        assertEq(tiki.totalSupply(), 2022);
        assertEq(tiki.balanceOf(usr, 1), 1);
        assertEq(tiki.balanceOf(usr, 2), 1);
        assertEq(tiki.balanceOf(usr, 2022), 1);
    }

    function test_reserve_MoreThanLimit() public {
        HEVM.prank(owner);
        HEVM.expectRevert(Errors.MaxSupply());
        tiki.reserve(usr, 2023);
    }

    function test_reserve_AsNotOwner() public {
        HEVM.prank(usr);
        HEVM.expectRevert("Ownable: caller is not the owner");
        tiki.reserve(usr, 10);
    }
}
