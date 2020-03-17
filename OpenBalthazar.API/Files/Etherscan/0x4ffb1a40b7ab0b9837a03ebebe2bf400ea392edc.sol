[{"SourceCode":"pragma solidity ^0.5.11;\r\n\r\n// Voken panel\r\n//\r\n// More info:\r\n//   https://vision.network\r\n//   https://voken.io\r\n//\r\n// Contact us:\r\n//   support@vision.network\r\n//   support@voken.io\r\n\r\n\r\n/**\r\n * @dev Uint256 wrappers over Solidity\u0027s arithmetic operations with added overflow checks.\r\n */\r\nlibrary SafeMath256 {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, errorMessage);\r\n        return a / b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n */\r\ncontract Ownable {\r\n    address internal _owner;\r\n    address internal _newOwner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n    event OwnershipAccepted(address indexed previousOwner, address indexed newOwner);\r\n\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(msg.sender == _owner, \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     *\r\n     * IMPORTANT: Need to run {acceptOwnership} by the new owner.\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _newOwner = newOwner;\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     *\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Accept ownership of the contract.\r\n     *\r\n     * Can only be called by the new owner.\r\n     */\r\n    function acceptOwnership() public {\r\n        require(msg.sender == _newOwner, \u0022Ownable: caller is not the new owner address\u0022);\r\n        require(msg.sender != address(0), \u0022Ownable: caller is the zero address\u0022);\r\n\r\n        emit OwnershipAccepted(_owner, msg.sender);\r\n        _owner = msg.sender;\r\n        _newOwner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Rescue compatible ERC20 Token\r\n     *\r\n     * Can only be called by the current owner.\r\n     */\r\n    function rescueTokens(address tokenAddr, address recipient, uint256 amount) external onlyOwner {\r\n        IERC20 _token = IERC20(tokenAddr);\r\n        require(recipient != address(0), \u0022Rescue: recipient is the zero address\u0022);\r\n        uint256 balance = _token.balanceOf(address(this));\r\n\r\n        require(balance \u003E= amount, \u0022Rescue: amount exceeds balance\u0022);\r\n        _token.transfer(recipient, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Withdraw Ether\r\n     *\r\n     * Can only be called by the current owner.\r\n     */\r\n    function withdrawEther(address payable recipient, uint256 amount) external onlyOwner {\r\n        require(recipient != address(0), \u0022Withdraw: recipient is the zero address\u0022);\r\n\r\n        uint256 balance = address(this).balance;\r\n\r\n        require(balance \u003E= amount, \u0022Withdraw: amount exceeds balance\u0022);\r\n        recipient.transfer(amount);\r\n    }\r\n}\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard\r\n */\r\ninterface IERC20 {\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n}\r\n\r\n\r\n/**\r\n * @dev Interface of Voken2.0\r\n */\r\ninterface IVoken2 {\r\n    function totalSupply() external view returns (uint256);\r\n    function whitelistingMode() external view returns (bool);\r\n    function safeMode() external view returns (bool);\r\n    function burningMode() external view returns (bool, uint16);\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function reservedOf(address account) external view returns (uint256);\r\n    function whitelisted(address account) external view returns (bool);\r\n    function whitelistCounter() external view returns (uint256);\r\n    function whitelistReferralsCount(address account) external view returns (uint256);\r\n}\r\n\r\n\r\n/**\r\n * @dev Interface of Voken shareholders\r\n */\r\ninterface VokenShareholders {\r\n    function page() external view returns (uint256);\r\n    function weis() external view returns (uint256);\r\n    function vokens() external view returns (uint256);\r\n    function shareholdersCounter(uint256 pageNumber) external view returns (uint256);\r\n    function pageEther(uint256 pageNumber) external view returns (uint256);\r\n    function pageEtherSum(uint256 pageNumber) external view returns (uint256);\r\n    function pageVoken(uint256 pageNumber) external view returns (uint256);\r\n    function pageVokenSum(uint256 pageNumber) external view returns (uint256);\r\n    function pageEndingBlock(uint256 pageNumber) external view returns (uint256);\r\n    function vokenHolding(address account, uint256 pageNumber) external view returns (uint256);\r\n    function etherDividend(address account, uint256 pageNumber) external view returns (uint256 amount,\r\n                                                                                       uint256 dividend,\r\n                                                                                       uint256 remain);\r\n    function reservedOf(address account) external view returns (uint256 reserved);\r\n}\r\n\r\n\r\n/**\r\n * @dev Interface of Voken public-sale\r\n */\r\ninterface VokenPublicSale {\r\n    function status() external view returns (uint16 stage,\r\n                                             uint16 season,\r\n                                             uint256 etherUsdPrice,\r\n                                             uint256 vokenUsdPrice,\r\n                                             uint256 shareholdersRatio);\r\n    function sum() external view returns(uint256 vokenIssued,\r\n                                         uint256 vokenBonus,\r\n                                         uint256 weiSold,\r\n                                         uint256 weiRewarded,\r\n                                         uint256 weiShareholders,\r\n                                         uint256 weiTeam,\r\n                                         uint256 weiPended,\r\n                                         uint256 usdSold,\r\n                                         uint256 usdRewarded);\r\n    function transactions() external view returns(uint256 txs,\r\n                                                  uint256 vokenIssuedTxs,\r\n                                                  uint256 vokenBonusTxs);\r\n    function queryAccount(address account) external view returns (uint256 vokenIssued,\r\n                                                                  uint256 vokenBonus,\r\n                                                                  uint256 vokenReferral,\r\n                                                                  uint256 vokenReferrals,\r\n                                                                  uint256 weiPurchased,\r\n                                                                  uint256 weiRewarded,\r\n                                                                  uint256 usdPurchased,\r\n                                                                  uint256 usdRewarded);\r\n    function accountInSeason(address account, uint16 seasonNumber) external view returns (uint256 vokenIssued,\r\n                                                                                          uint256 vokenBonus,\r\n                                                                                          uint256 vokenReferral,\r\n                                                                                          uint256 vokenReferrals,\r\n                                                                                          uint256 weiPurchased,\r\n                                                                                          uint256 weiReferrals,\r\n                                                                                          uint256 weiRewarded,\r\n                                                                                          uint256 usdPurchased,\r\n                                                                                          uint256 usdReferrals,\r\n                                                                                          uint256 usdRewarded);\r\n    function seasonReferrals(uint16 seasonNumber) external view returns (address[] memory);\r\n    function seasonAccountReferrals(uint16 seasonNumber, address account) external view returns (address[] memory);\r\n    function reservedOf(address account) external view returns (uint256);\r\n}\r\n\r\n\r\n/**\r\n * @title Voken Panel\r\n */\r\ncontract VokenPanel is Ownable {\r\n    using SafeMath256 for uint256;\r\n\r\n    IVoken2 private _VOKEN = IVoken2(0xFfFAb974088Bd5bF3d7E6F522e93Dd7861264cDB);\r\n    VokenShareholders private _SHAREHOLDERS = VokenShareholders(0x7712F76D2A52141D44461CDbC8b660506DCAB752);\r\n    VokenPublicSale private _PUBLIC_SALE = VokenPublicSale(0xfEb75b3cC7281B18f2d475A04F1fFAAA3C9a6E36);\r\n\r\n    event Donate(address indexed account, uint256 amount);\r\n\r\n\r\n    /**\r\n     * @dev Donate\r\n     */\r\n    function () external payable {\r\n        if (msg.value \u003E 0) {\r\n            emit Donate(msg.sender, msg.value);\r\n        }\r\n    }\r\n\r\n    function voken2() public view returns (uint256 totalSupply,\r\n                                           bool whitelistingMode,\r\n                                           bool safeMode,\r\n                                           bool burningMode) {\r\n        totalSupply = _VOKEN.totalSupply();\r\n\r\n        whitelistingMode = _VOKEN.whitelistingMode();\r\n        safeMode = _VOKEN.safeMode();\r\n        (burningMode,) = _VOKEN.burningMode();\r\n    }\r\n\r\n\r\n    function shareholders() public view returns (uint256 page,\r\n                                                 uint256 weis,\r\n                                                 uint256 vokens) {\r\n        page = _SHAREHOLDERS.page();\r\n        weis = _SHAREHOLDERS.weis();\r\n        vokens = _SHAREHOLDERS.vokens();\r\n    }\r\n\r\n    function publicSaleStatus() public view returns (uint16 stage,\r\n                                                     uint16 season,\r\n                                                     uint256 etherUsdPrice,\r\n                                                     uint256 vokenUsdPrice,\r\n                                                     uint256 shareholdersRatio,\r\n                                                     uint256 txs,\r\n                                                     uint256 vokenIssued,\r\n                                                     uint256 vokenBonus,\r\n                                                     uint256 weiRewarded,\r\n                                                     uint256 usdRewarded) {\r\n        (stage, season, etherUsdPrice, vokenUsdPrice, shareholdersRatio) = _PUBLIC_SALE.status();\r\n        (vokenIssued, vokenBonus, , weiRewarded, , , , usdRewarded, ) = _PUBLIC_SALE.sum();\r\n        (txs, ,) = _PUBLIC_SALE.transactions();\r\n    }\r\n\r\n    function accountVoken2(address account) public view returns (bool whitelisted,\r\n                                                                 uint256 whitelistReferralsCount,\r\n                                                                 uint256 balance,\r\n                                                                 uint256 reserved) {\r\n        whitelisted = _VOKEN.whitelisted(account);\r\n        whitelistReferralsCount = _VOKEN.whitelistReferralsCount(account);\r\n        balance = _VOKEN.balanceOf(account);\r\n        reserved = _VOKEN.reservedOf(account);\r\n    }\r\n\r\n    function pageShareholders(uint256 pageNumber) public view returns (uint256 weis,\r\n                                                                       uint256 vokens,\r\n                                                                       uint256 sumWeis,\r\n                                                                       uint256 sumVokens,\r\n                                                                       uint256 endingBlock) {\r\n        weis = _SHAREHOLDERS.pageEther(pageNumber);\r\n        vokens = _SHAREHOLDERS.pageVoken(pageNumber);\r\n        sumWeis = _SHAREHOLDERS.pageEtherSum(pageNumber);\r\n        sumVokens = _SHAREHOLDERS.pageVokenSum(pageNumber);\r\n        endingBlock = _SHAREHOLDERS.pageEndingBlock(pageNumber);\r\n    }\r\n\r\n    function accountShareholders(address account, uint256 pageNumber) public view returns (bool isShareholder,\r\n                                                                                           uint256 proportion,\r\n                                                                                           uint256 devidendWeis,\r\n                                                                                           uint256 dividendWithdrawed,\r\n                                                                                           uint256 dividendRemain) {\r\n        uint256 __vokenHolding = _SHAREHOLDERS.vokenHolding(account, pageNumber);\r\n        isShareholder = __vokenHolding \u003E 0;\r\n\r\n        uint256 __page = _SHAREHOLDERS.page();\r\n\r\n        if (0 == pageNumber) {\r\n            if (isShareholder) {\r\n                proportion = __vokenHolding.mul(100000000).div(_SHAREHOLDERS.vokens());\r\n\r\n                for (uint256 i = 1; i \u003C= __page; i\u002B\u002B) {\r\n                    (uint256 __devidendWeis, uint256 __dividendWithdrawed, uint256 __dividendRemain) = _SHAREHOLDERS.etherDividend(account, i);\r\n                    devidendWeis = devidendWeis.add(__devidendWeis);\r\n                    dividendWithdrawed = dividendWithdrawed.add(__dividendWithdrawed);\r\n                    dividendRemain = dividendRemain.add(__dividendRemain);\r\n                }\r\n            }\r\n        }\r\n\r\n        else if (pageNumber \u003C __page) {\r\n            proportion = __vokenHolding.mul(100000000).div(_SHAREHOLDERS.pageVokenSum(pageNumber));\r\n\r\n            (uint256 __devidendEthers, uint256 __dividendWithdrawed, uint256 __dividendRemain) = _SHAREHOLDERS.etherDividend(account, pageNumber);\r\n            devidendWeis = devidendWeis.add(__devidendEthers);\r\n            dividendWithdrawed = dividendWithdrawed.add(__dividendWithdrawed);\r\n            dividendRemain = dividendRemain.add(__dividendRemain);\r\n        }\r\n\r\n        else {\r\n            proportion = __vokenHolding.mul(100000000).div(_SHAREHOLDERS.vokens());\r\n        }\r\n    }\r\n\r\n    function accountPublicSale(address account) public view returns (uint256 vokenIssued,\r\n                                                                     uint256 vokenBonus,\r\n                                                                     uint256 vokenReferral,\r\n                                                                     uint256 vokenReferrals,\r\n                                                                     uint256 weiRewarded,\r\n                                                                     uint256 usdRewarded,\r\n                                                                     uint256 reserved) {\r\n        (vokenIssued, vokenBonus, vokenReferral, vokenReferrals, , weiRewarded, , usdRewarded) = _PUBLIC_SALE.queryAccount(account);\r\n        reserved = _PUBLIC_SALE.reservedOf(account);\r\n    }\r\n\r\n    function accountPublicSaleSeason(address account, uint16 seasonNumber) public view returns (uint256 vokenIssued,\r\n                                                                                                uint256 vokenBonus,\r\n                                                                                                uint256 vokenReferral,\r\n                                                                                                uint256 vokenReferrals,\r\n                                                                                                uint256 weiRewarded,\r\n                                                                                                uint256 usdRewarded) {\r\n        (vokenIssued, vokenBonus, vokenReferral, vokenReferrals, , , weiRewarded, , , usdRewarded) = _PUBLIC_SALE.accountInSeason(account, seasonNumber);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022shareholders\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022page\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022weis\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022vokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint16\u0022,\u0022name\u0022:\u0022seasonNumber\u0022,\u0022type\u0022:\u0022uint16\u0022}],\u0022name\u0022:\u0022accountPublicSaleSeason\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022vokenIssued\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022vokenBonus\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022vokenReferral\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022vokenReferrals\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022weiRewarded\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022usdRewarded\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawEther\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022voken2\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022totalSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022whitelistingMode\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022safeMode\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022burningMode\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022accountPublicSale\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022vokenIssued\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022vokenBonus\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022vokenReferral\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022vokenReferrals\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022weiRewarded\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022usdRewarded\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022reserved\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022pageNumber\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022pageShareholders\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022weis\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022vokens\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022sumWeis\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022sumVokens\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022endingBlock\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022publicSaleStatus\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint16\u0022,\u0022name\u0022:\u0022stage\u0022,\u0022type\u0022:\u0022uint16\u0022},{\u0022internalType\u0022:\u0022uint16\u0022,\u0022name\u0022:\u0022season\u0022,\u0022type\u0022:\u0022uint16\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022etherUsdPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022vokenUsdPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022shareholdersRatio\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022txs\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022vokenIssued\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022vokenBonus\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022weiRewarded\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022usdRewarded\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022tokenAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022rescueTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022pageNumber\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022accountShareholders\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022isShareholder\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022proportion\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022devidendWeis\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022dividendWithdrawed\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022dividendRemain\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022accountVoken2\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022whitelisted\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022whitelistReferralsCount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022reserved\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Donate\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipAccepted\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"VokenPanel","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://b754009578d653a117cc3e90976ee647b91273c0527a5487ddf4b7ed5fd48553"}]