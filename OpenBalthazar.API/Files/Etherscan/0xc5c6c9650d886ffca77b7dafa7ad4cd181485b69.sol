[{"SourceCode":"pragma solidity 0.5.14;\r\n\r\ncontract SwapProxyInterface {\r\n    function name() public view returns(string memory);\r\n    function getSwapQuantity(address src, address dst, uint256 srcQty) public view returns(uint256);\r\n    function getSwapRate(address src, address dst, uint256 srcQty) public view returns(uint256);\r\n    function executeSwap(address srcToken, uint256 srcQty, address dstToken, address dstAddress) public returns(bool);\r\n}\r\n\r\ncontract ERC20 {\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n    function decimals() public view returns(uint);\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n    function approve(address spender, uint256 value) public returns (bool);\r\n    function allowance(address owner, address spender) public view returns (uint256);\r\n}\r\n\r\ncontract Auction {\r\n    function bidAndWithdraw(address _rebalancingSetToken, uint256 _quantity, bool _allowPartialFill) external;\r\n}\r\n\r\n\r\ncontract AdminRole {\r\n\r\n    mapping (address =\u003E bool) adminGroup;\r\n    address payable owner;\r\n\r\n    constructor () public {\r\n        adminGroup[msg.sender] = true;\r\n        owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyAdmin() {\r\n        require(\r\n            isAdmin(msg.sender),\r\n            \u0022The caller is not Admin\u0022\r\n        );\r\n        _;\r\n    }\r\n\r\n    modifier onlyOwner {\r\n        require(\r\n            owner == msg.sender,\r\n            \u0022The caller is not Owner\u0022\r\n        );\r\n        _;\r\n    }\r\n\r\n    function addAdmin(address addr) external onlyAdmin {\r\n        adminGroup[addr] = true;\r\n    }\r\n    function delAdmin(address addr) external onlyAdmin {\r\n        adminGroup[addr] = false;\r\n    }\r\n\r\n    function isAdmin(address addr) public view returns(bool) {\r\n        return adminGroup[addr];\r\n    }\r\n\r\n    function kill() external onlyOwner {\r\n        selfdestruct(owner);\r\n    }\r\n}\r\n\r\ncontract Withdrawable is AdminRole {\r\n    /*\r\n     * External Function to withdraw founds -\u003E Gas or Tokens\r\n     */\r\n    function withdrawTo (address payable dst, uint founds, address token) external onlyAdmin {\r\n        if (token == address(0))\r\n            require (address(this).balance \u003E= founds);\r\n        else {\r\n            ERC20 erc20 = ERC20(token);\r\n            require (erc20.balanceOf(address(this)) \u003E= founds);\r\n        }\r\n        sendFounds(dst,founds, token);\r\n    }\r\n\r\n    /*\r\n     * Function to send founds -\u003E Gas or Tokens\r\n     */\r\n    function sendFounds(address payable dst, uint amount, address token) internal returns(bool) {\r\n        ERC20 erc20;\r\n        if (token == address(0))\r\n            require(address(dst).send(amount), \u0022Impossible send founds\u0022);\r\n        else {\r\n            erc20 = ERC20(token);\r\n            require(erc20.transfer(dst, amount), \u0022Impossible send founds\u0022);\r\n        }\r\n    }\r\n}\r\n\r\ncontract GasReserve {\r\n    uint256[] g;\r\n\r\n    event GasReport(\r\n        uint256 total_gas_consumed,\r\n        uint256 words_used\r\n    );\r\n\r\n    function reserveGas(uint256 quantity) public {\r\n        if (quantity != 0)\r\n            reserve(quantity);\r\n    }\r\n\r\n    function gasWordsQuantity() external view returns(uint256) {\r\n        return g.length;\r\n    }\r\n\r\n    function useGas(uint256 start_gas) internal {\r\n        uint256 consumed_gas = start_gas - gasleft();\r\n        uint256 words = consumed_gas/25000;\r\n        releaseGas(words);\r\n        emit GasReport(consumed_gas,words);\r\n    }\r\n\r\n    function releaseGas(uint256 quantity) internal {\r\n        if (g.length!=0) {\r\n            if (quantity \u003C= g.length)\r\n                release(quantity);\r\n            else\r\n                release(g.length);\r\n        }\r\n    }\r\n\r\n    function getReserveAddr () private pure returns(uint256 reserve) {\r\n        uint256 gaddr;\r\n        assembly {\r\n            gaddr := g_slot\r\n        }\r\n        return uint256(keccak256(abi.encode(gaddr)));\r\n    }\r\n\r\n    function reserve(uint256 quantity) private {\r\n        uint256 len = g.length;\r\n        uint256 start = getReserveAddr() \u002B len;\r\n        uint256 end = start \u002B quantity;\r\n\r\n        len = len \u002B quantity;\r\n\r\n        for (uint256 i = start; i \u003C end; i \u002B\u002B) {\r\n            assembly {\r\n                sstore(i,1)\r\n            }\r\n        }\r\n        assembly {\r\n            sstore(g_slot, len)\r\n        }\r\n    }\r\n\r\n    function release(uint256 quantity) private {\r\n        uint256 len = g.length;\r\n        uint256 start = getReserveAddr() \u002B (len - quantity);\r\n        uint256 end = getReserveAddr() \u002B len;\r\n\r\n        len = len - quantity;\r\n \r\n        for (uint256 i = start; i \u003C end; i\u002B\u002B) {\r\n            assembly {\r\n                sstore(i,0)\r\n            }\r\n        }\r\n        assembly {\r\n            sstore(g_slot, len)\r\n        }\r\n    }\r\n}\r\n\r\ncontract Swapper is Withdrawable, GasReserve {\r\n\r\n    event TokenSwapped(address indexed srcToken, address indexed dstToken, string swapProxy);\r\n\r\n    address[10] swapProxy;\r\n    uint256 swapProxySize = 0;\r\n\r\n    function addSwapProxy (address addr) external onlyAdmin {\r\n        require(swapProxySize \u003C 10, \u0022Max SwapProxy has reatched\u0022);\r\n\r\n        for (uint256 i; i \u003C 10; i\u002B\u002B ) {\r\n            if (swapProxy[i] == address(0)) {\r\n                swapProxy[i] = addr;\r\n                swapProxySize = swapProxySize \u002B 1;\r\n                return;\r\n            }\r\n        }\r\n        revert(\u0022Unable to found free slot\u0022);\r\n    }\r\n\r\n    function delSwapProxy(address addr) external onlyAdmin {\r\n        for (uint256 i; i \u003C 10; i\u002B\u002B ) {\r\n            if (swapProxy[i] == addr) {\r\n                swapProxy[i] = address(0);\r\n                swapProxySize = swapProxySize - 1;\r\n                return;\r\n            }\r\n        }\r\n        revert(\u0022Unable to found a proxy\u0022);\r\n    }\r\n\r\n    function getBestSwapRate(address src, address dst, uint256 srcQty) external view\r\n        returns (string memory name, uint256 rate, uint256 index)\r\n    {\r\n        SwapProxyInterface spi;\r\n\r\n        /**\r\n         * Si no existe nigun swap proxy\r\n         */\r\n        if (swapProxySize == 0)\r\n            return (name,rate,index);\r\n\r\n        (index, rate) = getBestRate(src,dst,srcQty);\r\n\r\n        if (rate != 0) {\r\n            spi = SwapProxyInterface(swapProxy[index]);\r\n            name = spi.name();\r\n        }\r\n    }\r\n\r\n    function TokenSwapOnBest(address srcToken, uint256 srcQty, address dstToken, address dstAddress, bool useReserveOfGas) external {\r\n        uint256 start_gas = gasleft();\r\n\r\n        ERC20 token = ERC20(srcToken);\r\n        require(token.transferFrom(msg.sender, address(this), srcQty), \u0022Unable to transferFrom()\u0022);\r\n\r\n        swapOnBest(srcToken, srcQty, dstToken, dstAddress);\r\n\r\n        if (useReserveOfGas) {\r\n            if (isAdmin(msg.sender)) {\r\n                useGas(start_gas);\r\n            }\r\n        }\r\n    }\r\n\r\n    function TokenSwapOn(uint256 dex, address srcToken, uint256 srcQty, address dstToken, address dstAddress, bool useReserveOfGas) external {\r\n        uint256 start_gas = gasleft();\r\n\r\n        ERC20 token = ERC20(srcToken);\r\n        require(token.transferFrom(msg.sender, address(this), srcQty), \u0022Unable to transferFrom()\u0022);\r\n\r\n        swapOn(dex,srcToken, srcQty, dstToken, dstAddress);\r\n\r\n        if (useReserveOfGas) {\r\n            if (isAdmin(msg.sender)) {\r\n                useGas(start_gas);\r\n            }\r\n        }\r\n    }\r\n\r\n    function getBestRate(address src, address dst, uint256 srcQty)\r\n        internal view returns(uint256 index, uint256 rate )\r\n    {\r\n        SwapProxyInterface spi;\r\n        uint256 tmp;\r\n        uint256 i;\r\n\r\n\r\n        for (i = 0; i \u003C 10; i\u002B\u002B) {\r\n            if (swapProxy[i] != address(0)) {\r\n                spi = SwapProxyInterface(swapProxy[i]);\r\n                tmp = spi.getSwapRate(src,dst,srcQty);\r\n                if (tmp \u003E rate) {\r\n                    rate = tmp;\r\n                    index = i;\r\n                }\r\n            }\r\n        }\r\n    }\r\n\r\n    function swapOnBest(address srcToken, uint256 srcQty, address dstToken, address dstAddress)\r\n        internal returns(bool)\r\n    {\r\n        SwapProxyInterface spi;\r\n        ERC20 token = ERC20(srcToken);\r\n        uint256 index;\r\n        uint256 rate;\r\n\r\n        require(swapProxySize != 0, \u0022Unable to found a configured swap\u0022);\r\n\r\n        (index,rate) = getBestRate(srcToken,dstToken,srcQty);\r\n\r\n        require(rate != 0, \u0022Unable to found a valid rate\u0022);\r\n\r\n        // Set the spender\u0027s token allowance to tokenQty\r\n        require(token.approve(swapProxy[index], srcQty), \u0022Unable to appove()\u0022);\r\n\r\n        spi = SwapProxyInterface(swapProxy[index]);\r\n\r\n        require(spi.executeSwap(srcToken,srcQty,dstToken,dstAddress), \u0022Unable to executeSwap\u0022);\r\n\r\n        emit TokenSwapped(srcToken,dstToken,spi.name());\r\n\r\n        return true;\r\n    }\r\n\r\n    function swapOn(uint256 dex, address srcToken, uint256 srcQty, address dstToken, address dstAddress)\r\n        internal returns(bool)\r\n    {\r\n        SwapProxyInterface spi;\r\n        ERC20 token = ERC20(srcToken);\r\n\r\n        require(swapProxySize != 0 \u0026\u0026 swapProxy[dex] != address(0), \u0022Unable to found a swap identified by dex\u0022);\r\n\r\n        // Set the spender\u0027s token allowance to tokenQty\r\n        require(token.approve(swapProxy[dex], srcQty), \u0022Unable to appove()\u0022);\r\n\r\n        spi = SwapProxyInterface(swapProxy[dex]);\r\n\r\n        require(spi.executeSwap(srcToken,srcQty,dstToken,dstAddress), \u0022Unable to executeSwap\u0022);\r\n\r\n        emit TokenSwapped(srcToken,dstToken,spi.name());\r\n\r\n        return true;\r\n    }\r\n}\r\n\r\n\r\ncontract Bidder is Swapper {\r\n    address public auctionAddress = 0xe23FB31dD2edacEbF7d92720358bB92445F47fDB;\r\n    address public transferProxy = 0x882d80D3a191859d64477eb78Cca46599307ec1C;\r\n\r\n    function bidAndSwapOn(uint256 dex, address tokenset, uint256 inflow, uint256 minimumBid, uint256 srcQty, address src, address dst, bool useReserveOfGas) external {\r\n        uint256 start_gas = gasleft();\r\n        uint256 quantity;\r\n        Auction auction = Auction(auctionAddress);\r\n        ERC20 srcToken = ERC20(src);\r\n        ERC20 dstToken = ERC20(dst);\r\n        uint256 dst_startBalance = dstToken.balanceOf(address(this));\r\n\r\n        /**\r\n         * 1- Traemos los fondos para poder participar de la subasta\r\n         */\r\n        require(srcToken.transferFrom(msg.sender,address(this),srcQty), \u0022Unable to transferFrom()\u0022);\r\n\r\n        /**\r\n         * 2- Habilitamos el approve al transfer proxy si no esta habilitado\r\n         */\r\n        require(srcToken.approve(transferProxy,srcQty), \u0022Unable to approve\u0022);\r\n\r\n        /**\r\n         * 3- Calculamos la cantidad para participar\r\n         */\r\n        quantity = (srcQty / inflow) * minimumBid;\r\n\r\n        /**\r\n         * 4- Participamos en la subasta\r\n         */\r\n        auction.bidAndWithdraw(tokenset,quantity,true);\r\n\r\n        /**\r\n         * 5- En este punto debemos tener mas balance del dstToken y esa diferencia es la que tenemos que\r\n         *    intercambiar\r\n         */\r\n        swapOn(dex,dst,dstToken.balanceOf(address(this))-dst_startBalance,src,msg.sender);\r\n\r\n        if (useReserveOfGas) {\r\n            if (isAdmin(msg.sender)) {\r\n                useGas(start_gas);\r\n            }\r\n        }\r\n    }\r\n\r\n    function bidAndSwapOnBest(address tokenset, uint256 inflow, uint256 minimumBid, uint256 srcQty, address src, address dst, bool useReserveOfGas)\r\n        external\r\n    {\r\n        uint256 start_gas = gasleft();\r\n        uint256 quantity;\r\n        Auction auction = Auction(auctionAddress);\r\n        ERC20 srcToken = ERC20(src);\r\n        ERC20 dstToken = ERC20(dst);\r\n        uint256 dst_startBalance = dstToken.balanceOf(address(this));\r\n\r\n        /**\r\n         * 1- Traemos los fondos para poder participar de la subasta\r\n         */\r\n        require(srcToken.transferFrom(msg.sender,address(this),srcQty), \u0022Unable to transferFrom()\u0022);\r\n\r\n        /**\r\n         * 2- Habilitamos el approve al transfer proxy si no esta habilitado\r\n         */\r\n        require(srcToken.approve(transferProxy,srcQty), \u0022Unable to approve\u0022);\r\n\r\n        /**\r\n         * 3- Calculamos la cantidad para participar\r\n         */\r\n         \r\n        quantity = (srcQty / inflow) * minimumBid;\r\n        /**\r\n         * 4- Participamos en la subasta\r\n         */\r\n        auction.bidAndWithdraw(tokenset,quantity,true);\r\n\r\n        /**\r\n         * 5- En este punto debemos tener mas balance del dstToken y esa diferencia es la que tenemos que\r\n         *    intercambiar\r\n         */\r\n        swapOnBest(dst,dstToken.balanceOf(address(this))-dst_startBalance,src,msg.sender);\r\n\r\n        if (useReserveOfGas) {\r\n            if (isAdmin(msg.sender)) {\r\n                useGas(start_gas);\r\n            }\r\n        }\r\n    }\r\n}","ABI":"[{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022total_gas_consumed\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022words_used\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022GasReport\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022srcToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dstToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022swapProxy\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022TokenSwapped\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022dex\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022srcToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022srcQty\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dstToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dstAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022useReserveOfGas\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022TokenSwapOn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022srcToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022srcQty\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dstToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dstAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022useReserveOfGas\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022TokenSwapOnBest\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addSwapProxy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022auctionAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022dex\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022tokenset\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022inflow\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022minimumBid\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022srcQty\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022useReserveOfGas\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022bidAndSwapOn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022tokenset\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022inflow\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022minimumBid\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022srcQty\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022useReserveOfGas\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022bidAndSwapOnBest\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022delAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022delSwapProxy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022gasWordsQuantity\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022srcQty\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getBestSwapRate\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isAdmin\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022kill\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022quantity\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022reserveGas\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022transferProxy\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022founds\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022withdrawTo\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"Bidder","CompilerVersion":"v0.5.14\u002Bcommit.1f1aaa4","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://f6a8fb839143306c4ccbae1d76f30d79526d439c35b4cbd829b7fcc3b8c903fd"}]