﻿pragma solidity ^0.4.18;

contract TestReentrancyRule {

	mapping (address => uint) balances;

	function withdrawVulnerable() public {
	
		uint balance = balances [msg.sender];

		if(msg.sender.call.value(balance)()) {
			balances[msg.sender] = 0;
		}
	}

	function withdrawNotVulnerable() public {
		
		uint balance = balances[msg.sender];
		
		msg.sender.transfer(balance);

		balances[msg.sender] = 0;
		
		// si la transferencia falla , se anula el
		// cambio de estado y se recupera el saldo
	}
}




