interface IPerpetualContractNFT {

    // Emitted when an NFT is collateralized for obtaining a loan
    event Collateralized(uint256 indexed tokenId, address indexed owner, uint256 loanAmount, uint256 interestRate, uint256 loanDuration);

    // Emitted when a loan secured by an NFT is fully repaid, releasing the NFT from collateral
    event LoanRepaid(uint256 indexed tokenId, address indexed owner);

    // Emitted when a loan defaults, resulting in the transfer of the NFT to the lender
    event Defaulted(uint256 indexed tokenId, address indexed lender);

    // Enables an NFT owner to collateralize their NFT in exchange for a loan
    // @param tokenId The NFT to be used as collateral
    // @param loanAmount The amount of funds to be borrowed
    // @param interestRate The interest rate for the loan
    // @param loanDuration The duration of the loan
    function collateralize(uint256 tokenId, uint256 loanAmount, uint256 interestRate, uint64 loanDuration) external;

    // Enables a borrower to repay their loan and regain ownership of the collateralized NFT
    // @param tokenId The NFT that was used as collateral
    // @param repayAmount The amount of funds to be repaid
    function repayLoan(uint256 tokenId, uint256 repayAmount) external;

    // Allows querying the loan terms for a given NFT
    // @param tokenId The NFT used as collateral
    // @return loanAmount The amount of funds borrowed
    // @return interestRate The interest rate for the loan
    // @return loanDuration The duration of the loan
    // @return loanDueDate The due date for the loan repayment
    function getLoanTerms(uint256 tokenId) external view returns (uint256 loanAmount, uint256 interestRate, uint256 loanDuration, uint256 loanDueDate);

    // Allows querying the current owner of the NFT
    // @param tokenId The NFT in question
    // @return The address of the current owner
    function currentOwner(uint256 tokenId) external view returns (address);

    // View the total amount required to repay the loan for a given NFT
    // @param tokenId The NFT used as collateral
    // @return The total amount required to repay the loan, including interest
    function viewRepayAmount(uint256 tokenId) external view returns (uint256);
}