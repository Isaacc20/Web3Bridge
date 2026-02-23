// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract Properties {

    IERC20 public immutable paymentToken;

    address public admin;

    mapping(address => bool) public isSeller;

    struct Property {
        uint id;
        string name;
        string location;
        uint price;
        bool sold;
        address seller;
        address buyer;
        uint createdAt;
    }

    uint public propertyCounter;

    mapping(uint => Property) private properties;
    uint[] private propertyIds;


    event SellerAdded(address seller);
    event SellerRemoved(address seller);
    event PropertyCreated(uint indexed id, string name, uint price);
    event PropertyRemoved(uint indexed id);
    event PropertyPurchased(uint indexed id, address buyer);


    constructor(address _token) {
        paymentToken = IERC20(_token);
        admin = msg.sender;
    }


    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    modifier onlySeller() {
        require(isSeller[msg.sender], "Not seller");
        _;
    }

    modifier propertyExists(uint _id) {
        require(properties[_id].seller != address(0), "Property not found");
        _;
    }

    modifier notSold(uint _id) {
        require(!properties[_id].sold, "Already sold");
        _;
    }


    function addSeller(address account) external onlyAdmin {
        require(account != address(0), "Zero address");
        isSeller[account] = true;
        emit SellerAdded(account);
    }

    function removeSeller(address account) external onlyAdmin {
        isSeller[account] = false;
        emit SellerRemoved(account);
    }


    function createProperty(string memory _name, string memory _location, uint _price)
        external
        onlySeller
    {
        require(_price > 0, "Invalid price");

        propertyCounter++;

        properties[propertyCounter] = Property({
            id: propertyCounter,
            name: _name,
            location: _location,
            price: _price,
            sold: false,
            seller: msg.sender,
            buyer: address(0),
            createdAt: block.timestamp
        });

        propertyIds.push(propertyCounter);

        emit PropertyCreated(propertyCounter, _name, _price);
    }


    function removeProperty(uint _id) external propertyExists(_id) {
        Property storage prop = properties[_id];

        require(
            msg.sender == admin || msg.sender == prop.seller,
            "Not authorized"
        );

        require(!prop.sold, "Cannot remove sold property");

        delete properties[_id];

        emit PropertyRemoved(_id);
    }


    function buyProperty(uint _id) external propertyExists(_id) notSold(_id) {
        Property storage prop = properties[_id];

        require(msg.sender != prop.seller, "Seller cannot buy");

        require(paymentToken.transferFrom(msg.sender, prop.seller, prop.price), "Payment failed");

        prop.sold = true;
        prop.buyer = msg.sender;

        emit PropertyPurchased(_id, msg.sender);
    }


    function getProperty(uint _id) external view propertyExists(_id) returns (Property memory) {
        return properties[_id];
    }

    function getAllProperties() external view returns (Property[] memory) {
        Property[] memory all = new Property[](propertyIds.length);

        for (uint i = 0; i < propertyIds.length; i++) {
            all[i] = properties[propertyIds[i]];
        }

        return all;
    }
}