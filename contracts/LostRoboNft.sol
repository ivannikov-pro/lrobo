// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./lib/ProxyRegistry.sol";

interface IStaker {
    function onStake(uint256[] memory tokenIds) external returns (bool);

    function onUnStake(uint256[] memory tokenIds) external returns (bool);
}

interface IDescriptor {
    function tokenURI(uint256 tokenId)
        external
        view
        virtual
        returns (string memory);
}

/**
 *
 */
contract LostRoboNft is
    ERC721A,
    ERC721ABurnable,
    ERC721AQueryable,
    ReentrancyGuard
{
    address private _migrator;
    address private _staker;
    address public descriptor;
    mapping(uint256 => uint256) public roboId;

    bool private _revealed;
    string private _notRevealedURI = "";

    // OpenSea
    ProxyRegistry private _proxyRegistry;

    event Linked(uint256 indexed tokenId, uint256 roboId);

    constructor(address proxyRegistry_, address migrator_)
        ERC721A("LostRobo", "LROBO")
    {
        _proxyRegistry = ProxyRegistry(proxyRegistry_);
        _migrator = migrator_;
    }

    modifier onlyMigrator() {
        require(msg.sender == _migrator, "Only migrator");
        _;
    }

    function link(uint256 tokenId, uint256 roboId_) external onlyMigrator {
        roboId[tokenId] = roboId_;
        emit Linked(tokenId, roboId_);
    }

    function mint(address to, uint256 quantity)
        external
        onlyMigrator
        nonReentrant
    {
        _safeMint(to, quantity);
    }

    function stake(uint256[] memory tokenIds) external {
        IStaker(_staker).onStake(tokenIds);
    }

    function unStake(uint256[] memory tokenIds) external {
        IStaker(_staker).onUnStake(tokenIds);
    }

    // The following functions are overrides required by Solidity.
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        override
        returns (bool)
    {
        if (address(_proxyRegistry.proxies(owner)) == operator) return true;
        return super.isApprovedForAll(owner, operator);
    }

    function name() external view override returns (string memory) {
        return "Name";
    }

    function symbol() external view returns (string memory) {
        return "Symbol";
    }

    function tokenURI(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (!_revealed) return _notRevealedURI;

        if (descriptor != address(0))
            return IDescriptor(descriptor).tokenURI(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        if (bytes(_tokenURI).length > 0) return _tokenURI;

        return
            string(
                abi.encodePacked(_baseURI, tokenId.toString(), _baseExtension)
            );
    }
}
