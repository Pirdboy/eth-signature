// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";

contract EIP191VerifySignature {
    using Strings for uint256;

    function getMessageHash(string memory _message) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n", bytes(_message).length.toString(), _message)
            );
    }

    function verify(
        address _signer,
        string calldata _message,
        bytes calldata _signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_message);
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return _signer == ecrecover(messageHash, v, r, s);
    }

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
