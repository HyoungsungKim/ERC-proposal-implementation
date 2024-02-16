import { expect } from "chai";
import { ethers } from "hardhat";

describe("PerpetualContractNFTDemo", function () {
  it("should allow an owner to collateralize an NFT, rent it to a contract, and then have the owner repay the loan", async function () {
    const [owner] = await ethers.getSigners();

    const PerpetualContractNFTDemo = await ethers.getContractFactory("PerpetualContractNFTDemo");
    const demo = await PerpetualContractNFTDemo.deploy("DemoNFT", "DNFT");
    await demo.waitForDeployment();
    expect(demo.target).to.be.properAddress;

    // Mint an NFT to the owner
    await demo.mint(1, owner.address);

    // Owner collateralizes the NFT for a loan
    const loanAmount = ethers.parseUnits("1", "ether"); // 1 Ether in Wei. Use Wei to avoid precision error.
    const interest = 5; // 5% interest
    const expiration = Math.floor(new Date().getTime() / 1000) + 300; // Expire after 60 minutes (3600 seconds), convert it to seconds because `hours` in solidity conveted to seconds
    
    await demo.connect(owner).collateralize(1, loanAmount, interest, expiration); // tokenId, loanAmount, interestRate, loanDuration

    // Check current user of the NFT (should be the contract address)
    expect(await demo.userOf(1)).to.equal(demo.target);

    // Borrower repays the loan to release the NFT
    const repayAmountWei = await demo.connect(owner).viewRepayAmount(1);
    await demo.connect(owner).repayLoan(1, repayAmountWei);
    
    // Check if the NFT is returned to the original owner after the loan is repaid
    expect(await demo.userOf(1)).to.equal("0x0000000000000000000000000000000000000000");
  });
});
