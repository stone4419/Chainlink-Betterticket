// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract meetup {

    address public owner;
    uint256 private counter;

    constructor() {
        counter = 0;
        owner = msg.sender;
     }

    struct eventInfo {
        string eventName;
        string eventLocation;
        string ShortDescription;
        string LongDescription;
        string imgUrl;
        uint256 maxGuests;
        uint256 price;
        string[] ticketType;
        uint256 id;
        address organizer;
    }

    event eventCreated (
        string eventName,
        string eventLocation,
        string ShortDescription,
        string LongDescription,
        string imgUrl,
        uint256 maxGuests,
        uint256 price,
        string[] ticketType,
        uint256 id,
        address organizer
    );

    event newTicketType (
        string[] ticketType,
        uint256 id,
        address buyer,
        string eventLocation,
        string imgUrl 
    );

    mapping(uint256 => eventInfo) events;
    uint256[] public eventIds;


    function addevents(
        string memory eventName,
        string memory eventLocation,
        string memory ShortDescription,
        string memory LongDescription,
        string memory imgUrl,
        uint256 maxGuests,
        uint256 price,
        string[] memory ticketType
    ) public {
        require(msg.sender == owner, "Only owner of smart contract can put up events");
        eventInfo storage newEvent = events[counter];
        newEvent.eventName = eventName;
        newEvent.eventLocation = eventLocation;
        newEvent.ShortDescription = ShortDescription;
        newEvent.LongDescription = LongDescription;
        newEvent.imgUrl = imgUrl;
        newEvent.maxGuests = maxGuests;
        newEvent.price = price;
        newEvent.ticketType = ticketType;
        newEvent.id = counter;
        newEvent.organizer = owner;
        eventIds.push(counter);
        emit eventCreated(
                eventName, 
                eventLocation,
                ShortDescription, 
                LongDescription, 
                imgUrl, 
                maxGuests, 
                price, 
                ticketType, 
                counter, 
                owner);
        counter++;
    }

    function checkTicket(uint256 id, string[] memory newTicket) private view returns (bool){
        
        for (uint i = 0; i < newTicket.length; i++) {
            for (uint j = 0; j < events[id].ticketType.length; j++) {
                if (keccak256(abi.encodePacked(events[id].ticketType[j])) == keccak256(abi.encodePacked(newTicket[i]))) {
                    return false;
                }
            }
        }
        return true;
    }


    function getTicket(uint256 id, string[] memory newTicket) public payable {
        
        require(id < counter, "No such Event");
        require(checkTicket(id, newTicket), "Already Sold For Requested Ticket");
        require(msg.value == (events[id].price * 1 ether * newTicket.length) , "Please submit the asking price in order to complete the purchase");
    
        for (uint i = 0; i < newTicket.length; i++) {
            events[id].ticketType.push(newTicket[i]);
        }

        payable(owner).transfer(msg.value);
        emit newTicketType(newTicket, id, msg.sender, events[id].eventLocation,  events[id].imgUrl);
    
    }

    function getEvent(uint256 id) public view returns (string memory, uint256, string[] memory){
        require(id < counter, "No such Event");

        eventInfo storage s = events[id];
        return (s.eventName,s.price,s.ticketType);
    }
}