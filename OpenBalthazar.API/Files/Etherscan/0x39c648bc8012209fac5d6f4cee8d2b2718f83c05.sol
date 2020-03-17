[{"SourceCode":"pragma solidity ^0.5.12;\r\npragma experimental ABIEncoderV2;\r\n/*-\r\n * Copyright (c) 2019 @secondphonejune\r\n * All rights reserved.\r\n *\r\n * This code is derived by @secondphonejune (Telegram ID)\r\n *\r\n * Redistribution and use in source and binary forms, with or without\r\n * modification, are permitted provided that the following conditions\r\n * are met:\r\n * 1. Redistributions of source code must retain the above copyright\r\n *    notice, this list of conditions and the following disclaimer.\r\n * 2. Redistributions in binary form must reproduce the above copyright\r\n *    notice, this list of conditions and the following disclaimer in the\r\n *    documentation and/or other materials provided with the distribution.\r\n *\r\n * THIS SOFTWARE IS PROVIDED BY THE NETBSD FOUNDATION, INC. AND CONTRIBUTORS\r\n * \u0060\u0060AS IS\u0027\u0027 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED\r\n * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR\r\n * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR CONTRIBUTORS\r\n * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR\r\n * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF\r\n * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS\r\n * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN\r\n * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)\r\n * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE\r\n * POSSIBILITY OF SUCH DAMAGE.\r\n *\r\n * This project is originally created to implement an election for 2019 Hong Kong local elections.\r\n * Ofcause the Hong Kong government is not going to use it, but we have a chance to show that how an election can be done completely anonymously with blockchain\r\n * Everyone can use the code provided in this project, but they must keep this statement here unchanged.\r\n * Fight for freedom, Stand with Hong Kong\r\n * Five Demands, Not One Less\r\n */\r\n/*\r\n* Expected workflow, voter get his/her voter ID from contract, this makes sure no one has access to his/her personal data\r\n* Second, the voter registers their voter ID and email (not phone as no money to do SMS) via a vote box and make a vote.\r\n* Email is checked by the voter box to prevent double voting and robot voting, but there should be a better way to do it.\r\n* Now registration will make old registration and votes from the same voter ID invalid\r\n* The vote will then encrypted using a public key and submitted to this contract for record\r\n* After the election, the private key will be made public and people can decrypt the votes and knows who wins\r\n* Currently we let the vote box decides if a new vote should replace the old vote, but there should be a better way to do it\r\n* Also if people can read the private variable voteListByVoter from blockchain, they will know who a person votes after election. \r\n* The variable is needed for replacing old votes. \r\n* This variable should be removed when there is a proper way to authenticate a person and replacing vote is not needed. \r\n*/\r\ncontract electionList{\r\n\tstring public hashHead;\r\n    //This one keeps the council list for easy checking by public\r\n\tstring[] public councilList;\r\n\tuint256 public councilNumber;\r\n}\r\ncontract localElection{\r\n    address payable public owner;\r\n    string public encryptionPublicKey; //Just keep record on the vote encryption key\r\n    bool public isRunningElection = false;\r\n\t//vote box exists only because most people do not own a crypto account.\r\n\t//vote box are needed to encrypt and submit votes for people and do email validations\r\n\t//Once the election is over, vote box also need to get votes from the contract and decrypt the votes\r\n\tmapping(address =\u003E bool) public approvedVoteBox;\r\n\t\r\n\t//This one is dummy list as the voter list is hidden from public\r\n\t//Even in real case, this one only keeps the hash of the voter information, so no private data is leaked\r\n\t//With the same name and HKID (voter), a person can only vote in one council\r\n\t//The following information is created and verified by government before the election, \r\n\t//but in this 2019 election even voter list is hidden from people. \r\n\t//We setup register function for people to register just before they vote\r\n\tmapping(uint256 =\u003E bool) public voterList;\r\n\tmapping(uint256 =\u003E uint256) public usedPhoneNumber;\r\n\tmapping(uint256 =\u003E mapping(string =\u003E bool)) public councilVoterList;\r\n\tmapping(string =\u003E uint) public councilVoterNumber;\r\n\t\r\n\t//This one keeps the votes, but arranged by voter so it is easy to check if someone has voted\r\n\t//This file must be kept private as it links a person to a vote, \r\n\t//people can find back who a person voted after the election \r\n\t//If there is an electronic way for public to really verify a person to do the voting,\r\n\t//there will be no need to setup replaceVote function. \r\n\t//We can safely remove the link between vote and voter\r\n\tmapping(uint256 =\u003E string) private voteListByVoter; \r\n\tmapping(string =\u003E string[]) private votes; //Votes grouped by council\r\n\tmapping(address =\u003E string[]) private voteByVotebox; //Votes grouped by votebox\r\n\tmapping(string =\u003E bool) private voteDictionary; //Makre sure votes are unique\r\n\tmapping(string =\u003E address) public invalidVotes;\r\n\t\r\n\taddress public dbAddress;\r\n\t\r\n\tconstructor(address electionDBaddr,string memory pKey) public{\r\n\t    owner = msg.sender;\r\n\t    dbAddress = electionDBaddr;\r\n\t    encryptionPublicKey = pKey;\r\n\t}\r\n\t\r\n\tfunction() external payable { \r\n\t\t//Thank you for donation, it will be sent to the owner. \r\n\t\t//The owner will send it to \u661F\u706B after deducting the cost (if they have ETH account)\r\n\t\tif(address(this).balance \u003E= msg.value \u0026\u0026 msg.value \u003E0) \r\n            owner.transfer(msg.value);\r\n\t}\r\n\t//Just in case someone manage to give ETH to this contract\r\n\tfunction withdrawAll() public payable{\r\n\t    if(address(this).balance \u003E0) owner.transfer(address(this).balance);\r\n\t}\r\n\tfunction addVoteBox(address box) public {\r\n\t\tif(msg.sender != owner) revert();\r\n\t\tapprovedVoteBox[box] = true;\r\n\t}\r\n\tfunction removeVoteBox(address box) public {\r\n\t\tif(msg.sender != owner) revert();\r\n\t\tapprovedVoteBox[box] = false;\r\n\t\t//Also remove all votes in that votebox from the election result\r\n\t\telectionList db = electionList(dbAddress);\r\n\t\tfor(uint i=0;i\u003Cdb.councilNumber();i\u002B\u002B){\r\n\t\t    for(uint a=0;a\u003CvoteByVotebox[box].length;a\u002B\u002B){\r\n\t\t        if(bytes(voteByVotebox[box][a]).length \u003E0){\r\n\t\t            invalidVotes[voteByVotebox[box][a]] = msg.sender;\r\n\t\t        }\r\n\t\t    }\r\n\t\t}\r\n\t}\r\n\tfunction getVoteboxVoteCount(address box) public view returns(uint256){\r\n\t    return voteByVotebox[box].length;\r\n\t}\r\n\tfunction getCouncilVoteCount(string memory council) public view returns(uint256){\r\n\t    return votes[council].length;\r\n\t}\r\n\tfunction startElection() public {\r\n\t    if(msg.sender != owner) revert();\r\n\t    isRunningElection = true;\r\n\t}\r\n\tfunction stopElection() public {\r\n\t    if(msg.sender != owner) revert();\r\n\t    isRunningElection = false;\r\n\t}\r\n\t//This function allows people to generate a voterID to register and vote.\r\n\t//Supposingly this ID should be random so that people do not know who it belongs to, \r\n\t//and each person has only one unique ID so they cannot double vote. \r\n\t//It means a public key pair binding with identity / hash of identity. \r\n\t//As most people do not have a wallet, we can only make sure each person has one ID only\r\n\tfunction getVoterID(string memory name, string memory HKID) \r\n\t\tpublic view returns(uint256){\r\n\t\telectionList db = electionList(dbAddress);\r\n\t\tif(!checkHKID(HKID)) return 0;\r\n\t\treturn uint256(sha256(joinStrToBytes(db.hashHead(),name,HKID)));\r\n\t}\r\n\t//function getphoneHash(uint number)\r\n\tfunction getEmailHash(string memory email)\r\n\t\tpublic view returns(uint256){\r\n\t\t//return uint256(sha256(joinStrToBytes(hashHead,uint2str(number),\u0022\u0022)));\r\n\t\telectionList db = electionList(dbAddress);\r\n\t\treturn uint256(sha256(joinStrToBytes(db.hashHead(),email,\u0022\u0022)));\r\n\t}\r\n\t//function register(uint256 voterID, uint256 hashedPhone, string memory council)\r\n\tfunction register(uint256 voterID, uint256 hashedEmail, string memory council) \r\n\t\tpublic returns(bool){\r\n\t\trequire(isRunningElection);\r\n\t\trequire(approvedVoteBox[msg.sender]);\r\n\t\t//Register happens during election as we do not have the voter list\r\n\t\t//require(now \u003E= votingStartTime);\r\n\t\t//require(now \u003C votingEndTime);\r\n\t\tif(voterList[voterID]) deregister(voterID);\r\n\t\t//if(usedPhoneNumber[hashedPhone] \u003E 0)\r\n\t\t\t//deregister(usedPhoneNumber[hashedPhone]);\r\n\t\tif(usedPhoneNumber[hashedEmail] \u003E 0)\r\n\t\t\tderegister(usedPhoneNumber[hashedEmail]);\r\n\t\tvoterList[voterID] = true;\r\n\t\t//usedPhoneNumber[hashedPhone] = voterID;\r\n\t\tusedPhoneNumber[hashedEmail] = voterID;\r\n\t\tcouncilVoterList[voterID][council] = true;\r\n\t\tcouncilVoterNumber[council]\u002B\u002B;\r\n\t\treturn true;\r\n\t}\r\n\tfunction deregister(uint256 voterID) \r\n\t\tinternal returns(bool){\r\n\t\trequire(isRunningElection);\r\n\t\tvoterList[voterID] = false;\t\r\n\t\telectionList db = electionList(dbAddress);\r\n\t\tfor(uint i=0;i\u003Cdb.councilNumber();i\u002B\u002B){\r\n\t\t\t//deregister them from the other councils\r\n\t\t\tif(councilVoterList[voterID][db.councilList(i)]){\r\n\t\t\t\tcouncilVoterList[voterID][db.councilList(i)] = false;\r\n\t\t\t\tcouncilVoterNumber[db.councilList(i)]--;\r\n\t\t\t}\r\n\t\t}\r\n\t\tif(bytes(voteListByVoter[voterID]).length \u003E0){\r\n\t\t\tinvalidVotes[voteListByVoter[voterID]] = msg.sender;\r\n\t\t\tdelete voteListByVoter[voterID];\r\n\t\t}\r\n\t\treturn true;\r\n\t}\r\n\t//function isValidVoter(uint256 voterID, uint256 hashedPhone, string memory council)\r\n\tfunction isValidVoter(uint256 voterID, uint256 hashedEmail, string memory council) \r\n\t\tpublic view returns(bool){\r\n\t\tif(!voterList[voterID]) return false;\r\n\t\t//if(usedPhoneNumber[hashedPhone] == 0 || usedPhoneNumber[hashedPhone] != voterID)\r\n\t\tif(usedPhoneNumber[hashedEmail] == 0 || usedPhoneNumber[hashedEmail] != voterID)\r\n\t\t\treturn false;\r\n\t\tif(!councilVoterList[voterID][council]) return false;\r\n\t\treturn true;\r\n\t}\r\n\tfunction isVoted(uint256 voterID) public view returns(bool){\r\n\t\tif(bytes(voteListByVoter[voterID]).length \u003E0) return true;\r\n\t\treturn false;\r\n\t}\r\n\t//function submitVote(uint256 voterID, uint256 hashedPhone, \r\n\tfunction submitVote(uint256 voterID, uint256 hashedEmail, \r\n\t    string memory council, string memory singleVote) public returns(bool){\r\n\t\trequire(isRunningElection);\r\n\t\trequire(approvedVoteBox[msg.sender]);\r\n\t\t//require(now \u003E= votingStartTime);\r\n\t\t//require(now \u003C votingEndTime);\r\n\t\t//require(isValidVoter(voterID,hashedPhone,council));\r\n\t\trequire(isValidVoter(voterID,hashedEmail,council));\r\n\t\trequire(!isVoted(voterID)); //Voted already\r\n\t\trequire(!voteDictionary[singleVote]);\r\n\t\tvoteListByVoter[voterID] = singleVote;\r\n\t\tvotes[council].push(singleVote);\r\n\t\tvoteByVotebox[msg.sender].push(singleVote);\r\n\t\tvoteDictionary[singleVote] = true;\r\n\t\treturn true;\r\n\t}\r\n\t\r\n\t//function replaceVote(uint256 voterID, uint256 hashedPhone,\r\n\t/*function replaceVote(uint256 voterID, uint256 hashedEmail, \r\n\t    string memory council, string memory singleVote) public returns(bool){\r\n\t\trequire(isRunningElection);\r\n\t\trequire(approvedVoteBox[msg.sender]);\r\n\t\t//require(now \u003E= votingStartTime);\r\n\t\t//require(now \u003C votingEndTime);\r\n\t\t//require(isValidVoter(voterID,hashedPhone,council));\r\n\t\trequire(isValidVoter(voterID,hashedEmail,council));\r\n\t\trequire(!voteDictionary[singleVote]);\r\n\t\tif(bytes(voteListByVoter[voterID]).length \u003E0){\r\n\t\t    electionList db = electionList(dbAddress);\r\n\t\t\tfor(uint i=0;i\u003Cdb.councilNumber();i\u002B\u002B){\r\n\t\t\t\t//reduce the vote count in the previous council\r\n\t\t\t\tif(councilVoterList[voterID][db.councilList(i)]){\r\n\t\t\t\t\tcouncilVoteCount[db.councilList(i)]--;\t\t\t\t\t\r\n\t\t\t\t}\r\n\t\t\t}\r\n\t\t\tinvalidVotes[voteListByVoter[voterID]] = msg.sender;\r\n\t\t\tdelete voteListByVoter[voterID];\r\n\t\t}\r\n\t\tvoteListByVoter[voterID] = singleVote;\r\n\t\tvotes[council].push(singleVote);\r\n\t\tcouncilVoteCount[council]\u002B\u002B;\r\n\t\tvoteDictionary[singleVote] = true;\r\n\t\treturn true;\r\n\t}*/\r\n\tfunction registerAndVote(uint256 voterID, uint256 hashedEmail, \r\n\t    string memory council, string memory singleVote) public returns(bool){\r\n\t    if(register(voterID,hashedEmail,council) \r\n\t        \u0026\u0026 submitVote(voterID,hashedEmail,council,singleVote))\r\n\t        return true;\r\n\t    return false;\r\n\t}\r\n\t\r\n\tfunction getResult(string memory council) public view returns(uint, uint, uint, uint, \r\n\t\tstring[] memory, string[] memory){\r\n\t\trequire(!isRunningElection);\r\n\t\t//require(now \u003E= votingEndTime);\r\n\t\tuint totalVoteCount = votes[council].length;\r\n\t\tuint validVoteCount;\r\n\t\t//uint invalidCount;\r\n\t\tfor(uint i=0;i\u003CtotalVoteCount;i\u002B\u002B){\r\n\t\t\tstring memory singleVote = votes[council][i];\r\n\t\t\tif(invalidVotes[singleVote] == address(0)){\r\n\t\t\t    validVoteCount\u002B\u002B;   \r\n\t\t\t}\r\n\t\t\t//else invalidCount\u002B\u002B;\r\n\t\t}\r\n\t\t//assert((validVoteCount\u002BinvalidCount) == totalVoteCount);\r\n\t\tstring[] memory validVoteIndex = new string[](validVoteCount);\r\n\t\tstring[] memory invalidVoteIndex = new string[](totalVoteCount-validVoteCount);\r\n\t\tuint a=0;\r\n\t\tfor(uint i=0;i\u003CtotalVoteCount \u0026\u0026 (a\u003CvalidVoteCount || validVoteCount==0);i\u002B\u002B){\r\n\t\t\tstring memory singleVote = votes[council][i];\r\n\t\t\tif(invalidVotes[singleVote] == address(0)){\r\n\t\t\t    validVoteIndex[a\u002B\u002B] = singleVote;\r\n\t\t\t}else{\r\n\t\t\t    invalidVoteIndex[i-a] = singleVote;\r\n\t\t\t}\r\n\t\t}\r\n\t\treturn (councilVoterNumber[council],totalVoteCount,validVoteCount,\r\n\t\t    totalVoteCount-validVoteCount,validVoteIndex,invalidVoteIndex);\r\n\t}\r\n\t\r\n\tfunction joinStrToBytes(string memory _a, string memory _b, string memory _c) \r\n\t\tinternal pure returns (bytes memory){\r\n        bytes memory _ba = bytes(_a);\r\n        bytes memory _bb = bytes(_b);\r\n\t\tbytes memory _bc = bytes(_c);\r\n        string memory ab = new string(_ba.length \u002B _bb.length \u002B _bc.length);\r\n        bytes memory bab = bytes(ab);\r\n        uint k = 0;\r\n        for (uint i = 0; i \u003C _ba.length; i\u002B\u002B) bab[k\u002B\u002B] = _ba[i];\r\n        for (uint i = 0; i \u003C _bb.length; i\u002B\u002B) bab[k\u002B\u002B] = _bb[i];\r\n\t\tfor (uint i = 0; i \u003C _bc.length; i\u002B\u002B) bab[k\u002B\u002B] = _bc[i];\t\t\r\n        //return string(bab);\r\n        return bab;\r\n    }\r\n    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {\r\n\t\tif (_i == 0) {\r\n\t\t\treturn \u00220\u0022;\r\n\t\t}\r\n\t\tuint j = _i;\r\n\t\tuint len;\r\n\t\twhile (j != 0) {\r\n\t\t\tlen\u002B\u002B;\r\n\t\t\tj /= 10;\r\n\t\t}\r\n\t\tbytes memory bstr = new bytes(len);\r\n\t\tuint k = len - 1;\r\n\t\twhile (_i != 0) {\r\n\t\t\tbstr[k--] = byte(uint8(48 \u002B _i % 10));\r\n\t\t\t_i /= 10;\r\n\t\t}\r\n\t\treturn string(bstr);\r\n\t}\r\n\t//Sample G123456A AB9876543, C1234569 invalid sample AY987654A C668668E\r\n\tfunction checkHKID(string memory HKID) \r\n\t\tinternal pure returns(bool){\r\n\t\tbytes memory b = bytes(HKID);\r\n\t\tif(b.length !=8 \u0026\u0026 b.length !=9) return false;\r\n\t\tuint256 checkDigit = 0;\r\n\t\tuint256 power = 9;\r\n\t\tif(b.length ==8){\r\n\t\t\tcheckDigit \u002B= (36*power);\r\n\t\t\tpower--;\r\n\t\t}\r\n\t\tfor(uint i=0;i\u003Cb.length;i\u002B\u002B){\r\n\t\t\tuint digit = uint8(b[i]);\r\n\t\t\tif(i\u003E(b.length-8) \u0026\u0026 i\u003C(b.length-1)){\r\n\t\t\t\t//It should be a number\r\n\t\t\t\tif(digit \u003C 48 || digit \u003E 57) return false;\r\n\t\t\t}\r\n\t\t\tif(digit \u003E=48 \u0026\u0026 digit\u003C=57) checkDigit \u002B= ((digit-48)*power); //Number\r\n\t\t\telse if(digit \u003E=65 \u0026\u0026 digit\u003C=90) checkDigit \u002B= ((digit-55)*power); //A-Z\r\n\t\t\telse return false;\r\n\t\t\tpower--;\r\n\t\t}\r\n\t\tif(checkDigit % 11 == 0) return true;\r\n\t\treturn false;\r\n\t}\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022electionDBaddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022pKey\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022box\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addVoteBox\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022approvedVoteBox\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022councilVoterList\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022councilVoterNumber\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022dbAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022encryptionPublicKey\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022council\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022getCouncilVoteCount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022email\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022getEmailHash\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022council\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022getResult\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022string[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string[]\u0022},{\u0022internalType\u0022:\u0022string[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022box\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getVoteboxVoteCount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022HKID\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022getVoterID\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022invalidVotes\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isRunningElection\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022voterID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022hashedEmail\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022council\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022isValidVoter\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022voterID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022isVoted\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022voterID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022hashedEmail\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022council\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022register\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022voterID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022hashedEmail\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022council\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022singleVote\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022registerAndVote\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022box\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeVoteBox\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022startElection\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022stopElection\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022voterID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022hashedEmail\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022council\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022singleVote\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022submitVote\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022usedPhoneNumber\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022voterList\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdrawAll\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"localElection","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"00000000000000000000000064e9f4bdf14f0cbcd4e922571bb96dc80434d938000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000001794141414142334e7a6143317963324541414141424a51414141514541696b78414961616b446e576f4f2b66614639794c33314a4e59544c6f6f45303734324a2f206f756b4e456174457a686a4c6e446564457746373963445a664f784a4a4b30382f3344796549695948653467483339594246414b646e363673454e5070423065206757385234675a75644b382b32597764396659362b6a42647a4256416e48666c3836374d62504e646e3767535369696a69386765684b484d53417769387a4b612036503653693771313744764a394b33566c64744d6173436a35647855596a54775072514c53654964566c5a653345694d77794c5848734f6d7a487a79687535412044486f625937574d63644757576f504e524b476b6c79423873302b6f75586c7370576136332f5a4d4c68494c536e514f47684342733672462b4537444b3644552050653642353974563379385a654c456a695a6648446576525365654e6c616e3753762f76484f4e566a57576c3844656b72773d3d00000000000000","Library":"","SwarmSource":"bzzr://96b5fc04a550f8d3f8eed5ad5c5c13788854a280af47f122092cb51a654878b1"}]