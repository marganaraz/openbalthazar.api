[{"SourceCode":"pragma solidity ^0.5.7;\r\n\r\ncontract ApproveAndCallFallBack {\r\n    function receiveApproval(address from, uint256 _amount, address _token, bytes memory _data) public;\r\n}\r\n\r\n\r\n\r\n\r\n\r\ncontract SafeTransfer {\r\n    function _safeTransfer(ERC20Token _token, address _to, uint256 _value) internal returns (bool result) {\r\n        _token.transfer(_to, _value);\r\n        assembly {\r\n        switch returndatasize()\r\n            case 0 {\r\n            result := not(0)\r\n            }\r\n            case 32 {\r\n            returndatacopy(0, 0, 32)\r\n            result := mload(0)\r\n            }\r\n            default {\r\n            revert(0, 0)\r\n            }\r\n        }\r\n        require(result, \u0022Unsuccessful token transfer\u0022);\r\n    }\r\n\r\n    function _safeTransferFrom(\r\n        ERC20Token _token,\r\n        address _from,\r\n        address _to,\r\n        uint256 _value\r\n    ) internal returns (bool result)\r\n    {\r\n        _token.transferFrom(_from, _to, _value);\r\n        assembly {\r\n        switch returndatasize()\r\n            case 0 {\r\n            result := not(0)\r\n            }\r\n            case 32 {\r\n            returndatacopy(0, 0, 32)\r\n            result := mload(0)\r\n            }\r\n            default {\r\n            revert(0, 0)\r\n            }\r\n        }\r\n        require(result, \u0022Unsuccessful token transfer\u0022);\r\n    }\r\n}/* solium-disable security/no-block-members */\r\n/* solium-disable security/no-inline-assembly */\r\n\r\n\r\n\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n     * account.\r\n     */\r\n    constructor () internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Get the contract\u0027s owner\r\n     * @return the address of the owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Only the contract\u0027s owner can invoke this function\u0022);\r\n        _;\r\n    }\r\n\r\n     /**\r\n      * @dev Sets an owner address\r\n      * @param _newOwner new owner address\r\n      */\r\n    function _setOwner(address _newOwner) internal {\r\n        _owner = _newOwner;\r\n    }\r\n\r\n    /**\r\n     * @dev is sender the owner of the contract?\r\n     * @return true if \u0060msg.sender\u0060 is the owner of the contract.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to relinquish control of the contract.\r\n     *      Renouncing to ownership will leave the contract without an owner.\r\n     *      It will not be possible to call the functions with the \u0060onlyOwner\u0060\r\n     *      modifier anymore.\r\n     */\r\n    function renounceOwnership() external onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n     * @param _newOwner The address to transfer ownership to.\r\n     */\r\n    function transferOwnership(address _newOwner) external onlyOwner {\r\n        _transferOwnership(_newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers control of the contract to a newOwner.\r\n     * @param _newOwner The address to transfer ownership to.\r\n     */\r\n    function _transferOwnership(address _newOwner) internal {\r\n        require(_newOwner != address(0), \u0022New owner cannot be address(0)\u0022);\r\n        emit OwnershipTransferred(_owner, _newOwner);\r\n        _owner = _newOwner;\r\n    }\r\n}\r\n\r\n\r\n// Abstract contract for the full ERC 20 Token standard\r\n// https://github.com/ethereum/EIPs/issues/20\r\n\r\ninterface ERC20Token {\r\n\r\n    /**\r\n     * @notice send \u0060_value\u0060 token to \u0060_to\u0060 from \u0060msg.sender\u0060\r\n     * @param _to The address of the recipient\r\n     * @param _value The amount of token to be transferred\r\n     * @return Whether the transfer was successful or not\r\n     */\r\n    function transfer(address _to, uint256 _value) external returns (bool success);\r\n\r\n    /**\r\n     * @notice \u0060msg.sender\u0060 approves \u0060_spender\u0060 to spend \u0060_value\u0060 tokens\r\n     * @param _spender The address of the account able to transfer the tokens\r\n     * @param _value The amount of tokens to be approved for transfer\r\n     * @return Whether the approval was successful or not\r\n     */\r\n    function approve(address _spender, uint256 _value) external returns (bool success);\r\n\r\n    /**\r\n     * @notice send \u0060_value\u0060 token to \u0060_to\u0060 from \u0060_from\u0060 on the condition it is approved by \u0060_from\u0060\r\n     * @param _from The address of the sender\r\n     * @param _to The address of the recipient\r\n     * @param _value The amount of token to be transferred\r\n     * @return Whether the transfer was successful or not\r\n     */\r\n    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);\r\n\r\n    /**\r\n     * @param _owner The address from which the balance will be retrieved\r\n     * @return The balance\r\n     */\r\n    function balanceOf(address _owner) external view returns (uint256 balance);\r\n\r\n    /**\r\n     * @param _owner The address of the account owning tokens\r\n     * @param _spender The address of the account able to transfer the tokens\r\n     * @return Amount of remaining tokens allowed to spent\r\n     */\r\n    function allowance(address _owner, address _spender) external view returns (uint256 remaining);\r\n\r\n    /**\r\n     * @notice return total supply of tokens\r\n     */\r\n    function totalSupply() external view returns (uint256 supply);\r\n\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n}\r\n\r\n\r\n\r\n\r\ncontract Proxiable {\r\n    // Code position in storage is keccak256(\u0022PROXIABLE\u0022) = \u00220xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7\u0022\r\n    event Upgraded(address indexed implementation);\r\n\r\n    function updateCodeAddress(address newAddress) internal {\r\n        require(\r\n            bytes32(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7) == Proxiable(newAddress).proxiableUUID(),\r\n            \u0022Not compatible\u0022\r\n        );\r\n        assembly { // solium-disable-line\r\n            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, newAddress)\r\n        }\r\n        emit Upgraded(newAddress);\r\n    }\r\n    function proxiableUUID() public pure returns (bytes32) {\r\n        return 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;\r\n    }\r\n\r\n    bool internal _initialized;\r\n\r\n    function isInitialized() public view returns(bool) {\r\n        return _initialized;\r\n    }\r\n}\r\n\r\n/**\r\n* @title License\r\n* @dev Contract for buying a license\r\n*/\r\ncontract License is Ownable, ApproveAndCallFallBack, SafeTransfer, Proxiable {\r\n    uint256 public price;\r\n\r\n    ERC20Token token;\r\n    address burnAddress;\r\n\r\n    struct LicenseDetails {\r\n        uint price;\r\n        uint creationTime;\r\n    }\r\n\r\n    address[] public licenseOwners;\r\n    mapping(address =\u003E uint) public idxLicenseOwners;\r\n    mapping(address =\u003E LicenseDetails) public licenseDetails;\r\n\r\n    event Bought(address buyer, uint256 price);\r\n    event PriceChanged(uint256 _price);\r\n    event BurnAddressChanged(address sender, address prevBurnAddress, address newBurnAddress);\r\n\r\n    /**\r\n     * @dev Changes the burn address\r\n     * @param _burnAddress New burn address\r\n     */\r\n    function setBurnAddress(address payable _burnAddress) external onlyOwner {\r\n        emit BurnAddressChanged(msg.sender, burnAddress, _burnAddress);\r\n        burnAddress = _burnAddress;\r\n    }\r\n\r\n    /**\r\n     * @param _tokenAddress Address of token used to pay for licenses (SNT)\r\n     * @param _price Price of the licenses\r\n     * @param _burnAddress Address where the license fee is going to be sent\r\n     */\r\n    constructor(address _tokenAddress, uint256 _price, address _burnAddress) public {\r\n        init(_tokenAddress, _price, _burnAddress);\r\n    }\r\n\r\n    /**\r\n     * @dev Initialize contract (used with proxy). Can only be called once\r\n     * @param _tokenAddress Address of token used to pay for licenses (SNT)\r\n     * @param _price Price of the licenses\r\n     * @param _burnAddress Address where the license fee is going to be sent\r\n     */\r\n    function init(\r\n        address _tokenAddress,\r\n        uint256 _price,\r\n        address _burnAddress\r\n    ) public {\r\n        assert(_initialized == false);\r\n\r\n        _initialized = true;\r\n\r\n        price = _price;\r\n        token = ERC20Token(_tokenAddress);\r\n        burnAddress = _burnAddress;\r\n\r\n        _setOwner(msg.sender);\r\n    }\r\n\r\n    function updateCode(address newCode) public onlyOwner {\r\n        updateCodeAddress(newCode);\r\n    }\r\n\r\n    /**\r\n     * @notice Check if the address already owns a license\r\n     * @param _address The address to check\r\n     * @return bool\r\n     */\r\n    function isLicenseOwner(address _address) public view returns (bool) {\r\n        return licenseDetails[_address].price != 0 \u0026\u0026 licenseDetails[_address].creationTime != 0;\r\n    }\r\n\r\n    /**\r\n     * @notice Buy a license\r\n     * @dev Requires value to be equal to the price of the license.\r\n     *      The msg.sender must not already own a license.\r\n     */\r\n    function buy() external returns(uint) {\r\n        uint id = _buyFrom(msg.sender);\r\n        return id;\r\n    }\r\n\r\n    /**\r\n     * @notice Buy a license\r\n     * @dev Requires value to be equal to the price of the license.\r\n     *      The _owner must not already own a license.\r\n     */\r\n    function _buyFrom(address _licenseOwner) internal returns(uint) {\r\n        require(licenseDetails[_licenseOwner].creationTime == 0, \u0022License already bought\u0022);\r\n\r\n        licenseDetails[_licenseOwner] = LicenseDetails({\r\n            price: price,\r\n            creationTime: block.timestamp\r\n        });\r\n\r\n        uint idx = licenseOwners.push(_licenseOwner);\r\n        idxLicenseOwners[_licenseOwner] = idx;\r\n\r\n        emit Bought(_licenseOwner, price);\r\n\r\n        require(_safeTransferFrom(token, _licenseOwner, burnAddress, price), \u0022Unsuccessful token transfer\u0022);\r\n\r\n        return idx;\r\n    }\r\n\r\n    /**\r\n     * @notice Set the license price\r\n     * @param _price The new price of the license\r\n     * @dev Only the owner of the contract can perform this action\r\n    */\r\n    function setPrice(uint256 _price) external onlyOwner {\r\n        price = _price;\r\n        emit PriceChanged(_price);\r\n    }\r\n\r\n    /**\r\n     * @dev Get number of license owners\r\n     * @return uint\r\n     */\r\n    function getNumLicenseOwners() external view returns (uint256) {\r\n        return licenseOwners.length;\r\n    }\r\n\r\n    /**\r\n     * @notice Support for \u0022approveAndCall\u0022. Callable only by \u0060token()\u0060.\r\n     * @param _from Who approved.\r\n     * @param _amount Amount being approved, need to be equal \u0060price()\u0060.\r\n     * @param _token Token being approved, need to be equal \u0060token()\u0060.\r\n     * @param _data Abi encoded data with selector of \u0060buy(and)\u0060.\r\n     */\r\n    function receiveApproval(address _from, uint256 _amount, address _token, bytes memory _data) public {\r\n        require(_amount == price, \u0022Wrong value\u0022);\r\n        require(_token == address(token), \u0022Wrong token\u0022);\r\n        require(_token == address(msg.sender), \u0022Wrong call\u0022);\r\n        require(_data.length == 4, \u0022Wrong data length\u0022);\r\n\r\n        require(_abiDecodeBuy(_data) == bytes4(0xa6f2ae3a), \u0022Wrong method selector\u0022); //bytes4(keccak256(\u0022buy()\u0022))\r\n\r\n        _buyFrom(_from);\r\n    }\r\n\r\n    /**\r\n     * @dev Decodes abi encoded data with selector for \u0022buy()\u0022.\r\n     * @param _data Abi encoded data.\r\n     * @return Decoded registry call.\r\n     */\r\n    function _abiDecodeBuy(bytes memory _data) internal pure returns(bytes4 sig) {\r\n        assembly {\r\n            sig := mload(add(_data, add(0x20, 0)))\r\n        }\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getNumLicenseOwners\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022idxLicenseOwners\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isInitialized\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_price\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_burnAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022init\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newCode\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022updateCode\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_burnAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setBurnAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022proxiableUUID\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isLicenseOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022licenseDetails\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022price\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022creationTime\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022receiveApproval\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setPrice\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022licenseOwners\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022price\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022buy\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_price\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_burnAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022buyer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Bought\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022PriceChanged\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022prevBurnAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newBurnAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022BurnAddressChanged\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022implementation\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Upgraded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"License","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000744d70fdbe2ba4cf95131626614a1763df805b9e0000000000000000000000000000000000000000000000000de0b6b3a764000000000000000000000000000033534cc18d50ab082324a98ee69a7cce47b75c49","Library":"","SwarmSource":"bzzr://703c9d7661c9d6d7fa2fad398e324ba40af112df85e57b25bd7f45c41ab6ddad"}]