[{"SourceCode":"pragma solidity ^0.5.11;\r\n\r\ncontract Owned {\r\n    // State variable\r\n    address payable owner;\r\n\r\n    // Modifiers\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner, \u0022Only owner can call this function.\u0022);\r\n        _;\r\n    }\r\n\r\n    // constructor\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n}\r\n\r\ncontract MoneyPotSystem is Owned {\r\n\r\n    // Custom types\r\n    struct Donation {\r\n        address payable donor;\r\n        uint amount;\r\n    }\r\n\r\n    struct MoneyPot {\r\n        uint id;\r\n        address payable author;\r\n        address payable beneficiary;\r\n        string name;\r\n        string description;\r\n        address[] donors;\r\n        mapping(uint32 =\u003E Donation) donations;\r\n        uint32 donationsCounter;\r\n        bool open;\r\n        uint feesAmount;\r\n    }\r\n\r\n    // State variables\r\n    mapping(uint =\u003E MoneyPot) public moneypots;\r\n    mapping(address =\u003E uint256[]) public addressToMoneyPot;\r\n\r\n    uint fees;\r\n    uint feesAmount;\r\n\r\n    uint moneypotCounter;\r\n\r\n    bool contractOpen;\r\n\r\n    // Modifiers\r\n    modifier onlyContractOpen() {\r\n        require(contractOpen == true);\r\n        _;\r\n    }\r\n\r\n    // Events\r\n    event createMoneyPotEvent (\r\n        uint indexed _id,\r\n        address payable indexed _author,\r\n        string _name,\r\n        uint _feesAmount,\r\n        address[] _donors\r\n    );\r\n\r\n    event chipInEvent (\r\n        uint indexed _id,\r\n        address payable indexed _donor,\r\n        uint256 _amount,\r\n        string _name,\r\n        uint _donation,\r\n        uint32 indexed _donationId\r\n    );\r\n\r\n    event closeEvent (\r\n        uint indexed _id,\r\n        address payable indexed _benefeciary,\r\n        uint256 _amount,\r\n        string _name,\r\n        address payable indexed _sender\r\n    );\r\n\r\n    event addDonorEvent(\r\n        uint indexed _id,\r\n        address payable indexed _donor\r\n    );\r\n\r\n    event feesAmountChangeEvent(\r\n        uint _oldFeesAmount,\r\n        uint _newFeesAmount\r\n    );\r\n\r\n    event withdrawFeesEvent(\r\n        uint _feesAmount\r\n    );\r\n\r\n    constructor() public {\r\n        moneypotCounter = 0;\r\n        fees = 0;\r\n        feesAmount = 6800000000000000; // 0.0068 ether\r\n        contractOpen = true;\r\n    }\r\n\r\n    function createMoneyPot(string memory _name, string memory _description, address payable _benefeciary, address[] memory _donors) onlyContractOpen public {\r\n\r\n        address[] memory donors = new address[](_donors.length \u002B 1);\r\n\r\n        address payable author = msg.sender;\r\n        uint moneyPotId = moneypotCounter;\r\n\r\n        uint j = 0;\r\n        for (j; j \u003C _donors.length; j\u002B\u002B) {\r\n            require(author != _donors[j]);\r\n\r\n            donors[j] = _donors[j];\r\n            // add money pot id to donor money pot list\r\n            addressToMoneyPot[_donors[j]].push(moneyPotId);\r\n        }\r\n\r\n        // add author to donor\r\n        donors[j] = msg.sender;\r\n        // add money pot id to author money pot list\r\n        addressToMoneyPot[msg.sender].push(moneyPotId);\r\n\r\n        // Add money pot to benefeciary money pot list, if benefeciary is not author\r\n        if (msg.sender != _benefeciary) {\r\n            addressToMoneyPot[_benefeciary].push(moneyPotId);\r\n        }\r\n\r\n        moneypots[moneypotCounter] = MoneyPot(moneyPotId, author, _benefeciary, _name, _description, donors, 0, true, feesAmount);\r\n\r\n        // trigger the event\r\n        emit createMoneyPotEvent(moneypotCounter, author, _name, feesAmount, _donors);\r\n\r\n        moneypotCounter\u002B\u002B;\r\n\r\n    }\r\n\r\n    function addDonor(uint _id, address payable _donor) public {\r\n\r\n        // we check whether the money pot exists\r\n        require(_id \u003E= 0 \u0026\u0026 _id \u003C= moneypotCounter);\r\n\r\n        MoneyPot storage myMoneyPot = moneypots[_id];\r\n\r\n        // we check if moneypot is open\r\n        require(myMoneyPot.open);\r\n\r\n        //check caller is author\r\n        require(myMoneyPot.author == msg.sender);\r\n\r\n        // check if donor already exist\r\n        bool donorFound = false;\r\n\r\n        for (uint j = 0; j \u003C myMoneyPot.donors.length; j\u002B\u002B) {\r\n            if (myMoneyPot.donors[j] == _donor) {\r\n                donorFound = true;\r\n                break;\r\n            }\r\n        }\r\n        require(!donorFound);\r\n\r\n        // Add donor\r\n        myMoneyPot.donors.push(_donor);\r\n\r\n        // le b\u00E9n\u00E9ficiaire poss\u00E8de deja l\u0027identififiant de son pot commun\r\n        if(myMoneyPot.beneficiary != _donor) {\r\n            addressToMoneyPot[_donor].push(_id);\r\n        }\r\n\r\n        emit addDonorEvent(_id, _donor);\r\n    }\r\n    // fetch the number of money pots in the truffleContract\r\n    function getNumberOfMoneyPots() public view returns (uint256) {\r\n        return moneypotCounter;\r\n    }\r\n\r\n    function getNumberOfMyMoneyPots() public view returns (uint256) {\r\n        return addressToMoneyPot[msg.sender].length;\r\n    }\r\n\r\n    function getMyMoneyPotsIds(address who) public view returns (uint256[] memory) {\r\n        return addressToMoneyPot[who];\r\n    }\r\n\r\n    function getDonors(uint256 moneyPotId) public view returns (address[] memory) {\r\n        return moneypots[moneyPotId].donors;\r\n    }\r\n\r\n    function getDonation(uint moneyPotId, uint32 donationId) public view returns (address donor, uint amount) {\r\n\r\n        Donation storage donation = moneypots[moneyPotId].donations[donationId];\r\n\r\n        return (donation.donor, donation.amount);\r\n    }\r\n\r\n    function chipIn(uint _id) payable public {\r\n        require(moneypotCounter \u003E 0);\r\n\r\n        // we check whether the money pot exists\r\n        require(_id \u003E= 0 \u0026\u0026 _id \u003C= moneypotCounter);\r\n\r\n        // we retrieve the article\r\n        MoneyPot storage myMoneyPot = moneypots[_id];\r\n\r\n        // we check if moneypot is open\r\n        require(myMoneyPot.open);\r\n\r\n        //forbidden to give if you are not a donor\r\n        bool donorFound = false;\r\n\r\n        for (uint j = 0; j \u003C myMoneyPot.donors.length; j\u002B\u002B) {\r\n            if (myMoneyPot.donors[j] == msg.sender) {\r\n                donorFound = true;\r\n                break;\r\n            }\r\n        }\r\n\r\n        require(donorFound);\r\n\r\n        fees = fees \u002B myMoneyPot.feesAmount;\r\n\r\n        uint donation = msg.value - myMoneyPot.feesAmount;\r\n\r\n        // Add donation\r\n        myMoneyPot.donations[myMoneyPot.donationsCounter] = Donation(msg.sender, donation);\r\n\r\n        // trigger the event\r\n        emit chipInEvent(_id, msg.sender, msg.value, myMoneyPot.name, donation, myMoneyPot.donationsCounter);\r\n\r\n        myMoneyPot.donationsCounter \u002B= 1;\r\n\r\n    }\r\n\r\n    function withdrawFees() onlyOwner public {\r\n        owner.transfer(fees);\r\n        emit withdrawFeesEvent(fees);\r\n        fees = 0;\r\n    }\r\n\r\n    function getFeesAmount() public view returns (uint) {\r\n        return feesAmount;\r\n    }\r\n\r\n    function setFeesAmount(uint _amount) onlyOwner public {\r\n        require(feesAmount != _amount);\r\n\r\n        emit feesAmountChangeEvent(feesAmount, _amount);\r\n        feesAmount = _amount;\r\n    }\r\n\r\n    function getFees() onlyOwner public view returns (uint) {\r\n        return fees;\r\n    }\r\n\r\n    function getMoneyPotAmount(uint _id) public view returns (uint256) {\r\n        require(moneypotCounter \u003E 0);\r\n\r\n        // we check whether the money pot exists\r\n        require(_id \u003E= 0 \u0026\u0026 _id \u003C= moneypotCounter);\r\n\r\n        // we retrieve the article\r\n        MoneyPot storage myMoneyPot = moneypots[_id];\r\n\r\n        uint256 amount = 0;\r\n\r\n        for (uint32 j = 0; j \u003C myMoneyPot.donationsCounter; j\u002B\u002B) {\r\n            amount \u002B= myMoneyPot.donations[j].amount;\r\n        }\r\n\r\n        return amount;\r\n    }\r\n\r\n    function close(uint _id) public {\r\n        require(moneypotCounter \u003E 0);\r\n\r\n        require(_id \u003E= 0 \u0026\u0026 _id \u003C= moneypotCounter);\r\n\r\n        MoneyPot storage myMoneyPot = moneypots[_id];\r\n\r\n        //check caller is author or beneficiary or truffleContract owner\r\n        require(msg.sender == myMoneyPot.author || msg.sender == myMoneyPot.beneficiary || msg.sender == owner);\r\n\r\n        //check open\r\n        require(myMoneyPot.open);\r\n\r\n        uint amount = getMoneyPotAmount(myMoneyPot.id);\r\n\r\n        myMoneyPot.open = false;\r\n\r\n        myMoneyPot.beneficiary.transfer(amount);\r\n\r\n        emit closeEvent(_id, myMoneyPot.beneficiary, amount, myMoneyPot.name, msg.sender);\r\n    }\r\n\r\n    function closeAllMoneypot() onlyOwner public {\r\n\r\n        for (uint i = 0; i \u003C moneypotCounter; i\u002B\u002B) {\r\n\r\n            MoneyPot storage moneyPot = moneypots[i];\r\n            if (moneyPot.open) {\r\n                close(moneyPot.id);\r\n            }\r\n        }\r\n    }\r\n\r\n    function closeContract() onlyOwner public {\r\n        require(contractOpen);\r\n        contractOpen = false;\r\n    }\r\n\r\n    function openContract() onlyOwner public {\r\n        require(!contractOpen);\r\n        contractOpen = true;\r\n    }\r\n\r\n    function isOpen() public view returns (bool) {\r\n        return contractOpen;\r\n    }\r\n\r\n    // kill the smart contract\r\n    function kill() onlyOwner public {\r\n        withdrawFees();\r\n        closeAllMoneypot();\r\n        selfdestruct(owner);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022close\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022moneyPotId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getDonors\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022moneypots\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022author\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022description\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022uint32\u0022,\u0022name\u0022:\u0022donationsCounter\u0022,\u0022type\u0022:\u0022uint32\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022open\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022feesAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022kill\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOpen\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdrawFees\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022addressToMoneyPot\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_description\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_benefeciary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022_donors\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022createMoneyPot\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022closeAllMoneypot\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022moneyPotId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint32\u0022,\u0022name\u0022:\u0022donationId\u0022,\u0022type\u0022:\u0022uint32\u0022}],\u0022name\u0022:\u0022getDonation\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022donor\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022closeContract\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getNumberOfMyMoneyPots\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getMoneyPotAmount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getFeesAmount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_donor\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addDonor\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getMyMoneyPotsIds\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getFees\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setFeesAmount\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022openContract\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022chipIn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getNumberOfMoneyPots\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_author\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_feesAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022_donors\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022createMoneyPotEvent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_donor\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_donation\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint32\u0022,\u0022name\u0022:\u0022_donationId\u0022,\u0022type\u0022:\u0022uint32\u0022}],\u0022name\u0022:\u0022chipInEvent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_benefeciary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_sender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022closeEvent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_donor\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addDonorEvent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_oldFeesAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_newFeesAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022feesAmountChangeEvent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_feesAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawFeesEvent\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"MoneyPotSystem","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://57051e76be2a43eea300665a4c3dd226374638ab466422593e1a29df97ae734e"}]