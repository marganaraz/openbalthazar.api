[{"SourceCode":"pragma solidity 0.5.12;\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address previousOwner, address newOwner);\r\n\r\n    /**\r\n     * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n     * account.\r\n     */\r\n    constructor () internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @return the address of the owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner());\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @return true if \u0060msg.sender\u0060 is the owner of the contract.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to relinquish control of the contract.\r\n     * @notice Renouncing to ownership will leave the contract without an owner.\r\n     * It will not be possible to call the functions with the \u0060onlyOwner\u0060\r\n     * modifier anymore.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\ncontract StaticCheckCheezeWizards is Ownable {\r\n\r\n    // Currently on Rinkeby at: 0x108FC97479Ec5E0ab8e68584b3Ea9518BE78BeB4\r\n    // Currently on Mainnet at: (Not deployed yet)\r\n    address cheezeWizardTournamentAddress;\r\n\r\n    // Currently on Rinkeby at: 0x9B814233894Cd227f561B78Cc65891AA55C62Ad2 (OpenSeaAdmin address)\r\n    // Currently on Mainnet at: 0x9B814233894Cd227f561B78Cc65891AA55C62Ad2 (OpenSeaAdmin address)\r\n    address openSeaAdminAddress;\r\n\r\n    constructor (address _cheezeWizardTournamentAddress, address _openSeaAdminAddress) public {\r\n        cheezeWizardTournamentAddress = _cheezeWizardTournamentAddress;\r\n        openSeaAdminAddress = _openSeaAdminAddress;\r\n    }\r\n\r\n    function succeedIfCurrentWizardFingerprintMatchesProvidedWizardFingerprint(uint256 _wizardId, bytes32 _fingerprint, bool checkTxOrigin) public view {\r\n        require(_fingerprint == IBasicTournament(cheezeWizardTournamentAddress).wizardFingerprint(_wizardId));\r\n        if(checkTxOrigin){\r\n            require(openSeaAdminAddress == tx.origin);\r\n        }\r\n    }\r\n\r\n    function changeTournamentAddress(address _newTournamentAddress) external onlyOwner {\r\n        cheezeWizardTournamentAddress = _newTournamentAddress;\r\n    }\r\n\r\n    function changeOpenSeaAdminAddress(address _newOpenSeaAdminAddress) external onlyOwner {\r\n        openSeaAdminAddress = _newOpenSeaAdminAddress;\r\n    }\r\n}\r\n\r\ncontract IBasicTournament {\r\n    function wizardFingerprint(uint256 wizardId) external view returns (bytes32);\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_cheezeWizardTournamentAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_openSeaAdminAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newOpenSeaAdminAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeOpenSeaAdminAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newTournamentAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeTournamentAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_wizardId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_fingerprint\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022checkTxOrigin\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022succeedIfCurrentWizardFingerprintMatchesProvidedWizardFingerprint\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"StaticCheckCheezeWizards","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000dd903896aacc543abeef0deea9b2a27496f762ad0000000000000000000000009b814233894cd227f561b78cc65891aa55c62ad2","Library":"","SwarmSource":"bzzr://3c8813d0c33838051fc7e033ca1b446e4e76f7eb4458ac7e7127bfd0512e2a41"}]