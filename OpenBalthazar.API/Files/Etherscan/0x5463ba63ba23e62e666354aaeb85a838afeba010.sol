[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\ncontract UtilFairWin  {\r\n   \r\n    /* fairwin.me */\r\n    \r\n    function getRecommendScaleBylevelandTim(uint level,uint times) public view returns(uint);\r\n    function compareStr (string _str,string str) public view returns(bool);\r\n    function getLineLevel(uint value) public view returns(uint);\r\n    function getScBylevel(uint level) public view returns(uint);\r\n    function getFireScBylevel(uint level) public view returns(uint);\r\n    function getlevel(uint value) public view returns(uint);\r\n}\r\ncontract FairWin {\r\n    \r\n     /* fairwin.me */\r\n     \r\n    uint ethWei = 1 ether;\r\n    uint allCount = 0;\r\n    uint oneDayCount = 0;\r\n    uint totalMoney = 0;\r\n    uint totalCount = 0;\r\n\tuint private beginTime = 1;\r\n    uint lineCountTimes = 1;\r\n\tuint private currentIndex = 0;\r\n\taddress private owner;\r\n\tuint private actStu = 0;\r\n\t\r\n\tconstructor () public {\r\n        owner = msg.sender;\r\n    }\r\n\tstruct User{\r\n\r\n        address userAddress;\r\n        uint freeAmount;\r\n        uint freezeAmount;\r\n        uint rechargeAmount;\r\n        uint withdrawlsAmount;\r\n        uint inviteAmonut;\r\n        uint bonusAmount;\r\n        uint dayInviteAmonut;\r\n        uint dayBonusAmount;\r\n        uint level;\r\n        uint resTime;\r\n        uint lineAmount;\r\n        uint lineLevel;\r\n        string inviteCode;\r\n        string beInvitedCode;\r\n\t\tuint isline;\r\n\t\tuint status; \r\n\t\tbool isVaild;\r\n    }\r\n    \r\n    struct Invest{\r\n\r\n        address userAddress;\r\n        uint inputAmount;\r\n        uint resTime;\r\n        string inviteCode;\r\n        string beInvitedCode;\r\n\t\tuint isline;\r\n\t\tuint status; \r\n\t\tuint times;\r\n    }\r\n    \r\n    mapping (address =\u003E User) userMapping;\r\n    mapping (string =\u003E address) addressMapping;\r\n    mapping (uint =\u003E address) indexMapping;\r\n    \r\n    Invest[] invests;\r\n    UtilFairWin  util = UtilFairWin(0x062b203190C5C9419a474bDc80F89a5671e0EEbd);\r\n    \r\n    modifier onlyOwner {\r\n        require (msg.sender == owner, \u0022OnlyOwner methods called by non-owner.\u0022);\r\n        _;\r\n    }\r\n    \r\n    function () public payable {\r\n    }\r\n    \r\n     function invest(address userAddress ,uint inputAmount,string  inviteCode,string  beInvitedCode) public payable{\r\n        \r\n        userAddress = msg.sender;\r\n  \t\tinputAmount = msg.value;\r\n        uint lineAmount = inputAmount;\r\n        \r\n        if(!getUserByinviteCode(beInvitedCode)){\r\n            userAddress.transfer(msg.value);\r\n            require(getUserByinviteCode(beInvitedCode),\u0022Code must exit\u0022);\r\n        }\r\n        if(inputAmount \u003C 1* ethWei || inputAmount \u003E 15* ethWei || util.compareStr(inviteCode,\u0022\u0022)){\r\n             userAddress.transfer(msg.value);\r\n                require(inputAmount \u003E= 1* ethWei \u0026\u0026 inputAmount \u003C= 15* ethWei \u0026\u0026 !util.compareStr(inviteCode,\u0022\u0022), \u0022between 1 and 15\u0022);\r\n        }\r\n        User storage userTest = userMapping[userAddress];\r\n        if(userTest.isVaild \u0026\u0026 userTest.status != 2){\r\n            if((userTest.lineAmount \u002B userTest.freezeAmount \u002B lineAmount)\u003E (15 * ethWei)){\r\n                userAddress.transfer(msg.value);\r\n                require((userTest.lineAmount \u002B userTest.freezeAmount \u002B lineAmount) \u003C= 15 * ethWei,\u0022can not beyond 15 eth\u0022);\r\n                return;\r\n            }\r\n        }\r\n       totalMoney = totalMoney \u002B inputAmount;\r\n        totalCount = totalCount \u002B 1;\r\n        bool isLine = false;\r\n        \r\n        uint level =util.getlevel(inputAmount);\r\n        uint lineLevel = util.getLineLevel(lineAmount);\r\n        if(beginTime==1){\r\n            lineAmount = 0;\r\n            oneDayCount = oneDayCount \u002B inputAmount;\r\n            Invest memory invest = Invest(userAddress,inputAmount,now, inviteCode, beInvitedCode ,1,1,0);\r\n            invests.push(invest);\r\n            sendFeetoAdmin(inputAmount);\r\n        }else{\r\n            allCount = allCount \u002B inputAmount;\r\n            isLine = true;\r\n            invest = Invest(userAddress,inputAmount,now, inviteCode, beInvitedCode ,0,1,0);\r\n            inputAmount = 0;\r\n            invests.push(invest);\r\n        }\r\n          User memory user = userMapping[userAddress];\r\n            if(user.isVaild \u0026\u0026 user.status == 1){\r\n                user.freezeAmount = user.freezeAmount \u002B inputAmount;\r\n                user.rechargeAmount = user.rechargeAmount \u002B inputAmount;\r\n                user.lineAmount = user.lineAmount \u002B lineAmount;\r\n                level =util.getlevel(user.freezeAmount);\r\n                lineLevel = util.getLineLevel(user.freezeAmount \u002B user.freeAmount \u002Buser.lineAmount);\r\n                user.level = level;\r\n                user.lineLevel = lineLevel;\r\n                userMapping[userAddress] = user;\r\n                \r\n            }else{\r\n                if(isLine){\r\n                    level = 0;\r\n                }\r\n                if(user.isVaild){\r\n                   inviteCode = user.inviteCode;\r\n                   beInvitedCode = user.beInvitedCode;\r\n                }\r\n                user = User(userAddress,0,inputAmount,inputAmount,0,0,0,0,0,level,now,lineAmount,lineLevel,inviteCode, beInvitedCode ,1,1,true);\r\n                userMapping[userAddress] = user;\r\n                \r\n                indexMapping[currentIndex] = userAddress;\r\n                currentIndex = currentIndex \u002B 1;\r\n            }\r\n            address  userAddressCode = addressMapping[inviteCode];\r\n            if(userAddressCode == 0x0000000000000000000000000000000000000000){\r\n                addressMapping[inviteCode] = userAddress;\r\n            }\r\n        \r\n    }\r\n     \r\n      function remedy(address userAddress ,uint freezeAmount,string  inviteCode,string  beInvitedCode ,uint freeAmount,uint times) public {\r\n        require(actStu == 0,\u0022this action was closed\u0022);\r\n        freezeAmount = freezeAmount * ethWei;\r\n        freeAmount = freeAmount * ethWei;\r\n        uint level =util.getlevel(freezeAmount);\r\n        uint lineLevel = util.getLineLevel(freezeAmount \u002B freeAmount);\r\n        if(beginTime==1 \u0026\u0026 freezeAmount \u003E 0){\r\n            Invest memory invest = Invest(userAddress,freezeAmount,now, inviteCode, beInvitedCode ,1,1,times);\r\n            invests.push(invest);\r\n        }\r\n          User memory user = userMapping[userAddress];\r\n            if(user.isVaild){\r\n                user.freeAmount = user.freeAmount \u002B freeAmount;\r\n                user.freezeAmount = user.freezeAmount \u002B  freezeAmount;\r\n                user.rechargeAmount = user.rechargeAmount \u002B freezeAmount \u002BfreezeAmount;\r\n                user.level =util.getlevel(user.freezeAmount);\r\n                user.lineLevel = util.getLineLevel(user.freezeAmount \u002B user.freeAmount \u002Buser.lineAmount);\r\n                userMapping[userAddress] = user;\r\n            }else{\r\n                user = User(userAddress,freeAmount,freezeAmount,freeAmount\u002BfreezeAmount,0,0,0,0,0,level,now,0,lineLevel,inviteCode, beInvitedCode ,1,1,true);\r\n                userMapping[userAddress] = user;\r\n                \r\n                indexMapping[currentIndex] = userAddress;\r\n                currentIndex = currentIndex \u002B 1;\r\n            }\r\n            address  userAddressCode = addressMapping[inviteCode];\r\n            if(userAddressCode == 0x0000000000000000000000000000000000000000){\r\n                addressMapping[inviteCode] = userAddress;\r\n            }\r\n        \r\n    }\r\n     \r\n    function userWithDraw(address userAddress) public{\r\n        bool success = false;\r\n        require (msg.sender == userAddress, \u0022account diffrent\u0022);\r\n        \r\n         User memory user = userMapping[userAddress];\r\n         uint sendMoney  = user.freeAmount;\r\n         \r\n        bool isEnough = false ;\r\n        uint resultMoney = 0;\r\n        (isEnough,resultMoney) = isEnoughBalance(sendMoney);\r\n        \r\n            user.withdrawlsAmount =user.withdrawlsAmount \u002B resultMoney;\r\n            user.freeAmount = user.freeAmount - resultMoney;\r\n            user.level = util.getlevel(user.freezeAmount);\r\n            user.lineLevel = util.getLineLevel(user.freezeAmount \u002B user.freeAmount);\r\n            userMapping[userAddress] = user;\r\n            if(resultMoney \u003E 0 ){\r\n                userAddress.transfer(resultMoney);\r\n            }\r\n    }\r\n\r\n    //\r\n    function countShareAndRecommendedAward(uint startLength ,uint endLength,uint times) external onlyOwner {\r\n\r\n        for(uint i = startLength; i \u003C endLength; i\u002B\u002B) {\r\n            Invest memory invest = invests[i];\r\n             address  userAddressCode = addressMapping[invest.inviteCode];\r\n            User memory user = userMapping[userAddressCode];\r\n            if(invest.isline==1 \u0026\u0026 invest.status == 1 \u0026\u0026 now \u003C (invest.resTime \u002B 5 days) \u0026\u0026 invest.times \u003C5){\r\n             invests[i].times = invest.times \u002B 1;\r\n               uint scale = util.getScBylevel(user.level);\r\n                user.dayBonusAmount =user.dayBonusAmount \u002B scale*invest.inputAmount/1000;\r\n                user.bonusAmount = user.bonusAmount \u002B scale*invest.inputAmount/1000;\r\n                userMapping[userAddressCode] = user;\r\n               \r\n            }else if(invest.isline==1 \u0026\u0026 invest.status == 1 \u0026\u0026 ( now \u003E= (invest.resTime \u002B 5 days) || invest.times \u003E= 5 )){\r\n                invests[i].status = 2;\r\n                user.freezeAmount = user.freezeAmount - invest.inputAmount;\r\n                user.freeAmount = user.freeAmount \u002B invest.inputAmount;\r\n                user.level = util.getlevel(user.freezeAmount);\r\n                userMapping[userAddressCode] = user;\r\n            }\r\n        }\r\n    }\r\n    \r\n    function countRecommend(uint startLength ,uint endLength,uint times) public {\r\n        require ((msg.sender == owner || msg.sender == 0x6b00afC5a90ac2305Ae223e7FB50898027Aa5862 || msg.sender == 0x8948E4B00DEB0a5ADb909F4DC5789d20D0851D71\r\n                || msg.sender == 0xcE82Cf84558aDD0Eff5eCFB3dE63fF75Df59AcE0 || msg.sender == 0xA732E7665fF54Ba63AE40E67Fac9f23EcD0b1223 || msg.sender == 0x445b660236c39F5bc98bc49ddDc7CF1F246a40aB\r\n                || msg.sender == 0x60e31B8b79bd92302FE452242Ea6F7672a77a80f), \u0022\u0022);\r\n         for(uint i = startLength; i \u003C= endLength; i\u002B\u002B) {\r\n             \r\n            address userAddress = indexMapping[i];\r\n            if(userAddress != 0x0000000000000000000000000000000000000000){\r\n                \r\n                User memory user =  userMapping[userAddress];\r\n                if(user.status == 1 \u0026\u0026 user.freezeAmount \u003E= 1 * ethWei){\r\n                    uint scale = util.getScBylevel(user.level);\r\n                    execute(user.beInvitedCode,1,user.freezeAmount,scale);\r\n                }\r\n            }\r\n        }\r\n    }\r\n    \r\n    \r\n    function execute(string inviteCode,uint runtimes,uint money,uint shareSc) private  returns(string,uint,uint,uint) {\r\n \r\n        string memory codeOne = \u0022null\u0022;\r\n        \r\n        address  userAddressCode = addressMapping[inviteCode];\r\n        User memory user = userMapping[userAddressCode];\r\n        \r\n        if (user.isVaild \u0026\u0026 runtimes \u003C= 25){\r\n            codeOne = user.beInvitedCode;\r\n              if(user.status == 1){\r\n                  \r\n                  uint fireSc = util.getFireScBylevel(user.lineLevel);\r\n                  uint recommendSc = util.getRecommendScaleBylevelandTim(user.lineLevel,runtimes);\r\n                  uint moneyResult = 0;\r\n                  \r\n                  if(money \u003C= (user.freezeAmount\u002Buser.lineAmount\u002Buser.freeAmount)){\r\n                      moneyResult = money;\r\n                  }else{\r\n                      moneyResult = user.freezeAmount\u002Buser.lineAmount\u002Buser.freeAmount;\r\n                  }\r\n                  \r\n                  if(recommendSc != 0){\r\n                      user.dayInviteAmonut =user.dayInviteAmonut \u002B (moneyResult*shareSc*fireSc*recommendSc/1000/10/100);\r\n                      user.inviteAmonut = user.inviteAmonut \u002B (moneyResult*shareSc*fireSc*recommendSc/1000/10/100);\r\n                      userMapping[userAddressCode] = user;\r\n                  }\r\n              }\r\n              return execute(codeOne,runtimes\u002B1,money,shareSc);\r\n        }\r\n        return (codeOne,0,0,0);\r\n\r\n    }\r\n    \r\n    function sendMoneyToUser(address userAddress, uint money) private {\r\n        address send_to_address = userAddress;\r\n        uint256 _eth = money;\r\n        send_to_address.transfer(_eth);\r\n        \r\n    }\r\n\r\n    function sendAward(uint startLength ,uint endLength,uint times)  external onlyOwner  {\r\n        \r\n         for(uint i = startLength; i \u003C= endLength; i\u002B\u002B) {\r\n             \r\n            address userAddress = indexMapping[i];\r\n            if(userAddress != 0x0000000000000000000000000000000000000000){\r\n                \r\n                User memory user =  userMapping[userAddress];\r\n                if(user.status == 1){\r\n                    uint sendMoney =user.dayInviteAmonut \u002B user.dayBonusAmount;\r\n                    \r\n                    if(sendMoney \u003E= (ethWei/10)){\r\n                         sendMoney = sendMoney - (ethWei/1000);  \r\n                        bool isEnough = false ;\r\n                        uint resultMoney = 0;\r\n                        (isEnough,resultMoney) = isEnoughBalance(sendMoney);\r\n                        if(isEnough){\r\n                            sendMoneyToUser(user.userAddress,resultMoney);\r\n                            //\r\n                            user.dayInviteAmonut = 0;\r\n                            user.dayBonusAmount = 0;\r\n                            userMapping[userAddress] = user;\r\n                        }else{\r\n                            userMapping[userAddress] = user;\r\n                            if(sendMoney \u003E 0 ){\r\n                                sendMoneyToUser(user.userAddress,resultMoney);\r\n                                user.dayInviteAmonut = 0;\r\n                                user.dayBonusAmount = 0;\r\n                                userMapping[userAddress] = user;\r\n                            }\r\n                        }\r\n                    }\r\n                }\r\n            }\r\n        }\r\n    }\r\n\r\n    function isEnoughBalance(uint sendMoney) private view returns (bool,uint){\r\n        \r\n        if(this.balance \u003E 0 ){\r\n             if(sendMoney \u003E= this.balance){\r\n                if((this.balance ) \u003E 0){\r\n                    return (false,this.balance); \r\n                }else{\r\n                    return (false,0);\r\n                }\r\n            }else{\r\n                 return (true,sendMoney);\r\n            }\r\n        }else{\r\n             return (false,0);\r\n        }\r\n    }\r\n    \r\n    function getUserByAddress(address userAddress) public view returns(uint,uint,uint,uint,uint,uint,uint,uint,uint,string,string,uint){\r\n\r\n            User memory user = userMapping[userAddress];\r\n            return (user.lineAmount,user.freeAmount,user.freezeAmount,user.inviteAmonut,\r\n            user.bonusAmount,user.lineLevel,user.status,user.dayInviteAmonut,user.dayBonusAmount,user.inviteCode,user.beInvitedCode,user.level);\r\n    } \r\n    function getUserByinviteCode(string inviteCode) public view returns (bool){\r\n        \r\n        address  userAddressCode = addressMapping[inviteCode];\r\n        User memory user = userMapping[userAddressCode];\r\n      if (user.isVaild){\r\n            return true;\r\n      }\r\n        return false;\r\n    }\r\n    function getSomeInfo() public view returns(uint,uint,uint){\r\n        return(totalMoney,totalCount,beginTime);\r\n    }\r\n    function test() public view returns(uint,uint,uint){\r\n        return (invests.length,currentIndex,actStu);\r\n    }\r\n     function sendFeetoAdmin(uint amount) private {\r\n        address adminAddress = 0x6b00afC5a90ac2305Ae223e7FB50898027Aa5862;\r\n        adminAddress.transfer(amount/25);\r\n    }\r\n    function closeAct()  external onlyOwner {\r\n        actStu = 1;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022closeAct\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022userAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022inputAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022inviteCode\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022beInvitedCode\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022invest\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022startLength\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022endLength\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022times\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022sendAward\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022startLength\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022endLength\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022times\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022countShareAndRecommendedAward\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getSomeInfo\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022userAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022freezeAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022inviteCode\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022beInvitedCode\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022freeAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022times\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022remedy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022userAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getUserByAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022inviteCode\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022getUserByinviteCode\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022userAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022userWithDraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022startLength\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022endLength\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022times\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022countRecommend\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022test\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022}]","ContractName":"FairWin","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://c672d05c0f4725f4172d3ba9869e5b54f631d1546bc4b8ebd2d3cf8e13a5f2ef"}]