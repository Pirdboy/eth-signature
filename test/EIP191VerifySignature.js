const { expect } = require("chai");
const { ethers } = require("hardhat");

const message = "This request will not trigger a blockchain transaction or cost any gas fees. Your authentication status will reset after 24 hours中文";

describe("EIP191VerifySignature test", function () {
    it("test solidity verify", async () => {
        let [signer] = await ethers.getSigners();

        const Factory = await ethers.getContractFactory('EIP191VerifySignature');
        let contract = await Factory.deploy();
        await contract.deployed();

        let signature = await signer.signMessage(message); 
        expect(await contract.verify(signer.address, message, signature)).to.eq(true);
    });

    it("test js verify", async () => {
        let [signer] = await ethers.getSigners();
        let signature = await signer.signMessage(message);
        expect(ethers.utils.verifyMessage(message, signature)).to.eq(signer.address);
    });
});
