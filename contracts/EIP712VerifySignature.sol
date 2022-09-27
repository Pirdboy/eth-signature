// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

struct Order {
    address offerer;
    uint256 itemType;
    uint256 tokenId;
}

struct EIP712Domain {
    string name;
    string version;
    uint256 chainId;
    address verifyingContract;
    bytes32 salt;
}

contract EIP712VerifySignature {
    uint256 constant chainId = 5;
    address constant verifyingContract = 0x00000000006c3852cbEf3e08E8dF289169EdE581;
    bytes32 constant salt = 0xcab6554389422575ff776cbe4c196fff08454285c466423b2f91b6ebfa166ca5;
    bytes32 private constant ORDER_TYPEHASH =
        keccak256("Order(address offerer,uint256 itemType,uint256 tokenId)");
    bytes32 private constant EIP712_DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)"
        );
    bytes32 private constant DOMAIN_SEPARATOR =
        keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256("nftland"),
                keccak256("1.0"),
                chainId,
                verifyingContract,
                salt
            )
        );

    function verify(address _signer,Order calldata _order, bytes calldata _signature) public pure returns (bool) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        address signer = ecrecover(getTypedDataHash(_order), v, r, s);
        return signer == _signer;
    }

    function getStructHash(Order calldata _order) private pure returns (bytes32) {
        return
            keccak256(abi.encode(ORDER_TYPEHASH, _order.offerer, _order.itemType, _order.tokenId));
    }

    function getTypedDataHash(Order calldata _order) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, getStructHash(_order)));
    }

    // 这里必须用memory, 不能用calldata, 因为mload指令需要
    function splitSignature(bytes memory _sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(_sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(_sig, 32))
            // second 32 bytes
            s := mload(add(_sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(_sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}
