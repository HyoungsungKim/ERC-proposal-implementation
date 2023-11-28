// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PerpetualContractNFT.sol";

contract PerpetualContractNFTDemo is PerpetualContractNFT {

    constructor(string memory name, string memory symbol)
        PerpetualContractNFT(name, symbol)
    {         
    }

    function mint(uint256 tokenId, address to) public {
        _mint(to, tokenId);
    }
}
