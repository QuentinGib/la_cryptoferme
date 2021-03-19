pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
contract Francistan is ERC721 {
    uint256 private _tokenIds;
    mapping (address => bool) public breeders;
    mapping (uint256 => Auction) public auction;
    mapping (uint256 => Fight) public fight;
    address admin;
    uint randNonce = 0; 

    struct Fight{
        uint256 tokenId;
        uint256 stake;
        bool isActive;
    }
    struct Auction{
        uint256 price;
        uint256 time;
        bool isActive;
        address bidder;
    }
    struct Animal{
        string feathers;
        uint256 weight;
        uint256 size;
        uint256 aggressivity;
    }
    constructor() ERC721("Francistan", "Coq") public {
        admin = msg.sender;
    }

    modifier isBreeder(){
        require(breeders[msg.sender]);
        _;
    }

    function registerBreeder(address breeder) public {
        require(msg.sender==admin);
        breeders[breeder]=true;
    }
    
    function declareAnimal(address breeder, string memory feathers, uint256 weight,uint256 size,uint256 aggressivity) isBreeder public {
        _tokenIds++;
        uint256 newItemId = _tokenIds;
        _mint(breeder, newItemId);
        _setTokenURI(newItemId, Animal(feathers,weight,size,aggressivity));
        return newItemId;
    }

    function deadAnimal(uint256 tokenId) public isBreeder {
        require(msg.sender==ownerOf(tokenId));
        _burn(tokenId);
    }

    function breedAnimal(uint256 tokenId1,uint256 tokenId2) public isBreeder{
        require(msg.sender==ownerOf(tokenId1) && msg.sender==ownerOf(tokenId2));
        string memory feathersChild = tokenURI(tokenId2).feathers;
        uint256 weightChild = (tokenURI(tokenId1).weight+ tokenURI(tokenId2).weight)/2;
        uint256 sizeChild = (tokenURI(tokenId1).size+ tokenURI(tokenId2).size)/2;
        uint256 aggressivityChild = (tokenURI(tokenId1).aggressivity+ tokenURI(tokenId2).aggressivity)/2;
        declareAnimal(msg.sender,feathersChild , weightChild, sizeChild, aggressivityChild);
    }

    function createAuction(uint256 price, uint256 tokenId) public isBreeder{
        require(msg.sender==ownerOf(tokenId));
        auction[tokenId]=Auction(price,block.timestamp+60*60*24*2,true,msg.sender);
    }

    function bidOnAuction(uint256 tokenId) public payable isBreeder{
        require(auction[tokenId].time>block.timestamp);
        require(auction[tokenId].price<msg.value);
        require(auction[tokenId].isActive);
        if (auction[tokenId].bidder!= ownerOf(tokenId)){
            auction[tokenId].bidder.send(auction[tokenId].price);
        }
        auction[tokenId].price=msg.value;
        auction[tokenId].bidder=msg.sender;
    }
    function acceptAuction(uint256 tokenId) public {
        approve(auction[tokenId].bidder,tokenId);
        require(auction[tokenId].time<=block.timestamp);
        auction[tokenId].isActive=false;
    }
    function claimAuction(uint256 tokenId) public isBreeder{
        require(msg.sender==auction[tokenId].bidder);
        require(!auction[tokenId].isActive);
        transferFrom(ownerOf(tokenId),auction[tokenId].bidder,tokenId);
    }

    function proposeFight(uint256 tokenId) public payable isBreeder{
        require(ownerOf(tokenId)==msg.sender);
        fight[tokenId]=Fight(msg.sender,msg.value, true);
    }
    
    function agreeToFight(uint256 tokenId1, uint256 tokenId2) public payable isBreeder{
        require(msg.value==fight[tokenId1].stake);
        fight[tokenId1].tokenId=tokenId1;
        uint256 result = animalFighting(tokenURI(tokenId1).aggressivity+tokenURI(tokenId2).aggressivity);
        if (result<= tokenURI(tokenId1).aggressivity) {
            ownerOf(tokenId1).send(fight[tokenId1].stake*2);
            deadAnimal(tokenId1);
        }
        else {
            ownerOf(tokenId2).send(fight[tokenId1].stake*2);
            deadAnimal(tokenId2);
        }
    }

    function animalFighting(uint256 odd) internal{
        
        randNonce++;   
       return uint(keccak256(abi.encodePacked(block.timestamp,  
                                              msg.sender,  
                                              randNonce))) % odd; 
    }
}