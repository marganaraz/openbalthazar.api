[{"SourceCode":"/****************************************************************************** \r\n * \r\n *                                                                           \r\n *                      ;\u0027\u002B:                                                                         \r\n *                       \u0027\u0027\u0027\u0027\u0027\u0027\u0060                                                                     \r\n *                        \u0027\u0027\u0027\u0027\u0027\u0027\u0027;                                                                   \r\n *                         \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u002B.                                                                \r\n *                          \u002B\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027,                                                              \r\n *                           \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u002B\u0027.                                                            \r\n *                            \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                                                           \r\n *                             \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                                                         \r\n *                             ,\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027.                                                       \r\n *                              \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                                                      \r\n *                               \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                                                     \r\n *                               :\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027.                                                   \r\n *                                \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027;                                                  \r\n *                                .\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                                                 \r\n *                                 \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                                                \r\n *                                 ;\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                                               \r\n *                                  \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u002B\u0027                                              \r\n *                                  \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                                             \r\n *                                  \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027,                                            \r\n *                                  ,\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                                            \r\n *                                   \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                                           \r\n *                                   \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027:                                          \r\n *                                   \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u002B\u0027                                          \r\n *                                   \u0060\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027:                                         \r\n *                                    \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                                         \r\n *                                    .\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027;                                        \r\n *                                    \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0060                                       \r\n *                                     \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                                       \r\n *                                       \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                                      \r\n *                  :                     \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                                     \r\n *                  ,:                     \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                                    \r\n *                  :::.                    \u0027\u0027\u002B\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027:                                  \r\n *                  ,:,,:\u0060        .:::::::,. :\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027.                                \r\n *                   ,,,::::,.,::::::::,:::,::,\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027;                              \r\n *                   :::::::,::,::::::::,,,\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0060                           \r\n *                    :::::::::,::::::::;\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u002B\u0060                         \r\n *                    ,:,::::::::::::,;\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027;                        \r\n *                     :,,:::::::::::\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                       \r\n *                      ::::::::::,\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                      \r\n *                       :,,:,:,:\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0060                     \r\n *                        .;::;\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                     \r\n *                            :\u0027\u002B\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                     \r\n *                                  \u0060\u0060.::;\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027;;:::,..\u0060\u0060\u0060\u0060\u0060,\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027,                    \r\n *                                                                       \u0027\u0027\u0027\u0027\u0027\u0027\u0027;                    \r\n *                                                                         \u0027\u0027\u0027\u0027\u0027\u0027                    \r\n *                           .\u0027\u0027\u0027\u0027\u0027\u0027\u0027;       \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027       \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027   \u0027\u0027\u0027\u0027\u0027                    \r\n *                          \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0060     \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027     ;\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027;  \u0027\u0027\u0027;                    \r\n *                         \u0027\u0027\u0027       \u0027\u0027\u0027\u0060    \u0027\u0027               \u0027\u0027\u0027,      ,\u0027\u0027\u0027  \u0027\u0027:                    \r\n *                        \u0027\u0027\u0027         :      \u0027\u0027              \u0060\u0027\u0027          \u0027\u0027\u0060 :\u0027\u0060                    \r\n *                        \u0027\u0027                 \u0027\u0027              \u0027\u0027:          :\u0027\u0027  \u0027                     \r\n *                        \u0027\u0027                 \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027      \u0027\u0027            \u0027\u0027  \u0027                     \r\n *                       \u0060\u0027\u0027     \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027   \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027      \u0027\u0027            \u0027\u0027                        \r\n *                        \u0027\u0027     \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027:   \u0027\u0027              \u0027\u0027            \u0027\u0027                        \r\n *                        \u0027\u0027           \u0027\u0027    \u0027\u0027              \u0027\u0027\u0027          \u0027\u0027\u0027                        \r\n *                        \u0027\u0027\u0027         \u0027\u0027\u0027    \u0027\u0027               \u0027\u0027\u0027        \u0027\u0027\u0027                         \r\n *                         \u0027\u0027\u0027.     .\u0027\u0027\u0027     \u0027\u0027                \u0027\u0027\u0027.    .\u0027\u0027\u0027                         \r\n *                          \u0060\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027      \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0060    \u0060\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027                          \r\n *                            \u0027\u0027\u0027\u0027\u0027\u0027\u0027        \u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0027\u0060      .\u0027\u0027\u0027\u0027\u0027\u0027.                            \r\n *\r\n * *********************************************************************************************/\r\npragma solidity ^0.5.0;\r\n// ---------------------------------------------------------------------------------------------\r\n// \u0027iBlockchain Bank \u0026 Trust\u2122\u0027 ERC20 Security Token (Common Share)\r\n//\r\n// Symbol           : iBBTs\r\n// Trademarks (tm)  : iBBTs\u2122 , IBBTS\u2122 , iBlockchain Bank \u0026 Trust\u2122 , Decentralised Autonomous Corporation\u2122 , DAC\u2122\r\n// Name             : Share/Comon Stock/Security Token\r\n// Total supply     : 10,000,000 (Million)\r\n// Decimals         : 2\r\n// Implementation   : Decentralised Autonomous Corporation (DAC)\r\n// Github           : https://github.com/Geopay/iBlockchain-Bank-and-Trust-Security-Token\r\n// Beta Platform    : https://myetherbanktrust.com/asset-class/primary-market/smart-securities/\r\n//\r\n// (c) by A. Valamontes with Blockchain Ventures / Geopay.me Inc 2013-2019. Affero GPLv3 Licence.\r\n// --\r\n\r\n\r\nlibrary SafeMath {\r\n  function add(uint a, uint b) internal pure returns (uint c) {\r\n    c = a \u002B b;\r\n    require(c \u003E= a);\r\n  }\r\n  \r\n  function sub(uint a, uint b) internal pure returns (uint c) {\r\n    require(b \u003C= a);\r\n    c = a - b;\r\n  }\r\n\r\n  function mul(uint a, uint b) internal pure returns (uint c) {\r\n    c = a * b;\r\n    require(a == 0 || c / a == b);\r\n  }\r\n\r\n  function div(uint a, uint b) internal pure returns (uint c) {\r\n    require(b \u003E 0);\r\n    c = a / b;\r\n  }\r\n}\r\n\r\n// (c) by A. Valamontes with Blockchain Ventures / Geopay.me Inc 2013-2019. Affero GPLv3 Licence.\r\n// ----------------------------------------------------------------------------------------------\r\n\r\ncontract Nonpayable {\r\n\r\n  // --------------------------------------------------------------------------------------------\r\n  // Don\u0027t accept ETH\r\n  // --------------------------------------------------------------------------------------------\r\n  function () external payable {\r\n    revert();\r\n  }\r\n}\r\n\r\ncontract Ownable {\r\n  address public owner;\r\n\r\n  constructor() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  modifier onlyOwner {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  function DissolveBusiness() public onlyOwner { \r\n    // This function is called when the organization is no longer actively operating\r\n    // The Management can decide to Terminate access to the Securities Token. \r\n    // The Blockchain records remain, but the contract no longer can perform functions pertaining \r\n    // to the operations of the Securities.\r\n    // https://www.irs.gov/businesses/small-businesses-self-employed/closing-a-business-checklist\r\n    selfdestruct(msg.sender);\r\n  }\r\n}\r\n\r\n// (c) by A. Valamontes with Blockchain Ventures / Geopay.me Inc 2013-2019. Affero GPLv3 Licence.\r\n// ----------------------------------------------------------------------------------------------\r\n\r\n// ----------------------------------------------------------------------------------------------\r\n// ERC Token Standard #20 Interface\r\n// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md\r\n// ----------------------------------------------------------------------------------------------\r\ncontract ERC20Interface {\r\n    function totalSharesIssued() public returns (uint);\r\n    function balanceOf(address tokenOwner) public returns (uint balance);\r\n    function allowance(address tokenOwner, address spender) public returns (uint remaining);\r\n    function transfer(address to, uint tokens) public returns (bool success);\r\n    function approve(address spender, uint tokens) public returns (bool success);\r\n    function transferFrom(address from, address to, uint tokens) public returns (bool success);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint tokens);\r\n    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);\r\n}\r\n\r\ncontract Regulated is Ownable {\r\n    \r\n  event ShareholderRegistered(address indexed shareholder);\r\n  event CorpBlackBook(address indexed shareholder);           // Consider this option as the Nevada Commission little black book, bad actors are blacklisted \r\n  \r\n  mapping(address =\u003E bool) regulationStatus;\r\n\r\n  function RegisterShareholder(address shareholder) public onlyOwner {\r\n    regulationStatus[shareholder] = true;\r\n    emit ShareholderRegistered(shareholder);\r\n  }\r\n\r\n  function NevadaBlackBook(address shareholder) public onlyOwner {\r\n    regulationStatus[shareholder] = false;\r\n    emit CorpBlackBook(shareholder);\r\n  }\r\n  \r\n  function ensureRegulated(address shareholder) public view  {\r\n    require(regulationStatus[shareholder] == true);\r\n  }\r\n\r\n  function isRegulated(address shareholder) public view returns (bool approved) { \r\n    return regulationStatus[shareholder];\r\n  }\r\n}\r\n// (c) by A. Valamontes with Blockchain Ventures / Geopay.me Inc 2013-2019. Affero GPLv3 Licence.\r\n// ----------------------------------------------------------------------------------------------\r\ncontract  AcceptEth is Regulated {\r\n    address public owner;\r\n    address newOwner;\r\n    uint public price;\r\n    mapping (address =\u003E uint) balance;\r\n\r\n    constructor() public {\r\n        // set owner as the address of the one who created the contract\r\n        owner = msg.sender;\r\n        // set the price to 2 ether\r\n        price = 0.00372805 ether; // Exclude Gas/Wei to transfer\r\n        \r\n    }\r\n\r\n    function accept() public payable onlyOwner {\r\n\r\n        // Error out if anything other than 2 ether is sent\r\n        require(msg.value == price);\r\n        \r\n        require(newOwner != address(0));\r\n        require(newOwner != owner);\r\n   \r\n        RegisterShareholder(owner);\r\n        \r\n        regulationStatus[owner] = true;\r\n        emit ShareholderRegistered(owner);        \r\n \r\n\r\n        // Track that calling account deposited ether\r\n        balance[msg.sender] \u002B= msg.value;\r\n    }\r\n    \r\n    function refund(uint amountRequested) public onlyOwner {\r\n        \r\n        require(newOwner != address(0));\r\n        require(newOwner != owner);\r\n   \r\n        RegisterShareholder(owner);\r\n        \r\n        regulationStatus[owner] = true;\r\n        \r\n        emit ShareholderRegistered(owner);\r\n        \r\n        require(amountRequested \u003E 0 \u0026\u0026 amountRequested \u003C= balance[msg.sender]);\r\n        \r\n\r\n        balance[msg.sender] -= amountRequested;\r\n\r\n        msg.sender.transfer(amountRequested); // contract transfers ether to msg.sender\u0027s address\r\n        \r\n        \r\n    }\r\n    \r\n    event Accept(address from, address indexed to, uint amountRequested);\r\n    event Refund(address to, address indexed from, uint amountRequested);\r\n}\r\n\r\ncontract ERC20 {\r\n  function totalSupply() public returns (uint);\r\n  function balanceOf(address tokenOwner) public returns (uint balance);\r\n  function allowance(address tokenOwner, address spender) public returns (uint remaining);\r\n  function transfer(address to, uint tokens) public returns (bool success);\r\n  function approve(address spender, uint tokens) public returns (bool success);\r\n  function transferFrom(address from, address to, uint tokens) public returns (bool success);\r\n  \r\n  \r\n// \u0022Increases total supply of the token by value and credits it to address owner.\u0022\r\n//  function increaseShares(uint256 value, address to) returns (bool);\r\n\r\n// \u0022Decreases total supply by value and withdraws it from address owner if it has a sufficient balance.\u0022\r\n//  function decreaseShares(uint256 value, address from) returns (bool);\r\n// (c) by A. Valamontes with Blockchain Ventures / Geopay.me Inc 2013-2019. Affero GPLv3 Licence.\r\n// ----------------------------------------------------------------------------------------------\r\n\r\n\r\n  event Transfer(address indexed from, address indexed to, uint tokens);\r\n  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);\r\n}\r\n\r\ncontract iBBTs is ERC20, Regulated, AcceptEth {\r\n  using SafeMath for uint;\r\n\r\n  string public symbol;\r\n  string public  name;\r\n  uint8 public decimals;\r\n  uint public _totalShares;\r\n\r\n  mapping(address =\u003E uint) balances;\r\n  mapping(address =\u003E mapping(address =\u003E uint)) allowed;\r\n\r\n  constructor() public {\r\n// (c) by A. Valamontes with Blockchain Ventures / Geopay.me Inc 2013-2019. Affero GPLv3 Licence.\r\n// ----------------------------------------------------------------------------------------------\r\n    symbol = \u0022iBBTs\u0022;                                             // Create the Security Token Symbol Here\r\n    name = \u0022iBlockchain Bank and Trust Securities/Share Token \u0022;  // Description of the Securetized Tokens\r\n    // In our sample we have created securites tokens and fractional securities for the tokens upto 18 digits\r\n    decimals = 2;                                                 // Number of Digits [0-18] If an organization wants to fractionalize the securities\r\n    // The 0 can be any digit up to 18. Eighteen is the standard for cryptocurrencies\r\n    _totalShares = 10000000 * 10**uint(decimals);                // Total Number of Securities Issued (example 10,000,000 Shares of iBBTs)\r\n    balances[owner] = _totalShares;\r\n    emit Transfer(address(0), owner, _totalShares);               // Owner or Company Representative (CFO/COO/CEO/CHAIRMAN)\r\n\r\n    regulationStatus[owner] = true;\r\n    emit ShareholderRegistered(owner);\r\n  }\r\n\r\n  function issue(address recipient, uint tokens) public onlyOwner returns (bool success) {\r\n    require(recipient != address(0));\r\n    require(recipient != owner);\r\n    \r\n    RegisterShareholder(recipient);\r\n    transfer(recipient, tokens);\r\n    return true;\r\n  }\r\n\r\n  function transferOwnership(address newOwner) public onlyOwner {\r\n    // Organization is Merged or Sold and Securities Management needs to transfer to new owners\r\n    require(newOwner != address(0));\r\n    require(newOwner != owner);\r\n   \r\n    RegisterShareholder(newOwner);\r\n    transfer(newOwner, balances[owner]);\r\n    owner = newOwner;\r\n  }\r\n\r\n  function totalSupply() public returns (uint supply) {\r\n    return _totalShares - balances[address(0)];\r\n  }\r\n\r\n  function balanceOf(address tokenOwner) public returns (uint balance) {\r\n    return balances[tokenOwner];\r\n  }\r\n\r\n  function transfer(address to, uint tokens) public returns (bool success) {\r\n    ensureRegulated(msg.sender);\r\n    ensureRegulated(to);\r\n    \r\n    balances[msg.sender] = balances[msg.sender].sub(tokens);\r\n    balances[to] = balances[to].add(tokens);\r\n    emit Transfer(msg.sender, to, tokens);\r\n    return true;\r\n  }\r\n\r\n  function approve(address spender, uint tokens) public returns (bool success) {\r\n    // Put a check for race condition issue with approval workflow of ERC20\r\n    require((tokens == 0) || (allowed[msg.sender][spender] == 0));\r\n    \r\n    allowed[msg.sender][spender] = tokens;\r\n    emit Approval(msg.sender, spender, tokens);\r\n    return true;\r\n  }\r\n\r\n  function transferFrom(address from, address to, uint tokens) public returns (bool success) {\r\n    ensureRegulated(from);\r\n    ensureRegulated(to);\r\n\r\n    balances[from] = balances[from].sub(tokens);\r\n    allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);\r\n    balances[to] = balances[to].add(tokens);\r\n    emit Transfer(from, to, tokens);\r\n    return true;\r\n  }\r\n\r\n  function allowance(address tokenOwner, address spender) public returns (uint remaining) {\r\n    return allowed[tokenOwner][spender];\r\n  }\r\n\r\n  // --------------------------------------------------------------------------------------------\r\n  // Corporation can issue more shares or revoce/cancel shares\r\n  // https://github.com/ethereum/EIPs/pull/621\r\n  // --------------------------------------------------------------------------------------------\r\n  \r\n  // --------------------------------------------------------------------------------------------\r\n  // Owner can transfer out any accidentally sent ERC20 tokens\r\n  // --------------------------------------------------------------------------------------------\r\n  function transferOtherERC20Assets(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {\r\n        return ERC20Interface(tokenAddress).transfer(owner, tokens);\r\n  }\r\n}\r\n// (c) by A. Valamontes with Blockchain Ventures / Geopay.me Inc 2013-2019. Affero GPLv3 Licence.\r\n// ----------------------------------------------------------------------------------------------","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferOtherERC20Assets\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022supply\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022shareholder\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022RegisterShareholder\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amountRequested\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022refund\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022accept\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DissolveBusiness\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022issue\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022shareholder\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022NevadaBlackBook\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022price\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_totalShares\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022shareholder\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isRegulated\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022approved\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022shareholder\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022ensureRegulated\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amountRequested\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Accept\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amountRequested\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Refund\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022shareholder\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022ShareholderRegistered\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022shareholder\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022CorpBlackBook\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"iBBTs","CompilerVersion":"v0.5.0\u002Bcommit.1d4f565a","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://e78240b6671a2eae2683fb646903ce3f87eb7e6b5ef835fba2cf4dc20e6bdc2a"}]