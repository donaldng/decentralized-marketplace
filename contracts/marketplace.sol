pragma solidity ^0.4.0;

contract Marketplace {
    
    bool completed;
    uint256 priceTag;
    address sellerAddress;
    address ownerAddress;

    event Transfer(address _address, uint256 _sent);
    event Refund(address _address, uint256 _overpaidAmt);
    event Status(bool _completed, uint256 _remainingAmt);

    function Marketplace(address addr, uint256 price) public {
        // buyer initiate contract to buy from seller.
        require(price > 0);

        completed = false;
        ownerAddress = msg.sender;
        priceTag = price;
        sellerAddress = addr;
        
    }

    modifier isValidAddress(address addr) {
        require(msg.sender==addr);        
        _;
    }

    function transfer() public payable {
        // transfer fund to smart contract

        require(msg.value > 0);
        require(!completed);
        
        Transfer(msg.sender, msg.value);
        
        checkContractStatus();
    }
    
    function checkContractStatus() private {
        // check if contract is completed
        uint256 remainingAmt = priceTag - this.balance;

        if (this.balance >= priceTag) {
            completed = true;
            remainingAmt = 0;
            checkIfOverpaid();
        }

        Status(completed, remainingAmt);
    }

    function getBalance() public constant returns (uint256) {
        return this.balance;
    }

    function checkIfOverpaid() private {
        // if contract target is already fulfilled, refund all overpaid fund.
        if (this.balance > priceTag) {
            uint256 overpaidAmt = this.balance - priceTag;
            msg.sender.transfer(overpaidAmt);

            Refund(msg.sender, overpaidAmt);
        }
    }

    function receivedItem() public isValidAddress(ownerAddress) {
        // buyer received item, and close the deal.
        require(completed);
        
        sellerAddress.transfer(priceTag);
        termination(ownerAddress);
    }

    function cancelOrder() public isValidAddress(sellerAddress) {
        // seller cancel order, and refund to buyer.
        // refund to buyer
        termination(ownerAddress);
    }
    
    function termination(address addr) private {
        selfdestruct(addr);
    }

}
