// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;

contract A {
    uint public  a;
    function setA() public {
        a = 5;
    }
}

contract B {
    uint public b;
    function setB() public {
        b = 3;
    } 
    
    enum Operation {
        DelegateCall,
        Call
    }

    // Operation == 0 的时候合约b delegate 调用合约a方法，地址是a的地址
    // 关键函数：通过 call/delegatecall 触发合约A的 setA()
    function setA(address to, Operation operation) public returns (bool success) {
        bytes4 selector = bytes4(keccak256("setA()")); // 函数选择器（0x6c5ce5e6）
        bytes memory data = abi.encodeWithSelector(selector); // 编码调用数据
        
        if(operation == Operation.DelegateCall) {
            assembly {
                // delegatecall(gas, address, input_ptr, input_len, output_ptr, output_len)
                success := delegatecall(gas(), to, add(data, 0x20), mload(data), 0, 0)
            }
        } else {
            assembly {
                // call(gas, address, value, input_ptr, input_len, output_ptr, output_len)
                success := call(gas(), to, 0, add(data, 0x20), mload(data), 0, 0)
            }
        }
    }

}

