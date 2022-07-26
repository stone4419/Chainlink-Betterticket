// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Ticket is IERC721 {

    struct TicketDetails {
        uint256 resellProfitShare;
        uint256 percentageMaximum;
        uint256 initialPrice;
        uint256 previousPrice;
        uint256 resalePrice;
    }

    mapping(uint256 => TicketDetails) public TicketDetails;

    constructor(
        address _management,
        string _name,
        string _symbol
    )
    public
    IERC721(_name, _symbol)
    Managed(_management)

    {
    }

    function createTicket(
        address _tokenOwner,
        uint256 _initialPrice,
        uint256 _resellProfitShare,
        uint256 _percentageMaximum
    )
    public
    requirePermission(CAN_SELL_TICKETS)
    canCallOnlyRegisteredContract (CONTRACT_MARKETPLACE)
    returns (uint256 _ticketID)

    {
        require(
            management.IsContract (_tokenOwner) == false &&
            _percentageMaximum >= _resellProfitShare,
            ERROR_ACCESS_DENIED
        );

        _ticketID = allTokens.length;
        _mint(_tokenOwner, _ticketID);

        ticketDetails [_ticketID] = TicketDetails({
            resellProfitShare: _resellProfitShare,
            percentageMaximum: _percentageMaximum,
            initialPrice: _initialPrice,
            previousPrice: _previousPrice,
            resale: 0 
        });
    }

    function resellTicket(
        uint256 _ticketID,
        address _newTicketOwner
    )
    
    public
    requirePermission(CAN_SELL_TICKETS)
    canCallOnlyRegisteredContract (CONTRACT_MARKETPLACE)
    returns (address _previousTicketOwner)
    {
        require(
            isForResale(_ticketID) == true &&
            management.isContract(_newTicketOwner) == false,
            ERROR_ACCESS_DENIED
        );

        _previousTicketOwner = ownerOf(_ticketID);

        removeTicketOwner = ownerOf(_ticketID);
        addTokenTo(_newTicketOwner, _ticketID);

        ticketDetails(_ticketID).previousPrice = ticketsDetails (_ticketID).resalePrice;
        ticketDetails(_ticketID).resalePrice = 0;
    }

    function setResalePrice(
        uint256 _ticketID,
        uint256 _resalePrice
    )
    public
    {
        require(
            ownerOf(_ticketID) == msg.sender &&
            (_resalePrice == 0 || _resalePrice > ticketsDetails [_ticketID].previousPrice),
            ERROR_INVALID_INPUT
        );

        ticketDetails [_ticketID].resalePrice = _resalePrice;
    }

    function burnTicket (address _holder, uint256 _tokenID)
    public
    requirePermission(CAN_BURN_TICKETS)
    canCallOnlyRegisteredContract(CONTRACT_MARKETPLACE)
    returns (uint256)
    {
        require(
            exists(_tokenID),
            ERROR_INVALID_INPUT
        );

        _burn(_holder, _tokenID);
        delete ticketDetails[_tokenID];
    }

    
    function approve(address, uint256) public{
        require(false, ERROR_ACCESS_DENIED);
    }

    function setApprovalForAll(address, bool) public{
        require(false, ERROR_ACCESS_DENIED);
    }

    function transferFrom(
        address,
        address,
        uint256
    )
    public
    {
        require(false, ERROR_ACCESS_DENIED);
    }

    function ifForResale(
        uint256 _ticketID
    )

    public
    view
    returns (bool)
    {
        require(
            exists(_ticketID),
            ERROR_INVALID_INPUT
        );

        return ticketDetails[_ticketID].resalePrice != 0 ? true : false;
    }


    function getCustomerTicketsIDs(
        address _customer
    )
    public
    view
    returns (uint256[] _ticketID)
    {
        return ownedTokens[_customer];
    }

    function getTicket(
        uint256 _ticketID
    )
    public
    view
    returns (
        address _ticketOwner,
        uint256 _resellProfitShare,
        uint256 _percentageMaximum,
        uint256 _initialPrice,
        uint256 _previousPrice,
        uint256 _resalePrice
    );
}