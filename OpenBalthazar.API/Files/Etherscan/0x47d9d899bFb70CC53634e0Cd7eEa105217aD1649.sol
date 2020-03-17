[{"SourceCode":"pragma solidity ^0.4.16;\r\n\r\n\r\ninterface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }\r\n\r\ncontract TokenERC20 {\r\n    string public name;\r\n    string public symbol;\r\n    uint8 public decimals = 18;  // decimals \u53EF\u4EE5\u6709\u7684\u5C0F\u6570\u70B9\u4E2A\u6570\uFF0C\u6700\u5C0F\u7684\u4EE3\u5E01\u5355\u4F4D\u300218 \u662F\u5EFA\u8BAE\u7684\u9ED8\u8BA4\u503C\r\n    uint256 public totalSupply;\r\n\r\n// \u7528mapping\u4FDD\u5B58\u6BCF\u4E2A\u5730\u5740\u5BF9\u5E94\u7684\u4F59\u989D\r\nmapping (address =\u003E uint256) public balanceOf;\r\n// \u5B58\u50A8\u5BF9\u8D26\u53F7\u7684\u63A7\u5236\r\nmapping (address =\u003E mapping (address =\u003E uint256)) public allowance;\r\n\r\n// \u4E8B\u4EF6\uFF0C\u7528\u6765\u901A\u77E5\u5BA2\u6237\u7AEF\u4EA4\u6613\u53D1\u751F\r\nevent Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n// \u4E8B\u4EF6\uFF0C\u7528\u6765\u901A\u77E5\u5BA2\u6237\u7AEF\u4EE3\u5E01\u88AB\u6D88\u8D39\r\nevent Burn(address indexed from, uint256 value);\r\n\r\n/**\r\n * \u521D\u59CB\u5316\u6784\u9020\r\n */\r\nfunction TokenERC20(uint256 initialSupply, string tokenName, string tokenSymbol) public {\r\n\r\n\ttotalSupply = initialSupply * 10 ** uint256(decimals);  // \u4F9B\u5E94\u7684\u4EFD\u989D\uFF0C\u4EFD\u989D\u8DDF\u6700\u5C0F\u7684\u4EE3\u5E01\u5355\u4F4D\u6709\u5173\uFF0C\u4EFD\u989D = \u5E01\u6570 * 10 ** decimals\u3002\r\n\tbalanceOf[msg.sender] = totalSupply;                // \u521B\u5EFA\u8005\u62E5\u6709\u6240\u6709\u7684\u4EE3\u5E01\r\n\tname = tokenName;                                   // \u4EE3\u5E01\u540D\u79F0\r\n\tsymbol = tokenSymbol;                               // \u4EE3\u5E01\u7B26\u53F7\r\n}\r\n\r\n/**\r\n * \u4EE3\u5E01\u4EA4\u6613\u8F6C\u79FB\u7684\u5185\u90E8\u5B9E\u73B0\r\n */\r\nfunction _transfer(address _from, address _to, uint _value) internal {\r\n\t// \u786E\u4FDD\u76EE\u6807\u5730\u5740\u4E0D\u4E3A0x0\uFF0C\u56E0\u4E3A0x0\u5730\u5740\u4EE3\u8868\u9500\u6BC1\r\n\trequire(_to != 0x0);\r\n\t// \u68C0\u67E5\u53D1\u9001\u8005\u4F59\u989D\r\n\trequire(balanceOf[_from] \u003E= _value);\r\n\t// \u6EA2\u51FA\u68C0\u67E5\r\n\trequire(balanceOf[_to] \u002B _value \u003E balanceOf[_to]);\r\n\r\n\t// \u4EE5\u4E0B\u7528\u6765\u68C0\u67E5\u4EA4\u6613\uFF0C\r\n\tuint previousBalances = balanceOf[_from] \u002B balanceOf[_to];\r\n\t// Subtract from the sender\r\n\tbalanceOf[_from] -= _value;\r\n\t// Add the same to the recipient\r\n\tbalanceOf[_to] \u002B= _value;\r\n\tTransfer(_from, _to, _value);\r\n\r\n\t// \u7528assert\u6765\u68C0\u67E5\u4EE3\u7801\u903B\u8F91\u3002\r\n\tassert(balanceOf[_from] \u002B balanceOf[_to] == previousBalances);\r\n}\r\n\r\n/**\r\n *  \u4EE3\u5E01\u4EA4\u6613\u8F6C\u79FB\r\n * \u4ECE\u81EA\u5DF1\uFF08\u521B\u5EFA\u4EA4\u6613\u8005\uFF09\u8D26\u53F7\u53D1\u9001\u0060_value\u0060\u4E2A\u4EE3\u5E01\u5230 \u0060_to\u0060\u8D26\u53F7\r\n *\r\n * @param _to \u63A5\u6536\u8005\u5730\u5740\r\n * @param _value \u8F6C\u79FB\u6570\u989D\r\n */\r\nfunction transfer(address _to, uint256 _value) public {\r\n\t_transfer(msg.sender, _to, _value);\r\n}\r\n\r\n/**\r\n * \u8D26\u53F7\u4E4B\u95F4\u4EE3\u5E01\u4EA4\u6613\u8F6C\u79FB\r\n * @param _from \u53D1\u9001\u8005\u5730\u5740\r\n * @param _to \u63A5\u6536\u8005\u5730\u5740\r\n * @param _value \u8F6C\u79FB\u6570\u989D\r\n */\r\nfunction transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {\r\n\trequire(_value \u003C= allowance[_from][msg.sender]);     // Check allowance\r\n\tallowance[_from][msg.sender] -= _value;\r\n\t_transfer(_from, _to, _value);\r\n\treturn true;\r\n}\r\n\r\n/**\r\n * \u8BBE\u7F6E\u67D0\u4E2A\u5730\u5740\uFF08\u5408\u7EA6\uFF09\u53EF\u4EE5\u521B\u5EFA\u4EA4\u6613\u8005\u540D\u4E49\u82B1\u8D39\u7684\u4EE3\u5E01\u6570\u3002\r\n *\r\n * \u5141\u8BB8\u53D1\u9001\u8005\u0060_spender\u0060 \u82B1\u8D39\u4E0D\u591A\u4E8E \u0060_value\u0060 \u4E2A\u4EE3\u5E01\r\n *\r\n * @param _spender The address authorized to spend\r\n * @param _value the max amount they can spend\r\n */\r\nfunction approve(address _spender, uint256 _value) public\r\nreturns (bool success) {\r\n\tallowance[msg.sender][_spender] = _value;\r\n\treturn true;\r\n}\r\n\r\n/**\r\n * \u8BBE\u7F6E\u5141\u8BB8\u4E00\u4E2A\u5730\u5740\uFF08\u5408\u7EA6\uFF09\u4EE5\u6211\uFF08\u521B\u5EFA\u4EA4\u6613\u8005\uFF09\u7684\u540D\u4E49\u53EF\u6700\u591A\u82B1\u8D39\u7684\u4EE3\u5E01\u6570\u3002\r\n *\r\n * @param _spender \u88AB\u6388\u6743\u7684\u5730\u5740\uFF08\u5408\u7EA6\uFF09\r\n * @param _value \u6700\u5927\u53EF\u82B1\u8D39\u4EE3\u5E01\u6570\r\n * @param _extraData \u53D1\u9001\u7ED9\u5408\u7EA6\u7684\u9644\u52A0\u6570\u636E\r\n */\r\nfunction approveAndCall(address _spender, uint256 _value, bytes _extraData)\r\n\tpublic\r\n\treturns (bool success) {\r\n\t\ttokenRecipient spender = tokenRecipient(_spender);\r\n\t\tif (approve(_spender, _value)) {\r\n\t\t\t// \u901A\u77E5\u5408\u7EA6\r\n\t\t\tspender.receiveApproval(msg.sender, _value, this, _extraData);\r\n\t\t\treturn true;\r\n\t\t}\r\n\t}\r\n\r\n/**\r\n * \u9500\u6BC1\u6211\uFF08\u521B\u5EFA\u4EA4\u6613\u8005\uFF09\u8D26\u6237\u4E2D\u6307\u5B9A\u4E2A\u4EE3\u5E01\r\n */\r\nfunction burn(uint256 _value) public returns (bool success) {\r\n\trequire(balanceOf[msg.sender] \u003E= _value);   // Check if the sender has enough\r\n\tbalanceOf[msg.sender] -= _value;            // Subtract from the sender\r\n\ttotalSupply -= _value;                      // Updates totalSupply\r\n\tBurn(msg.sender, _value);\r\n\treturn true;\r\n}\r\n\r\n/**\r\n * \u9500\u6BC1\u7528\u6237\u8D26\u6237\u4E2D\u6307\u5B9A\u4E2A\u4EE3\u5E01\r\n *\r\n * Remove \u0060_value\u0060 tokens from the system irreversibly on behalf of \u0060_from\u0060.\r\n *\r\n * @param _from the address of the sender\r\n * @param _value the amount of money to burn\r\n */\r\nfunction burnFrom(address _from, uint256 _value) public returns (bool success) {\r\n\trequire(balanceOf[_from] \u003E= _value);                // Check if the targeted balance is enough\r\n\trequire(_value \u003C= allowance[_from][msg.sender]);    // Check allowance\r\n\tbalanceOf[_from] -= _value;                         // Subtract from the targeted balance\r\n\tallowance[_from][msg.sender] -= _value;             // Subtract from the sender\u0027s allowance\r\n\ttotalSupply -= _value;                              // Update totalSupply\r\n\tBurn(_from, _value);\r\n\treturn true;\r\n}\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_extraData\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022approveAndCall\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022initialSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022tokenName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022tokenSymbol\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"TokenERC20","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000000000000000000000000000000000000572a740000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000009502e426f6f6d696e67000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000035042430000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://5916903d8fecc508de859f6eb068f72b977c5cd8934daeca23d08e80a6c9d56d"}]