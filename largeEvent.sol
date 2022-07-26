// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Event is Managed {

    struct EventDetails {
        uint256 ticketsAmount;
        uint256 soldTickets;
        uint256 ticketsPayout;
        uint256 startTime; 
    }

    EventDetails[] public events;

    event EventCreated(
        uint indexed_eventID,
        uint256 _ticketsAmount,
        uint _startTime
    );

    constructor (address _management) public Managed(_management){}

    function createEvent(
        uint256 _ticketsAmount,
        uint _startTime
    )
    public
    requirePermission(CAN_ADD_EVENTS)
    canCallOnlyRegisteredContract(CONTRACT_MARKETPLACE)
    returns (uint256 _eventID)
    
    {
        require(
        _ticketsAmount > 0 &&
        _startTime > block.timestamp,
        ERROR_INVALID_INPUT
        );

        events.push(
            EventDetails({
                ticketsAmount: _ticketsAmount,
                soldTickets: 0,
                ticketsPayout: 0,
                startTime: _startTime
            })
        );

        emit EventCreated( _eventID, _ticketsAmount, _startTime);
    }

    function updateEvent(
        uint _eventID,
        uint256 _ticketsAmount,
        uint _startTime
    )
    public
    {
        require(
            msg.sender ==management.eventOrganizersRegistry(_eventID),
            ERROR_INVALID_INPUT
        );

        require(
            _ticketsAmount >= events [_eventID].soldTickets &&
            _startTime > block.timestamp &&
            eventHasBeenStarted(_eventID) == false,
            ERROR_INVALID_INPUT
        );

        events [_eventID].ticketsAmount = _ticketsAmount;
        events [_eventID].startTime = _startTime;
    }

    function sellTicket(
        uint256 _eventID,
        uint _ticketsAmount,
        uint256 _ticketsPayout
    )

    public
    requirePermission(CAN_SELL_TICKETS)
    canCallOnlyRegisteredContract(CONTRACT_MARKETPLACE)
    {
        require(
            eventHasBeenStarted(_eventID) == false &&
             _ticketsAmount <= getAvailableTickets(0),
            ERROR_INVALID_INPUT
        );
        events [_eventID].soldTickets = events [_eventID].soldTickets.add(_ticketsAmount);
        events [_eventID].ticketsPayout = events [_eventID].ticketsPayout(_ticketsPayout);
    }

    function refundTicket(
        uint256 _eventID,
        uint _ticketsAmount,
        uint256 _refundAmount
    )

    public
    requirePermission(CAN__MAKE_REFUND)
    canCallOnlyRegisteredContract(CONTRACT_MARKETPLACE)
    {
        require(
            eventHasBeenStarted(_eventID) == false &&
             _ticketsAmount <= events [_eventID].soldTickets &&
             _refundAmount <= events [_eventID].ticketsPayout,
            ERROR_INVALID_INPUT
        );
        events [_eventID].soldTickets = events [_eventID].soldTickets.sub(_ticketsPayout);
        events [_eventID].ticketsPayout = events [_eventID].ticketsPayout.sub(_refundAmount);
    }

      function withdrawfunds(
        uint256 _eventID
    )

     public
    requirePermission(CAN__UPDATE_EVENT)
    canCallOnlyRegisteredContract(CONTRACT_MARKETPLACE)
    {
        require(
            eventHasBeenStarted[_eventID] == true &&
            events [_eventID].ticketsPayout > 0,
            ERROR_INVALID_INPUT
        );
        events [_eventID].ticketsPayout = 0;
    }

     function IsInitialized()
        public
        view
        returns (bool)
        {
            return (
                address(management) !=address (0) &&
                management.contractRegistry(CONTRACT_EVENT) != address(0) 
            );
        }

        function getEventsAmount()
        public
        view
        returns (uint256 _eventsAmount)
        {
        return events.length;
        }

        function eventExists(
        uint256 _eventID
        )
        public
        view
        returns (bool)
        {
            return (_eventID < getEventsAmount()) ? true : false;
        }

        function eventHasBeenStarted(
        uint256 _eventID
        )
         public
        view
        returns (bool)
        {
            require(
                eventExists(_eventID),
                ERROR_INVALID_INPUT
            );
            return (events[_eventID].startTime < block.timestamp) ? true : false;
        }

        function getAvailableTickets(
        uint256 _eventID
        )
         public
        view
        returns (uint256)
        {
            require(
                eventHasBeenStarted(_eventID) == false,
                ERROR_INVALID_INPUT
            );
            return events[_eventID].ticketsPayout
            .sub(events[_eventID].soldTickets);
        }

        function getEvent(
        uint256 _eventID
        )
        public
        view
        returns (
            address _organizer,
            uint256 _ticketsAmount,
            uint256 _soldTickets,
            uint256 _ticketsPayout,
            uint256 _startTime
        )
        {
        require(
                eventExists(_eventID),
                ERROR_INVALID_INPUT
            );
            EventDetails storage _event = events[_eventID];

            return(
                _event.ticketsPayout,
                _event.soldTickets,
                _event.ticketsPayout,
                _event.startTime
            );
        }
}
