// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IERC20 {
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function transfer(address to, uint amount) external returns (bool);
}

contract SaveERC {
    
    uint256 TotalETH;
    uint256 TotalERC;

    mapping(address => uint256) public ethBalance;
    mapping(address => mapping(address => uint256)) public tokenBalance;

    event WithdrawalSuccessful(address indexed receiver, uint256 indexed amount, bytes data);


    function depositETH() external payable {
        require(msg.value > 0, "Cannot deposit 0 ETH");

        ethBalance[msg.sender] += msg.value;
        TotalETH = TotalETH + msg.value;
    }

    function withdrawETH(uint amount) external {
        require(ethBalance[msg.sender] >= amount);

        ethBalance[msg.sender] -= amount;

        (bool result, bytes memory data) = payable(msg.sender).call{value: amount}("");

        require(result, "transfer failed");

        emit WithdrawalSuccessful(msg.sender, amount, data);
    }

      function depositToken(address token, uint amount) external {
        require(amount > 0);

        require(
            IERC20(token).transferFrom(msg.sender, address(this), amount)
        );

        tokenBalance[msg.sender][token] += amount;
    }

    function withdrawToken(address token, uint amount) external {
        require(tokenBalance[msg.sender][token] >= amount);

        tokenBalance[msg.sender][token] -= amount;
        require(
            IERC20(token).transfer(msg.sender, amount)
        );
    }


}