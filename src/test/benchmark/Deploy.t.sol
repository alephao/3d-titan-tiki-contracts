// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

import {TitanTiki3D} from "$/TitanTiki3D.sol";

// solhint-disable func-name-mixedcase
contract TitanTiki3DDeployBenchmarkTest {
    function test_deploy() public {
        // solhint-disable-next-line no-unused-vars
        TitanTiki3D tiki = new TitanTiki3D(
            0x0000000000000000000000000000000000000001,
            "ipfs://somerandomci/{id}",
            0x1012932b5e7975480732d479fe7b267c7c82b3d9d8b491e34a3239c5b2371abd
        );
    }
}
