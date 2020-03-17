[{"SourceCode":"pragma solidity \u003E=0.4.24;\r\ncontract LUKTokenStore {\r\n    /** \u7CBE\u5EA6\uFF0C\u63A8\u8350\u662F 8 */\r\n    uint8 public decimals = 8;\r\n    /** \u4EE3\u5E01\u603B\u91CF */\r\n    uint256 public totalSupply;\r\n    /** \u67E5\u770B\u67D0\u4E00\u5730\u5740\u4EE3\u5E01\u4F59\u989D */\r\n    mapping (address =\u003E uint256) private tokenAmount;\r\n    /** \u4EE3\u5E01\u4EA4\u6613\u4EE3\u7406\u4EBA\u6388\u6743\u5217\u8868 */\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) private allowanceMapping;\r\n    //\u5408\u7EA6\u6240\u6709\u8005\r\n    address private owner;\r\n    //\u5199\u6388\u6743\r\n    mapping (address =\u003E bool) private authorization;\r\n    \r\n    /**\r\n     * Constructor function\r\n     * \r\n     * \u521D\u59CB\u5408\u7EA6\r\n     * @param initialSupply \u4EE3\u5E01\u603B\u91CF\r\n     */\r\n    constructor (uint256 initialSupply) public {\r\n        //** \u662F\u5E42\u8FD0\u7B97\r\n        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount\r\n        tokenAmount[msg.sender] = totalSupply;                // Give the creator all initial tokens\r\n        owner = msg.sender;\r\n    }\r\n    \r\n    //\u5B9A\u4E49\u51FD\u6570\u4FEE\u9970\u7B26\uFF0C\u5224\u65AD\u6D88\u606F\u53D1\u9001\u8005\u662F\u5426\u662F\u5408\u7EA6\u6240\u6709\u8005\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner,\u0022Illegal operation.\u0022);\r\n        _;\r\n    }\r\n    \r\n    modifier checkWrite() {\r\n        require(authorization[msg.sender] == true,\u0022Illegal operation.\u0022);\r\n        _;\r\n    }\r\n    \r\n    //\u5199\u6388\u6743\uFF0C\u5408\u7EA6\u8C03\u7528\u5408\u7EA6\u65F6\u8C03\u7528\u8005\u4E3A\u7236\u5408\u7EA6\u5730\u5740\r\n    function writeGrant(address _address) public onlyOwner {\r\n        authorization[_address] = true;\r\n    }\r\n    function writeRevoke(address _address) public onlyOwner {\r\n        authorization[_address] = false;\r\n    }\r\n    \r\n    /**\r\n     * \u8BBE\u7F6E\u4EE3\u5E01\u6D88\u8D39\u4EE3\u7406\u4EBA\uFF0C\u4EE3\u7406\u4EBA\u53EF\u4EE5\u5728\u6700\u5927\u53EF\u4F7F\u7528\u91D1\u989D\u5185\u6D88\u8D39\u4EE3\u5E01\r\n     *\r\n     * @param _from \u8D44\u91D1\u6240\u6709\u8005\u5730\u5740\r\n     * @param _spender \u4EE3\u7406\u4EBA\u5730\u5740\r\n     * @param _value \u6700\u5927\u53EF\u4F7F\u7528\u91D1\u989D\r\n     */\r\n    function approve(address _from,address _spender, uint256 _value) public checkWrite returns (bool) {\r\n        allowanceMapping[_from][_spender] = _value;\r\n        return true;\r\n    }\r\n    \r\n    function allowance(address _from, address _spender) public view returns (uint256) {\r\n        return allowanceMapping[_from][_spender];\r\n    }\r\n    \r\n    /**\r\n     * Internal transfer, only can be called by this contract\r\n     */\r\n    function transfer(address _from, address _to, uint256 _value) public checkWrite returns (bool) {\r\n        // Prevent transfer to 0x0 address. Use burn() instead\r\n        require(_to != address(0x0),\u0022Invalid address\u0022);\r\n        // Check if the sender has enough\r\n        require(tokenAmount[_from] \u003E= _value,\u0022Not enough balance.\u0022);\r\n        // Check for overflows\r\n        require(tokenAmount[_to] \u002B _value \u003E tokenAmount[_to],\u0022Target account cannot be received.\u0022);\r\n\r\n        // \u8F6C\u8D26\r\n        // Subtract from the sender\r\n        tokenAmount[_from] -= _value;\r\n        // Add the same to the recipient\r\n        tokenAmount[_to] \u002B= _value;\r\n\r\n        return true;\r\n    }\r\n    \r\n    function transferFrom(address _from,address _spender, address _to, uint256 _value) public checkWrite returns (bool) {\r\n        // Prevent transfer to 0x0 address. Use burn() instead\r\n        require(_from != address(0x0),\u0022Invalid address\u0022);\r\n        // Prevent transfer to 0x0 address. Use burn() instead\r\n        require(_to != address(0x0),\u0022Invalid address\u0022);\r\n        \r\n        // Check if the sender has enough\r\n        require(allowanceMapping[_from][_spender] \u003E= _value,\u0022Insufficient credit limit.\u0022);\r\n        // Check if the sender has enough\r\n        require(tokenAmount[_from] \u003E= _value,\u0022Not enough balance.\u0022);\r\n        // Check for overflows\r\n        require(tokenAmount[_to] \u002B _value \u003E tokenAmount[_to],\u0022Target account cannot be received.\u0022);\r\n        \r\n        // \u8F6C\u8D26\r\n        // Subtract from the sender\r\n        tokenAmount[_from] -= _value;\r\n        // Add the same to the recipient\r\n        tokenAmount[_to] \u002B= _value;\r\n        \r\n        allowanceMapping[_from][_spender] -= _value; \r\n    }\r\n    \r\n    function balanceOf(address _owner) public view returns (uint256){\r\n        require(_owner != address(0x0),\u0022Address can\u0027t is zero.\u0022);\r\n        return tokenAmount[_owner] ;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022writeGrant\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022writeRevoke\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022initialSupply\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"LUKTokenStore","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"00000000000000000000000000000000000000000000000000000002540be400","Library":"","SwarmSource":"bzzr://600a83ecb1a9ca91db895003575666d551e3323063f12458c93972aa0eb3da8c"}]