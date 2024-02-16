// SPDX-License-Identifier: CC0-1.0 
pragma solidity ^0.8.0;

//import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IPerpetualContractNFT.sol";
import "./ERC4907/ERC4907.sol";

contract PerpetualContractNFT is ERC4907, IPerpetualContractNFT {
    struct LoanInfo {
        address borrower;   // Address that borrowed against the NFT
        uint256 loanAmount; // Amount of funds borrowed
        uint256 interestRate; // Interest rate for the loan
        uint64 loanDuration; // Duration of the loan
        uint256 loanStartTime; // Timestamp when the loan starts
    }

    mapping(uint256 => LoanInfo) internal _loans;

    //Constructor to initialize the Perpetual Contract NFT contract with the given name and symbo
    constructor(string memory name_, string memory symbol_)
        ERC4907(name_, symbol_)
    {}

    function collateralize(uint256 tokenId, uint256 loanAmount, uint256 interestRate, uint64 loanDuration) public override {
        require(ownerOf(tokenId) == msg.sender || isApprovedForAll(ownerOf(tokenId), msg.sender) || getApproved(tokenId) == msg.sender, "Not owner nor approved");

        LoanInfo storage info = _loans[tokenId];
        info.borrower = msg.sender;
        // The loan amount should reflect the asset's value as represented by the NFT, considering an appropriate loan-to-value (LTV) ratio.
        info.loanAmount = loanAmount;
        info.loanAmount = loanAmount;
        info.interestRate = interestRate;
        info.loanDuration = loanDuration;
        info.loanStartTime = block.timestamp;

        setUser(tokenId, address(this), loanDuration);
        emit Collateralized(tokenId, msg.sender, loanAmount, interestRate, loanDuration);

        // Further logic can be implemented here to manage the lending of assets
    }

    function repayLoan(uint256 tokenId, uint256 repayAmount) public override {
        require(_loans[tokenId].borrower == msg.sender, "Not the borrower.");

        // Calculate the total amount due for repayment
        uint256 totalDue = viewRepayAmount(tokenId);

        // Check if the repayAmount is sufficient to cover at least a part of the total due amount
        require(repayAmount <= totalDue, "Repay amount exceeds total due.");

        // Calculate the remaining loan amount after repayment
        _loans[tokenId].loanAmount = totalDue - repayAmount;

        // Resets the user of the NFT to the default state if the entire loan amount is fully repaid
        if(_loans[tokenId].loanAmount == 0) {
            setUser(tokenId, address(0), 0);
        }

        emit LoanRepaid(tokenId, msg.sender);
    }


    function getLoanTerms(uint256 tokenId) public view override returns (uint256, uint256, uint256, uint256) {
        LoanInfo storage info = _loans[tokenId];
        return (info.loanAmount, info.interestRate, info.loanDuration, info.loanStartTime);
    }

    function currentOwner(uint256 tokenId) public view override returns (address) {
        return ownerOf(tokenId);
    }

    function viewRepayAmount(uint256 tokenId) public view returns (uint256) {
        if (_loans[tokenId].loanAmount == 0) {
            // If the loan amount is zero, there is nothing to repay
            return 0;
        }

        // The interest is calculated on an hourly basis, prorated based on the actual duration for which the loan was held.
        // If the borrower repays before the loan duration ends, they are charged interest only for the time the loan was held.
        // For example, if the annual interest rate is 5% and the borrower repays in half the loan term, they pay only 2.5% interest.
        uint256 elapsed = block.timestamp > (_loans[tokenId].loanStartTime + _loans[tokenId].loanDuration) 
                        ? _loans[tokenId].loanDuration  / 1 hours
                        : (block.timestamp - _loans[tokenId].loanStartTime) / 1 hours;

        // Round up
        // Example: 15/4 = 3.75
        // round((15 + 4 - 1)/4) = 4, round((15/4) = 3)
        uint256 interest = ((_loans[tokenId].loanAmount * _loans[tokenId].interestRate / 100) * elapsed + (_loans[tokenId].loanDuration / 1 hours) - 1) / 
                       (_loans[tokenId].loanDuration / 1 hours);

        // Calculate the total amount due
        uint256 totalDue = _loans[tokenId].loanAmount + interest;

        return totalDue;
    }

    // Additional functions and logic to handle loan defaults, transfers, and other aspects of the NFT lifecycle
}