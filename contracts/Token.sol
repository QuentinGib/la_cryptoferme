pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Francistan is ERC721 {
    uint256 private _tokenIds=0;
    mapping (address => bool) public breeders;
    mapping (uint256 => Auction) public auction;
    mapping (uint256 => Fight) public fight;
    mapping (uint256 => Animal) public animals;
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
        address payable bidder;
    }
    struct Animal{
        string feathers;
        uint256 weight;
        uint256 size;
        uint256 aggressivity;
        bool alive;
    }
    constructor() ERC721("Francistan", "Coq") public {
        admin = msg.sender;
    }

    modifier isBreeder(){
        require(breeders[msg.sender]);
        _;
    }
    modifier isAlive(uint256 tokenId){
        require(animals[tokenId]);
        _;
    }

    function registerBreeder(address breeder) public {
        require(msg.sender==admin);
        breeders[breeder]=true;
    }
    
    function declareAnimal(address breeder, string memory feathers, uint256 weight,uint256 size,uint256 aggressivity) isBreeder public returns(uint256){
        _tokenIds++;
        uint256 newItemId = _tokenIds;
        _mint(breeder, newItemId);
        animals[newItemId]=Animal(feathers,weight,size,aggressivity,true);
        _setTokenURI(newItemId, "");
        return newItemId;
    }

    function deadAnimal(uint256 tokenId) public isBreeder isAlive(tokenId){
        require(msg.sender==ownerOf(tokenId));
        animals[tokenId].alive =false;
        _burn(tokenId);
    }

    function breedAnimal(uint256 tokenId1,uint256 tokenId2) public isBreeder isAlive(tokenId1) isAlive(tokenId2){
        require(msg.sender==ownerOf(tokenId1) && msg.sender==ownerOf(tokenId2));
        string memory feathersChild = animals[tokenId2].feathers;
        uint256 weightChild = (animals[tokenId1].weight+ animals[tokenId2].weight)/2;
        uint256 sizeChild = (animals[tokenId1].size+ animals[tokenId2].size)/2;
        uint256 aggressivityChild = (animals[tokenId1].aggressivity+ animals[tokenId2].aggressivity)/2;
        declareAnimal(msg.sender,feathersChild , weightChild, sizeChild, aggressivityChild,true);
    }

    function createAuction(uint256 price, uint256 tokenId) public isBreeder isAlive(tokenId){
        require(msg.sender==ownerOf(tokenId));
        auction[tokenId]=Auction(price,block.timestamp+60*60*24*2,true,msg.sender);
    }

    function bidOnAuction(uint256 tokenId) public payable isBreeder{
        require(auction[tokenId].time>block.timestamp);
        require(auction[tokenId].price<msg.value);
        require(auction[tokenId].isActive);
        if (auction[tokenId].bidder!= ownerOf(tokenId)){
            auction[tokenId].bidder.transfer(auction[tokenId].price);
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

    function proposeFight(uint256 tokenId) public payable isBreeder isAlive(tokenId){
        require(ownerOf(tokenId)==msg.sender);
        fight[tokenId]=Fight(tokenId, msg.value, true);
    }
    
    function agreeToFight(uint256 tokenId1, uint256 tokenId2) public payable isBreeder isAlive(tokenId2){
        require(msg.value==fight[tokenId1].stake);
        require(tokenId1 != tokenId2);
        fight[tokenId1].tokenId=tokenId2;
        uint256 result = animalFighting(animals[tokenId1].aggressivity+animals[tokenId2].aggressivity);
        if (result<= animals[tokenId1].aggressivity) {
            payable(ownerOf(tokenId1)).transfer(fight[tokenId1].stake*2);
            deadAnimal(tokenId1);
        }
        else {
            payable(ownerOf(tokenId2)).transfer(fight[tokenId1].stake*2);
            deadAnimal(tokenId2);
        }
    }

    function animalFighting(uint256 odd) internal returns(uint){
        
        randNonce++;   
       return uint(keccak256(abi.encodePacked(block.timestamp,  
                                              msg.sender,  
                                              randNonce))) % odd; 
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
    if (_i == 0) {
        return "0";
    }
    uint j = _i;
    uint len;
    while (j != 0) {
        len++;
        j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    while (_i != 0) {
        bstr[k--] = byte(uint8(48 + _i % 10));
        _i /= 10;
    }
    return string(bstr);
    }
}