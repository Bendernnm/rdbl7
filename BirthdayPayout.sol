pragma solidity ^0.8.0;

import "./BokkyPooBahsDateTimeLibrary.sol";

contract BirthdayPayout {

    string private _name;
    address private _owner;
    Teammate[] public _teammates;
    mapping(address => bool) private _giftsGiven;

    struct Teammate {
        string name;
        address account;
        uint256 salary;
        uint256 birthday;
    }

    constructor() {
        _name = "max";
        _owner = msg.sender;
    }

    function addTeammate(address account, string memory name, uint256 salary, uint256 birthday) public onlyOwner {
        require(msg.sender != account, "Cannot add oneself");
        Teammate memory newTeammate = Teammate(name, account, salary, birthday);
        _teammates.push(newTeammate);
        emit NewTeammate(account, name);
    }

    function findBirthday() public onlyOwner {
        require(getTeammatesNumber() > 0, "No teammates in the database");

        uint256 currentYear = BokkyPooBahsDateTimeLibrary.timestampToDateTime(block.timestamp).year;

        for (uint256 i = 0; i < getTeammatesNumber(); i++) {
            if (checkBirthday(i, currentYear) && !_giftsGiven[_teammates[i].account]) {
                birthdayPayout(i);
                _giftsGiven[_teammates[i].account] = true;
            }
        }
    }

    function birthdayPayout(uint256 index) public onlyOwner {
        require(index < getTeammatesNumber(), "Invalid teammate index");
        sendToTeammate(index);
        emit HappyBirthday(_teammates[index].name, _teammates[index].account);
    }

    function getDate(uint256 timestamp) public view returns (uint256 year, uint256 month, uint256 day) {
        return BokkyPooBahsDateTimeLibrary.timestampToDate(timestamp);
    }

    function checkBirthday(uint256 index, uint256 currentYear) public view returns (bool) {
        uint256 birthday = getTeammate(index).birthday;
        (, uint256 birthday_month, uint256 birthday_day) = getDate(birthday);
        uint256 today = block.timestamp;
        (, uint256 today_month, uint256 today_day) = getDate(today);

        if (birthday_day == today_day && birthday_month == today_month) {
            uint256 teammateBirthYear = BokkyPooBahsDateTimeLibrary.timestampToDateTime(birthday).year;
            return teammateBirthYear <= currentYear;
        }
        return false;
    }

    function getTeammate(uint256 index) public view returns (Teammate memory) {
        require(index < getTeammatesNumber(), "Invalid teammate index");
        return _teammates[index];
    }

    function getTeam() public view returns (Teammate[] memory) {
        return _teammates;
    }

    function getTeammatesNumber() public view returns (uint256) {
        return _teammates.length;
    }

    function sendToTeammate(uint256 index) internal {
        require(index < getTeammatesNumber(), "Invalid teammate index");
        payable(_teammates[index].account).transfer(_teammates[index].salary);
    }

    function deposit() public payable {}

    modifier onlyOwner {
        require(msg.sender == _owner, "Sender should be the owner of the contract");
        _;
    }

    event NewTeammate(address account, string name);

    event HappyBirthday(string name, address account);
}
