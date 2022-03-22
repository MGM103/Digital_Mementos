//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Upgradable contracts require upgradable type libraries
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "hardhat/console.sol";

//Library imports
import "./libraries/Base64.sol";

contract Milestone_Mementos is Initializable, ERC721URIStorageUpgradeable, UUPSUpgradeable, AccessControlUpgradeable {
    //Creating counter for keeping track of IDs
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenID;

    //Roles
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    //Will be used to keep track of all the mementos each person owns
    mapping(address => uint256[]) public owner2Mementos;

    event mementoCreated(uint256 tokenID, address creator);

    function initialize() initializer public {
        //console.log("Mementos deployed, Nolsy would be proud");
        __ERC721_init("Mementos", "MMNTOS");
        __ERC721URIStorage_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        //Grant appropriate roles to the creator
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);

        //Ensure the first NFT is ID 1
        _tokenID.increment();
    }

    function getMementos() public view returns(uint256[] memory){
        uint256[] memory userMementoIDs = owner2Mementos[msg.sender];
        return userMementoIDs;
    }

    function mintMemento(string memory _title, string memory _description, string memory _imageURI) external onlyRole(MINTER_ROLE) {
        //check for description length
        //possible check for proper URI, maybe will have to be done through front end
        //maybe make this ownable to ensure the contract isn't used by randoms

        uint256 newNFTID = _tokenID.current();

        string memory JSON = Base64.encode(
            abi.encodePacked(
                '{"name": "', _title, ' - #',
                // We set the title of our NFT as the generated word.
                StringsUpgradeable.toString(newNFTID),
                '", "description": "', _description,'", "image": "', _imageURI,
                '"}'
            )
        );

        string memory finalTokenURI = string(abi.encodePacked("data:application/json;base64,", JSON));

        _safeMint(msg.sender, newNFTID);
        _setTokenURI(newNFTID, finalTokenURI);

        owner2Mementos[msg.sender].push(newNFTID);
        _tokenID.increment();
        console.log("Mint successful!");

        emit mementoCreated(newNFTID, msg.sender);
    }

    //ensure only the deployer of the contract can upgrade them
    function _authorizeUpgrade(address newImplementation) internal onlyRole(UPGRADER_ROLE) override {}

    function supportsInterface(bytes4 interfaceId) public view 
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
