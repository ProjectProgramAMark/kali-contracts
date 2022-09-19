// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";


contract Button is Ownable {
    event ButtonPushed(address pusher, uint256 pushes);

    uint256 public pushes;

    function pushButton() public onlyOwner {
        pushes++;
        console.log('button pushed called');
        emit ButtonPushed(msg.sender, pushes);
    }

    receive() external payable {
        console.log("receive called on Button.sol");
    }

    fallback() external payable {
        console.log("fallback called on Button.sol");
    }
}
