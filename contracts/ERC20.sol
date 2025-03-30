// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20 {
    //给所有变量都加上public，就会自动生成所有变量的get方法
    string public  name;
    string public  symbol;
    uint8  public  decimals; //用来表示指数 
    uint public totalSupply;

    
    mapping (address => uint) public  balances;
    //授权转账，谁给谁授信多少钱
    mapping (address =>mapping (address => uint)) public  allowances;

    event Transfer(address from,address to, uint value);


    //复杂类型，不能写在栈上的，我们都要给他一个memory的关键字，不然就会报错
    constructor(string memory _name,string memory _symbol, uint8 _dicimals, uint _totalSupply){
        name = _name;
        symbol =  _symbol;
        decimals = _dicimals;
        totalSupply = _totalSupply;
        //我们把发出来的所有的token给到合约创建者，注意sender是创建者
        balances[msg.sender] =  _totalSupply;
    }

    //转账
    function transfer(address _to,uint _value) public  {
        //做条件检查，如果不满足情况，输出后边的内容
        require(balances[msg.sender] >= _value,"balance too low");

        //然后做值修改
        balances[msg.sender] -= _value;
        balances[_to] += _value;

        //异步系统通知使用事件来通知，需要我们提前定义一个Event
        emit Transfer(msg.sender,_to,_value);
    }


    //授信 - 授权转账
    function approve(address _to, uint _value) public {
        //先验证有没有前
        require(balances[msg.sender] >= _value,"balance too low");
        //在考虑赋值
        allowances[msg.sender][_to] = _value; 

        //emit Approve 
    }

    //完成授信，我们就可以写tranferFrom，由谁，转给谁，转了多少钱
    function transferFrom(address _from, address _to, uint _value) public {
        //通过_from定位到的是_to的地址:value对儿，我们再通过它的msg.sender拿到value
        require(allowances[_from][msg.sender] >= _value,"no permission");

        allowances[_from][msg.sender] -= _value;
        balances[msg.sender] -=  _value;
        balances[_to] += _value;
        //emit Transfer
        emit Transfer(_from,_to,_value);
    }
}



//合约和合约之间如何实现业务操作
contract BuyCourse {

    // ERC20接口
    ERC20 public token; // 代币合约接口
    address public owner; // 课程所有者
    uint public price; // 课程价格
    
    event CoursePurchased(address buyer, uint amount);

    constructor(address _tokenAddress, uint _price) {
        token = ERC20(_tokenAddress);
        owner = msg.sender;
        price = _price;
    }

    // 核心购买函数
    function buy() external {
        // 检查用户授权额度
        require(
            token.allowances(msg.sender, address(this)) >= price,
            "Insufficient allowance"
        );
        
        // 转移代币
        token.transferFrom(msg.sender, owner, price);
        
        emit CoursePurchased(msg.sender, price);
    }
}



