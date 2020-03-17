[{"SourceCode":"pragma solidity ^0.4.4;\r\ncontract Token {\r\n\r\n    /// @return total amount of tokens\r\n    function totalSupply() constant returns (uint256 supply) {}\r\n\r\n    /// @param _owner The address from which the balance will be retrieved\r\n    /// @return The balance\r\n    function balanceOf(address _owner) constant returns (uint256 balance) {}\r\n\r\n    /// @notice send \u0060_value\u0060 token to \u0060_to\u0060 from \u0060msg.sender\u0060\r\n    /// @param _to The address of the recipient\r\n    /// @param _value The amount of token to be transferred\r\n    /// @return Whether the transfer was successful or not\r\n    function transfer(address _to, uint256 _value) returns (bool success) {}\r\n\r\n    /// @notice send \u0060_value\u0060 token to \u0060_to\u0060 from \u0060_from\u0060 on the condition it is approved by \u0060_from\u0060\r\n    /// @param _from The address of the sender\r\n    /// @param _to The address of the recipient\r\n    /// @param _value The amount of token to be transferred\r\n    /// @return Whether the transfer was successful or not\r\n    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}\r\n\r\n    /// @notice \u0060msg.sender\u0060 approves \u0060_addr\u0060 to spend \u0060_value\u0060 tokens\r\n    /// @param _spender The address of the account able to transfer the tokens\r\n    /// @param _value The amount of wei to be approved for transfer\r\n    /// @return Whether the approval was successful or not\r\n    function approve(address _spender, uint256 _value) returns (bool success) {}\r\n\r\n    /// @param _owner The address of the account owning tokens\r\n    /// @param _spender The address of the account able to transfer the tokens\r\n    /// @return Amount of remaining tokens allowed to spent\r\n    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}\r\n\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n\r\n}\r\n\r\ncontract StandardToken is Token {\r\n\r\n    function transfer(address _to, uint256 _value) returns (bool success) {\r\n        //Default assumes totalSupply can\u0027t be over max (2^256 - 1).\r\n        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn\u0027t wrap.\r\n        //Replace the if with this one instead.\r\n        //if (balances[msg.sender] \u003E= _value \u0026\u0026 balances[_to] \u002B _value \u003E balances[_to]) {\r\n        if (balances[msg.sender] \u003E= _value \u0026\u0026 _value \u003E 0) {\r\n            balances[msg.sender] -= _value;\r\n            balances[_to] \u002B= _value;\r\n            Transfer(msg.sender, _to, _value);\r\n            return true;\r\n        } else { return false; }\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {\r\n        //same as above. Replace this line with the following if you want to protect against wrapping uints.\r\n        //if (balances[_from] \u003E= _value \u0026\u0026 allowed[_from][msg.sender] \u003E= _value \u0026\u0026 balances[_to] \u002B _value \u003E balances[_to]) {\r\n        if (balances[_from] \u003E= _value \u0026\u0026 allowed[_from][msg.sender] \u003E= _value \u0026\u0026 _value \u003E 0) {\r\n            balances[_to] \u002B= _value;\r\n            balances[_from] -= _value;\r\n            allowed[_from][msg.sender] -= _value;\r\n            Transfer(_from, _to, _value);\r\n            return true;\r\n        } else { return false; }\r\n    }\r\n\r\n    function balanceOf(address _owner) constant returns (uint256 balance) {\r\n        return balances[_owner];\r\n    }\r\n\r\n    function approve(address _spender, uint256 _value) returns (bool success) {\r\n        allowed[msg.sender][_spender] = _value;\r\n        Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {\r\n      return allowed[_owner][_spender];\r\n    }\r\n\r\n    mapping (address =\u003E uint256) balances;\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) allowed;\r\n    uint256 public totalSupply;\r\n}\r\n\r\ncontract Margintradingtoken is StandardToken { // CHANGE THIS. Update the contract name.\r\n\r\n    /* Public variables of the token */\r\n\r\n    /*\r\n    NOTE:\r\n    The following variables are OPTIONAL vanities. One does not have to include them.\r\n    They allow one to customise the token contract \u0026 in no way influences the core functionality.\r\n    Some wallets/interfaces might not even bother to look at this information.\r\n    */\r\n    string public name;                   // Token Name\r\n    uint8 public decimals;                // How many decimals to show. To be standard complicant keep it 18\r\n    string public symbol;                 // An identifier: eg SBX, XPR etc..\r\n    string public version = \u0027H1.0\u0027; \r\n    uint256 public unitsOneEthCanBuy;     // How many units of your coin can be bought by 1 ETH?\r\n    uint256 public totalEthInWei;         // WEI is the smallest unit of ETH (the equivalent of cent in USD or satoshi in BTC). We\u0027ll store the total ETH raised via our ICO here.  \r\n    address public fundsWallet;           // Where should the raised ETH go?\r\n\r\n    // This is a constructor function \r\n    // which means the following function name has to match the contract name declared above\r\n    function Margintradingtoken() {\r\n        balances[msg.sender] = 14000000000000000000000000;               // Give the creator all initial tokens. This is set to 1000 for example. If you want your initial tokens to be X and your decimal is 5, set this value to X * 100000. (CHANGE THIS)\r\n        totalSupply = 14000000000000000000000000;                        // Update total supply (1000 for example) (CHANGE THIS)\r\n        name = \u0022Margintradingtoken\u0022;                                   // Set the name for display purposes (CHANGE THIS)\r\n        decimals = 18;                                               // Amount of decimals for display purposes (CHANGE THIS)\r\n        symbol = \u0022MTT\u0022;                                             // Set the symbol for display purposes (CHANGE THIS)\r\n        unitsOneEthCanBuy = 4220;                                      // Set the price of your token for the ICO (CHANGE THIS)\r\n        fundsWallet = msg.sender;                                    // The owner of the contract gets ETH\r\n    }\r\n\r\n    function() payable{\r\n        totalEthInWei = totalEthInWei \u002B msg.value;\r\n        uint256 amount = msg.value * unitsOneEthCanBuy;\r\n        require(balances[fundsWallet] \u003E= amount);\r\n\r\n        balances[fundsWallet] = balances[fundsWallet] - amount;\r\n        balances[msg.sender] = balances[msg.sender] \u002B amount;\r\n\r\n        Transfer(fundsWallet, msg.sender, amount); // Broadcast a message to the blockchain\r\n\r\n        //Transfer ether to fundsWallet\r\n        fundsWallet.transfer(msg.value);                               \r\n    }\r\n\r\n    /* Approves and then calls the receiving contract */\r\n    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {\r\n        allowed[msg.sender][_spender] = _value;\r\n        Approval(msg.sender, _spender, _value);\r\n\r\n        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn\u0027t have to include a contract in here just for this.\r\n        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)\r\n        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.\r\n        if(!_spender.call(bytes4(bytes32(sha3(\u0022receiveApproval(address,uint256,address,bytes)\u0022))), msg.sender, _value, this, _extraData)) { throw; }\r\n        return true;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022fundsWallet\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022version\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unitsOneEthCanBuy\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalEthInWei\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_extraData\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022approveAndCall\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Margintradingtoken","CompilerVersion":"v0.4.19\u002Bcommit.c4cbbb05","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://798687a47d0b8e66e9175870cf7a47500aa086a85629cd141b9ff53d646dc4bd"}]