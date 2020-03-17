[{"SourceCode":"pragma solidity \u003E=0.4.22 \u003C0.6.0;\r\n\r\ninterface tokenRecipient { \r\n    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; \r\n}\r\n\r\ncontract MDC{\r\n    // Public variables of the token\r\n    string public name;\r\n    string public symbol;\r\n    uint8 public decimals = 8;\r\n    // 18 decimals is the strongly suggested default, avoid changing it\r\n    uint256 public totalSupply;\r\n\r\n    // This creates an array with all balances\r\n    mapping (address =\u003E uint256) public balanceOf;\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) public allowance;\r\n\r\n    // This generates a public event on the blockchain that will notify clients\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    \r\n    // This generates a public event on the blockchain that will notify clients\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n\r\n    // This notifies clients about the amount burnt\r\n    event Burn(address indexed from, uint256 value);\r\n\r\n    /**\r\n     * Constructor function\r\n     *\r\n     * Initializes contract with initial supply tokens to the creator of the contract\r\n     */\r\n    constructor(\r\n        uint256 initialSupply,\r\n        string memory tokenName,\r\n        string memory tokenSymbol\r\n    ) public {\r\n        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount\r\n        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens\r\n        name = tokenName;                                   // Set the name for display purposes\r\n        symbol = tokenSymbol;                               // Set the symbol for display purposes\r\n    }\r\n\r\n    /**\r\n     * Internal transfer, only can be called by this contract\r\n     */\r\n    function _transfer(address _from, address _to, uint _value) internal {\r\n        // Prevent transfer to 0x0 address. Use burn() instead\r\n        require(_to != address(0x0));\r\n        // Check if the sender has enough\r\n        require(balanceOf[_from] \u003E= _value);\r\n        // Check for overflows\r\n        require(balanceOf[_to] \u002B _value \u003E= balanceOf[_to]);\r\n        // Save this for an assertion in the future\r\n        uint previousBalances = balanceOf[_from] \u002B balanceOf[_to];\r\n        // Subtract from the sender\r\n        balanceOf[_from] -= _value;\r\n        // Add the same to the recipient\r\n        balanceOf[_to] \u002B= _value;\r\n        emit Transfer(_from, _to, _value);\r\n        // Asserts are used to use static analysis to find bugs in your code. They should never fail\r\n        assert(balanceOf[_from] \u002B balanceOf[_to] == previousBalances);\r\n    }\r\n\r\n    /**\r\n     * Transfer tokens\r\n     *\r\n     * Send \u0060_value\u0060 tokens to \u0060_to\u0060 from your account\r\n     *\r\n     * @param _to The address of the recipient\r\n     * @param _value the amount to send\r\n     */\r\n    function transfer(address _to, uint256 _value) public returns (bool success) {\r\n        _transfer(msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * Transfer tokens from other address\r\n     *\r\n     * Send \u0060_value\u0060 tokens to \u0060_to\u0060 on behalf of \u0060_from\u0060\r\n     *\r\n     * @param _from The address of the sender\r\n     * @param _to The address of the recipient\r\n     * @param _value the amount to send\r\n     */\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {\r\n        require(_value \u003C= allowance[_from][msg.sender]);     // Check allowance\r\n        allowance[_from][msg.sender] -= _value;\r\n        _transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * Set allowance for other address\r\n     *\r\n     * Allows \u0060_spender\u0060 to spend no more than \u0060_value\u0060 tokens on your behalf\r\n     *\r\n     * @param _spender The address authorized to spend\r\n     * @param _value the max amount they can spend\r\n     */\r\n    function approve(address _spender, uint256 _value) public\r\n        returns (bool success) {\r\n        allowance[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * Set allowance for other address and notify\r\n     *\r\n     * Allows \u0060_spender\u0060 to spend no more than \u0060_value\u0060 tokens on your behalf, and then ping the contract about it\r\n     *\r\n     * @param _spender The address authorized to spend\r\n     * @param _value the max amount they can spend\r\n     * @param _extraData some extra information to send to the approved contract\r\n     */\r\n    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)\r\n        public\r\n        returns (bool success) {\r\n        tokenRecipient spender = tokenRecipient(_spender);\r\n        if (approve(_spender, _value)) {\r\n            spender.receiveApproval(msg.sender, _value, address(this), _extraData);\r\n            return true;\r\n        }\r\n    }\r\n\r\n    /**\r\n     * Destroy tokens\r\n     *\r\n     * Remove \u0060_value\u0060 tokens from the system irreversibly\r\n     *\r\n     * @param _value the amount of money to burn\r\n     */\r\n    function burn(uint256 _value) public returns (bool success) {\r\n        require(balanceOf[msg.sender] \u003E= _value);   // Check if the sender has enough\r\n        balanceOf[msg.sender] -= _value;            // Subtract from the sender\r\n        totalSupply -= _value;                      // Updates totalSupply\r\n        emit Burn(msg.sender, _value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * Destroy tokens from other account\r\n     *\r\n     * Remove \u0060_value\u0060 tokens from the system irreversibly on behalf of \u0060_from\u0060.\r\n     *\r\n     * @param _from the address of the sender\r\n     * @param _value the amount of money to burn\r\n     */\r\n    function burnFrom(address _from, uint256 _value) public returns (bool success) {\r\n        require(balanceOf[_from] \u003E= _value);                // Check if the targeted balance is enough\r\n        require(_value \u003C= allowance[_from][msg.sender]);    // Check allowance\r\n        balanceOf[_from] -= _value;                         // Subtract from the targeted balance\r\n        allowance[_from][msg.sender] -= _value;             // Subtract from the sender\u0027s allowance\r\n        totalSupply -= _value;                              // Update totalSupply\r\n        emit Burn(_from, _value);\r\n        return true;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_extraData\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022approveAndCall\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022initialSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022tokenName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022tokenSymbol\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"MDC","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000000000000000000000000000000000006b49d200000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000c4d65646963616c20436f696e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000034d44430000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://b7cedb93b3b76d63f383341c95f86133cf7eb1614c2ee9b4ed54fb35fd0d7e57"}]