[{"SourceCode":"pragma solidity ^0.5.2;\r\n\r\n\r\ncontract LibOwnable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(\r\n        address indexed previousOwner,\r\n        address indexed newOwner\r\n    );\r\n\r\n    \r\n    constructor() internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    \r\n    function owner() public view returns(address) {\r\n        return _owner;\r\n    }\r\n\r\n    \r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022NOT_OWNER\u0022);\r\n        _;\r\n    }\r\n\r\n    \r\n    function isOwner() public view returns(bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    \r\n    \r\n    \r\n    \r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    \r\n    \r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        require(newOwner != address(0), \u0022INVALID_OWNER\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\ncontract LibWhitelist is LibOwnable {\r\n    mapping (address =\u003E bool) public whitelist;\r\n    address[] public allAddresses;\r\n\r\n    event AddressAdded(address indexed adr);\r\n    event AddressRemoved(address indexed adr);\r\n\r\n    \r\n    modifier onlyAddressInWhitelist {\r\n        require(whitelist[msg.sender], \u0022SENDER_NOT_IN_WHITELIST_ERROR\u0022);\r\n        _;\r\n    }\r\n\r\n    \r\n    \r\n    function addAddress(address adr) external onlyOwner {\r\n        emit AddressAdded(adr);\r\n        whitelist[adr] = true;\r\n        allAddresses.push(adr);\r\n    }\r\n\r\n    \r\n    \r\n    function removeAddress(address adr) external onlyOwner {\r\n        emit AddressRemoved(adr);\r\n        delete whitelist[adr];\r\n        for(uint i = 0; i \u003C allAddresses.length; i\u002B\u002B){\r\n            if(allAddresses[i] == adr) {\r\n                allAddresses[i] = allAddresses[allAddresses.length - 1];\r\n                allAddresses.length -= 1;\r\n                break;\r\n            }\r\n        }\r\n    }\r\n\r\n    \r\n    function getAllAddresses() external view returns (address[] memory) {\r\n        return allAddresses;\r\n    }\r\n}\r\n\r\ncontract IMarketContractPool {\r\n    function mintPositionTokens(\r\n        address marketContractAddress,\r\n        uint qtyToMint,\r\n        bool isAttemptToPayInMKT\r\n    ) external;\r\n    function redeemPositionTokens(\r\n        address marketContractAddress,\r\n        uint qtyToRedeem\r\n    ) external;\r\n    function mktToken() external view returns (address);\r\n}\r\n\r\ninterface IMarketContract {\r\n    \r\n    function CONTRACT_NAME()\r\n        external\r\n        view\r\n        returns (string memory);\r\n    function COLLATERAL_TOKEN_ADDRESS()\r\n        external\r\n        view\r\n        returns (address);\r\n    function COLLATERAL_POOL_ADDRESS()\r\n        external\r\n        view\r\n        returns (address);\r\n    function PRICE_CAP()\r\n        external\r\n        view\r\n        returns (uint);\r\n    function PRICE_FLOOR()\r\n        external\r\n        view\r\n        returns (uint);\r\n    function PRICE_DECIMAL_PLACES()\r\n        external\r\n        view\r\n        returns (uint);\r\n    function QTY_MULTIPLIER()\r\n        external\r\n        view\r\n        returns (uint);\r\n    function COLLATERAL_PER_UNIT()\r\n        external\r\n        view\r\n        returns (uint);\r\n    function COLLATERAL_TOKEN_FEE_PER_UNIT()\r\n        external\r\n        view\r\n        returns (uint);\r\n    function MKT_TOKEN_FEE_PER_UNIT()\r\n        external\r\n        view\r\n        returns (uint);\r\n    function EXPIRATION()\r\n        external\r\n        view\r\n        returns (uint);\r\n    function SETTLEMENT_DELAY()\r\n        external\r\n        view\r\n        returns (uint);\r\n    function LONG_POSITION_TOKEN()\r\n        external\r\n        view\r\n        returns (address);\r\n    function SHORT_POSITION_TOKEN()\r\n        external\r\n        view\r\n        returns (address);\r\n\r\n    \r\n    function lastPrice()\r\n        external\r\n        view\r\n        returns (uint);\r\n    function settlementPrice()\r\n        external\r\n        view\r\n        returns (uint);\r\n    function settlementTimeStamp()\r\n        external\r\n        view\r\n        returns (uint);\r\n    function isSettled()\r\n        external\r\n        view\r\n        returns (bool);\r\n\r\n    \r\n    function isPostSettlementDelay()\r\n        external\r\n        view\r\n        returns (bool);\r\n}\r\n\r\nlibrary SafeMath {\r\n    \r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    \r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a, \u0022SafeMath: subtraction overflow\u0022);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    \r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        \r\n        \r\n        \r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    \r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        \r\n        require(b \u003E 0, \u0022SafeMath: division by zero\u0022);\r\n        uint256 c = a / b;\r\n        \r\n\r\n        return c;\r\n    }\r\n\r\n    \r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0, \u0022SafeMath: modulo by zero\u0022);\r\n        return a % b;\r\n    }\r\n}\r\n\r\ninterface IERC20 {\r\n    \r\n    function totalSupply() external view returns (uint256);\r\n\r\n    \r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    \r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    \r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    \r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    \r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    \r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    \r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\nlibrary Address {\r\n    \r\n    function isContract(address account) internal view returns (bool) {\r\n        \r\n        \r\n        \r\n\r\n        uint256 size;\r\n        \r\n        assembly { size := extcodesize(account) }\r\n        return size \u003E 0;\r\n    }\r\n}\r\n\r\nlibrary SafeERC20 {\r\n    using SafeMath for uint256;\r\n    using Address for address;\r\n\r\n    function safeTransfer(IERC20 token, address to, uint256 value) internal {\r\n        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\r\n    }\r\n\r\n    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {\r\n        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\r\n    }\r\n\r\n    function safeApprove(IERC20 token, address spender, uint256 value) internal {\r\n        \r\n        \r\n        \r\n        \r\n        require((value == 0) || (token.allowance(address(this), spender) == 0),\r\n            \u0022SafeERC20: approve from non-zero to non-zero allowance\u0022\r\n        );\r\n        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\r\n    }\r\n\r\n    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {\r\n        uint256 newAllowance = token.allowance(address(this), spender).add(value);\r\n        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\r\n    }\r\n\r\n    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {\r\n        uint256 newAllowance = token.allowance(address(this), spender).sub(value);\r\n        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\r\n    }\r\n\r\n    \r\n    function callOptionalReturn(IERC20 token, bytes memory data) private {\r\n        \r\n        \r\n\r\n        \r\n        \r\n        \r\n        \r\n        \r\n        require(address(token).isContract(), \u0022SafeERC20: call to non-contract\u0022);\r\n\r\n        \r\n        (bool success, bytes memory returndata) = address(token).call(data);\r\n        require(success, \u0022SafeERC20: low-level call failed\u0022);\r\n\r\n        if (returndata.length \u003E 0) { \r\n            \r\n            require(abi.decode(returndata, (bool)), \u0022SafeERC20: ERC20 operation did not succeed\u0022);\r\n        }\r\n    }\r\n}\r\n\r\ncontract MintingPool is LibOwnable, LibWhitelist {\r\n\r\n    using SafeMath for uint256;\r\n    using SafeERC20 for IERC20;\r\n\r\n    \r\n    mapping(address =\u003E uint256) public minted;\r\n    mapping(address =\u003E uint256) public redeemed;\r\n    mapping(address =\u003E uint256) public sent;\r\n    mapping(address =\u003E uint256) public received;\r\n\r\n    event Mint(address indexed contractAddress, address indexed to, uint256 value);\r\n    event Redeem(address indexed contractAddress, address indexed to, uint256 value);\r\n    event Withdraw(address indexed tokenAddress, address indexed to, uint256 amount);\r\n    event Approval(address indexed tokenAddress, address indexed spender, uint256 amount);\r\n\r\n    \r\n    \r\n    \r\n    function withdrawERC20(address token, uint256 amount)\r\n        external\r\n        onlyOwner\r\n    {\r\n        require(amount \u003E 0, \u0022INVALID_AMOUNT\u0022);\r\n\r\n        IERC20(token).safeTransfer(msg.sender, amount);\r\n\r\n        emit Withdraw(token, msg.sender, amount);\r\n    }\r\n\r\n\r\n    \r\n    \r\n    \r\n    \r\n    \r\n    function approveERC20(address token, address spender, uint256 amount)\r\n        public\r\n        onlyOwner\r\n    {\r\n        IERC20(token).safeApprove(spender, amount);\r\n\r\n        emit Approval(token, spender, amount);\r\n    }\r\n\r\n\r\n    \r\n    \r\n    \r\n    \r\n    \r\n    \r\n    function internalMintPositionTokens(\r\n        address marketContractAddress,\r\n        uint qtyToMint,\r\n        bool payInMKT\r\n    )\r\n        external\r\n        onlyOwner\r\n    {\r\n        IMarketContract marketContract = IMarketContract(marketContractAddress);\r\n        IMarketContractPool marketContractPool = IMarketContractPool(\r\n            marketContract.COLLATERAL_POOL_ADDRESS()\r\n        );\r\n        marketContractPool.mintPositionTokens(\r\n            marketContractAddress,\r\n            qtyToMint,\r\n            payInMKT\r\n        );\r\n\r\n        emit Mint(marketContractAddress, address(this), qtyToMint);\r\n    }\r\n\r\n\r\n    \r\n    \r\n    \r\n    \r\n    \r\n    function internalRedeemPositionTokens(\r\n        address marketContractAddress,\r\n        uint qtyToRedeem\r\n    )\r\n        external\r\n        onlyOwner\r\n    {\r\n        IMarketContract marketContract = IMarketContract(marketContractAddress);\r\n        IMarketContractPool marketContractPool = IMarketContractPool(\r\n            marketContract.COLLATERAL_POOL_ADDRESS()\r\n        );\r\n        marketContractPool.redeemPositionTokens(marketContractAddress, qtyToRedeem);\r\n\r\n        emit Redeem(marketContractAddress, address(this), qtyToRedeem);\r\n    }\r\n\r\n\r\n    \r\n    \r\n    \r\n    \r\n    \r\n    \r\n    \r\n    \r\n    \r\n    function mintPositionTokens(\r\n        address marketContractAddress,\r\n        uint qtyToMint,\r\n        bool\r\n    )\r\n        external\r\n        onlyAddressInWhitelist\r\n    {\r\n        require(qtyToMint \u003E 0, \u0022INVALID_AMOUNT\u0022);\r\n\r\n        IMarketContract marketContract = IMarketContract(marketContractAddress);\r\n\r\n        uint256 neededCollateral = calculateTotalCollateral(marketContract, qtyToMint);\r\n\r\n        IERC20(marketContract.COLLATERAL_TOKEN_ADDRESS()).safeTransferFrom(\r\n            msg.sender,\r\n            address(this),\r\n            neededCollateral\r\n        );\r\n\r\n        if (hasEnoughPositionBalance(marketContractAddress, qtyToMint)) {\r\n            sent[marketContractAddress] = sent[marketContractAddress].add(qtyToMint);\r\n        } else {\r\n            uint256 neededMakretToken = calculateMarketTokenFee(marketContract, qtyToMint);\r\n\r\n            IMarketContractPool marketContractPool = IMarketContractPool(\r\n                marketContract.COLLATERAL_POOL_ADDRESS()\r\n            );\r\n            bool useMarketToken = hasEnoughBalance(\r\n                marketContractPool.mktToken(),\r\n                neededMakretToken\r\n            );\r\n            marketContractPool.mintPositionTokens(marketContractAddress, qtyToMint, useMarketToken);\r\n\r\n            minted[marketContractAddress] = minted[marketContractAddress].add(qtyToMint);\r\n        }\r\n\r\n        IERC20(marketContract.LONG_POSITION_TOKEN()).safeTransfer(msg.sender, qtyToMint);\r\n        IERC20(marketContract.SHORT_POSITION_TOKEN()).safeTransfer(msg.sender, qtyToMint);\r\n\r\n        emit Mint(marketContractAddress, msg.sender, qtyToMint);\r\n    }\r\n\r\n    \r\n    \r\n    \r\n    \r\n    \r\n    \r\n    function redeemPositionTokens(\r\n        address marketContractAddress,\r\n        uint qtyToRedeem\r\n    )\r\n        external\r\n        onlyAddressInWhitelist\r\n    {\r\n        require(qtyToRedeem \u003E 0, \u0022INVALID_AMOUNT\u0022);\r\n\r\n        IMarketContract marketContract = IMarketContract(marketContractAddress);\r\n\r\n        IERC20(marketContract.LONG_POSITION_TOKEN()).safeTransferFrom(\r\n            msg.sender,\r\n            address(this),\r\n            qtyToRedeem\r\n        );\r\n        IERC20(marketContract.SHORT_POSITION_TOKEN()).safeTransferFrom(\r\n            msg.sender,\r\n            address(this),\r\n            qtyToRedeem\r\n        );\r\n\r\n        uint256 collateralToReturn = calculateCollateralToReturn(marketContract, qtyToRedeem);\r\n\r\n        if (hasEnoughBalance(marketContract.COLLATERAL_TOKEN_ADDRESS(), collateralToReturn)) {\r\n            received[marketContractAddress] = received[marketContractAddress].add(qtyToRedeem);\r\n        } else {\r\n            IMarketContractPool marketContractPool = IMarketContractPool(\r\n                marketContract.COLLATERAL_POOL_ADDRESS()\r\n            );\r\n            marketContractPool.redeemPositionTokens(marketContractAddress, qtyToRedeem);\r\n\r\n            redeemed[marketContractAddress] = redeemed[marketContractAddress].add(qtyToRedeem);\r\n        }\r\n        IERC20(marketContract.COLLATERAL_TOKEN_ADDRESS()).safeTransfer(\r\n            msg.sender,\r\n            collateralToReturn\r\n        );\r\n\r\n        emit Redeem(marketContractAddress, msg.sender, qtyToRedeem);\r\n    }\r\n\r\n    \r\n    \r\n    \r\n    \r\n    function hasEnoughBalance(address tokenAddress, uint256 amount)\r\n        internal\r\n        view\r\n        returns (bool)\r\n    {\r\n        return IERC20(tokenAddress).balanceOf(address(this)) \u003E= amount;\r\n    }\r\n\r\n    \r\n    \r\n    \r\n    \r\n    function hasEnoughPositionBalance(address marketContractAddress, uint256 amount)\r\n        internal\r\n        view\r\n        returns (bool)\r\n    {\r\n        IMarketContract marketContract = IMarketContract(marketContractAddress);\r\n        return hasEnoughBalance(marketContract.LONG_POSITION_TOKEN(), amount)\r\n            \u0026\u0026 hasEnoughBalance(marketContract.SHORT_POSITION_TOKEN(), amount);\r\n    }\r\n\r\n    \r\n    \r\n    \r\n    \r\n    function calculateTotalCollateral(IMarketContract marketContract, uint256 qtyToMint)\r\n        internal\r\n        view\r\n        returns (uint256)\r\n    {\r\n        return marketContract.COLLATERAL_PER_UNIT()\r\n            .add(marketContract.COLLATERAL_TOKEN_FEE_PER_UNIT())\r\n            .mul(qtyToMint);\r\n    }\r\n\r\n    \r\n    \r\n    \r\n    \r\n    function calculateMarketTokenFee(IMarketContract marketContract, uint256 qtyToMint)\r\n        internal\r\n        view\r\n        returns (uint256)\r\n    {\r\n        return marketContract.MKT_TOKEN_FEE_PER_UNIT().mul(qtyToMint);\r\n    }\r\n\r\n    \r\n    \r\n    \r\n    \r\n    function calculateCollateralToReturn(IMarketContract marketContract, uint256 qtyToRedeem)\r\n        internal\r\n        view\r\n        returns (uint256)\r\n    {\r\n        return marketContract.COLLATERAL_PER_UNIT().mul(qtyToRedeem);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022marketContractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022qtyToMint\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022mintPositionTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022minted\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022adr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022adr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022marketContractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022qtyToRedeem\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022internalRedeemPositionTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022sent\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAllAddresses\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022whitelist\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022redeemed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawERC20\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approveERC20\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022marketContractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022qtyToMint\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022payInMKT\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022internalMintPositionTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022marketContractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022qtyToRedeem\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022redeemPositionTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022allAddresses\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022received\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022contractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Mint\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022contractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Redeem\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Withdraw\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022adr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022AddressAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022adr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022AddressRemoved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"MintingPool","CompilerVersion":"v0.5.2\u002Bcommit.1df8f40c","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://b288d881cdecfd6f853c0da2c3a306a8ecd24b06d52cb04b4a77351574f6e9dd"}]