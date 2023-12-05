// SPDX-License-Identifier: MIT
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

pragma solidity ^0.8.19;

contract ERC20Token is ERC20 {
    constructor(string memory name, string memory symbol, uint256 supply) ERC20(name, symbol) {
        _mint(msg.sender, supply);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract ERC721Token is ERC721 {
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function mint(address user, uint256 id) external {
        _mint(user, id);
    }
}

contract propertyMarketplace {
    ERC721Token public nftMarket;
    address public TokenForInvesting;
    uint256 public users;
    uint256 public numOfPropertiesOnSelling;

    struct property {
        address token;
        address owner;
        uint256 propertyCost;
        uint256 TotalAmountInvested;
        uint256 numOfinvestors;
    }

    struct investor {
        uint256[] propertiesInvested;
        address investorAddress;
    }

    mapping(uint256 => property) public Property;
    mapping(uint256 => investor) public Investor;

    mapping(address => mapping(uint256 => bool)) public hasUserInvestedInThisProperty;
    mapping(address => mapping(uint256 => uint256)) public AmountInvestedInPropertyByUser;
    mapping(address => uint256) public investorId;
    mapping(address => mapping(uint256 => address)) public UserPropertyToken;
    mapping(address => uint256) public numOfPropertiesOfUser;

    // mapping(address=>address) public UserInvestedInproperty;

    constructor(string memory name, string memory symbol, address investingToken) {
        nftMarket = new ERC721Token(name, symbol);
        TokenForInvesting = investingToken;
    }

    function listProperty(string memory propertyName, uint256 value, string memory Symbol)
        public
        returns (address, uint256)
    {
        if (numOfPropertiesOfUser[msg.sender] == 0) {
            users++;
        }
        numOfPropertiesOnSelling++;
        uint256 a = users;
        numOfPropertiesOfUser[msg.sender] += 1;
        nftMarket.mint(msg.sender, a);
        ERC20Token token = new ERC20Token(propertyName, Symbol, value);
        token.mint(msg.sender, value);
        uint256 b = numOfPropertiesOfUser[msg.sender];
        UserPropertyToken[msg.sender][b] = address(token);
        Property[numOfPropertiesOnSelling].token = address(token);
        Property[numOfPropertiesOnSelling].owner = msg.sender;
        Property[numOfPropertiesOnSelling].propertyCost = value;
        Property[numOfPropertiesOnSelling].TotalAmountInvested = 0;
        Property[numOfPropertiesOnSelling].numOfinvestors = 0;
        bool success;
        if (ERC20(token).balanceOf(msg.sender) > 0) {
            success = true;
        }
        return (address(token), a);
    }

    function InitiateInvestment(uint256 _property, uint256 amount) public returns (address, uint256, uint256, bool) {
        uint256 investedAmt = AmountInvestedInPropertyByUser[msg.sender][_property];
        // uint256 totalAmountInvestedInthisProperty = TotalAmountInvested(_property);
        uint256 AmountUserCanInvest = AmountUserCanInvestInProperty(_property);
        uint256 PropertyCost = propertyCost(_property);
        // require(amount < PropertyCost, " amount is greater than property cost");
        // require(
        //     investedAmt + amount <= PropertyCost,
        //     " previous invested amount by user + amount is greater than property cost"
        // );
        // require(amount <= AmountUserCanInvest,"please check how much you can invest");
        if (hasUserInvestedInThisProperty[msg.sender][_property] == false) {
            investorId[msg.sender] = Property[_property].numOfinvestors + 1;
        }

        uint256 a = investorId[msg.sender];
        if (hasUserInvestedInThisProperty[msg.sender][_property] == false) {
            Property[_property].numOfinvestors++;
            Investor[a].investorAddress = msg.sender;
            Investor[a].propertiesInvested.push(_property);
        }
        hasUserInvestedInThisProperty[msg.sender][_property] = true;
        AmountInvestedInPropertyByUser[msg.sender][_property] += amount;
        Property[_property].TotalAmountInvested += amount;
        // ERC20(TokenForInvesting).approve(address(this),amount);
        bool success = ERC20(TokenForInvesting).transferFrom(msg.sender, address(this), amount);
        if (!success) {
            success = false;
        }
        return (TokenForInvesting, a, amount, success);
    }

    function UsdtContractBalance() public view returns (uint256) {
        return ERC20(TokenForInvesting).balanceOf(address(this));
    }

    function AmountUserCanInvestInProperty(uint256 _propertyId) public view returns (uint256) {
        uint256 a = TotalAmountInvested(_propertyId);
        uint256 b = propertyCost(_propertyId);

        return b - a;
    }

    function TotalAmountInvested(uint256 _propertyId) internal view returns (uint256) {
        return Property[_propertyId].TotalAmountInvested;
    }

    function propertyCost(uint256 _propertyId) internal view returns (uint256) {
        return Property[_propertyId].propertyCost;
    }

    function PropertiesInWhichUserInvested(uint256 _investor) public view returns (uint256[] memory) {
        return Investor[_investor].propertiesInvested;
    }

    function transferFundsToInvestors(address _investor, uint256 _property) public returns (uint256, bool, address) {
        require(
            hasUserInvestedInThisProperty[_investor][_property] == true,
            "this address has not invested in this property"
        );
        uint256 amount = AmountInvestedInPropertyByUser[_investor][_property];
        address propertyTokenAddress = Property[_property].token;
        uint256 a;
        bool pass;
        require(amount > 0 && propertyTokenAddress != address(0), "fail");
        if (amount > 0 && propertyTokenAddress != address(0)) {
            require(
                ERC20(propertyTokenAddress).transferFrom(msg.sender, _investor, amount),
                "transaction of property tokens failed"
            );
            require(ERC20(TokenForInvesting).transfer(msg.sender, amount), "transaction  of usdt tokens failed");
            a = amount;
            pass = true;
        } else {
            a = 0;
            pass = false;
        }

        return (a, pass, msg.sender);
    }

    function Property1(uint256 id) public view returns (property memory) {
        return Property[id];
    }

    function amountInvestedInPropertyByUser(address _investor, uint256 _property) public view returns (uint256) {
        return AmountInvestedInPropertyByUser[_investor][_property];
    }
}
