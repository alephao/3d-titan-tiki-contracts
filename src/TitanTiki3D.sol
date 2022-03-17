// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

import {ERC1155} from "solmate/tokens/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract TitanTiki3D is ERC1155, Ownable {
    using Strings for uint160;
    using Strings for uint8;

    /// @dev 0x98d4901c
    error WrongValue();
    /// @dev 0x750b219c
    error WithdrawFailed();
    /// @dev 0x80cb55e2
    error NotActive();
    /// @dev 0xb36c1284
    error MaxSupply();
    /// @dev 0xb05e92fa
    error InvalidMerkleProof();
    /// @dev 0x843ce46b
    error InvalidClaimAmount();
    /// @dev 0x2c5211c6
    error InvalidAmount();

    // Immutable

    uint256 public constant TOTAL_LIMIT = 2022;
    uint256 public constant UNIT_PRICE = 0.1 ether;
    uint256 public constant MAX_PER_TX = 10;

    bytes32 public immutable merkleRoot;
    address private immutable _payoutAddress;

    // Mutable

    uint256 public totalSupply = 0;
    bool public isPresaleActive = false;
    string private _uri;
    bool public isSaleActive = false;

    /// @dev we know no one is allow-listed to claim more than 255, and we
    ///      found out uint8 was cheaper than other uints by trial
    mapping(address => uint8) public amountClaimedByUser;

    // Constructor

    constructor(
        address payoutAddress,
        string memory __uri,
        bytes32 _merkleRoot
    ) {
        // slither-disable-next-line missing-zero-check
        _payoutAddress = payoutAddress;
        _uri = __uri;
        merkleRoot = _merkleRoot;
    }

    // Owner Only

    function setURI(string calldata newUri) external onlyOwner {
        _uri = newUri;
    }

    function setIsSaleActive(bool newIsSaleActive) external onlyOwner {
        isSaleActive = newIsSaleActive;
    }

    function setIsPresaleActive(bool newIsPresaleActive) external onlyOwner {
        isPresaleActive = newIsPresaleActive;
    }

    function withdraw() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        // slither-disable-next-line low-level-calls
        (bool payoutSent, ) = payable(_payoutAddress).call{ // solhint-disable-line avoid-low-level-calls
            value: contractBalance
        }("");
        if (!payoutSent) revert WithdrawFailed();
    }

    function reserve(address to, uint256 amount) external onlyOwner {
        unchecked {
            if (amount + totalSupply > TOTAL_LIMIT) revert MaxSupply();
        }
        _mintMany(to, amount);
    }

    // User

    function mint(uint256 amount) external payable {
        if (!isSaleActive) revert NotActive();
        if (amount == 0 || amount > MAX_PER_TX) revert InvalidAmount();
        unchecked {
            if (msg.value != amount * UNIT_PRICE) revert WrongValue();
            if (amount + totalSupply > TOTAL_LIMIT) revert MaxSupply();
        }
        _mintMany(msg.sender, amount);
    }

    function claim(
        uint8 amount,
        uint8 totalAmount,
        bytes32[] calldata proof
    ) external {
        if (!isPresaleActive) revert NotActive();
        unchecked {
            if (amountClaimedByUser[msg.sender] + amount > totalAmount)
                revert InvalidClaimAmount();
        }
        bytes32 leaf = keccak256(
            abi.encodePacked(
                uint160(msg.sender).toHexString(20),
                ":",
                totalAmount.toString()
            )
        );
        bool isProofValid = MerkleProof.verify(proof, merkleRoot, leaf);
        if (!isProofValid) revert InvalidMerkleProof();
        unchecked {
            amountClaimedByUser[msg.sender] += amount;
        }
        _mintMany(msg.sender, amount);
    }

    // Internal Helpers

    function _mintMany(address to, uint256 amount) internal {
        uint256[] memory ids = new uint256[](amount);
        uint256[] memory amounts = new uint256[](amount);

        uint256 supply = totalSupply;
        unchecked {
            totalSupply += amount;
            for (uint256 i = 0; i < amount; i++) {
                ids[i] = supply + i + 1;
                amounts[i] = 1;
            }
        }

        _batchMint(to, ids, amounts, "");
    }

    // Overrides

    function uri(uint256) public view override returns (string memory) {
        return _uri;
    }
}
