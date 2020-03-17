[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060\u002B\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a, \u0022SafeMath: subtraction overflow\u0022);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060*\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, \u0022SafeMath: division by zero\u0022);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0, \u0022SafeMath: modulo by zero\u0022);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n\r\n// We should reference that this was inspired by Melon Protocol Engine\r\n\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n// GNU General Public License for more details.\r\n\r\n// You should have received a copy of the GNU General Public License\r\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\r\n\r\ncontract BurnableToken {\r\n    function burnAndRetrieve(uint256 _tokensToBurn) public returns (bool success);\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\r\n}\r\n\r\n/// @notice NEC Auction Engine\r\ncontract Engine {\r\n    using SafeMath for uint256;\r\n\r\n    event Thaw(uint amount);\r\n    event Burn(uint amount, uint price, address burner);\r\n    event FeesPaid(uint amount);\r\n    event AuctionClose(uint indexed auctionNumber, uint ethPurchased, uint necBurned);\r\n\r\n    uint public constant NEC_DECIMALS = 18;\r\n    address public necAddress;\r\n\r\n    uint public frozenEther;\r\n    uint public liquidEther;\r\n    uint public lastThaw;\r\n    uint public thawingDelay;\r\n    uint public totalEtherConsumed;\r\n    uint public totalNecBurned;\r\n    uint public thisAuctionTotalEther;\r\n\r\n    uint private necPerEth; // Price at which the previous auction ended\r\n    uint private lastSuccessfulSale;\r\n\r\n    uint public auctionCounter;\r\n\r\n    // Params for auction price multiplier - TODO: can make customizable with an admin function\r\n    uint private startingPercentage = 200;\r\n    uint private numberSteps = 35;\r\n\r\n    constructor(uint _delay, address _token) public {\r\n        lastThaw = 0;\r\n        thawingDelay = _delay;\r\n        necAddress = _token;\r\n        necPerEth = uint(20000).mul(10 ** uint(NEC_DECIMALS));\r\n    }\r\n\r\n    function payFeesInEther() external payable {\r\n        totalEtherConsumed = totalEtherConsumed.add(msg.value);\r\n        frozenEther = frozenEther.add(msg.value);\r\n        emit FeesPaid(msg.value);\r\n    }\r\n\r\n    /// @notice Move frozen ether to liquid pool after delay\r\n    /// @dev Delay only restarts when this function is called\r\n    function thaw() public {\r\n        require(\r\n            block.timestamp \u003E= lastThaw.add(thawingDelay),\r\n            \u0022Thawing delay has not passed\u0022\r\n        );\r\n        require(frozenEther \u003E 0, \u0022No frozen ether to thaw\u0022);\r\n        lastThaw = block.timestamp;\r\n        if (lastSuccessfulSale \u003E 0) {\r\n          necPerEth = lastSuccessfulSale;\r\n        } else {\r\n          necPerEth = necPerEth.div(4);\r\n        }\r\n        liquidEther = liquidEther.add(frozenEther);\r\n        thisAuctionTotalEther = liquidEther;\r\n        emit Thaw(frozenEther);\r\n        frozenEther = 0;\r\n\r\n\r\n        emit AuctionClose(auctionCounter, totalEtherConsumed, totalNecBurned);\r\n        auctionCounter\u002B\u002B;\r\n    }\r\n\r\n    function getPriceWindow() public view returns (uint window) {\r\n      window = (now.sub(lastThaw)).mul(numberSteps).div(thawingDelay);\r\n    }\r\n\r\n    function percentageMultiplier() public view returns (uint) {\r\n        return (startingPercentage.sub(getPriceWindow().mul(5)));\r\n    }\r\n\r\n    /// @return NEC per ETH including premium\r\n    function enginePrice() public view returns (uint) {\r\n        return necPerEth.mul(percentageMultiplier()).div(100);\r\n    }\r\n\r\n    function ethPayoutForNecAmount(uint necAmount) public view returns (uint) {\r\n        return necAmount.mul(10 ** uint(NEC_DECIMALS)).div(enginePrice());\r\n    }\r\n\r\n    /// @notice NEC must be approved first\r\n    function sellAndBurnNec(uint necAmount) external {\r\n        if (block.timestamp \u003E= lastThaw.add(thawingDelay)) {\r\n          thaw();\r\n          return;\r\n        }\r\n        require(\r\n            necToken().transferFrom(msg.sender, address(this), necAmount),\r\n            \u0022NEC transferFrom failed\u0022\r\n        );\r\n        uint ethToSend = ethPayoutForNecAmount(necAmount);\r\n        lastSuccessfulSale = enginePrice();\r\n        require(ethToSend \u003E 0, \u0022No ether to pay out\u0022);\r\n        require(liquidEther \u003E= ethToSend, \u0022Not enough liquid ether to send\u0022);\r\n        liquidEther = liquidEther.sub(ethToSend);\r\n        totalNecBurned = totalNecBurned.add(necAmount);\r\n        msg.sender.transfer(ethToSend);\r\n        necToken().burnAndRetrieve(necAmount);\r\n        emit Burn(necAmount, lastSuccessfulSale, msg.sender);\r\n    }\r\n\r\n    /// @dev Get NEC token\r\n    function necToken()\r\n        public\r\n        view\r\n        returns (BurnableToken)\r\n    {\r\n        return BurnableToken(necAddress);\r\n    }\r\n\r\n\r\n/// Useful read functions for UI\r\n\r\n    function getNextPriceChange() public view returns (\r\n        uint newPriceMultiplier,\r\n        uint nextChangeTimeSeconds )\r\n    {\r\n        uint nextWindow = getPriceWindow() \u002B 1;\r\n        nextChangeTimeSeconds = lastThaw \u002B thawingDelay.mul(nextWindow).div(numberSteps);\r\n        newPriceMultiplier = (startingPercentage.sub(nextWindow.mul(5)));\r\n    }\r\n\r\n    function getNextAuction() public view returns (\r\n        uint nextStartTimeSeconds,\r\n        uint predictedEthAvailable,\r\n        uint predictedStartingPrice\r\n        ) {\r\n        nextStartTimeSeconds = lastThaw \u002B thawingDelay;\r\n        predictedEthAvailable = frozenEther;\r\n        if (lastSuccessfulSale \u003E 0) {\r\n          predictedStartingPrice = lastSuccessfulSale * 2;\r\n        } else {\r\n          predictedStartingPrice = necPerEth.div(4);\r\n        }\r\n    }\r\n\r\n    function getCurrentAuction() public view returns (\r\n        uint auctionNumber,\r\n        uint startTimeSeconds,\r\n        uint nextPriceChangeSeconds,\r\n        uint currentPrice,\r\n        uint nextPrice,\r\n        uint initialEthAvailable,\r\n        uint remainingEthAvailable\r\n        ) {\r\n        auctionNumber = auctionCounter;\r\n        startTimeSeconds = lastThaw;\r\n        currentPrice = enginePrice();\r\n        uint nextPriceMultiplier;\r\n        (nextPriceMultiplier, nextPriceChangeSeconds) = getNextPriceChange();\r\n        nextPrice = currentPrice.mul(nextPriceMultiplier).div(percentageMultiplier());\r\n        initialEthAvailable = thisAuctionTotalEther;\r\n        remainingEthAvailable = liquidEther;\r\n    }\r\n\r\n\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_delay\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022auctionNumber\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022ethPurchased\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022necBurned\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022AuctionClose\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022price\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022burner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022FeesPaid\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Thaw\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022NEC_DECIMALS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022auctionCounter\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022enginePrice\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022necAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ethPayoutForNecAmount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022frozenEther\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCurrentAuction\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022auctionNumber\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022startTimeSeconds\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nextPriceChangeSeconds\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022currentPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nextPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022initialEthAvailable\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022remainingEthAvailable\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getNextAuction\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nextStartTimeSeconds\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022predictedEthAvailable\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022predictedStartingPrice\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getNextPriceChange\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022newPriceMultiplier\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nextChangeTimeSeconds\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getPriceWindow\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022window\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022lastThaw\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022liquidEther\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022necAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022necToken\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract BurnableToken\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022payFeesInEther\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022percentageMultiplier\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022necAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022sellAndBurnNec\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022thaw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022thawingDelay\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022thisAuctionTotalEther\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalEtherConsumed\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalNecBurned\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"Engine","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000000000000000000000000000000000000000093a80000000000000000000000000cc80c051057b774cd75067dc48f8987c4eb97a5e","Library":"","SwarmSource":"bzzr://e6e9e5f2c53e458cda980483d7a4fb1c413d59cc608716ab8686805c4a293591"}]