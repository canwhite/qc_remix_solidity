// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;

contract Father {
    function extCaller() external view returns (address){
        return msg.sender;
    } 
    function pubCaller() public  view  returns (address){
        return  msg.sender;
    }
}

contract Son is Father{
    function caller1() public  view  returns (address){
        //external对内不能直接调用，需要加this
        //这个和其他输出地址不同，是因为这里是当前合约的address
        return  this.extCaller();
    }
    function caller2() public view returns (address){
        //public对内可以直接调用
        return  pubCaller();
    }

    
}
