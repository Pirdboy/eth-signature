const { ethers } = require("hardhat");

const main = async () => {
    const accounts = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("Greeter");
    const contract = await Factory.connect(accounts[0]).deploy("HAHAHAHAHA");
    await contract.deployed();
    console.log("deployed address", contract.address);
};

main();