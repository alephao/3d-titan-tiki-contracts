// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

import {Errors} from "$/test/utils/Errors.sol";
import {TitanTiki3DTestBase} from "./TitanTiki3DTestBase.sol";

// solhint-disable func-name-mixedcase
contract TitanTiki3DMintUnitTest is TitanTiki3DTestBase {
    // solhint-disable-next-line var-name-mixedcase
    uint256 internal UNIT_PRICE;

    function setUp() public override {
        super.setUp();
        UNIT_PRICE = tiki.UNIT_PRICE();
    }

    function test_mint() public {
        HEVM.prank(owner);
        tiki.setIsSaleActive(true);

        HEVM.deal(usr, UNIT_PRICE);
        HEVM.prank(usr);
        tiki.mint{value: UNIT_PRICE}(1);

        assertEq(tiki.balanceOf(usr, 1), 1);
        assertEq(tiki.totalSupply(), 1);
    }

    function test_mint_SaleNotActive() public {
        HEVM.deal(usr, UNIT_PRICE);
        HEVM.startPrank(usr);
        HEVM.expectRevert(Errors.NotActive());
        tiki.mint{value: UNIT_PRICE}(1);
    }

    function test_mint_GreaterPrice() public {
        HEVM.prank(owner);
        tiki.setIsSaleActive(true);

        HEVM.deal(usr, UNIT_PRICE + 1);
        HEVM.prank(usr);
        HEVM.expectRevert(Errors.WrongValue());

        tiki.mint{value: UNIT_PRICE + 1}(1);
    }

    function test_mint_LowerPrice() public {
        HEVM.prank(owner);
        tiki.setIsSaleActive(true);

        HEVM.deal(usr, UNIT_PRICE);
        HEVM.startPrank(usr);
        HEVM.expectRevert(Errors.WrongValue());
        tiki.mint{value: UNIT_PRICE - 1}(1);
    }

    function test_mint_OverTxLimit() public {
        HEVM.prank(owner);
        tiki.setIsSaleActive(true);

        HEVM.deal(usr, UNIT_PRICE * 11);
        HEVM.prank(usr);
        HEVM.expectRevert(Errors.InvalidAmount());
        tiki.mint{value: UNIT_PRICE * 11}(11);
    }

    function test_mint_Zero() public {
        HEVM.prank(owner);
        tiki.setIsSaleActive(true);

        HEVM.prank(usr);
        HEVM.expectRevert(Errors.InvalidAmount());
        tiki.mint(0);
    }

    function test_mint_OverMaxSupply() public {
        HEVM.startPrank(owner);
        tiki.setIsSaleActive(true);
        tiki.reserve(owner, 2021);
        HEVM.stopPrank();

        HEVM.deal(usr, UNIT_PRICE * 2);
        HEVM.prank(usr);
        HEVM.expectRevert(Errors.MaxSupply());
        tiki.mint{value: UNIT_PRICE * 2}(2);
    }
}
