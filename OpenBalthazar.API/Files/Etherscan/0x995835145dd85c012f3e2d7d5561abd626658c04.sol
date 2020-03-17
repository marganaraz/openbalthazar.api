[{"SourceCode":"pragma solidity ^0.5.8;\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Unsigned math operations with safety checks that revert on error\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n    * @dev Multiplies two unsigned integers, reverts on overflow.\r\n    */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.\r\n    */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n    */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Adds two unsigned integers, reverts on overflow.\r\n    */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),\r\n    * reverts when dividing by zero.\r\n    */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n/// @title WrappedNFTLiquidationProxy accompanies WrappedNFT and WrappedNFTFactory. This contract\r\n///  allows you to send a mixed bundle of NFT\u2019s to a single address, wraps them appropriately, and\r\n///  liquidates them with Uniswap, as well as allowing you to purchase random NFTs with ETH by\r\n///  grabbing wrapped-NFTs from Uniswap and converting them back into the underlying NFT.\r\n\r\ncontract WrappedNFTLiquidationProxy {\r\n\r\n    // OpenZeppelin\u0027s SafeMath library is used for all arithmetic operations to avoid overflows/underflows.\r\n    using SafeMath for uint256;\r\n\r\n    /* ****** */\r\n    /* EVENTS */\r\n    /* ****** */\r\n\r\n    /// @dev This event is fired when a user atomically wraps tokens from ERC721s\r\n    ///  to ERC20s and then atomically sells the ERC20s to Uniswap in the same\r\n    ///  transaction.\r\n    /// @param numTokensMelted The number of NFTs that were liquified\r\n    /// @param nftContractAddress The core contract address of the NFTs that were\r\n    ///  liquified.\r\n    /// @param ethReceived The amount of ETH (in wei) that was sent to the User in\r\n    ///  exchange for their NFTs.\r\n    event LiquidateNFTs(\r\n        uint256 numTokensMelted,\r\n        address nftContractAddress,\r\n        uint256 ethReceived\r\n    );\r\n\r\n    /// @dev This event is fired when a user atomically buys WNFT ERC20 tokens\r\n    ///  from Uniswap and subsequently converts them back into ERC721s in the\r\n    ///  same transaction.\r\n    /// @param numTokensBought The number of NFTs that were purchased\r\n    /// @param nftContractAddress The core contract address of the NFTs that were\r\n    ///  purchased.\r\n    /// @param ethSpent The amount of ETH (in wei) that was sent from the User to\r\n    ///  Uniswap in exchange for the NFTs that they received.\r\n    event PurchaseNFTs(\r\n        uint256 numTokensBought,\r\n        address nftContractAddress,\r\n        uint256 ethSpent\r\n    );\r\n\r\n    /// @dev This event is fired when a user wraps a bundle of NFTs from ERC721s\r\n    ///  into ERC20s\r\n    /// @param numTokensWrapped The number of NFTs that were wrapped\r\n    /// @param nftContractAddress The core contract address of the NFTs that were\r\n    ///  wrapped.\r\n    event WrapNFTs(\r\n        uint256 numTokensWrapped,\r\n        address nftContractAddress\r\n    );\r\n\r\n    /// @dev This event is fired when a user unwraps a bundle of NFTs from ERC20s\r\n    ///  into ERC721s\r\n    /// @param numTokensUnwrapped The number of NFTs that were unwrapped\r\n    /// @param nftContractAddress The core contract address of the NFTs that were\r\n    ///  unwrapped.\r\n    event UnwrapNFTs(\r\n        uint256 numTokensUnwrapped,\r\n        address nftContractAddress\r\n    );\r\n\r\n    /* ********* */\r\n    /* CONSTANTS */\r\n    /* ********* */\r\n\r\n    /// @dev This contract\u0027s instance of the WrappedNFTFactory contract\r\n    address public wrappedNFTFactoryAddress;\r\n    WrappedNFTFactory private wrappedNFTFactory;\r\n\r\n    /// @dev This contract\u0027s instance of the UniswapFactory contract\r\n    address public uniswapFactoryAddress;\r\n    UniswapFactory private uniswapFactory;\r\n\r\n    /// @dev The address of the wrappedKitties contract, used in our internal functions\r\n    ///  in order to specify the correct function call name for depositNftsAndMintTokens,\r\n    ///  since the WrappedKitties contract uses slightly different wording in its function\r\n    ///  calls.\r\n    address private wrappedKittiesAddress = 0x09fE5f0236F0Ea5D930197DCE254d77B04128075;\r\n\r\n    /* ********* */\r\n    /* FUNCTIONS */\r\n    /* ********* */\r\n\r\n    /// @dev This function allows aa user to atomically wrap tokens from ERC721s\r\n    ///  to ERC20s and then atomically sell the ERC20s to Uniswap in the same\r\n    ///  transaction.\r\n    /// @param _nftIds The array of ids of the NFT tokens.\r\n    /// @param _nftContractAddresses The nftCore addresses for each of the respective tokens.\r\n    /// @param _isMixedBatchOfNFTs A flag indicating whether all of the NFTs originate from\r\n    ///  the same NFTCore contract or not\r\n    /// @param _uniswapSlippageAllowedInBasisPoints A percentage (measured in hundreths of a\r\n    ///  percent), of how much slippage is tolerated when the wrapped NFTs are sold on Uniswap.\r\n    ///  If Uniswap is would cause more slippage (or this call has been frontrun), then this\r\n    ///  this call will revert.\r\n    function liquidateNFTs(uint256[] memory _nftIds, address[] memory _nftContractAddresses, bool _isMixedBatchOfNFTs, uint256 _uniswapSlippageAllowedInBasisPoints) public {\r\n        require(_nftIds.length == _nftContractAddresses.length, \u0027you did not provide an nftContractAddress for each of the groups of NFTs that you wish to liquidate\u0027);\r\n        require(_nftIds.length \u003E 0, \u0027you must submit an array with at least one element\u0027);\r\n\r\n        for(uint i = 0; i \u003C _nftIds.length; i\u002B\u002B){\r\n            // Transfer NFTs from User to Proxy, since only the owner of the token can call depositNftsAndMintTokens.\r\n            NFTCore(_nftContractAddresses[i]).transferFrom(msg.sender, address(this), _nftIds[i]);\r\n\r\n            // If we are melting an array of NFTs that come from different NFTCore contracts, then we\r\n            //  call wrapAndLiquidate one by one, since each NFT has a different corresponding wrapper\r\n            //  contract and uniswap contract\r\n            if(_isMixedBatchOfNFTs){\r\n                uint256[] memory nftIdArray = new uint256[](1);\r\n                nftIdArray[0] = _nftIds[i];\r\n                _wrapAndLiquidateArrayOfNfts(nftIdArray, _nftContractAddresses[i], msg.sender, _uniswapSlippageAllowedInBasisPoints);\r\n            }\r\n        }\r\n        // If we are melting an array of NFTs that come from the same NFTCore contract, then we call\r\n        //  wrapAndLiquidate together in a bundle to save gas, since they share the same wrapper contract\r\n        //  and the same uniswap contract.\r\n        if(!_isMixedBatchOfNFTs){\r\n            _wrapAndLiquidateArrayOfNfts(_nftIds, _nftContractAddresses[0], msg.sender, _uniswapSlippageAllowedInBasisPoints);\r\n        }\r\n    }\r\n\r\n    /// @dev This function allows a user atomically to buy WNFT ERC20 tokens\r\n    ///  from Uniswap and subsequently convert them back into ERC721s in the\r\n    ///  same transaction.\r\n    /// @param _nftContractAddress The nftCore addresses for the tokens to be purchased\r\n    /// @param _numTokensToPurchase The number of NFTs to be purchased.\r\n    function purchaseNFTs(address _nftContractAddress, uint256 _numTokensToPurchase) payable external {\r\n        require(_numTokensToPurchase \u003E 0, \u0027you need to purchase at least one full NFT\u0027);\r\n\r\n        address wrapperContractAddress = wrappedNFTFactory.getWrapperContractForNFTContractAddress(_nftContractAddress);\r\n        address uniswapAddress = uniswapFactory.getExchange(wrapperContractAddress);\r\n\r\n        // Buy tokens from Uniswap\r\n        uint256 inputEth = msg.value;\r\n        uint256 ethRequired = UniswapExchange(uniswapAddress).getEthToTokenOutputPrice(_numTokensToPurchase.mul(10**18));\r\n        require(inputEth \u003E= ethRequired, \u0027you did not submit enough ETH to purchase the number of NFTs that you requested\u0027);\r\n        uint256 ethSpent = UniswapExchange(uniswapAddress).ethToTokenSwapOutput.value(msg.value)(_numTokensToPurchase.mul(10**18), ~uint256(0));\r\n\r\n        // Unwrap ERC20s to ERC721s And Send ERC721s To User\r\n        uint256[] memory tokenIds = new uint256[](_numTokensToPurchase);\r\n        address[] memory destinationAddresses = new address[](_numTokensToPurchase);\r\n        for(uint i = 0; i \u003C _numTokensToPurchase; i\u002B\u002B){\r\n            tokenIds[i] = 0;\r\n            destinationAddresses[i] = msg.sender;\r\n        }\r\n        _burnTokensAndWithdrawNfts(wrapperContractAddress, tokenIds, destinationAddresses);\r\n\r\n        // Refund the user for any remaining ETH that wasn\u0027t spent on Uniswap\r\n        msg.sender.transfer(inputEth.sub(ethSpent));\r\n\r\n        emit PurchaseNFTs(_numTokensToPurchase, _nftContractAddress, ethSpent);\r\n    }\r\n\r\n        /// @dev This function allows a user to wrap a bundle of NFTs from ERC721s\r\n    ///  into ERC20s, even if they come from different nftCore contracts\r\n    /// @param _nftIds The array of ids of the NFT tokens.\r\n    /// @param _nftContractAddresses The nftCore addresses for each of the respective tokens.\r\n    /// @param _isMixedBatchOfNFTs A flag indicating whether all of the NFTs originate from the same NFTCore contract or not\r\n    function wrapNFTs(uint256[] calldata _nftIds, address[] calldata _nftContractAddresses, bool _isMixedBatchOfNFTs) external {\r\n        require(_nftIds.length == _nftContractAddresses.length, \u0027you did not provide an nftContractAddress for each of the groups of NFTs that you wish to wrap\u0027);\r\n        require(_nftIds.length \u003E 0, \u0027you must submit an array with at least one element\u0027);\r\n\r\n        for(uint i = 0; i \u003C _nftIds.length; i\u002B\u002B){\r\n            address wrapperContractAddress = wrappedNFTFactory.getWrapperContractForNFTContractAddress(_nftContractAddresses[i]);\r\n\r\n            // Transfer NFTs from User to Proxy, since only the owner of the token can call depositNftsAndMintTokens.\r\n            NFTCore(_nftContractAddresses[i]).transferFrom(msg.sender, address(this), _nftIds[i]);\r\n            NFTCore(_nftContractAddresses[i]).approve(wrapperContractAddress, _nftIds[i]);\r\n\r\n            // If we are wrapping an array of NFTs that come from different NFTCore contracts, then we\r\n            //  call depositNftsAndMintTokens one by one, since each NFT has a different corresponding\r\n            //  wrapper contract\r\n            if(_isMixedBatchOfNFTs){\r\n                // Convert NFTs from ERC721 to ERC20\r\n                uint256[] memory nftIdArray = new uint256[](1);\r\n                nftIdArray[0] = _nftIds[i];\r\n\r\n                _depositNFTsAndMintTokens(wrapperContractAddress, nftIdArray);\r\n                WrappedNFT(wrapperContractAddress).transfer(msg.sender, (10**18));\r\n                emit WrapNFTs(1, _nftContractAddresses[i]);\r\n            }\r\n        }\r\n        // If we are wrapping an array of NFTs that come from the same NFTCore contract, then we call\r\n        //  depositNftsAndMintTokens together in a bundle to save gas, since they share the same wrapper\r\n        //  contract.\r\n        if(!_isMixedBatchOfNFTs){\r\n            address wrapperContractAddress = wrappedNFTFactory.getWrapperContractForNFTContractAddress(_nftContractAddresses[0]);\r\n            // Convert NFTs from ERC721 to ERC20\r\n            _depositNFTsAndMintTokens(wrapperContractAddress, _nftIds);\r\n            WrappedNFT(wrapperContractAddress).transfer(msg.sender, (_nftIds.length).mul(10**18));\r\n            emit WrapNFTs(_nftIds.length, _nftContractAddresses[0]);\r\n        }\r\n    }\r\n\r\n    /// @dev This function allows a user to unwraps a bundle of NFTs from ERC20s\r\n    ///  into ERC721s, even if they come from different NFTCore contracts\r\n    /// @param _nftIds The array of ids of the NFT tokens.\r\n    /// @param _nftContractAddresses The nftCore addresses for each of the respective tokens.\r\n    /// @param _destinationAddresses The destination addresses for where each of the unwrapped NFTs should be sent (this\r\n    ///  is specified on a per-token basis the wrappedNFT contract to allow for the ability to \u0022airdrop\u0022 tokens to many\r\n    ///  addresses in a single transaction).\r\n    /// @param _isMixedBatchOfNFTs A flag indicating whether all of the NFTs originate from the same NFTCore contract or not\r\n    function unwrapNFTs(uint256[] calldata _nftIds, address[] calldata _nftContractAddresses, address[] calldata _destinationAddresses, bool _isMixedBatchOfNFTs) external {\r\n        require(_nftIds.length == _nftContractAddresses.length, \u0027you did not provide an nftContractAddress for each of the groups of NFTs that you wish to unwrap\u0027);\r\n        require(_nftIds.length \u003E 0, \u0027you must submit an array with at least one element\u0027);\r\n\r\n        if(_isMixedBatchOfNFTs){\r\n             // If we are unwrapping a mixed batch of NFTs, then we need to unwrap them one at a time,\r\n            //  since each comes from a different NFTCore contract with a different corresponding\r\n            for(uint i = 0; i \u003C _nftIds.length; i\u002B\u002B){\r\n                // Convert NFTs from ERC20 to ERC721\r\n                address wrapperContractAddress = wrappedNFTFactory.getWrapperContractForNFTContractAddress(_nftContractAddresses[i]);\r\n                WrappedNFT(wrapperContractAddress).transferFrom(msg.sender, address(this), (10**18));\r\n\r\n                uint256[] memory nftIdArray = new uint256[](1);\r\n                nftIdArray[0] = _nftIds[i];\r\n\r\n                address[] memory destinationAddressesArray = new address[](1);\r\n                destinationAddressesArray[0] = _destinationAddresses[i];\r\n\r\n                _burnTokensAndWithdrawNfts(wrapperContractAddress, nftIdArray, destinationAddressesArray);\r\n                emit UnwrapNFTs(1, _nftContractAddresses[i]);\r\n            }\r\n        } else if(!_isMixedBatchOfNFTs){\r\n            // If we are unwrapping an array of NFTs that come from the same NFTCore contract, then we call\r\n            //  burnTokensAndWithdrawNfts together in a bundle to save gas, since they share the same wrapper\r\n            //  contract.\r\n\r\n            // Convert NFTs from ERC20 to ERC721\r\n            address wrapperContractAddress = wrappedNFTFactory.getWrapperContractForNFTContractAddress(_nftContractAddresses[0]);\r\n            WrappedNFT(wrapperContractAddress).transferFrom(msg.sender, address(this), _nftIds.length.mul(10**18));\r\n            _burnTokensAndWithdrawNfts(wrapperContractAddress, _nftIds, _destinationAddresses);\r\n            emit UnwrapNFTs(_nftIds.length, _nftContractAddresses[0]);\r\n        }\r\n    }\r\n\r\n    /// @dev If a user sends an NFT from nftCoreContract directly to this contract using a\r\n    ///  transfer function that implements onERC721Received, then we will call liquidateNFTs().\r\n    ///  The reason that we call liquidateNFTs() and not wrapNFTs() is that they can use\r\n    ///  OnERC721Received to wrap kitties using the corresponding Wrapped NFT contract for this\r\n    ///  NFT.\r\n    /// @notice The contract address is always the message sender.\r\n    /// @param _operator The address which called \u0060safeTransferFrom\u0060 function\r\n    /// @param _from The address which previously owned the token\r\n    /// @param _tokenId The NFT identifier which is being transferred\r\n    /// @param _data Additional data with no specified format\r\n    /// @return \u0060bytes4(keccak256(\u0022onERC721Received(address,address,uint256,bytes)\u0022))\u0060 to indicate that\r\n    ///  this contract is written in such a way to be prepared to receive ERC721 tokens.\r\n    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4) {\r\n        address nftCoreAddress = msg.sender;\r\n\r\n        uint256[] memory nftIdArray = new uint256[](1);\r\n        nftIdArray[0] = _tokenId;\r\n\r\n        _wrapAndLiquidateArrayOfNfts(nftIdArray, nftCoreAddress, _from, uint256(9999));\r\n        return bytes4(keccak256(\u0022onERC721Received(address,address,uint256,bytes)\u0022));\r\n    }\r\n\r\n    /// @dev We set the address for the WrappedNFTFactory contract and the UniswapFactory\r\n    ///  in the constructor, so that no special permissons are needed and no user can change\r\n    ///  the factory logic from under our feet.\r\n    /// @param _wrappedNFTFactoryAddress The mainnet address of the wrappedNFTFactory contract.\r\n    ///  This contract serves as the directory for finding the corresponding WrappedNFT contract\r\n    ///  for any NFTCore contract.\r\n    /// @param _uniswapFactoryAddress The mainnet address of the uniswapFactoryAddress contract.\r\n    ///  This contract serves as the directory for finding the corresponding UniswapExchange\r\n    ///  contract for any NFTCore contract.\r\n    constructor(address _wrappedNFTFactoryAddress, address _uniswapFactoryAddress) public {\r\n        wrappedNFTFactoryAddress = _wrappedNFTFactoryAddress;\r\n        wrappedNFTFactory = WrappedNFTFactory(_wrappedNFTFactoryAddress);\r\n        uniswapFactoryAddress = _uniswapFactoryAddress;\r\n        uniswapFactory = UniswapFactory(_uniswapFactoryAddress);\r\n    }\r\n\r\n    /// @notice We need to accept external payments since Uniswap will send refunds directly\r\n    ///  to this contract.\r\n    function() external payable {}\r\n\r\n    /* ****************** */\r\n    /* INTERNAL FUNCTIONS */\r\n    /* ****************** */\r\n\r\n    /// @dev This function transforms ERC721 tokens into their corresponding ERC20 WNFT tokens.\r\n    /// @param _wrapperContractAddress The address of the corresponding WNFT contract for this\r\n    ///  ERC721 token.\r\n    /// @param _nftIds An array of the ids of the NFTs to be transformed into ERC20s.\r\n    function _depositNFTsAndMintTokens(address _wrapperContractAddress, uint256[] memory _nftIds) internal {\r\n        if(_wrapperContractAddress != wrappedKittiesAddress){\r\n            WrappedNFT(_wrapperContractAddress).depositNftsAndMintTokens(_nftIds);\r\n        } else {\r\n            WrappedKitties(_wrapperContractAddress).depositKittiesAndMintTokens(_nftIds);\r\n        }\r\n    }\r\n\r\n    /// @dev This function transforms WNFT ERC20 tokens into their corresponding ERC721 assets.\r\n    /// @param _wrapperContractAddress The address of the corresponding WNFT contract for this\r\n    ///  ERC721 token.\r\n    /// @param _nftIds An array of the ids of the NFTs to be transformed into ERC20s.\r\n    /// @param _destinationAddresses An array of the addresses that each nft should be sent to.\r\n    ///  You can provide different addresses for each NFT in order to \u0022airdrop\u0022 them in a single\r\n    ///  transaction to many people.\r\n    function _burnTokensAndWithdrawNfts(address _wrapperContractAddress, uint256[] memory _nftIds, address[] memory _destinationAddresses) internal {\r\n        if(_wrapperContractAddress != wrappedKittiesAddress){\r\n            WrappedNFT(_wrapperContractAddress).burnTokensAndWithdrawNfts(_nftIds, _destinationAddresses);\r\n        } else {\r\n            WrappedKitties(_wrapperContractAddress).burnTokensAndWithdrawKitties(_nftIds, _destinationAddresses);\r\n        }\r\n    }\r\n\r\n    /// @dev This internal helper function wraps ERC721 tokens from the same nftCore contract\r\n    ///  into ERC20 tokens and then subsequently liquidates them on Uniswap.\r\n    /// @param _nftIds The array of ids of the NFT tokens.\r\n    /// @param _nftContractAddress The nftCore address for the tokens\r\n    /// @param _destinationAddress The address that will receive the payout from Uniswap.\r\n    /// @param _uniswapSlippageAllowedInBasisPoints A percentage (measured in hundreths of a\r\n    ///  percent), of how much slippage is tolerated when the wrapped NFTs are sold on Uniswap.\r\n    ///  If Uniswap is would cause more slippage (or this call has been frontrun), then this\r\n    ///  this call will revert.\r\n    function _wrapAndLiquidateArrayOfNfts(uint256[] memory _nftIds, address _nftContractAddress, address _destinationAddress, uint256 _uniswapSlippageAllowedInBasisPoints) internal {\r\n        require(_uniswapSlippageAllowedInBasisPoints \u003C= uint256(9999), \u0027you provided an invalid value for uniswapSlippageAllowedInBasisPoints\u0027);\r\n        address wrapperContractAddress = wrappedNFTFactory.getWrapperContractForNFTContractAddress(_nftContractAddress);\r\n        address uniswapAddress = uniswapFactory.getExchange(wrapperContractAddress);\r\n\r\n        // Approve each NFT to send them to WrappedNFT contract to be converted to ERC20s\r\n        for(uint i = 0; i \u003C _nftIds.length; i\u002B\u002B){\r\n            NFTCore(_nftContractAddress).approve(wrapperContractAddress, _nftIds[i]);\r\n        }\r\n\r\n        // Convert NFTs from ERC721 to ERC20\r\n        _depositNFTsAndMintTokens(wrapperContractAddress, _nftIds);\r\n\r\n        // Liquidate ERC20s for ETH and send ETH to User\r\n        WrappedNFT(wrapperContractAddress).approve(uniswapAddress, ~uint256(0));\r\n        uint256 theoreticalEthReceived = UniswapExchange(uniswapAddress).getTokenToEthInputPrice((_nftIds.length).mul(10**18));\r\n        uint256 minEthReceived = (theoreticalEthReceived.mul(uint256(10000).sub(_uniswapSlippageAllowedInBasisPoints))).div(uint256(10000));\r\n        uint256 ethReceived = UniswapExchange(uniswapAddress).tokenToEthTransferInput((_nftIds.length).mul(10**18), minEthReceived, ~uint256(0), _destinationAddress);\r\n\r\n        emit LiquidateNFTs(_nftIds.length, _nftContractAddress, ethReceived);\r\n    }\r\n}\r\n\r\n/// @title Interface for interacting with the NFTCore contract\r\ncontract NFTCore {\r\n    function ownerOf(uint256 _tokenId) public view returns (address owner);\r\n    function transferFrom(address _from, address _to, uint256 _tokenId) external;\r\n    function transfer(address _to, uint256 _tokenId) external;\r\n    function approve(address _to, uint256 _tokenId) external;\r\n}\r\n\r\n/// @title Interface for interacting with the WrappedNFTFactory contract\r\ncontract WrappedNFTFactory {\r\n    function getWrapperContractForNFTContractAddress(address _nftContractAddress) external returns (address);\r\n}\r\n\r\n/// @title Interface for interacting with the WrappedNFT contract\r\ncontract WrappedNFT {\r\n    function depositNftsAndMintTokens(uint256[] calldata _nftIds) external;\r\n    function burnTokensAndWithdrawNfts(uint256[] calldata _nftIds, address[] calldata _destinationAddresses) external;\r\n    function transfer(address to, uint256 value) public returns (bool);\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool);\r\n    function approve(address spender, uint256 value) public returns (bool);\r\n}\r\n\r\n/// @title Interface for interacting with the WrappedKitties contract\r\ncontract WrappedKitties {\r\n    function depositKittiesAndMintTokens(uint256[] calldata _nftIds) external;\r\n    function burnTokensAndWithdrawKitties(uint256[] calldata _nftIds, address[] calldata _destinationAddresses) external;\r\n}\r\n\r\n/// @title Interface for interacting with the UniswapFactory contract\r\ncontract UniswapFactory {\r\n    function getExchange(address token) external view returns (address exchange);\r\n    function getToken(address exchange) external view returns (address token);\r\n}\r\n\r\n/// @title Interface for interacting with a UniswapExchange contract\r\ncontract UniswapExchange {\r\n    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);\r\n    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);\r\n    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256 eth_bought);\r\n    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_operator\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022onERC721Received\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes4\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes4\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_nftIds\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022_nftContractAddresses\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_isMixedBatchOfNFTs\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022wrapNFTs\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022uniswapFactoryAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022wrappedNFTFactoryAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_nftContractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_numTokensToPurchase\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022purchaseNFTs\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_nftIds\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022_nftContractAddresses\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_isMixedBatchOfNFTs\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_uniswapSlippageAllowedInBasisPoints\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022liquidateNFTs\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_nftIds\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022_nftContractAddresses\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022_destinationAddresses\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_isMixedBatchOfNFTs\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022unwrapNFTs\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_wrappedNFTFactoryAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_uniswapFactoryAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022numTokensMelted\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022nftContractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022ethReceived\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LiquidateNFTs\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022numTokensBought\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022nftContractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022ethSpent\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022PurchaseNFTs\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022numTokensWrapped\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022nftContractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WrapNFTs\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022numTokensUnwrapped\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022nftContractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022UnwrapNFTs\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"WrappedNFTLiquidationProxy","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000f11b5815b143472b7f7c52af0bfa6c6a2c8f40e1000000000000000000000000c0a47dfe034b400b47bdad5fecda2621de6c4d95","Library":"","SwarmSource":"bzzr://a91b535578ad6719d58b002655f3190877be557645b8433452ad379afe69cdc3"}]