[{"SourceCode":"pragma solidity ^0.4.16;\r\n\r\ninterface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }\r\n\r\ncontract LAIToken {\r\n\t// Setting constant\r\n\tuint256 constant public TOTAL_TOKEN = 10 ** 9;\r\n\tuint256 constant public TOKEN_FOR_ICO = 550 * 10 ** 6;\r\n\tuint256 constant public TOKEN_FOR_BONUS = 50 * 10 ** 6;\r\n\tuint256 constant public TOKEN_FOR_COMPANY = 300 * 10 ** 6;\r\n\tuint256 constant public TOKEN_FOR_INDIVIDUAL = 100 * 10 ** 6;\r\n\t\r\n\tuint256 public tokenForCompany;\r\n\tuint public period = 1;\r\n\r\n\tuint public startTime;\r\n\t\r\n    // Public variables of the token\r\n    string public name;\r\n    string public symbol;\r\n    uint8 public decimals = 8;\r\n    // 18 decimals is the strongly suggested default, avoid changing it\r\n    uint256 public totalSupply;\r\n\r\n    // This creates an array with all balances\r\n    mapping (address =\u003E uint256) public balanceOf;\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) public allowance;\r\n\r\n    // This generates a public event on the blockchain that will notify clients\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    // This notifies clients about the amount burnt\r\n    event Burn(address indexed from, uint256 value);\r\n\r\n    /**\r\n     * Constrctor function\r\n     *\r\n     * Initializes contract with initial supply tokens to the creator of the contract\r\n     */\r\n    function LAIToken(\r\n    ) public {\r\n        totalSupply = TOTAL_TOKEN * 10 ** uint256(decimals); // Update total supply with the decimal amount\r\n        name = \u0022LAI Token\u0022;                                 // Set the name for display purposes\r\n        symbol = \u0022LAI\u0022;                               \t\t// Set the symbol for display purposes\r\n\t\t\r\n\t\t// Initializes\r\n\t\tstartTime = 1512997200; // need to update start time\r\n\t\t\r\n\t\t// INDIVIDUAL \r\n\t\t// 1.TECH TEAM\r\n\t\tbalanceOf[0xE0C6d444C475A89e50eD6C05314263D1B280d8D8] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0xc53a01d0711C433b37EA85A08B6CDcad5977c6EE] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x710a332d19FC37eE9FFBb52F4F6e4d08db10f769] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0xA24fab2B636e238F4581F881D9a76a5C38207bf4] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x151dB6D9e1e6E3599d5eeeD7E0Ad8Cf2cEb42D09] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x30626Fa60154f9102e3b977CAb66E4424Ed14fe6] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\t// 2.XDMT - TGTX\r\n\t\tbalanceOf[0xc3e359019bCc6888250916361f4b8c6c719474c3] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x769ef98835685cD5B569443cd8ea8C35420ba3dD] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x67fd37B157843B5750aB35E96C98d5720e827c17] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x54A5C24000f22338587B59E8F04227E60bbFd4cD] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x3E56DcCd10b7965d1C314ac1D60A0dA3ED09a8f7] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0xd462B827A1fDAE6B34C020ca86Ed1312a11A1676] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x4451d98b978e3A3D738A087dFf15cfe294fb5b1D] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\t// 3.HTD\r\n\t\tbalanceOf[0x382f5304782C146243259f1ADD021aDD8D50D719] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x4451d98b978e3A3D738A087dFf15cfe294fb5b1D] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0xa239BBF3F85a8aEFA4a7ab7C6C9AC75879903C65] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x9a02aE27Af9771622D8D6Bf39BE2e1c3976F89d0] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x9dD2155921Fc27229EE57dd4F1F95B5014Fd1F91] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x86c0e8353E0b5c2c998D8dD09c16A0F0d75813d9] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0xc31fdD93B26Ba08c11614914bc035cde5565D005] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x52D639E2254591d8ba938f316019d860bD104fbe] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x0099a03937543720Fd9050bBF3DF4f0BB7d3A6F3] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x3C59022Fa73A9D521AD9C8C4843FDe858EE1d536] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x1587134f21156C55b153EC73F5A90AA3d029cA75] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0xAdb5566880D8b0463DfCcC31804a727E419d9D19] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\t// 4.Butta\t\t\r\n\t\tbalanceOf[0x3CB617913C6Ab9b4bc0CF17C2fAEBe3149E58dC6] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x39535CfC26F74F73C2508922140c5859B733ec67] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x7906A41853dA81E0e1bC122687C47fc4fb02e1e8] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x1C30f6dCe6a955f68a644cd08058A71C0b5211BC] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\t// 5.Du phong\r\n\t\tbalanceOf[0x2d55C27207F47A2B06dC164f30Bd477C174AfA22] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0xCD9c24061A8BF99Afce291B98eEa8C6D384AF20a] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x360A12310E7Ea8FBc4f13b372eeF4Faf9Ee6F18b] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x0271869e03b8F03A3Cd2E6cd2992322BdF017A63] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x08E2500116eeCfFC597daC6750f6c4B80A52810E] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x696c7Fc8d746c9Fd9E0c365de795601aa494e9bD] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x7b65D808d1d5a2CfB217385Bd225AF541Cf64E06] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\t// 6.Private investor\r\n\t\tbalanceOf[0x28826530DC2b4bee050F946236c4De1846523209] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0xe5E7Ba0df9c1321F28FD330722705C6504525f78] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0xb57ACF012d41D95CABb91C1CBf4461605Edc5a47] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0xf6e5E30338C2f11ED30c96Cb68d820beF837cd61] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x379e136247864468B80c158643BDa3101d22e252] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x39cb2246d335c33a52831e7a1913208bb755B506] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0xbE218E067A2Cc86222c904cFF7e7e4e04a010a87] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0xCc3985704019E39c526438CAEd107bfC32403fDa] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0xCB79a26d969bb1FCe352407F42f46bc22a861624] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0xeA68D5BD9E63c3795D81Ffae7D20423Ebe924D05] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\t// 7.Advisor\r\n\t\tbalanceOf[0x3252c8451f295f078654A68Af4a1363F5Dc9137b] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x8E50B7cC390a3EADCffbB2880f02Ff66d7F648e7] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0xB6A8F95E2E87045c512be48766ef20a5EF349d20] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x3f62c536A29db068c30B637880D61e1Cf27F24F8] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\tbalanceOf[0x86C942186C3C09E7856488821497B713058563fb] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;\r\n\t\t\r\n\t\t// COMPANY, ICO, BONUS\r\n\t\tbalanceOf[0x966F2884524858326DfF216394a61b9894166c68] = TOKEN_FOR_ICO * 10 ** uint256(decimals);\r\n\t\ttokenForCompany = TOKEN_FOR_COMPANY * 10 ** uint256(decimals);\r\n\t\tbalanceOf[0xf28edB52E808cd9DCe18A87fD94D373D6B9f65ae] = tokenForCompany * 10 / 100;// 10% in the beginning\r\n\t\ttokenForCompany = tokenForCompany * 90 / 100;\r\n\t\tbalanceOf[0x919afCd5bDf9e8a6cff95cB5016F9DD5FeDbdEC5] = TOKEN_FOR_BONUS * 10 ** uint256(decimals);\r\n    }\r\n\r\n    /**\r\n     * Internal transfer, only can be called by this contract\r\n     */\r\n    function _transfer(address _from, address _to, uint _value) internal {\r\n        // Prevent transfer to 0x0 address. Use burn() instead\r\n        require(_to != 0x0);\r\n        // Check if the sender has enough\r\n        require(balanceOf[_from] \u003E= _value);\r\n        // Check for overflows\r\n        require(balanceOf[_to] \u002B _value \u003E balanceOf[_to]);\r\n        // Save this for an assertion in the future\r\n        uint previousBalances = balanceOf[_from] \u002B balanceOf[_to];\r\n        // Subtract from the sender\r\n        balanceOf[_from] -= _value;\r\n        // Add the same to the recipient\r\n        balanceOf[_to] \u002B= _value;\r\n        Transfer(_from, _to, _value);\r\n        // Asserts are used to use static analysis to find bugs in your code. They should never fail\r\n        assert(balanceOf[_from] \u002B balanceOf[_to] == previousBalances);\r\n    }\r\n\r\n    /**\r\n     * Transfer tokens\r\n     *\r\n     * Send \u0060_value\u0060 tokens to \u0060_to\u0060 from your account\r\n     *\r\n     * @param _to The address of the recipient\r\n     * @param _value the amount to send\r\n     */\r\n    function transfer(address _to, uint256 _value) public {\r\n        _transfer(msg.sender, _to, _value);\r\n    }\r\n\r\n    /**\r\n     * Transfer tokens from other address\r\n     *\r\n     * Send \u0060_value\u0060 tokens to \u0060_to\u0060 in behalf of \u0060_from\u0060\r\n     *\r\n     * @param _from The address of the sender\r\n     * @param _to The address of the recipient\r\n     * @param _value the amount to send\r\n     */\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {\r\n        require(_value \u003C= allowance[_from][msg.sender]);     // Check allowance\r\n        allowance[_from][msg.sender] -= _value;\r\n        _transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * Set allowance for other address\r\n     *\r\n     * Allows \u0060_spender\u0060 to spend no more than \u0060_value\u0060 tokens in your behalf\r\n     *\r\n     * @param _spender The address authorized to spend\r\n     * @param _value the max amount they can spend\r\n     */\r\n    function approve(address _spender, uint256 _value) public\r\n        returns (bool success) {\r\n        allowance[msg.sender][_spender] = _value;\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * Set allowance for other address and notify\r\n     *\r\n     * Allows \u0060_spender\u0060 to spend no more than \u0060_value\u0060 tokens in your behalf, and then ping the contract about it\r\n     *\r\n     * @param _spender The address authorized to spend\r\n     * @param _value the max amount they can spend\r\n     * @param _extraData some extra information to send to the approved contract\r\n     */\r\n    function approveAndCall(address _spender, uint256 _value, bytes _extraData)\r\n        public\r\n        returns (bool success) {\r\n        tokenRecipient spender = tokenRecipient(_spender);\r\n        if (approve(_spender, _value)) {\r\n            spender.receiveApproval(msg.sender, _value, this, _extraData);\r\n            return true;\r\n        }\r\n    }\r\n\r\n    /**\r\n     * Destroy tokens\r\n     *\r\n     * Remove \u0060_value\u0060 tokens from the system irreversibly\r\n     *\r\n     * @param _value the amount of money to burn\r\n     */\r\n    function burn(uint256 _value) public returns (bool success) {\r\n        require(balanceOf[msg.sender] \u003E= _value);   // Check if the sender has enough\r\n        balanceOf[msg.sender] -= _value;            // Subtract from the sender\r\n        totalSupply -= _value;                      // Updates totalSupply\r\n        Burn(msg.sender, _value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * Destroy tokens from other account\r\n     *\r\n     * Remove \u0060_value\u0060 tokens from the system irreversibly on behalf of \u0060_from\u0060.\r\n     *\r\n     * @param _from the address of the sender\r\n     * @param _value the amount of money to burn\r\n     */\r\n    function burnFrom(address _from, uint256 _value) public returns (bool success) {\r\n        require(balanceOf[_from] \u003E= _value);                // Check if the targeted balance is enough\r\n        require(_value \u003C= allowance[_from][msg.sender]);    // Check allowance\r\n        balanceOf[_from] -= _value;                         // Subtract from the targeted balance\r\n        allowance[_from][msg.sender] -= _value;             // Subtract from the sender\u0027s allowance\r\n        totalSupply -= _value;                              // Update totalSupply\r\n        Burn(_from, _value);\r\n        return true;\r\n    }\r\n\t\r\n\tfunction companyPeriodFund() public {\r\n\t\t// Second period after 1 year\r\n\t\tif (now \u003E= startTime \u002B 365 days \u0026\u0026 period == 1) {\r\n\t\t\tperiod = 2;\r\n\t\t\tbalanceOf[0xf28edB52E808cd9DCe18A87fD94D373D6B9f65ae] \u002B= TOKEN_FOR_COMPANY * 10 ** uint256(decimals) * 4 / 10;\r\n\t\t\ttokenForCompany -= TOKEN_FOR_COMPANY * 10 ** uint256(decimals) * 4 / 10;\r\n\t\t}\r\n\t\t\r\n\t\t// Third period after 2 years\r\n\t\tif (now \u003E= startTime \u002B 730 days \u0026\u0026 period == 2) {\r\n\t\t\tperiod = 3;\r\n\t\t\tbalanceOf[0xf28edB52E808cd9DCe18A87fD94D373D6B9f65ae] \u002B= TOKEN_FOR_COMPANY * 10 ** uint256(decimals) * 5 / 10;\r\n\t\t\ttokenForCompany -= TOKEN_FOR_COMPANY * 10 ** uint256(decimals) * 5 / 10;\t\t\r\n\t\t}\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022companyPeriodFund\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_FOR_COMPANY\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_FOR_ICO\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022startTime\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_FOR_BONUS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokenForCompany\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOTAL_TOKEN\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_FOR_INDIVIDUAL\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_extraData\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022approveAndCall\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022period\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"LAIToken","CompilerVersion":"v0.4.16\u002Bcommit.d7661dd9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://2080837bef41ea911138be220b50641c08d8b838255285df94cf7ba460b453d7"}]