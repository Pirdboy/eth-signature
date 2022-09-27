const { expect } = require("chai");
const { ethers } = require("hardhat");

const domain = {
    name: "nftland",
    version: '1.0',
    chainId: 5,
    verifyingContract: "0x00000000006c3852cbEf3e08E8dF289169EdE581", 
    salt: "0xcab6554389422575ff776cbe4c196fff08454285c466423b2f91b6ebfa166ca5", // 一个自己定义的值
};
const types = {
    Order: [
        { name: 'offerer', type: 'address' },
        { name: 'itemType', type: 'uint256' },
        { name: 'tokenId', type: 'uint256' }
    ]
}
const order = {
    offerer: '0xC1af4aB1EceDEDa57cb28c401094c155B47ba6b8',
    itemType: 1,
    tokenId: 2
}

describe("EIP712VerifySignature test", function () {
    it("test solidity verify", async () => {
        let [signer] = await ethers.getSigners();        
        const Factory = await ethers.getContractFactory('EIP712VerifySignature');
        let contract = await Factory.deploy();
        await contract.deployed();
        let signature = await signer._signTypedData(domain, types, order);
        expect(await contract.verify(signer.address, order, signature)).to.eq(true);

        let order2 = Object.assign({}, order, {tokenId:3});
        expect(await contract.verify(signer.address, order2, signature)).to.eq(false);
    });

    it("test js verify", async () => {
        let [signer] = await ethers.getSigners();
        let signature = await signer._signTypedData(domain, types, order);
        expect(ethers.utils.verifyTypedData(domain, types, order, signature)).to.eq(signer.address);
    });
});
