pragma solidity ^0.4.15;

/**
 * @title This is a smartcontract for managing BloxOffice tickets
 * @author Jason Brown
 */

import "./BloxOfficeWallet.sol";

contract BloxOfficeTickets {

	/* Events - START */
    // Indexed arguments in a event are made filterable in the user interface.
    // Only up to 3 indexed arguments are allowed.
    event TicketCreated(uint seat, string  indexed eventName, address indexed host);
    event TicketListed(bytes32 ID, address owner);
    event TicketUnlisted(bytes32 ID, address owner);
    event TicketTransfered(bytes32 ID, address indexed newOwner, address indexed oldOwner);
    event SalePriceUpdated(bytes32 ID, address owner);
    /* Events - END */


    /* State Variables - START */

    struct Ticket {
    	address owner;
        uint seat;
        string eventName;
        uint faceValue;
        uint lastSoldPrice;
        uint forSalePrice;
        bool forSale;
        bytes32 ID;
        address issuer;
    }

    BloxOfficeWallet private allWallets;

    mapping (bytes32 => Ticket) public tickets;
	/* State Variables - END */


	modifier isLegitimateSale(uint _seat, string _eventName){
		bytes32 _ID = sha3(_seat, _eventName);
		require (tickets[_ID].forSale == true);
		require (allWallets.sufficientFunds(msg.sender, tickets[_ID].forSalePrice));
		_;
	}

	modifier isNewTicket(uint _seat, string _eventName){
		require (tickets[sha3(_seat, _eventName)].ID != bytes32(0));
		_;
	}

	function BloxOfficeTickets(address _BloxOfficeWallets){
		allWallets = BloxOfficeWallet(_BloxOfficeWallets);
	}

	function createTicket(uint _seat, string _eventName, uint _faceValue) isNewTicket(_seat, _eventName) public returns(bool){
		bytes32 _ID = sha3(_seat, _eventName);

		tickets[_ID].owner = msg.sender;
		tickets[_ID].seat = _seat;
		tickets[_ID].eventName = _eventName;
		tickets[_ID].faceValue = _faceValue;
		tickets[_ID].lastSoldPrice = 0;
		tickets[_ID].forSalePrice = _faceValue;
		tickets[_ID].forSale = false;
		tickets[_ID].ID = _ID;
		tickets[_ID].issuer = msg.sender;


		TicketCreated(_seat, _eventName, msg.sender);
		return true;
	}

	function setSalePrice(uint _seat, string _eventName, uint _price) public returns(bool){
		bytes32 _ID = sha3(_seat, _eventName);
		require(tickets[_ID].owner == msg.sender);
		tickets[_ID].forSalePrice = _price;

		SalePriceUpdated(_ID, msg.sender);
		return true;
	}

	function upForSale(uint _seat, string _eventName) public returns(bool){
		bytes32 _ID = sha3(_seat, _eventName);
		require(tickets[_ID].owner == msg.sender);
		tickets[_ID].forSale = true;

		TicketListed(_ID, msg.sender);
		return true;
	}

	function notUpForSale(uint _seat, string _eventName) public returns(bool){
		bytes32 _ID = sha3(_seat, _eventName);
		require(tickets[_ID].owner == msg.sender);
		tickets[_ID].forSale = false;

		TicketUnlisted(_ID, msg.sender);
		return true;
	}

	function transferTicket(uint _seat, string _eventName) isLegitimateSale(_seat, _eventName) public returns(bool){
		bytes32 _ID = sha3(_seat, _eventName);
		allWallets.sendCash(tickets[_ID].lastSoldPrice ,tickets[_ID].owner, msg.sender);
		allWallets.sendCash(tickets[_ID].forSalePrice - tickets[_ID].lastSoldPrice ,tickets[_ID].owner, msg.sender);
		tickets[_ID].owner = msg.sender;
		tickets[_ID].lastSoldPrice = tickets[_ID].forSalePrice;
		tickets[_ID].forSale = false;

		TicketTransfered(_ID, msg.sender, tickets[_ID].owner);
		return true;
	}

	function 
}