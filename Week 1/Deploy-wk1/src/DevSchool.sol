// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {IERC20} from "./IERC20.sol";

contract DevSchool {
    address token_address;


    enum Status {
        Enrolled,
        Graduate
    }
    
    struct Student {
        address account;
        string name;
        uint16 age;
        uint16 level;
        Status status;
        bool paidTuition;
    }

    struct Staff {
        address account;
        string name;
        uint16 age;
        bool suspended;
    }

    struct Price {
        uint ETH;
        uint HZK;
    }

    mapping (address => Student) students;
    mapping (address => Staff) staffs;

    address[] public studentList;
    address[] public staffList;

    mapping (uint16 => Price) level;

    address admin;
    Price schBalance;

    event RegisteredStudent(address indexed _address, string indexed name, uint16 level);
    event PaidTuition(address indexed _address, string indexed name, uint16 level, uint256 amount, uint256 paymentTime);
    event StudentPromoted(address indexed _address, string indexed name, uint16 prevLevel, uint16 newLevel);
    event RegisteredStaff(address indexed _address, string indexed name);
    event PaidStaff(address indexed receiver, string indexed name, uint256 amount, bytes data);

    constructor(address _token_address) {
        token_address = _token_address;
        admin = msg.sender;

        level[100] = Price(0.2 ether, 2);
        level[200] = Price(0.3 ether, 3);
        level[300] = Price(0.4 ether, 4);
        level[400] = Price(0.5 ether, 5);
    }

    modifier onlyStaff () {
        require(msg.sender == admin || staffs[msg.sender].account != address(0), "You cannot acces this function");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not an admin");
        _;
    }

    function addStudentCardETH() external {
        require(IERC20(token_address).approve(address(this), level[400].ETH), "Could not add Card");
    }

    function addStudentCardHZK() external {
        require(IERC20(token_address).approve(address(this), level[400].HZK), "Could not add Card");
    }

    function registerStudentETH(address _address, string memory _fullName, uint16 _age, uint16 _level) external payable onlyAdmin {
        require(_address != address(0), "Account zero detected");
        require(_address != students[_address].account, "Student already exists");
        require(msg.value > 0, "Cannot send 0 ETH");
        require(msg.value >= level[_level].ETH, "Incorrect amount");

        schBalance.ETH = schBalance.ETH + msg.value;

        students[_address] = Student(_address, _fullName, _age, _level, Status.Enrolled, true);
        studentList.push(_address);
        
        emit RegisteredStudent(_address, _fullName, 100);
    }

    function registerStudentERC20(address _address, string memory _fullName, uint16 _age, uint16 _level, uint256 _amount) external onlyAdmin {
        require(_address != address(0), "Account zero detected");
        require(_address != students[_address].account, "Student already exists");
        require(_amount > 0, "Cannot send 0 HZK");
        require(_amount >= level[_level].HZK, "Incorrect amount");

        schBalance.HZK = schBalance.HZK + _amount;
        require(IERC20(token_address).transferFrom(_address, address(this), level[_level].HZK), "Transfer failed");

        students[_address] = Student(_address, _fullName, _age, _level, Status.Enrolled, true);
        studentList.push(_address);
        
        emit RegisteredStudent(_address, _fullName, 100);
    }

    function payTuitionETH() external payable {
        require(msg.sender != address(0), "Account zero detected");
        require(students[msg.sender].account != address(0), "You are not a student");
        
        Student storage student = students[msg.sender];

        require(!student.paidTuition, "Your tuition is already paid");
        require(msg.value > 0, "Cannot send 0 ETH");
        require(msg.value >= level[student.level].ETH, "Incorrect amount");

        schBalance.ETH = schBalance.ETH + msg.value;

        student.paidTuition = true;
        
        emit PaidTuition(msg.sender, student.name, student.level, msg.value, block.timestamp);
    }

    function payTuitionHZK(uint _amount) external {
        require(msg.sender != address(0), "Account zero detected");
        require(students[msg.sender].account != address(0), "You are not a student");
        
        Student storage student = students[msg.sender];

        require(!student.paidTuition, "Your tuition is already paid");
        require(_amount > 0, "Cannot send 0 HZK");
        require(_amount >= level[student.level].HZK, "Incorrect amount");

        schBalance.HZK = schBalance.HZK + _amount;
        student.paidTuition = true;

        require(IERC20(token_address).transferFrom(msg.sender, address(this), level[student.level].HZK), "Transfer failed");
        
        emit PaidTuition(msg.sender, student.name, student.level, _amount, block.timestamp);
    }

    function getAllStudents() external view onlyAdmin returns (address[] memory) {
        return studentList;
    }

    function getStudentDetails(address _address) public view onlyAdmin returns (Student memory) {
        return students[_address];
    }

    function getAllStudentDetails() external view onlyAdmin returns (Student[] memory) {
        Student[] memory allDetails = new Student[](studentList.length);
        
        for (uint i = 0; i < studentList.length; i++) 
        {
            Student memory eachDetail = getStudentDetails(studentList[i]);
            allDetails[i] = eachDetail;
        }
        
        return allDetails;
    }
    
    function promoteStudent(address _address) external onlyStaff {
        require(_address != address(0), "Account zero detected");
        require(students[_address].account != address(0), "Not a student account");

        Student storage student = students[_address];

        uint16 currentLevel = student.level;

        if (student.level == 100) {
            student.level = 200;
        } else if (student.level == 200) {
            student.level = 300;
        } else if (student.level == 300) {
            student.level = 400;
        } else if (student.level == 400) {
            student.status = Status.Graduate;
        }

        student.paidTuition = false;

        emit StudentPromoted(_address, student.name, currentLevel, student.level);
    }

    function registerStaff(address _address, string memory _fullName, uint16 _age) external onlyAdmin {
        require(_address != address(0), "Account zero detected");
        require(_address != staffs[_address].account, "Staff already exists");

        staffs[_address] = Staff(_address, _fullName, _age, false);
        staffList.push(_address);
        
        emit RegisteredStaff(_address, _fullName);
    }

    function payStaffETH(address _address, uint256 _amount) external onlyAdmin {
        require(_address != address(0), "Account zero detected");
        require(staffs[_address].account == address(0), "Not a staff");
        require(!staffs[_address].suspended, "Staff is suspended");
        require(_amount > 0, "Cannot send 0 ETH");
        require(schBalance.ETH > _amount, "Insufficient balance");

        schBalance.ETH = schBalance.ETH - _amount;
        (bool result, bytes memory data) = payable(_address).call{value: _amount}("");

        require(result, "Transfer failed");

        emit PaidStaff(_address, staffs[_address].name, _amount, data);
    }

    function payStaffHZK(address _address, uint256 _amount) external onlyAdmin {
        require(_address != address(0), "Account zero detected");
        require(staffs[_address].account == address(0), "Not a staff");
        require(!staffs[_address].suspended, "Staff is suspended");
        require(_amount > 0, "Cannot send 0 HZK"); 
        require(schBalance.HZK > _amount, "Insufficient balance");

        schBalance.ETH = schBalance.ETH - _amount;
        require(IERC20(token_address).transfer(_address, _amount), "Transfer failed");

        emit PaidStaff(_address, staffs[_address].name, _amount, "");
    }

    function suspendStaff(address _address) external {
        require(_address != address(0), "Account zero detected");
        require(staffs[_address].account == address(0), "Not a staff");

        staffs[_address].suspended = true;
    }

    function getAllStaffs() external view onlyAdmin returns (address[] memory) {
        return staffList;
    }

    function getStaffDetails(address _address) public view onlyAdmin returns (Staff memory) {
        return staffs[_address];
    }

    function getAllStaffDetails() external view onlyAdmin returns (Staff[] memory) {
        Staff[] memory allDetails = new Staff[](staffList.length);
        
        for (uint i = 0; i < staffList.length; i++) 
        {
            Staff memory eachDetail = getStaffDetails(staffList[i]);
            allDetails[i] = eachDetail;
        }
        
        return allDetails;
    }

}