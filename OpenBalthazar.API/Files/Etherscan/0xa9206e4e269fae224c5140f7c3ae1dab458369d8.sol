[{"SourceCode":"/*\r\n-----------------------------------------------------------------\r\nFILE INFORMATION\r\n-----------------------------------------------------------------\r\n\r\nfile:       EventRecorder.sol\r\nversion:    1.0\r\ndate:       2019-9-12\r\nauthor:     Hamish Ivison\r\n            Dominic Romanowski\r\n\r\n-----------------------------------------------------------------\r\nCONTRACT DESCRIPTION\r\n-----------------------------------------------------------------\r\n\r\nA contract with an owner, that can push arbitrary data to be emitted\r\nas an event.\r\n\r\nThe intention of this contract is to post a merkle tree root hash of\r\na group of events, to ensure that data from an external source can\r\nbe validated as having not been altered.\r\n\r\n-----------------------------------------------------------------\r\n*/\r\npragma solidity 0.5.12;\r\n\r\n/*\r\n-----------------------------------------------------------------\r\nMODULE INFORMATION\r\n-----------------------------------------------------------------\r\n\r\ncontract:   Owned\r\nversion:    1.1\r\ndate:       2018-2-26\r\nauthor:     Anton Jurisevic\r\n            Dominic Romanowski\r\n\r\nAuditors: Sigma Prime - https://github.com/sigp/havven-audit\r\n\r\nA contract with an owner, to be inherited by other contracts.\r\nRequires its owner to be explicitly set in the constructor.\r\nProvides an onlyOwner access modifier.\r\n\r\nTo change owner, the current owner must nominate the next owner,\r\nwho then has to accept the nomination. The nomination can be\r\ncancelled before it is accepted by the new owner by having the\r\nprevious owner change the nomination (setting it to 0).\r\n\r\nIf the ownership is to be relinquished, then it can be handed\r\nto a smart contract whose only function is to accept that\r\nownership, which guarantees no owner-only functionality can\r\never be invoked.\r\n\r\n-----------------------------------------------------------------\r\n*/\r\n\r\n/**\r\n * @title A contract with an owner.\r\n * @notice Contract ownership is transferred by first nominating the new owner,\r\n * who must then accept the ownership, which prevents accidental incorrect ownership transfers.\r\n */\r\ncontract Owned {\r\n    address public owner;\r\n    address public nominatedOwner;\r\n\r\n    /**\r\n     * @dev Owned Constructor\r\n     * @param _owner The initial owner of the contract.\r\n     */\r\n    constructor(address _owner)\r\n        public\r\n    {\r\n        require(_owner != address(0), \u0022Null owner address.\u0022);\r\n        owner = _owner;\r\n        emit OwnerChanged(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @notice Nominate a new owner of this contract.\r\n     * @dev Only the current owner may nominate a new owner.\r\n     * @param _owner The new owner to be nominated.\r\n     */\r\n    function nominateNewOwner(address _owner)\r\n        public\r\n        onlyOwner\r\n    {\r\n        nominatedOwner = _owner;\r\n        emit OwnerNominated(_owner);\r\n    }\r\n\r\n    /**\r\n     * @notice Accept the nomination to be owner.\r\n     */\r\n    function acceptOwnership()\r\n        external\r\n    {\r\n        require(msg.sender == nominatedOwner, \u0022Not nominated.\u0022);\r\n        emit OwnerChanged(owner, nominatedOwner);\r\n        owner = nominatedOwner;\r\n        nominatedOwner = address(0);\r\n    }\r\n\r\n    modifier onlyOwner\r\n    {\r\n        require(msg.sender == owner, \u0022Not owner.\u0022);\r\n        _;\r\n    }\r\n\r\n    event OwnerNominated(address newOwner);\r\n    event OwnerChanged(address oldOwner, address newOwner);\r\n}\r\n\r\n/**\r\n * @title A contract for recording events.\r\n */\r\ncontract EventRecorder is Owned {\r\n\r\n    /**\r\n     * @dev Owned Constructor\r\n     * @param _owner The initial owner of the contract.\r\n     */\r\n    constructor(address _owner) Owned(_owner) public {}\r\n\r\n    /**\r\n     * @notice Post arbitrary data to the blockchain.\r\n     */\r\n    function publishEvent(bytes memory data) public onlyOwner {\r\n        emit IglooEvent(data);\r\n    }\r\n\r\n    event IglooEvent(bytes eventData);\r\n}\r\n\r\n/*\r\n-----------------------------------------------------------------------------\r\nMIT License\r\n\r\nCopyright \u00A9 Havven 2018, Igloo 2019.\r\n\r\nPermission is hereby granted, free of charge, to any person obtaining a copy\r\nof this software and associated documentation files (the \u0022Software\u0022), to deal\r\nin the Software without restriction, including without limitation the rights\r\nto use, copy, modify, merge, publish, distribute, sublicense, and/or sell\r\ncopies of the Software, and to permit persons to whom the Software is\r\nfurnished to do so, subject to the following conditions:\r\n\r\nThe above copyright notice and this permission notice shall be included in\r\nall copies or substantial portions of the Software.\r\n\r\nTHE SOFTWARE IS PROVIDED \u0022AS IS\u0022, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\r\nIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\r\nFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\r\nAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\r\nLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\r\nOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\r\nSOFTWARE.\r\n-----------------------------------------------------------------------------\r\n*/","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022eventData\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022IglooEvent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022oldOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnerChanged\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnerNominated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022nominateNewOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022nominatedOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022publishEvent\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"EventRecorder","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000b10c85274d2a58ddec72c1d826e75256ff93dead","Library":"","SwarmSource":"bzzr://3fe2309ae0dc9888dbb972b560cec2c23511c30f345de82d8adc4bf428f5e5fa"}]