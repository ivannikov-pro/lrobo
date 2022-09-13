// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";

contract LostRoborovski is
    ERC721A,
    ERC721ABurnable,
    ERC721AQueryable,
    ReentrancyGuard
{
    address private _migrator;
    mapping(uint256 => uint256) public roboId;

    constructor(address migrator_) ERC721A("Lost Roborovski", "LROBO") {
        _migrator = migrator_;
    }

    modifier onlyMigrator() {
        require(msg.sender == _migrator, "Only migrator");
        _;
    }

    function link(uint256 tokenId, uint256 roboTokenId) external onlyMigrator {
        roboId[tokenId] = roboTokenId;
    }

    function mint(address to, uint256 quantity)
        external
        onlyMigrator
        nonReentrant
    {
        _safeMint(to, quantity);
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }
}
