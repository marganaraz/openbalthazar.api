[{"SourceCode":"{\u0022EIP20.sol\u0022:{\u0022content\u0022:\u0022/*\\nImplements EIP20 token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md\\n.*/\\n\\n\\npragma solidity ^0.4.21;\\n\\nimport \\\u0022./EIP20Interface.sol\\\u0022;\\n\\n\\ncontract EIP20 is EIP20Interface {\\n\\n    uint256 constant private MAX_UINT256 = 2**256 - 1;\\n    mapping (address =\\u003e uint256) public balances;\\n    mapping (address =\\u003e mapping (address =\\u003e uint256)) public allowed;\\n    /*\\n    NOTE:\\n    The following variables are OPTIONAL vanities. One does not have to include them.\\n    They allow one to customise the token contract \\u0026 in no way influences the core functionality.\\n    Some wallets/interfaces might not even bother to look at this information.\\n    */\\n    string public name;                   //fancy name: eg Simon Bucks\\n    uint8 public decimals;                //How many decimals to show.\\n    string public symbol;                 //An identifier: eg SBX\\n\\n    function EIP20(\\n        uint256 _initialAmount,\\n        string _tokenName,\\n        uint8 _decimalUnits,\\n        string _tokenSymbol\\n    ) public {\\n        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens\\n        totalSupply = _initialAmount;                        // Update total supply\\n        name = _tokenName;                                   // Set the name for display purposes\\n        decimals = _decimalUnits;                            // Amount of decimals for display purposes\\n        symbol = _tokenSymbol;                               // Set the symbol for display purposes\\n    }\\n\\n    function transfer(address _to, uint256 _value) public returns (bool success) {\\n        require(balances[msg.sender] \\u003e= _value);\\n        balances[msg.sender] -= _value;\\n        balances[_to] \u002B= _value;\\n        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars\\n        return true;\\n    }\\n\\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {\\n        uint256 allowance = allowed[_from][msg.sender];\\n        require(balances[_from] \\u003e= _value \\u0026\\u0026 allowance \\u003e= _value);\\n        balances[_to] \u002B= _value;\\n        balances[_from] -= _value;\\n        if (allowance \\u003c MAX_UINT256) {\\n            allowed[_from][msg.sender] -= _value;\\n        }\\n        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars\\n        return true;\\n    }\\n\\n    function balanceOf(address _owner) public view returns (uint256 balance) {\\n        return balances[_owner];\\n    }\\n\\n    function approve(address _spender, uint256 _value) public returns (bool success) {\\n        allowed[msg.sender][_spender] = _value;\\n        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars\\n        return true;\\n    }\\n\\n    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {\\n        return allowed[_owner][_spender];\\n    }\\n}\\n\u0022},\u0022EIP20Factory.sol\u0022:{\u0022content\u0022:\u0022import \\\u0022./EIP20.sol\\\u0022;\\n\\npragma solidity ^0.4.21;\\n\\n\\ncontract EIP20Factory {\\n\\n    mapping(address =\\u003e address[]) public created;\\n    mapping(address =\\u003e bool) public isEIP20; //verify without having to do a bytecode check.\\n    bytes public EIP20ByteCode; // solhint-disable-line var-name-mixedcase\\n\\n    function EIP20Factory() public {\\n        //upon creation of the factory, deploy a EIP20 (parameters are meaningless) and store the bytecode provably.\\n        address verifiedToken = createEIP20(10000, \\\u0022Verify Token\\\u0022, 3, \\\u0022VTX\\\u0022);\\n        EIP20ByteCode = codeAt(verifiedToken);\\n    }\\n\\n    //verifies if a contract that has been deployed is a Human Standard Token.\\n    //NOTE: This is a very expensive function, and should only be used in an eth_call. ~800k gas\\n    function verifyEIP20(address _tokenContract) public view returns (bool) {\\n        bytes memory fetchedTokenByteCode = codeAt(_tokenContract);\\n\\n        if (fetchedTokenByteCode.length != EIP20ByteCode.length) {\\n            return false; //clear mismatch\\n        }\\n\\n      //starting iterating through it if lengths match\\n        for (uint i = 0; i \\u003c fetchedTokenByteCode.length; i\u002B\u002B) {\\n            if (fetchedTokenByteCode[i] != EIP20ByteCode[i]) {\\n                return false;\\n            }\\n        }\\n        return true;\\n    }\\n\\n    function createEIP20(uint256 _initialAmount, string _name, uint8 _decimals, string _symbol)\\n        public\\n    returns (address) {\\n\\n        EIP20 newToken = (new EIP20(_initialAmount, _name, _decimals, _symbol));\\n        created[msg.sender].push(address(newToken));\\n        isEIP20[address(newToken)] = true;\\n        //the factory will own the created tokens. You must transfer them.\\n        newToken.transfer(msg.sender, _initialAmount);\\n        return address(newToken);\\n    }\\n\\n    //for now, keeping this internal. Ideally there should also be a live version of this that\\n    // any contract can use, lib-style.\\n    //retrieves the bytecode at a specific address.\\n    function codeAt(address _addr) internal view returns (bytes outputCode) {\\n        assembly { // solhint-disable-line no-inline-assembly\\n            // retrieve the size of the code, this needs assembly\\n            let size := extcodesize(_addr)\\n            // allocate output byte array - this could also be done without assembly\\n            // by using outputCode = new bytes(size)\\n            outputCode := mload(0x40)\\n            // new \\\u0022memory end\\\u0022 including padding\\n            mstore(0x40, add(outputCode, and(add(add(size, 0x20), 0x1f), not(0x1f))))\\n            // store length in memory\\n            mstore(outputCode, size)\\n            // actually retrieve the code, this needs assembly\\n            extcodecopy(_addr, add(outputCode, 0x20), 0, size)\\n        }\\n    }\\n}\\n\u0022},\u0022EIP20Interface.sol\u0022:{\u0022content\u0022:\u0022// Abstract contract for the full ERC 20 Token standard\\n// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md\\npragma solidity ^0.4.21;\\n\\n\\ncontract EIP20Interface {\\n    /* This is a slight change to the ERC20 base standard.\\n    function totalSupply() constant returns (uint256 supply);\\n    is replaced with:\\n    uint256 public totalSupply;\\n    This automatically creates a getter function for the totalSupply.\\n    This is moved to the base contract since public getter functions are not\\n    currently recognised as an implementation of the matching abstract\\n    function by the compiler.\\n    */\\n    /// total amount of tokens\\n    uint256 public totalSupply;\\n\\n    /// @param _owner The address from which the balance will be retrieved\\n    /// @return The balance\\n    function balanceOf(address _owner) public view returns (uint256 balance);\\n\\n    /// @notice send \u0060_value\u0060 token to \u0060_to\u0060 from \u0060msg.sender\u0060\\n    /// @param _to The address of the recipient\\n    /// @param _value The amount of token to be transferred\\n    /// @return Whether the transfer was successful or not\\n    function transfer(address _to, uint256 _value) public returns (bool success);\\n\\n    /// @notice send \u0060_value\u0060 token to \u0060_to\u0060 from \u0060_from\u0060 on the condition it is approved by \u0060_from\u0060\\n    /// @param _from The address of the sender\\n    /// @param _to The address of the recipient\\n    /// @param _value The amount of token to be transferred\\n    /// @return Whether the transfer was successful or not\\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\\n\\n    /// @notice \u0060msg.sender\u0060 approves \u0060_spender\u0060 to spend \u0060_value\u0060 tokens\\n    /// @param _spender The address of the account able to transfer the tokens\\n    /// @param _value The amount of tokens to be approved for transfer\\n    /// @return Whether the approval was successful or not\\n    function approve(address _spender, uint256 _value) public returns (bool success);\\n\\n    /// @param _owner The address of the account owning tokens\\n    /// @param _spender The address of the account able to transfer the tokens\\n    /// @return Amount of remaining tokens allowed to spent\\n    function allowance(address _owner, address _spender) public view returns (uint256 remaining);\\n\\n    // solhint-disable-next-line no-simple-event-func-name\\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\\n}\\n\u0022}}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balances\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_initialAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_tokenName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_decimalUnits\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022_tokenSymbol\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"EIP20","CompilerVersion":"v0.4.21\u002Bcommit.dfe3193c","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000000000000000000000115eec47f6cf7e350000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000000064b6f736d6f73000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000034b4d530000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://0be95606a553176c1151e438407b830d0d255b1f441992e9e7197307a3e9946a"}]