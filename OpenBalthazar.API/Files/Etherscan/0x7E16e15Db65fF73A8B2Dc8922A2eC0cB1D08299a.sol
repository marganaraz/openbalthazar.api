[{"SourceCode":"pragma solidity ^0.6.2;\r\n\r\n\r\ncontract ERC666{\r\n\r\n    Chump chump;\r\n\r\n\r\n    constructor() public{\r\n\r\n        supportedInterfaces[0x80ac58cd] = true;\r\n        supportedInterfaces[0x780e9d63] = true;\r\n        supportedInterfaces[0x5b5e139f] = true;\r\n        supportedInterfaces[0x01ffc9a7] = true;\r\n\r\n        chump = Chump(0x273f7F8E6489682Df756151F5525576E322d51A3);\r\n        \r\n    }\r\n\r\n    /// @dev This emits when ownership of any NFT changes by any mechanism.\r\n    ///  This event emits when NFTs are created (\u0060from\u0060 == 0) and destroyed\r\n    ///  (\u0060to\u0060 == 0). Exception: during contract creation, any number of NFTs\r\n    ///  may be created and assigned without emitting Transfer. At the time of\r\n    ///  any transfer, the approved address for that NFT (if any) is reset to none.\r\n    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);\r\n\r\n    /// @dev This emits when the approved address for an NFT is changed or\r\n    ///  reaffirmed. The zero address indicates there is no approved address.\r\n    ///  When a Transfer event emits, this also indicates that the approved\r\n    ///  address for that NFT (if any) is reset to none.\r\n    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);\r\n\r\n    /// @dev This emits when an operator is enabled or disabled for an owner.\r\n    ///  The operator can manage all NFTs of the owner.\r\n    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);\r\n\r\n\r\n    //////===721 Implementation\r\n    mapping(address =\u003E uint) internal BALANCES;\r\n    mapping (uint256 =\u003E address) internal ALLOWANCE;\r\n    mapping (address =\u003E mapping (address =\u003E bool)) internal AUTHORISED;\r\n\r\n    //    uint total_supply = uint(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF)  * 666;\r\n\r\n    uint total_supply;\r\n\r\n    mapping(uint256 =\u003E address) OWNERS;  //Mapping of ticket owners\r\n\r\n    //    METADATA VARS\r\n    string private __name = \u0022CryptoSatan\u0022;\r\n    string private __symbol = \u0022SATAN\u0022;\r\n    string private __tokenURI = \u0022https://anallergytoanalogy.github.io/beelzebub/metadata/beelzebub.json\u0022;\r\n\r\n\r\n    /// @notice Checks if a given tokenId is valid\r\n    /// @dev If adding the ability to burn tokens, this function will need to reflect that.\r\n    /// @param _tokenId The tokenId to check\r\n    /// @return (bool) True if valid, False if not valid.\r\n    function isValidToken(uint256 _tokenId) internal view returns(bool){\r\n        return _tokenId \u003C total_supply*10;\r\n    }\r\n\r\n\r\n    /// @notice Count all NFTs assigned to an owner\r\n    /// @dev NFTs assigned to the zero address are considered invalid, and this\r\n    ///  function throws for queries about the zero address.\r\n    /// @param _owner An address for whom to query the balance\r\n    /// @return The number of NFTs owned by \u0060_owner\u0060, possibly zero\r\n    function balanceOf(address _owner) external view returns (uint256){\r\n        return BALANCES[_owner];\r\n    }\r\n\r\n    /// @notice Find the owner of an NFT\r\n    /// @param _tokenId The identifier for an NFT\r\n    /// @dev NFTs assigned to zero address are considered invalid, and queries\r\n    ///  about them do throw.\r\n    /// @return The address of the owner of the NFT\r\n    function ownerOf(uint256 _tokenId) public view returns(address){\r\n        require(isValidToken(_tokenId),\u0022invalid\u0022);\r\n        uint innerId = tokenId_to_innerId(_tokenId);\r\n        return OWNERS[innerId];\r\n    }\r\n\r\n    function tokenId_to_innerId(uint _tokenId) internal pure returns(uint){\r\n        return _tokenId /10;\r\n    }\r\n    function innerId_to_tokenId(uint _innerId, uint index) internal pure returns(uint){\r\n        return _innerId * 10 \u002B index;\r\n    }\r\n\r\n    function issue_token(address mintee) internal {\r\n        uint innerId = total_supply;\r\n\r\n        for(uint  i = 0 ; i \u003C 10; i\u002B\u002B){\r\n            emit Transfer(address(0), mintee, innerId*10 \u002B i);\r\n        }\r\n\r\n        OWNERS[innerId] = mintee;\r\n\r\n        BALANCES[mintee] \u002B= 10;\r\n        total_supply\u002B\u002B;\r\n    }\r\n\r\n    function spread() internal{\r\n        uint chumpId = chump.tokenByIndex(total_supply);\r\n        address mintee = chump.ownerOf(chumpId);\r\n        issue_token(mintee);\r\n        issue_token(msg.sender);\r\n    }\r\n    function convert(address convertee) external{\r\n        issue_token(convertee);\r\n    }\r\n\r\n    /// @notice Set or reaffirm the approved address for an NFT\r\n    /// @dev The zero address indicates there is no approved address.\r\n    /// @dev Throws unless \u0060msg.sender\u0060 is the current NFT owner, or an authorized\r\n    ///  operator of the current owner.\r\n    /// @param _approved The new approved NFT controller\r\n    /// @param _tokenId The NFT to approve\r\n    function approve(address _approved, uint256 _tokenId)  external{\r\n        address owner = ownerOf(_tokenId);\r\n        uint innerId = tokenId_to_innerId(_tokenId);\r\n\r\n        require( owner == msg.sender                    //Require Sender Owns Token\r\n        || AUTHORISED[owner][msg.sender]                //  or is approved for all.\r\n        ,\u0022permission\u0022);\r\n        for(uint  i = 0 ; i \u003C 10; i\u002B\u002B){\r\n            emit Approval(owner, _approved, innerId*10 \u002B i);\r\n        }\r\n\r\n        ALLOWANCE[innerId] = _approved;\r\n    }\r\n\r\n    /// @notice Get the approved address for a single NFT\r\n    /// @dev Throws if \u0060_tokenId\u0060 is not a valid NFT\r\n    /// @param _tokenId The NFT to find the approved address for\r\n    /// @return The approved address for this NFT, or the zero address if there is none\r\n    function getApproved(uint256 _tokenId) external view returns (address) {\r\n        require(isValidToken(_tokenId),\u0022invalid\u0022);\r\n        return ALLOWANCE[_tokenId];\r\n    }\r\n\r\n    /// @notice Query if an address is an authorized operator for another address\r\n    /// @param _owner The address that owns the NFTs\r\n    /// @param _operator The address that acts on behalf of the owner\r\n    /// @return True if \u0060_operator\u0060 is an approved operator for \u0060_owner\u0060, false otherwise\r\n    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {\r\n        return AUTHORISED[_owner][_operator];\r\n    }\r\n\r\n\r\n\r\n\r\n    /// @notice Enable or disable approval for a third party (\u0022operator\u0022) to manage\r\n    ///  all your assets.\r\n    /// @dev Emits the ApprovalForAll event\r\n    /// @param _operator Address to add to the set of authorized operators.\r\n    /// @param _approved True if the operators is approved, false to revoke approval\r\n    function setApprovalForAll(address _operator, bool _approved) external {\r\n        emit ApprovalForAll(msg.sender,_operator, _approved);\r\n        AUTHORISED[msg.sender][_operator] = _approved;\r\n    }\r\n\r\n\r\n    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE\r\n    ///  TO CONFIRM THAT \u0060_to\u0060 IS CAPABLE OF RECEIVING NFTS OR ELSE\r\n    ///  THEY MAY BE PERMANENTLY LOST\r\n    /// @dev Throws unless \u0060msg.sender\u0060 is the current owner, an authorized\r\n    ///  operator, or the approved address for this NFT. Throws if \u0060_from\u0060 is\r\n    ///  not the current owner. Throws if \u0060_to\u0060 is the zero address. Throws if\r\n    ///  \u0060_tokenId\u0060 is not a valid NFT.\r\n    /// @param _from The current owner of the NFT\r\n    /// @param _to The new owner\r\n    /// @param _tokenId The NFT to transfer\r\n    function transferFrom(address _from, address _to, uint256 _tokenId) public {\r\n\r\n        uint innerId = tokenId_to_innerId(_tokenId);\r\n\r\n        //Check Transferable\r\n        //There is a token validity check in ownerOf\r\n        address owner = ownerOf(_tokenId);\r\n\r\n        require ( owner == msg.sender             //Require sender owns token\r\n        //Doing the two below manually instead of referring to the external methods saves gas\r\n        || ALLOWANCE[innerId] == msg.sender      //or is approved for this token\r\n        || AUTHORISED[owner][msg.sender]          //or is approved for all\r\n        ,\u0022permission\u0022);\r\n        require(owner == _from,\u0022owner\u0022);\r\n        require(_to != address(0),\u0022zero\u0022);\r\n\r\n\r\n        for(uint  i = 0 ; i \u003C 10; i\u002B\u002B){\r\n            emit Transfer(_from, _to, innerId*10 \u002B i);\r\n        }\r\n\r\n        OWNERS[innerId] =_to;\r\n\r\n        BALANCES[_from] -= 10;\r\n        BALANCES[_to] \u002B= 10;\r\n        \r\n        spread();\r\n\r\n        //Reset approved if there is one\r\n        if(ALLOWANCE[innerId] != address(0)){\r\n            delete ALLOWANCE[innerId];\r\n        }\r\n\r\n    }\r\n\r\n    /// @notice Transfers the ownership of an NFT from one address to another address\r\n    /// @dev Throws unless \u0060msg.sender\u0060 is the current owner, an authorized\r\n    ///  operator, or the approved address for this NFT. Throws if \u0060_from\u0060 is\r\n    ///  not the current owner. Throws if \u0060_to\u0060 is the zero address. Throws if\r\n    ///  \u0060_tokenId\u0060 is not a valid NFT. When transfer is complete, this function\r\n    ///  checks if \u0060_to\u0060 is a smart contract (code size \u003E 0). If so, it calls\r\n    ///  \u0060onERC721Received\u0060 on \u0060_to\u0060 and throws if the return value is not\r\n    ///  \u0060bytes4(keccak256(\u0022onERC721Received(address,address,uint256,bytes)\u0022))\u0060\r\n    /// @param _from The current owner of the NFT\r\n    /// @param _to The new owner\r\n    /// @param _tokenId The NFT to transfer\r\n    /// @param data Additional data with no specified format, sent in call to \u0060_to\u0060\r\n    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public {\r\n        transferFrom(_from, _to, _tokenId);\r\n    }\r\n\r\n    /// @notice Transfers the ownership of an NFT from one address to another address\r\n    /// @dev This works identically to the other function with an extra data parameter,\r\n    ///  except this function just sets data to \u0022\u0022\r\n    /// @param _from The current owner of the NFT\r\n    /// @param _to The new owner\r\n    /// @param _tokenId The NFT to transfer\r\n    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {\r\n        safeTransferFrom(_from,_to,_tokenId,\u0022\u0022);\r\n    }\r\n\r\n\r\n\r\n\r\n    // METADATA FUNCTIONS\r\n\r\n    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.\r\n    /// @dev Throws if \u0060_tokenId\u0060 is not a valid NFT. URIs are defined in RFC\r\n    ///  3986. The URI may point to a JSON file that conforms to the \u0022ERC721\r\n    ///  Metadata JSON Schema\u0022.\r\n    /// @param _tokenId The tokenId of the token of which to retrieve the URI.\r\n    /// @return (string) The URI of the token.\r\n    function tokenURI(uint256 _tokenId) public view returns (string memory){\r\n        //Note: changed visibility to public\r\n        require(isValidToken(_tokenId),\u0022invalid\u0022);\r\n        return __tokenURI;\r\n    }\r\n\r\n    /// @notice A descriptive name for a collection of NFTs in this contract\r\n    function name() external view returns (string memory _name){\r\n        //_name = \u0022Name must be hard coded\u0022;\r\n        return __name;\r\n    }\r\n\r\n    /// @notice An abbreviated name for NFTs in this contract\r\n    function symbol() external view returns (string memory _symbol){\r\n        //_symbol = \u0022Symbol must be hard coded\u0022;\r\n        return __symbol;\r\n    }\r\n\r\n    ///////===165 Implementation\r\n    mapping (bytes4 =\u003E bool) internal supportedInterfaces;\r\n    function supportsInterface(bytes4 interfaceID) external view returns (bool){\r\n        return supportedInterfaces[interfaceID];\r\n    }\r\n    ///==End 165\r\n}\r\n\r\n\r\ninterface Chump {\r\n    function tokenByIndex(uint256 _index) external view returns(uint256);\r\n    function ownerOf(uint256 _tokenId) external view returns(address);\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_approved\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_operator\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_approved\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022ApprovalForAll\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_approved\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022convertee\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022convert\u0022,\u0022outputs\u0022:[],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getApproved\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_operator\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isApprovedForAll\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ownerOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022safeTransferFrom\u0022,\u0022outputs\u0022:[],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022safeTransferFrom\u0022,\u0022outputs\u0022:[],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_operator\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_approved\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setApprovalForAll\u0022,\u0022outputs\u0022:[],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes4\u0022,\u0022name\u0022:\u0022interfaceID\u0022,\u0022type\u0022:\u0022bytes4\u0022}],\u0022name\u0022:\u0022supportsInterface\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022tokenURI\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"ERC666","CompilerVersion":"v0.6.2\u002Bcommit.bacdbe57","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"ipfs://a6ba96b13f5a6342b7e6231905b717466cbb4c5155cd0bd240c97b4c7756b7a7"}]