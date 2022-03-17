// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.4;

// The code in this file was generate. Do not modify!
// solhint-disable const-name-snakecase,func-name-mixedcase
library Errors {
    function WrongValue() internal pure returns (bytes memory) {
        return abi.encodeWithSignature("WrongValue()");
    }

    function InvalidAmount() internal pure returns (bytes memory) {
        return abi.encodeWithSignature("InvalidAmount()");
    }

    function InvalidClaimAmount() internal pure returns (bytes memory) {
        return abi.encodeWithSignature("InvalidClaimAmount()");
    }

    function MaxSupply() internal pure returns (bytes memory) {
        return abi.encodeWithSignature("MaxSupply()");
    }

    function InvalidMerkleProof() internal pure returns (bytes memory) {
        return abi.encodeWithSignature("InvalidMerkleProof()");
    }

    function WithdrawFailed() internal pure returns (bytes memory) {
        return abi.encodeWithSignature("WithdrawFailed()");
    }

    function NotActive() internal pure returns (bytes memory) {
        return abi.encodeWithSignature("NotActive()");
    }
}
// solhint-enalbe const-name-snakecase
