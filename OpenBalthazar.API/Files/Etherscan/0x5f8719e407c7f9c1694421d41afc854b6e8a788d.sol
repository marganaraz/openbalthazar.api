[{"SourceCode":"/**\r\n *Submitted for verification at Etherscan.io on 2019-08-20\r\n*/\r\n\r\npragma solidity ^0.5.0;\r\n\r\n// ----------------------------------------------------------------------------------------------\r\n// Acute Angle Coin by SDAAC Limited.\r\n// An ERC20 standard\r\n//\r\n// author:SDAAC Team\r\n\r\ncontract ERC20Interface {\r\n    function totalSupply() public view returns (uint256 _totalSupply);\r\n    function balanceOf(address _owner) public view returns (uint256 balance);\r\n    function transfer(address _to, uint256 _value) public returns (bool success);\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\r\n    function approve(address _spender, uint256 _value) public returns (bool success);\r\n    function allowance(address _owner, address _spender) public view returns (uint256 remaining);\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n}\r\n\r\ncontract SDAAC is ERC20Interface {\r\n    uint256 public constant decimals = 18;\r\n\r\n    string public constant symbol = \u0022SDAAC\u0022;\r\n    string public constant name = \u0022Super Distributed Adult Art \u0026 Culture Token\u0022;\r\n\r\n    uint256 public _totalSupply = 1000000000*(10 ** 18);\r\n\r\n    // Owner of this contract\r\n    address public owner;\r\n\r\n    // Balances SDAAC for each account\r\n    mapping(address =\u003E uint256) private balances;\r\n\r\n    // Owner of account approves the transfer of an amount to another account\r\n    mapping(address =\u003E mapping (address =\u003E uint256)) private allowed;\r\n\r\n    // List of approved investors\r\n    mapping(address =\u003E bool) private approvedInvestorList;\r\n\r\n    // deposit\r\n    // mapping(address =\u003E uint256) private deposit;\r\n\r\n    // totalTokenSold\r\n    // uint256 public totalTokenSold = 0;\r\n\r\n\r\n    /**\r\n     * @dev Fix for the ERC20 short address attack.\r\n     */\r\n    modifier onlyPayloadSize(uint size) {\r\n      if(msg.data.length \u003C size \u002B 4) {\r\n        revert();\r\n      }\r\n      _;\r\n    }\r\n\r\n\r\n\r\n    /// @dev Constructor\r\n    \r\n    constructor() public {\r\n        owner = msg.sender;\r\n        balances[owner] = _totalSupply;\r\n    }\r\n\r\n    /// @dev Gets totalSupply\r\n    /// @return Total supply\r\n    function totalSupply()\r\n        public view returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    /// @dev Gets account\u0027s balance\r\n    /// @param _addr Address of the account\r\n    /// @return Account balance\r\n    function balanceOf(address _addr)\r\n        public view returns (uint256) {\r\n        return balances[_addr];\r\n    }\r\n\r\n    /// @dev check address is approved investor\r\n    /// @param _addr address\r\n    function isApprovedInvestor(address _addr)\r\n        public view returns (bool) {\r\n        return approvedInvestorList[_addr];\r\n    }\r\n\r\n    /// @dev get ETH deposit\r\n    /// @param _addr address get deposit\r\n    /// @return amount deposit of an buyer\r\n    // function getDeposit(address _addr)\r\n    //     public constant returns(uint256){\r\n    //         return deposit[_addr];\r\n    //     }\r\n\r\n\r\n    /// @dev Transfers the balance from msg.sender to an account\r\n    /// @param _to Recipient address\r\n    /// @param _amount Transfered amount in unit\r\n    /// @return Transfer status\r\n    function transfer(address _to, uint256 _amount)\r\n        public returns (bool success) {\r\n            \r\n        // if sender\u0027s balance has enough unit and amount \u003E= 0,\r\n        //      and the sum is not overflow,\r\n        // then do transfer\r\n        require(_to != address(0));\r\n        require((balances[msg.sender] \u003E= _amount) \u0026\u0026 (_amount \u003E= 0) \u0026\u0026 (balances[_to] \u002B _amount \u003E balances[_to]));\r\n        balances[msg.sender] -= _amount;\r\n        balances[_to] \u002B= _amount;\r\n        emit Transfer(msg.sender, _to, _amount);\r\n        success = true;\r\n    }\r\n\r\n    // Send _value amount of tokens from address _from to address _to\r\n    // The transferFrom method is used for a withdraw workflow, allowing contracts to send\r\n    // tokens on your behalf, for example to \u0022deposit\u0022 to a contract address and/or to charge\r\n    // fees in sub-currencies; the command should fail unless the _from account has\r\n    // deliberately authorized the sender of the message via some mechanism; we propose\r\n    // these standardized APIs for approval:\r\n    function transferFrom(\r\n        address _from,\r\n        address _to,\r\n        uint256 _amount\r\n    )\r\n    public returns (bool success) {\r\n        require(balances[_from] \u003E= _amount \u0026\u0026 _amount \u003E 0);\r\n        require(allowed[_from][msg.sender] \u003E= _amount);\r\n        require(balances[_to] \u002B _amount \u003E balances[_to]);\r\n        balances[_from] -= _amount;\r\n        allowed[_from][msg.sender] -= _amount;\r\n        balances[_to] \u002B= _amount;\r\n        emit Transfer(_from, _to, _amount);\r\n        success =  true;\r\n    }\r\n\r\n    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.\r\n    // If this function is called again it overwrites the current allowance with _value.\r\n    function approve(address _spender, uint256 _amount)\r\n        public\r\n\r\n        returns (bool success) {\r\n        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));\r\n        allowed[msg.sender][_spender] = _amount;\r\n        emit Approval(msg.sender, _spender, _amount);\r\n        return true;\r\n    }\r\n\r\n    // get allowance\r\n    function allowance(address _owner, address _spender)\r\n        public\r\n        view\r\n        returns (uint256 remaining) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n\r\n    function () external payable {\r\n        revert();\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isApprovedInvestor\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"SDAAC","CompilerVersion":"v0.5.0\u002Bcommit.1d4f565a","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://e518fe240d6fb9f789a9c815177aac5eeb1f8fa13f6e42686ac370c593abb177"}]