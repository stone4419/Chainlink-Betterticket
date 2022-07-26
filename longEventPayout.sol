// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract FundsDistributor{
    using SafeMath for uint256;

    event FundsDistributor(
        address _organizer,
        uint256 _organizersProfit
    );

    contructor (address _management) public Managed(_management){}
    
    function distributedResaleFund(
        uint256 _eventID,
        uint256 _ticketID
    )
    public
    payable
    requirePermission(CAN_DISTRUBUTE_FUNDS)
    canCallOnlyRegisteredContract(CONTRACT_MARKETPLACE)
    {
        Ticket ticket = Ticket(management.ticketRegistry(_eventID));

        address ticketOwner;
        uint256 resellProfitShare;
        uint256 percentageMaximum;
        uint256 initialPrice;
        uint256 previousPrice;
        uint256 resalePrice;
        (
            ticketOwner,
            resellProfitShare,
            percentageMaximum,
            initialPrice,
            previousPrice,
            resalePrice
        ) = ticket.getTicket(_ticketID);

        require(
            resalePrice == msg.value,
            ERROR_NOT_AVAILABLE
        );

        uint256 _organizersProfit = (resalePrice.sub(previousPrice))
        .mul(resellProfitShare)
        .div(percentageMaximum);

        address organizer = management.eventOrganizersRegistry(_eventID);
        organizer.transfer(organizersProfit);

        ticketOwner.transfer(resalePrice.sub(organizersProfit));

        emit FundsDistributor(
            organizer,
            organizersProfit
        );
    }

    function IsInitialized()
    public
    view
    return (bool)
    {
        return(
            address(management) != address(0) &&
            management.contractRegistry(CONTRACT_MARKETPLACE) !=address(0)
        );
    }
}