// SPDX-License-Identifier: MIT

#[starknet::contract]
mod TGEM {
    use openzeppelin::token::erc20::ERC20Component;
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::ContractAddress;

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl ERC20MetadataImpl = ERC20Component::ERC20MetadataImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20CamelOnlyImpl = ERC20Component::ERC20CamelOnlyImpl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableCamelOnlyImpl = OwnableComponent::OwnableCamelOnlyImpl<ContractState>;

    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, recipient: ContractAddress, owner: ContractAddress) {
        self.erc20.initializer('TGEM', 'GEM');
        self.ownable.initializer(owner);

        self.erc20._mint(recipient, 1000000000000000000000);
    }
    // #[constructor]
    // fn constructor(
    //     ref self: ContractState,
    //     initial_supply: u256,
    //     recipient: ContractAddress
    // ) {
    //     let name = 'MyToken1';
    //     let symbol = 'MTK1';
    //     let INITIAL_SUPPLY: u256 = 1000000000000000000000; // Example initial supply value
    //     let RECIPIENT = starknet::contract_address_try_from_felt252(0x0524ca15cc7833cab13dbea627891962e289c8d83cac4dbc8d52e8d6a91f2f5e).unwrap(); // Example recipient address

    //     self.erc20.initializer(name, symbol);
    //     self.erc20._mint(RECIPIENT, INITIAL_SUPPLY);
    //      self.erc20._mint(recipient, initial_supply);
    // }

    #[generate_trait]
    #[external(v0)]
    impl ExternalImpl of ExternalTrait {
        fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            self.ownable.assert_only_owner();
            self.erc20._mint(recipient, amount);
        }
    }
}
