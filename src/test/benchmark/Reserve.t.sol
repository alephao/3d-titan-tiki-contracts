// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {TitanTiki3D} from "$/TitanTiki3D.sol";

// solhint-disable func-name-mixedcase
contract TitanTiki3DReserveBenchmarkTest is DSTest {
    // solhint-disable-next-line var-name-mixedcase
    Vm internal HEVM = Vm(HEVM_ADDRESS);

    TitanTiki3D internal tiki;

    function setUp() public virtual {
        tiki = new TitanTiki3D(address(this), "", "");
    }

    function test_reserve_ZeroToOne() public {
        tiki.reserve(address(1), 1);
    }

    function test_reserve_222() public {
        tiki.reserve(address(1), 222);
    }
}

// solhint-disable func-name-mixedcase
contract TitanTiki3DReserve2BenchmarkTest is DSTest {
    // solhint-disable-next-line var-name-mixedcase
    Vm internal HEVM = Vm(HEVM_ADDRESS);

    TitanTiki3D internal tiki;

    function setUp() public virtual {
        tiki = new TitanTiki3D(address(this), "", "");
        tiki.reserve(address(1), 1);
    }

    function test_reserve_OneToTwo() public {
        tiki.reserve(address(1), 1);
    }
}
