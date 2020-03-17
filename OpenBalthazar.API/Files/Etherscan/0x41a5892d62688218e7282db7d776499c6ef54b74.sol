[{"SourceCode":"pragma solidity ^0.4.10;contract WWC { // set contract name to token name\r\n   \r\nstring public name; \r\nstring public symbol; \r\nuint8 public decimals;\r\nuint256 public totalSupply;\r\n \r\n// Balances for each account\r\nmapping(address =\u003E uint256) balances;address devAddress;// Events\r\nevent Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\nevent Transfer(address indexed from, address indexed to, uint256 value);\r\n \r\n// Owner of account approves the transfer of an amount to another account\r\nmapping(address =\u003E mapping (address =\u003E uint256)) allowed;// This is the constructor and automatically runs when the smart contract is uploaded\r\nfunction WWC() { // Set the constructor to the same name as the contract name\r\n    name = \u0022World Wide Chain\u0022; // set the token name here\r\n    symbol = \u0022WWC\u0022; // set the Symbol here\r\n    decimals = 8; // set the number of decimals\r\n    devAddress=0x7FCf357b770C075858c9E0bf782f38aCD0b56309; // Add the address that you will distribute tokens from here\r\n    uint initialBalance=100000000*50000000000; // 1M tokens\r\n    balances[devAddress]=initialBalance;\r\n    totalSupply\u002B=initialBalance; // Set the total suppy\r\n}function balanceOf(address _owner) constant returns (uint256 balance) {\r\n    return balances[_owner];\r\n}// Transfer the balance from owner\u0027s account to another account\r\nfunction transfer(address _to, uint256 _amount) returns (bool success) {\r\n    if (balances[msg.sender] \u003E= _amount \r\n        \u0026\u0026 _amount \u003E 0\r\n        \u0026\u0026 balances[_to] \u002B _amount \u003E balances[_to]) {\r\n        balances[msg.sender] -= _amount;\r\n        balances[_to] \u002B= _amount;\r\n        Transfer(msg.sender, _to, _amount); \r\n        return true;\r\n    } else {\r\n        return false;\r\n    }\r\n}function transferFrom(\r\n    address _from,\r\n    address _to,\r\n    uint256 _amount\r\n) returns (bool success) {\r\n    if (balances[_from] \u003E= _amount\r\n        \u0026\u0026 allowed[_from][msg.sender] \u003E= _amount\r\n        \u0026\u0026 _amount \u003E 0\r\n        \u0026\u0026 balances[_to] \u002B _amount \u003E balances[_to]) {\r\n        balances[_from] -= _amount;\r\n        allowed[_from][msg.sender] -= _amount;\r\n        balances[_to] \u002B= _amount;\r\n        return true;\r\n    } else {\r\n        return false;\r\n    }\r\n}// Allow _spender to withdraw from your account, multiple times, up to the _value amount.\r\n// If this function is called again it overwrites the current allowance with _value.\r\nfunction approve(address _spender, uint256 _amount) returns (bool success) {\r\n    allowed[msg.sender][_spender] = _amount;\r\n    Approval(msg.sender, _spender, _amount);\r\n    return true;\r\n}\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"WWC","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://e091f313c8e809b361bccaa70e7130c737009ef2113e0b7cce73c2910094fcfc"}]