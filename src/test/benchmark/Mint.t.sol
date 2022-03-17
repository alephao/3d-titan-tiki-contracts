// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {TitanTiki3D} from "$/TitanTiki3D.sol";

// solhint-disable func-name-mixedcase
contract TitanTiki3DMintFromZeroBenchmarkTest is DSTest {
    // solhint-disable-next-line var-name-mixedcase
    Vm internal HEVM = Vm(HEVM_ADDRESS);

    TitanTiki3D internal tiki;

    function setUp() public virtual {
        tiki = new TitanTiki3D(address(this), "", "");
        tiki.setIsSaleActive(true);

        HEVM.deal(address(1), 100 ether);
    }

    function test_mint_1() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.1 ether}(1);
    }

    function test_mint_2() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.2 ether}(2);
    }

    function test_mint_3() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.3 ether}(3);
    }

    function test_mint_4() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.4 ether}(4);
    }

    function test_mint_5() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.5 ether}(5);
    }

    function test_mint_6() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.6 ether}(6);
    }

    function test_mint_7() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.7 ether}(7);
    }

    function test_mint_8() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.8 ether}(8);
    }

    function test_mint_9() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.9 ether}(9);
    }

    function test_mint_10() public {
        HEVM.prank(address(1));
        tiki.mint{value: 1 ether}(10);
    }
}

// solhint-disable func-name-mixedcase
contract TitanTiki3DMintFromOneBenchmarkTest is DSTest {
    // solhint-disable-next-line var-name-mixedcase
    Vm internal HEVM = Vm(HEVM_ADDRESS);

    TitanTiki3D internal tiki;

    function setUp() public virtual {
        tiki = new TitanTiki3D(address(this), "", "");
        tiki.setIsSaleActive(true);

        HEVM.deal(address(1), 100 ether);
        HEVM.prank(address(1));
        tiki.mint{value: 0.1 ether}(1);
    }

    function test_mint_1() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.1 ether}(1);
    }

    function test_mint_2() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.2 ether}(2);
    }

    function test_mint_3() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.3 ether}(3);
    }

    function test_mint_4() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.4 ether}(4);
    }

    function test_mint_5() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.5 ether}(5);
    }

    function test_mint_6() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.6 ether}(6);
    }

    function test_mint_7() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.7 ether}(7);
    }

    function test_mint_8() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.8 ether}(8);
    }

    function test_mint_9() public {
        HEVM.prank(address(1));
        tiki.mint{value: 0.9 ether}(9);
    }

    function test_mint_10() public {
        HEVM.prank(address(1));
        tiki.mint{value: 1 ether}(10);
    }
}
