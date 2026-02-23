// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyERC20 {

    string public name = "Hyzeek";
    string public symbol = "HZK";
    uint8 public decimals = 18;

    uint256 public totalSupply;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);


    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * 10 ** decimals;
        balances[msg.sender] = totalSupply;

        emit Transfer(address(0), msg.sender, totalSupply);
    }
    

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "zero address");
        require(balances[msg.sender] >= amount, "insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        returns (bool)
    {
        require(spender != address(0), "zero address");

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount)
        public
        returns (bool)
    {
        require(to != address(0), "zero address");
        require(balances[from] >= amount, "insufficient balance");
        require(allowances[from][msg.sender] >= amount, "allowance too low");

        balances[from] -= amount;
        balances[to] += amount;

        allowances[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }

}
