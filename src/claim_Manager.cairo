use starknet::{ClassHash, ContractAddress};
use array::SpanTrait;


#[starknet::interface]
trait IClaimContract<TContractState> {
    fn claim(
        ref self: TContractState,
        callData: Array<felt252>,
        external_contract: ContractAddress,
        entry_point_selector: felt252
    ) -> bool;
}

#[starknet::contract]
mod claim_Manager {
    use core::array::ArrayTrait;
    use serde::Serde;
    use starknet::{ClassHash, ContractAddress};

    use array::SpanTrait;
    use starknet::syscalls::replace_class_syscall;
    #[storage]
    struct Storage {
        counter: u128,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ExternalContract: ExternalContract,
    }

    #[derive(Drop, starknet::Event)]
    struct ExternalContract {
        value: bool
    }

    #[external(v0)]
    impl ClaimContract of super::IClaimContract<ContractState> {
        fn claim(
            ref self: ContractState,
            callData: Array<felt252>,
            external_contract: ContractAddress,
            entry_point_selector: felt252
        ) -> bool {
            let mut res = starknet::call_contract_syscall(
                address: external_contract,
                entry_point_selector: entry_point_selector,
                calldata: callData.span(),
            );

            let execflag = ResultTrait::is_ok(@res);
            self.emit(ExternalContract { value: execflag });
            execflag
        }
    }
}

