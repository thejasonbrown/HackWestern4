pragma solidity ^0.4.15;

/**
 * @title This contract is a wallet representing CAD for the BloxOffice Demo.
 * @author Jason Brown
 */

contract BloxOfficeWallet {

	/* Events - START */
    // Indexed arguments in a event are made filterable in the user interface.
    // Only up to 3 indexed arguments are allowed.
    event DepositSuccessful(address indexed account, uint balance);
    event WalletRegistered(address indexed account);
    event CashSent(address indexed sender, address indexed recipient, uint amount);
    /* Events - END */


    /* State Variables - START */

    address public companyAddress;

    struct Wallet {
        string name;
        uint balance;
        bool registered;
    }

    mapping (address => Wallet) public wallets;
	/* State Variables - END */

	modifier isCompany{
		require (msg.sender == companyAddress);
		_;
	}

	function BloxOfficeWallet(){
		companyAddress = msg.sender;
	}

	function registerNewWallet(string _name) public returns(bool){
		if (!wallets[msg.sender].registered){
			wallets[msg.sender].name = _name;
			wallets[msg.sender].balance = 0;
			wallets[msg.sender].registered = true;
			WalletRegistered(msg.sender);
		}
		return true;
	}

	function sendCash(uint _amount, address _recipient, address _sender) public returns(bool){
		if (sufficientFunds(_sender, _amount)){
			wallets[_recipient].balance = wallets[_recipient].balance + _amount;
			wallets[_sender].balance = wallets[_sender].balance - _amount;
			CashSent(_sender, _recipient, _amount);
		}
		return true;
	}

	function depositCash(uint _deposit, address _recipient) isCompany public returns(bool){
		wallets[_recipient].balance = wallets[_recipient].balance + _deposit;
		DepositSuccessful(_recipient, wallets[msg.sender].balance);
		return true;
	}

	function getBalance(address _account) public constant returns(uint){
		return wallets[_account].balance;
	}

	function getName(address _account) public constant returns(string){
		return wallets[_account].name;
	}

	function sufficientFunds(address _account, uint _amount) public constant returns(bool){
		return (wallets[_account].balance >= _amount);
	}

}