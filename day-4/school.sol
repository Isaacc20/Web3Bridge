// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract DevSchool {

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
    }

    mapping (address => Student) students;
    mapping (address => Staff) staffs;

    address[] public studentList;
    address[] public staffList;

    mapping (uint16 => uint256) level;

    address admin;
    uint256 schBalance;

    event RegisteredStudent(address indexed _address, string indexed name, uint16 level);
    event PaidTuition(address indexed _address, string indexed name, uint16 level, uint256 amount, uint256 paymentTime);
    event RegisteredStaff(address indexed _address, string indexed name);
    event PaidStaff(address indexed receiver, string indexed name, uint256 amount, bytes data);

    constructor() {
        admin = msg.sender;

        level[100] = 2 ether;
        level[200] = 3 ether;
        level[300] = 4 ether;
        level[400] = 5 ether;
    }

    modifier onlyStaff () {
        require(msg.sender == admin || staffs[msg.sender].account != address(0), "You cannot acces this function");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not an admin");
        _;
    }

    function registerStudent(address _address, string memory _fullName, uint16 _age, uint16 _level) external payable onlyAdmin {
        require(_address != address(0), "Account zero detected");
        require(msg.value > 0, "Cannot send 0 ETH");
        
        require(msg.value == level[students[_address].level], "Incorrect amount");

        schBalance = schBalance + msg.value;

        students[_address] = Student(_address, _fullName, _age, _level, Status.Enrolled, true);
        studentList.push(_address);
        
        emit RegisteredStudent(_address, _fullName, 100);
    }

    function payTuition() external payable {
        require(msg.sender != address(0), "Account zero detected");
        require(students[msg.sender].account != address(0), "You are not a student");
        
        Student storage student = students[msg.sender];

        require(!student.paidTuition, "Your tuition is already paid");
        require(msg.value > 0, "Cannot send 0 ETH");
        require(msg.value == level[student.level], "Incorrect amount");

        schBalance = schBalance + msg.value;

        student.paidTuition = true;
        
        emit PaidTuition(msg.sender, student.name, student.level, msg.value, block.timestamp);
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

        if (student.level == 100) {
            student.level = 200;
        } else if (student.level == 200) {
            student.level = 300;
        } else if (student.level == 300) {
            student.level = 400;
        } else if (student.level == 400) {
            student.level = 401;
            student.status = Status.Graduate;
        }
    }

    function registerStaff(address _address, string memory _fullName, uint16 _age) external onlyAdmin {
        require(_address != address(0), "Account zero detected");
        require(students[_address].status == Status.Graduate || students[_address].level == 401, "Student cannot be a staff");

        staffs[_address] = Staff(_address, _fullName, _age);
        staffList.push(_address);
        
        emit RegisteredStaff(_address, _fullName);
    }

    function payStaff(address _address, uint256 _amount) external onlyAdmin {
        require(_address != address(0), "Account zero detected");
        require(_amount > 0, "Cannot send 0ETH");
        require(schBalance > _amount, "Insufficient balance");

        schBalance = schBalance - _amount;
        (bool result, bytes memory data) = payable(_address).call{value: _amount}("");

        require(result, "Transfer failed");

        emit PaidStaff(_address, staffs[_address].name, _amount, data);
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