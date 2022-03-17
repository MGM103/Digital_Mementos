//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./libraries/Base64.sol";

contract Milestone_Mementos is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenID;

    uint256 immutable maxSupply;

    mapping(address => uint256[]) public owner2Mementos;

    event mementoCreated(uint256 tokenID, address creator);

    constructor(uint256 _initSupply) ERC721("Mementos", "MNTOS") {
        console.log("Mementos deployed, Nolsy would be proud");
        maxSupply = _initSupply;
        _tokenID.increment();
        console.log(_tokenID.current());
    }

    function getMementos() public view returns(uint256[] memory){
        uint256[] memory userMementoIDs = owner2Mementos[msg.sender];
        return userMementoIDs;
    }

    function mintMemento(string memory _description, string memory _imageURI) external {
        require(_tokenID.current() < maxSupply + 1, "Mementos are maxed out!");

        uint256 newNFTID = _tokenID.current();

        string memory JSON = Base64.encode(
            abi.encodePacked(
                '{"name": "Milestone Mementos - #',
                // We set the title of our NFT as the generated word.
                Strings.toString(newNFTID),
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
}
