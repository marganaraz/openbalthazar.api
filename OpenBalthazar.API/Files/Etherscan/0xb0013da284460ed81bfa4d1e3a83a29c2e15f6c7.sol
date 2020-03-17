[{"SourceCode":"// File: openzeppelin-solidity/contracts/ownership/Ownable.sol\r\n\r\npragma solidity ^0.4.24;\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n  address private _owner;\r\n\r\n  event OwnershipTransferred(\r\n    address indexed previousOwner,\r\n    address indexed newOwner\r\n  );\r\n\r\n  /**\r\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n  constructor() internal {\r\n    _owner = msg.sender;\r\n    emit OwnershipTransferred(address(0), _owner);\r\n  }\r\n\r\n  /**\r\n   * @return the address of the owner.\r\n   */\r\n  function owner() public view returns(address) {\r\n    return _owner;\r\n  }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(isOwner());\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @return true if \u0060msg.sender\u0060 is the owner of the contract.\r\n   */\r\n  function isOwner() public view returns(bool) {\r\n    return msg.sender == _owner;\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to relinquish control of the contract.\r\n   * @notice Renouncing to ownership will leave the contract without an owner.\r\n   * It will not be possible to call the functions with the \u0060onlyOwner\u0060\r\n   * modifier anymore.\r\n   */\r\n  function renounceOwnership() public onlyOwner {\r\n    emit OwnershipTransferred(_owner, address(0));\r\n    _owner = address(0);\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param newOwner The address to transfer ownership to.\r\n   */\r\n  function transferOwnership(address newOwner) public onlyOwner {\r\n    _transferOwnership(newOwner);\r\n  }\r\n\r\n  /**\r\n   * @dev Transfers control of the contract to a newOwner.\r\n   * @param newOwner The address to transfer ownership to.\r\n   */\r\n  function _transferOwnership(address newOwner) internal {\r\n    require(newOwner != address(0));\r\n    emit OwnershipTransferred(_owner, newOwner);\r\n    _owner = newOwner;\r\n  }\r\n}\r\n\r\n// File: contracts/token/IETokenProxy.sol\r\n\r\n/**\r\n * MIT License\r\n *\r\n * Copyright (c) 2019 eToroX Labs\r\n *\r\n * Permission is hereby granted, free of charge, to any person obtaining a copy\r\n * of this software and associated documentation files (the \u0022Software\u0022), to deal\r\n * in the Software without restriction, including without limitation the rights\r\n * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\r\n * copies of the Software, and to permit persons to whom the Software is\r\n * furnished to do so, subject to the following conditions:\r\n *\r\n * The above copyright notice and this permission notice shall be included in all\r\n * copies or substantial portions of the Software.\r\n *\r\n * THE SOFTWARE IS PROVIDED \u0022AS IS\u0022, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\r\n * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\r\n * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\r\n * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\r\n * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\r\n * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\r\n * SOFTWARE.\r\n */\r\n\r\npragma solidity 0.4.24;\r\n\r\n/**\r\n * @title Interface of an upgradable token\r\n * @dev See implementation for\r\n */\r\ninterface IETokenProxy {\r\n\r\n    /* solium-disable zeppelin/missing-natspec-comments */\r\n\r\n    /* Taken from ERC20Detailed in openzeppelin-solidity */\r\n    function nameProxy(address sender) external view returns(string);\r\n\r\n    function symbolProxy(address sender)\r\n        external\r\n        view\r\n        returns(string);\r\n\r\n    function decimalsProxy(address sender)\r\n        external\r\n        view\r\n        returns(uint8);\r\n\r\n    /* Taken from IERC20 in openzeppelin-solidity */\r\n    function totalSupplyProxy(address sender)\r\n        external\r\n        view\r\n        returns (uint256);\r\n\r\n    function balanceOfProxy(address sender, address who)\r\n        external\r\n        view\r\n        returns (uint256);\r\n\r\n    function allowanceProxy(address sender,\r\n                            address owner,\r\n                            address spender)\r\n        external\r\n        view\r\n        returns (uint256);\r\n\r\n    function transferProxy(address sender, address to, uint256 value)\r\n        external\r\n        returns (bool);\r\n\r\n    function approveProxy(address sender,\r\n                          address spender,\r\n                          uint256 value)\r\n        external\r\n        returns (bool);\r\n\r\n    function transferFromProxy(address sender,\r\n                               address from,\r\n                               address to,\r\n                               uint256 value)\r\n        external\r\n        returns (bool);\r\n\r\n    function mintProxy(address sender, address to, uint256 value)\r\n        external\r\n        returns (bool);\r\n\r\n    function changeMintingRecipientProxy(address sender,\r\n                                         address mintingRecip)\r\n        external;\r\n\r\n    function burnProxy(address sender, uint256 value) external;\r\n\r\n    function burnFromProxy(address sender,\r\n                           address from,\r\n                           uint256 value)\r\n        external;\r\n\r\n    function increaseAllowanceProxy(address sender,\r\n                                    address spender,\r\n                                    uint addedValue)\r\n        external\r\n        returns (bool success);\r\n\r\n    function decreaseAllowanceProxy(address sender,\r\n                                    address spender,\r\n                                    uint subtractedValue)\r\n        external\r\n        returns (bool success);\r\n\r\n    function pauseProxy(address sender) external;\r\n\r\n    function unpauseProxy(address sender) external;\r\n\r\n    function pausedProxy(address sender) external view returns (bool);\r\n\r\n    function finalizeUpgrade() external;\r\n}\r\n\r\n// File: contracts/token/IEToken.sol\r\n\r\n/**\r\n * MIT License\r\n *\r\n * Copyright (c) 2019 eToroX Labs\r\n *\r\n * Permission is hereby granted, free of charge, to any person obtaining a copy\r\n * of this software and associated documentation files (the \u0022Software\u0022), to deal\r\n * in the Software without restriction, including without limitation the rights\r\n * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\r\n * copies of the Software, and to permit persons to whom the Software is\r\n * furnished to do so, subject to the following conditions:\r\n *\r\n * The above copyright notice and this permission notice shall be included in all\r\n * copies or substantial portions of the Software.\r\n *\r\n * THE SOFTWARE IS PROVIDED \u0022AS IS\u0022, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\r\n * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\r\n * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\r\n * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\r\n * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\r\n * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\r\n * SOFTWARE.\r\n */\r\n\r\npragma solidity 0.4.24;\r\n\r\n\r\n/**\r\n * @title EToken interface\r\n * @dev The interface comprising an EToken contract\r\n * This interface is a superset of the ERC20 interface defined at\r\n * https://github.com/ethereum/EIPs/issues/20\r\n */\r\ninterface IEToken {\r\n\r\n    /* solium-disable zeppelin/missing-natspec-comments */\r\n\r\n    function upgrade(IETokenProxy upgradedToken) external;\r\n\r\n    /* Taken from ERC20Detailed in openzeppelin-solidity */\r\n    function name() external view returns(string);\r\n\r\n    function symbol() external view returns(string);\r\n\r\n    function decimals() external view returns(uint8);\r\n\r\n    /* Taken from IERC20 in openzeppelin-solidity */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    function balanceOf(address who) external view returns (uint256);\r\n\r\n    function allowance(address owner, address spender)\r\n        external view returns (uint256);\r\n\r\n    function transfer(address to, uint256 value) external returns (bool);\r\n\r\n    function approve(address spender, uint256 value)\r\n        external\r\n        returns (bool);\r\n\r\n    function transferFrom(address from, address to, uint256 value)\r\n        external\r\n        returns (bool);\r\n\r\n    /* Taken from ERC20Mintable */\r\n    function mint(address to, uint256 value) external returns (bool);\r\n\r\n    /* Taken from ERC20Burnable */\r\n    function burn(uint256 value) external;\r\n\r\n    function burnFrom(address from, uint256 value) external;\r\n\r\n    /* Taken from ERC20Pausable */\r\n    function increaseAllowance(\r\n        address spender,\r\n        uint addedValue\r\n    )\r\n        external\r\n        returns (bool success);\r\n\r\n    function pause() external;\r\n\r\n    function unpause() external;\r\n\r\n    function paused() external view returns (bool);\r\n\r\n    function decreaseAllowance(\r\n        address spender,\r\n        uint subtractedValue\r\n    )\r\n        external\r\n        returns (bool success);\r\n\r\n    event Transfer(\r\n        address indexed from,\r\n        address indexed to,\r\n        uint256 value\r\n    );\r\n\r\n    event Approval(\r\n        address indexed owner,\r\n        address indexed spender,\r\n        uint256 value\r\n    );\r\n\r\n}\r\n\r\n// File: contracts/TokenManager.sol\r\n\r\n/**\r\n * MIT License\r\n *\r\n * Copyright (c) 2019 eToroX Labs\r\n *\r\n * Permission is hereby granted, free of charge, to any person obtaining a copy\r\n * of this software and associated documentation files (the \u0022Software\u0022), to deal\r\n * in the Software without restriction, including without limitation the rights\r\n * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\r\n * copies of the Software, and to permit persons to whom the Software is\r\n * furnished to do so, subject to the following conditions:\r\n *\r\n * The above copyright notice and this permission notice shall be included in all\r\n * copies or substantial portions of the Software.\r\n *\r\n * THE SOFTWARE IS PROVIDED \u0022AS IS\u0022, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\r\n * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\r\n * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\r\n * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\r\n * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\r\n * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\r\n * SOFTWARE.\r\n */\r\n\r\npragma solidity 0.4.24;\r\n\r\n\r\n\r\n/**\r\n * @title The Token Manager contract\r\n * @dev Contract that keeps track of and adds new tokens to list\r\n */\r\ncontract TokenManager is Ownable {\r\n\r\n    /**\r\n     * @dev A TokenEntry defines a relation between an EToken instance and the\r\n     * index of the names list containing the name of the token.\r\n     */\r\n    struct TokenEntry {\r\n        bool exists;\r\n        uint index;\r\n        IEToken token;\r\n    }\r\n\r\n    mapping (bytes32 =\u003E TokenEntry) private tokens;\r\n    bytes32[] private names;\r\n\r\n    event TokenAdded(bytes32 indexed name, IEToken indexed addr);\r\n    event TokenDeleted(bytes32 indexed name, IEToken indexed addr);\r\n    event TokenUpgraded(bytes32 indexed name,\r\n                        IEToken indexed from,\r\n                        IEToken indexed to);\r\n\r\n    /**\r\n     * @dev Require that the token _name exists\r\n     * @param _name Name of token that is looked for\r\n     */\r\n    modifier tokenExists(bytes32 _name) {\r\n        require(_tokenExists(_name), \u0022Token does not exist\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Require that the token _name does not exist\r\n     * @param _name Name of token that is looked for\r\n     */\r\n    modifier tokenNotExists(bytes32 _name) {\r\n        require(!(_tokenExists(_name)), \u0022Token already exist\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Require that the token _iEToken is not null\r\n     * @param _iEToken Token that is checked for\r\n     */\r\n    modifier notNullToken(IEToken _iEToken) {\r\n        require(_iEToken != IEToken(0), \u0022Supplied token is null\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Adds a token to the tokenmanager\r\n     * @param _name Name of the token to be added\r\n     * @param _iEToken Token to be added\r\n     */\r\n    function addToken(bytes32 _name, IEToken _iEToken)\r\n        public\r\n        onlyOwner\r\n        tokenNotExists(_name)\r\n        notNullToken(_iEToken)\r\n    {\r\n        tokens[_name] = TokenEntry({\r\n            index: names.length,\r\n            token: _iEToken,\r\n            exists: true\r\n        });\r\n        names.push(_name);\r\n        emit TokenAdded(_name, _iEToken);\r\n    }\r\n\r\n    /**\r\n     * @dev Deletes a token.\r\n     * @param _name Name of token to be deleted\r\n     */\r\n    function deleteToken(bytes32 _name)\r\n        public\r\n        onlyOwner\r\n        tokenExists(_name)\r\n    {\r\n        IEToken prev = tokens[_name].token;\r\n        delete names[tokens[_name].index];\r\n        delete tokens[_name].token;\r\n        delete tokens[_name];\r\n        emit TokenDeleted(_name, prev);\r\n    }\r\n\r\n    /**\r\n     * @dev Upgrades a token\r\n     * @param _name Name of token to be upgraded\r\n     * @param _iEToken Upgraded version of token\r\n     */\r\n    function upgradeToken(bytes32 _name, IEToken _iEToken)\r\n        public\r\n        onlyOwner\r\n        tokenExists(_name)\r\n        notNullToken(_iEToken)\r\n    {\r\n        IEToken prev = tokens[_name].token;\r\n        tokens[_name].token = _iEToken;\r\n        emit TokenUpgraded(_name, prev, _iEToken);\r\n    }\r\n\r\n    /**\r\n     * @dev Finds a token of the specified name\r\n     * @param _name Name of the token to be returned\r\n     * @return The token of the given name\r\n     */\r\n    function getToken (bytes32 _name)\r\n        public\r\n        tokenExists(_name)\r\n        view\r\n        returns (IEToken)\r\n    {\r\n        return tokens[_name].token;\r\n    }\r\n\r\n    /**\r\n     * @dev Gets all token names\r\n     * @return A list of names\r\n     */\r\n    function getTokens ()\r\n        public\r\n        view\r\n        returns (bytes32[])\r\n    {\r\n        return names;\r\n    }\r\n\r\n    /**\r\n     * @dev Checks whether a token of specified name exists exists\r\n     * in list of tokens\r\n     * @param _name Name of token\r\n     * @return true if a token of the given name exists\r\n     */\r\n    function _tokenExists (bytes32 _name)\r\n        private\r\n        view\r\n        returns (bool)\r\n    {\r\n        return tokens[_name].exists;\r\n    }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_iEToken\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getTokens\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_iEToken\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022upgradeToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022deleteToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022TokenAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022TokenDeleted\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022TokenUpgraded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"TokenManager","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://ef6cb5c37ec7ff86d0ec636d4a33cc7ee0a9c1e90ce6e8731be53c5fe7d4a947"}]