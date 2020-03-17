[{"SourceCode":"pragma solidity ^ 0.4.4;\r\n\r\n/*\r\nThis is the smart contract for the ERC 20 standard Tratok token.\r\nDuring the development of the smart contract, active attention was paid to make the contract as simple as possible.\r\nAs the majority of functions are simple addition and subtraction of existing balances, we have been able to make the contract very lightweight.\r\nThis has the added advantage of reducing gas costs and ensuring that transaction fees remain low.\r\nThe smart contract has been made publically available, keeping with the team\u0027s philosophy of transparency.\r\nThis is an update on the second generation smart contract which can be found at 0x0cbc9b02b8628ae08688b5cc8134dc09e36c443b.\r\nThe contract has been updated to match a change in project philosophy and enhance distribution and widespread adoption of the token via free airdrops.\r\nFurther enhancements have been made for this third-generation:\r\nA.) Enhanced anti-fraud measures.\r\nB.) A Contingency plan to ensure that in the event of an exchange being compromised, that there is a facility to prevent the damage hurting the Tratok ecosystem.\r\nC.) More efficient gas usage (e.g. Use of External instead of public).\r\n\r\n\r\n@version \u00221.2\u0022\r\n@developer \u0022Tratok Team\u0022\r\n@date \u002225 June 2019\u0022\r\n@thoughts \u0022307 lines that will change the travel and tourism industry! Good luck!\u0022\r\n*/\r\n\r\n/*\r\n * Use of the SafeMath Library prevents malicious input. For security consideration, the\r\n * smart contract makes use of .add() and .sub() rather than \u002B= and -=\r\n */\r\n\r\nlibrary SafeMath {\r\n    \r\n//Ensures that b is greater than a to handle negatives.\r\n    function sub(uint256 a, uint256 b) internal returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    //Ensure that the sum of two values is greater than the initial value.\r\n    function add(uint256 a, uint256 b) internal returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}\r\n\r\n/*\r\n * ERC20 Standard will be used\r\n * see https://github.com/ethereum/EIPs/issues/20\r\n */\r\n\r\ncontract ERC20 {\r\n    //the total supply of tokens \r\n    uint public totalSupply;\r\n\r\n    //@return Returns the total amount of Tratok tokens in existence. The amount remains capped at the pre-created 100 Billion.  \r\n    function totalSupply() constant returns(uint256 supply){}\r\n\r\n    /* \r\n      @param _owner The address of the wallet which needs to be queried for the amount of Tratok held. \r\n      @return Returns the balance of Tratok tokens for the relevant address.\r\n      */\r\n    function balanceOf(address who) constant returns(uint);\r\n\r\n    /* \r\n       The transfer function which takes the address of the recipient and the amount of Tratok needed to be sent and complete the transfer\r\n       @param _to The address of the recipient (usually a \u0022service provider\u0022) who will receive the Tratok.\r\n       @param _value The amount of Tratok that needs to be transferred.\r\n       @return Returns a boolean value to verify the transaction has succeeded or failed.\r\n      */\r\n    function transfer(address to, uint value) returns(bool ok);\r\n\r\n    /*\r\n       This function will, conditional of being approved by the holder, send a determined amount of tokens to a specified address\r\n       @param _from The address of the Tratok sender.\r\n       @param _to The address of the Tratok recipient.\r\n       @param _value The volume (amount of Tratok which will be sent).\r\n       @return Returns a boolean value to verify the transaction has succeeded or failed.\r\n      */\r\n    function transferFrom(address from, address to, uint value) returns(bool ok);\r\n\r\n    /*\r\n      This function approves the transaction and costs\r\n      @param _spender The address of the account which is able to transfer the tokens\r\n      @param _value The amount of wei to be approved for transfer\r\n      @return Whether the approval was successful or not\r\n     */\r\n    function approve(address spender, uint value) returns(bool ok);\r\n\r\n    /*\r\n    This function determines how many Tratok remain and how many can be spent.\r\n     @param _owner The address of the account owning the Tratok tokens\r\n     @param _spender The address of the account which is authorized to spend the Tratok tokens\r\n     @return Amount of Tratok tokens which remain available and therefore, which can be spent\r\n    */\r\n    function allowance(address owner, address spender) constant returns(uint);\r\n\r\n\r\n    event Transfer(address indexed from, address indexed to, uint value);\r\n    event Approval(address indexed owner, address indexed spender, uint value);\r\n\r\n}\r\n\r\n/*\r\n *This is a basic contract held by one owner and prevents function execution if attempts to run are made by anyone other than the owner of the contract\r\n */\r\n\r\ncontract Ownable {\r\n    address public owner;\r\n\r\n    function Ownable() {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyOwner() {\r\n        if (msg.sender != owner) {\r\n            revert();\r\n        }\r\n        _;\r\n    }\r\n\r\n    function transferOwnership(address newOwner) onlyOwner {\r\n        if (newOwner != address(0)) {\r\n            owner = newOwner;\r\n        }\r\n    }\r\n    \r\n    function owner() public view returns (address) {\r\n        return owner;\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract StandardToken is ERC20, Ownable {\r\n\r\nevent FrozenAccount(address indexed _target);\r\nevent UnfrozenAccount(address indexed _target);    \r\n\r\nusing SafeMath for uint256;\r\n    function transfer(address _to, uint256 _value) returns(bool success) {\r\n        require(!frozenAccounts[msg.sender]);\r\n        if (balances[msg.sender] \u003E= _value \u0026\u0026 _value \u003E 0) {\r\n            balances[msg.sender] = balances[msg.sender].sub(_value);\r\n            balances[_to] = balances[_to].add(_value);\r\n            Transfer(msg.sender, _to, _value);\r\n            return true;\r\n        } else {\r\n            return false;\r\n        }\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) returns(bool success) {\r\n        if (balances[_from] \u003E= _value \u0026\u0026 allowed[_from][msg.sender] \u003E= _value \u0026\u0026 _value \u003E 0) {\r\n            balances[_to] = balances[_to].add(_value);\r\n            balances[_from] = balances[_from].sub(_value);\r\n            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n            Transfer(_from, _to, _value);\r\n            return true;\r\n        } else {\r\n            return false;\r\n        }\r\n    }\r\n     \r\n    function balanceOf(address _owner) constant returns(uint256 balance) {\r\n        return balances[_owner];\r\n    }\r\n\r\n    function approve(address _spender, uint256 _value) returns(bool success) {\r\n        allowed[msg.sender][_spender] = _value;\r\n        Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address _owner, address _spender) constant returns(uint256 remaining) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n    \r\n    \r\n     /*\r\nThis function determines distributes tratok to multiple addresses and is designed for the airdrop.\r\n     @param _destinations The address of the accounts which will be sent Tratok tokens.\r\n     @param _values The amount of the Tratok tokens to be sent.\r\n     @return The number of loop cycles\r\n     */        \r\n    \r\n    function airDropTratok(address[] _destinations, uint256[] _values) external onlyOwner\r\n    returns (uint256) {\r\n        uint256 i = 0;\r\n        while (i \u003C _destinations.length) {\r\n           transfer(_destinations[i], _values[i]);\r\n           i \u002B= 1;\r\n        }\r\n        return(i);\r\n    }\r\n\r\n    /*\r\nThis function determines distributes tratok to multiple addresses and is designed for the ecosystem. It is the same as the airDropTratok method but differs in that it can be run by all accounts, not just the Owner account.\r\n\r\n     @param _destinations The address of the accounts which will be sent Tratok tokens.\r\n     @param _values The amount of the Tratok tokens to be sent.\r\n     @return The number of loop cycles\r\n     */        \r\n    \r\n    function distributeTratok(address[] _destinations, uint256[] _values)\r\n    returns (uint256) {\r\n        uint256 i = 0;\r\n        while (i \u003C _destinations.length) {\r\n           transfer(_destinations[i], _values[i]);\r\n           i \u002B= 1;\r\n        }\r\n        return(i);\r\n    }\r\n    \r\n       /*\r\nThis function locks the account  from sending Tratok. This measure is taken to prevent fraud and to recover Tratok in the event that an exchange is hacked.\r\n     @param _target The address of the accounts which will be locked.\r\n     @return The number of loop cycles\r\n     */    \r\n     \r\n   function lockAccountFromSendingTratok(address _target) external onlyOwner returns(bool){\r\n   \r\n   \t//Ensure that the target address is not left blank to prevent errors.\r\n   \t  require(_target != address(0));\r\n\t//ensure the account is not already frozen.\t  \r\n      require(!frozenAccounts[_target]);\r\n      frozenAccounts[_target] = true;\r\n      emit FrozenAccount(_target);\r\n      return true;\r\n  }\r\n    \r\n    /*\r\nThis function unlocks accounts tratok to allow them to send Tratok.\r\n     @param _target The address of the accounts which will be sent Tratok tokens.\r\n     @return The number of loop cycles\r\n     */    \r\n      function unlockAccountFromSendingTratok(address _target) external onlyOwner returns(bool){\r\n      require(_target != address(0));\r\n      require(frozenAccounts[_target]);\r\n      delete frozenAccounts[_target];\r\n      emit UnfrozenAccount(_target);\r\n      return true;\r\n  }\r\n     \r\n    /*\r\nThis function is an emergency failsafe that allows Tratok to be reclaimed in the event of an exchange or partner hack. This contingency is meant as a last resort to protect the integrity of the ecosystem in the event of a security breach. It can only be executed by the holder of the custodian keys.\r\n     @param _from The address of the Tratok tokens will be seized.\r\n\t @param _to The address where the Tratok tokens will be sent.\r\n     @param _value The amount of Tratok tokens that will be transferred.\r\n     */    \r\n       \r\n     function confiscate(address _from, address _to, uint256 _value) external onlyOwner{\r\n     \tbalances[_to] = balances[_to].add(_value);\r\n        balances[_from] = balances[_from].sub(_value);\r\n        return (Transfer(_from, _to, _value));\r\n}     \r\n    \r\n\r\n    mapping(address =\u003E uint256) balances;\r\n    mapping(address =\u003E mapping(address =\u003E uint256)) allowed;\r\n    mapping(address =\u003E bool) internal frozenAccounts;\r\n    \r\n    uint256 public totalSupply;\r\n}\r\n\r\ncontract Tratok is StandardToken {\r\n\r\n    function() {\r\n        revert();\r\n        \r\n    }\r\n\r\n    /* \r\n     * The public variables of the token. Including the name, the symbol and the number of decimals.\r\n     */\r\n    string public name;\r\n    uint8 public decimals;\r\n    string public symbol;\r\n    string public version = \u0027H1.0\u0027;\r\n\r\n    /*\r\n     * Declaring the customized details of the token. The token will be called Tratok, with a total supply of 100 billion tokens.\r\n     * It will feature five decimal places and have the symbol TRAT.\r\n     */\r\n\r\n    function Tratok() {\r\n\r\n        //we will create 100 Billion utility tokens and send them to the creating wallet.\r\n        balances[msg.sender] = 10000000000000000;\r\n        totalSupply = 10000000000000000;\r\n        name = \u0022Tratok\u0022;\r\n        decimals = 5;\r\n        symbol = \u0022TRAT\u0022;\r\n    }\r\n\r\n    /*\r\n     *Approve and enact the contract.\r\n     *\r\n     */\r\n    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns(bool success) {\r\n        allowed[msg.sender][_spender] = _value;\r\n        Approval(msg.sender, _spender, _value);\r\n\r\n        //If the call fails, result to \u0022vanilla\u0022 approval.\r\n        if (!_spender.call(bytes4(bytes32(sha3(\u0022receiveApproval(address,uint256,address,bytes)\u0022))), msg.sender, _value, this, _extraData)) {\r\n            revert();\r\n        }\r\n        return true;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_destinations\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_values\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022airDropTratok\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022version\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022unlockAccountFromSendingTratok\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022confiscate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_extraData\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022approveAndCall\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_destinations\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_values\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022distributeTratok\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022lockAccountFromSendingTratok\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022FrozenAccount\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022UnfrozenAccount\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Tratok","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://c575ec2ec6849eeefcf50166668d53cbc63bd4d4ab2db3c20f601247ffd02ef2"}]