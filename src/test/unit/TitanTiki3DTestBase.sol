// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {TitanTiki3D} from "$/TitanTiki3D.sol";

// solhint-disable func-name-mixedcase
contract TitanTiki3DTestBase is DSTest {
    // solhint-disable-next-line var-name-mixedcase
    Vm internal HEVM = Vm(HEVM_ADDRESS);

    TitanTiki3D internal tiki;

    address internal _payoutAddress =
        address(uint160(uint256(keccak256("payout"))));
    string internal _uri = "https://example.com/{id}";
    bytes32 internal _merkleRoot = "";

    address internal usr = address(uint160(uint256(keccak256("usr"))));
    address internal owner = address(uint160(uint256(keccak256("owner"))));

    function setUp() public virtual {
        HEVM.prank(owner);
        tiki = new TitanTiki3D(_payoutAddress, _uri, _merkleRoot);
    }
}
