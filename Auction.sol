pragma solidity ^0.4.17;
contract Auction {
    
    // Data
    //Structure to hold details of the item
    struct Item {
        uint itemId; // id of the item
        uint[] itemTokens;  //tokens bid in favor of the item
       
    }
    
   //Structure to hold the details of a persons
    struct Person {
        uint remainingTokens; // tokens remaining with bidder
        uint personId; // it serves as tokenId as well
        address addr;//address of the bidder
    }
    mapping(address => Person) tokenDetails; //address to person 
    Person [4] bidders;//Array containing 4 person objects
    
    Item [3] public items;//Array containing 3 item objects
    address[3] public winners;//Array for address of winners
    address public beneficiary;//owner of the smart contract
    uint bidderCount=0;//counter of how many bidders we have in this contract
    
    //functions
    function Auction() public payable{    //constructor
        // setup the beneficiary to to address of the smart contract creator
        beneficiary=msg.sender;
        uint[] memory emptyArray;
        //initialize items 0,1 and 2
        items[0] = Item({itemId:0,itemTokens:emptyArray});
        items[1] = Item({itemId:1,itemTokens:emptyArray});
        items[2] = Item({itemId:2,itemTokens:emptyArray});
    }
    
    //bidders registration payable function, i need to add 
    //the function modifiers later to this one
    function register() public payable{
        bidders[bidderCount].personId = bidderCount;
        //Initialize the address of the bidder 
        bidders[bidderCount].addr=msg.sender;
        bidders[bidderCount].remainingTokens = 5; // only 5 tokens
        tokenDetails[msg.sender]=bidders[bidderCount];
        bidderCount++;
    }

        /*
            Arguments:
            _itemId -- uint, id of the item
            _count -- uint, count of tokens to bid for the item
        */
    function bid(uint _itemId, uint _count) public payable{
        
        // 1 If the number of tokens remaining with the bidder is < count of tokens bidded, revert.
        // 2 If there are no tokens remaining with the bidder, revert.
        // 3 If the id of the item for which bid is placed, is greater than 2, revert.
        if((tokenDetails[msg.sender].remainingTokens < _count) || (tokenDetails[msg.sender].remainingTokens == 0 ) || (_itemId > 2)){
        revert();
        }
        //Decrementing the remainingTokens by the number of tokens bid 
        //and store the value in remainingTokens of the address of the biddder 
        tokenDetails[msg.sender].remainingTokens=tokenDetails[msg.sender].remainingTokens - _count;
        bidders[tokenDetails[msg.sender].personId].remainingTokens=balance;//updating the same balance in bidders map.
        
        Item storage bidItem = items[_itemId];
        for(uint i=0; i<_count;i++) {
            bidItem.itemTokens.push(tokenDetails[msg.sender].personId);    
        }
    }
    
    //"onlyOwner" is to ensure that only owner is allowed to reveal winners
    modifier onlyOwner {
        require(msg.sender==beneficiary);
        _;
    }
    
    
    function revealWinners() public onlyOwner{
        
        /* 
            Iterate over all the items present in the auction.
            If at least on person has placed a bid, randomly select the winner */

        for (uint id = 0; id < 3; id++) {
            Item storage currentItem=items[id];
            if(currentItem.itemTokens.length != 0){
            // generate random# from block number 
            uint randomIndex = (block.number / currentItem.itemTokens.length)% currentItem.itemTokens.length; 
            // Obtain the winning tokenId
            uint winnerId = currentItem.itemTokens[randomIndex];

            //"currentItem.itemTokens[randomIndex]" is to obtain the winning tokenID.
            //Then Assign the winners by setting the address of the windner in the array winners.
            winners[id]=bidders[winnerId].addr;
            }
        }
    } 

  //methods to get some Data
    function getPersonDetails(uint id) public constant returns(uint,uint,address){
        return (bidders[id].remainingTokens,bidders[id].personId,bidders[id].addr);
    }

}