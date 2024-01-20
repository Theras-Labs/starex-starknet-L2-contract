// SPDX-License-Identifier: MIT

#[starknet::contract]
mod Ticket {
    use openzeppelin::token::erc721::ERC721Component;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::ContractAddress;

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl ERC721MetadataImpl = ERC721Component::ERC721MetadataImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721MetadataCamelOnly = ERC721Component::ERC721MetadataCamelOnlyImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721CamelOnly = ERC721Component::ERC721CamelOnlyImpl<ContractState>;
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableCamelOnlyImpl = OwnableComponent::OwnableCamelOnlyImpl<ContractState>;

    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        total_supply: u256 //can this started with 0 ?
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.erc721.initializer('Ticket', 'TIX');
        self.ownable.initializer(owner);
        self.total_supply.write(0)
    }

    #[generate_trait]
    #[external(v0)]
    impl ExternalImpl of ExternalTrait {
        fn safe_mint(
            ref self: ContractState,
            recipient: ContractAddress,
            token_id: u256,
            data: Span<felt252>,
            token_uri: felt252,
        ) {
            self.ownable.assert_only_owner();
            self.erc721._safe_mint(recipient, token_id, data);
            self.erc721._set_token_uri(token_id, token_uri);
        }

        fn mintCollectible(
            ref self: ContractState, 
            recipient: ContractAddress,
            token_id: u256,
        ){
            // TODO: ASSERT ONLY STORE

            // Generate the next token ID automatically
            let next_token_id = self.total_supply.read();
            
            // Mint the NFT
            self.erc721._mint(recipient, next_token_id);
            
            // Set the token URI (you can customize this as needed)
            let token_uri_str = 'https://metadata/';
            // let token_uri = felt252::from_str(token_uri_str).expect("Failed to convert to felt252");

            self.erc721._set_token_uri(next_token_id, token_uri_str);
        }

        fn safeMintTest(
            ref self: ContractState,
            recipient: ContractAddress,
            tokenId: u256,
            data: Span<felt252>,
            tokenURI: felt252,
        ) {
            self.safe_mint(recipient, tokenId, data, tokenURI);
        }
    }
}
