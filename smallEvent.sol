// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

    contract TownHall {
        uint price;
        address payable owner;

    struct Event {
        string title;
        address attendee;
        uint startTime;
        uint endTime;
        uint amountPaid;
    }

    Event[] events;

    constructor() {
        owner = payable(msg.sender);
    }

    function getPrice() public view returns (uint) {
        return price;
    }

    function setPrice(uint _price) public {
        require(msg.sender == owner, "Only the organizer can add Event Price");
        price = _price;
    }

    function getEvent() public view returns (Event[] memory) {
        return events;
    }

    function createEvent(string memory title, uint startTime, uint endTime) public payable{
        Event memory events;
        events.title = title;
        events.startTime = startTime;
        events.endTime = endTime;
        events.amountPaid = ((endTime - startTime) / 60) * price;
        events.attendee = msg.sender;

        require(msg.value >= events.amountPaid, "You need more Ether");

        (bool success,) = owner.call{value: msg.value}("");
        require(success, "Failed to send ETH");
    }
}