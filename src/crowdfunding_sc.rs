#![no_std]

use multiversx_sc::derive_imports::*;
#[allow(unused_imports)]
use multiversx_sc::imports::*;

#[type_abi]
#[derive(TopEncode, TopDecode, PartialEq, Clone, Copy)]
pub enum Status {
    FundingPeriod,
    Successful,
    Failed,
}

#[multiversx_sc::contract]
pub trait CrowdfundingSc {
    #[init]
    fn init(
        &self,
        target: BigUint,
        deadline: u64,
        min_per_tx: BigUint,
        max_per_wallet: BigUint,
        max_total: BigUint,
    ) {
        require!(target > 0, "Target must be more than 0");
        self.target().set(target);

        require!(deadline > self.get_current_time(), "Deadline can't be in the past");
        self.deadline().set(deadline);

        require!(min_per_tx > 0, "Min per tx must be > 0");
        require!(max_per_wallet > 0, "Max per wallet must be > 0");
        require!(max_total > 0, "Max total must be > 0");

        self.min_per_tx().set(min_per_tx);
        self.max_per_wallet().set(max_per_wallet);
        self.max_total().set(max_total);
    }

    #[upgrade]
    fn upgrade(&self) {}

    #[endpoint]
    #[payable("EGLD")]
    fn fund(&self) {
        let payment = self.call_value().egld().clone_value();
        let current_time = self.get_current_time();

        require!(current_time < self.deadline().get(), "cannot fund after deadline");

        // ✅ mínim per transacció
        let min_per_tx = self.min_per_tx().get();
        require!(payment >= min_per_tx, "Below minimum per transaction");

        // ✅ màxim per wallet acumulat
        let caller = self.blockchain().get_caller();
        let deposited_amount = self.deposit(&caller).get();
        let new_total_wallet = &deposited_amount + &payment;

        let max_per_wallet = self.max_per_wallet().get();
        require!(
            new_total_wallet <= max_per_wallet,
            "Exceeded max per wallet"
        );

        // ✅ màxim global del projecte
        let sc_balance = self.get_current_funds();
        let new_total_project = &sc_balance + &payment;
        let max_total = self.max_total().get();

        require!(
            new_total_project <= max_total,
            "Exceeded max total for project"
        );

        self.deposit(&caller).set(new_total_wallet);
    }

    #[endpoint]
    fn claim(&self) {
        match self.status() {
            Status::FundingPeriod => sc_panic!("cannot claim before deadline"),
            Status::Successful => {
                let caller = self.blockchain().get_caller();
                require!(
                    caller == self.blockchain().get_owner_address(),
                    "only owner can claim successful funding"
                );

                let sc_balance = self.get_current_funds();
                self.send().direct_egld(&caller, &sc_balance);
            }
            Status::Failed => {
                let caller = self.blockchain().get_caller();
                let deposit = self.deposit(&caller).get();

                if deposit > 0u32 {
                    self.deposit(&caller).clear();
                    self.send().direct_egld(&caller, &deposit);
                }
            }
        }
    }

    #[view]
    fn status(&self) -> Status {
        if self.get_current_time() <= self.deadline().get() {
            Status::FundingPeriod
        } else if self.get_current_funds() >= self.target().get() {
            Status::Successful
        } else {
            Status::Failed
        }
    }

    #[view(getCurrentFunds)]
    fn get_current_funds(&self) -> BigUint {
        self.blockchain()
            .get_sc_balance(&EgldOrEsdtTokenIdentifier::egld(), 0)
    }

    #[only_owner]
    #[endpoint(setLimits)]
    fn set_limits(
        &self,
        min_per_tx: BigUint,
        max_per_wallet: BigUint,
        max_total: BigUint,
    ) {
        require!(min_per_tx > 0, "Min per tx must be > 0");
        require!(max_per_wallet > 0, "Max per wallet must be > 0");
        require!(max_total > 0, "Max total must be > 0");

        self.min_per_tx().set(&min_per_tx);
        self.max_per_wallet().set(&max_per_wallet);
        self.max_total().set(&max_total);
    }

    // private

    fn get_current_time(&self) -> u64 {
        self.blockchain().get_block_timestamp()
    }

    // storage

    #[view(getTarget)]
    #[storage_mapper("target")]
    fn target(&self) -> SingleValueMapper<BigUint>;

    #[view(getDeadline)]
    #[storage_mapper("deadline")]
    fn deadline(&self) -> SingleValueMapper<u64>;

    #[view(getDeposit)]
    #[storage_mapper("deposit")]
    fn deposit(&self, donor: &ManagedAddress) -> SingleValueMapper<BigUint>;

    #[view(getMinPerTx)]
    #[storage_mapper("min_per_tx")]
    fn min_per_tx(&self) -> SingleValueMapper<BigUint>;

    #[view(getMaxPerWallet)]
    #[storage_mapper("max_per_wallet")]
    fn max_per_wallet(&self) -> SingleValueMapper<BigUint>;

    #[view(getMaxTotal)]
    #[storage_mapper("max_total")]
    fn max_total(&self) -> SingleValueMapper<BigUint>;
}
