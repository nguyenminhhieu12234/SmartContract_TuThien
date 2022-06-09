// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

contract TuThienSC2{
    struct Project{
        address addressOwner;
        uint amountNeed;
        uint endDate;
        bool isWithdraw;
    }
    
    struct Member{
        address addressDonate;
        uint amount;
    }
   
    //Biến khởi tạo SM.
    Project ProjectOwner;

    mapping(address => Member) public listMembers;
    
    event PayEnvent(address sendFrom, address to, string messages);
    
    constructor ( uint _amountneed, uint _endDate) {
           ProjectOwner = Project( msg.sender, _amountneed, _endDate, false);
    }
    //Lấy ngày kết thúc
    function EndDate() public view returns(uint) {
        return ProjectOwner.endDate;
    }
    //Lấy timestap hiện tại
    function Timestap() public view returns(uint) {
        return block.timestamp;
    }
    // Lấy số tiền cần
    function AmountNeed() public view returns(uint) {
        return ProjectOwner.amountNeed;
    }
    // Lấy số dư hiện tại
    function AmountNow() public view returns(uint) {
        return address(this).balance;
    }
    // Xem dự án thành công hay thất bại
     function Result() public view returns(bool) {
        return block.timestamp > ProjectOwner.endDate &&  ProjectOwner.isWithdraw == true;
    }
    //Hàm đóng góp dự án.
    function Donate(uint _amount) external payable{
        require(block.timestamp < ProjectOwner.endDate,"Project End");
        if(listMembers[msg.sender].addressDonate == address(0))
        {
            listMembers[msg.sender] = Member(msg.sender, _amount);
        }
        else
        {
            listMembers[msg.sender].amount += _amount;
        }
        if(address(this).balance >= ProjectOwner.amountNeed){
            ProjectOwner.isWithdraw = true;
        }
        emit PayEnvent(msg.sender, address(this), "success");
    }
    //Hàm rút tiền dự án nếu dự án hoàn thành.
    function Withdraw( uint _amount) external{
        require(ProjectOwner.addressOwner == msg.sender && block.timestamp > ProjectOwner.endDate && ProjectOwner.isWithdraw == true, "Withdraw Fail");
        payable(msg.sender).transfer(_amount);
        emit PayEnvent(address(this), msg.sender, "success");
    }
    //Hàm hoàn tiền dự án nếu dự án thất bại.
    function Refund() external{
        require(block.timestamp > ProjectOwner.endDate && ProjectOwner.isWithdraw == false,"Refund Fail");
        payable(msg.sender).transfer(listMembers[msg.sender].amount);
        listMembers[msg.sender].amount = 0;
        emit PayEnvent(address(this), msg.sender, "success");
    }
}
