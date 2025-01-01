module turbos_clmm::position_manager {
	use std::vector;
    use std::type_name::{Self};
    use sui::transfer;
    use sui::event;
    use std::string::{Self, String};
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_object_field as dof;
	use sui::coin::{Coin};
    use sui::table::{Self, Table};
    use turbos_clmm::i32::{Self, I32};
    use turbos_clmm::math_liquidity;
    use turbos_clmm::math_tick;
    use turbos_clmm::pool::{Self, Pool, PositionRewardInfo as PositionRewardInfoInPool, PoolRewardVault, Versioned};
    use turbos_clmm::position_nft::{Self, TurbosPositionNFT};
    use sui::clock::{Self, Clock};
    
    struct PositionRewardInfo has store {
        reward_growth_inside: u128,
        amount_owed: u64,
    }

	struct Position has key, store {
        id: UID,
        tick_lower_index: I32,
        tick_upper_index: I32,
        liquidity: u128,
        fee_growth_inside_a: u128,
        fee_growth_inside_b: u128,
        tokens_owed_a: u64,
        tokens_owed_b: u64,
        reward_infos: vector<PositionRewardInfo>,
    }

	struct Positions has key, store {
        id: UID,
		nft_minted: u64,
        user_position: Table<address, ID>,
        nft_name: String,
        nft_description: String,
        nft_img_url: String,
    }

    fun mint_nft_with_return_<CoinTypeA, CoinTypeB, FeeType>(
        arg0: sui::object::ID,
        arg1: sui::object::ID,
        arg2: &mut Positions,
        arg3: &mut sui::tx_context::TxContext
    ) : turbos_clmm::position_nft::TurbosPositionNFT {
        arg2.nft_minted = arg2.nft_minted + 1;
        turbos_clmm::position_nft::mint(arg2.nft_name, arg2.nft_description, arg2.nft_img_url, arg0, arg1, std::type_name::get<CoinTypeA>(), std::type_name::get<CoinTypeB>(), std::type_name::get<FeeType>(), arg3)
    }

    public fun mint_with_return_<CoinTypeA, CoinTypeB, FeeType>(
        arg0: &mut turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>,
        arg1: &mut Positions,
        arg2: vector<sui::coin::Coin<CoinTypeA>>,
        arg3: vector<sui::coin::Coin<CoinTypeB>>,
        arg4: u32,
        arg5: bool,
        arg6: u32,
        arg7: bool,
        arg8: u64,
        arg9: u64,
        arg10: u64,
        arg11: u64,
        arg12: u64,
        arg13: &sui::clock::Clock,
        arg14: &turbos_clmm::pool::Versioned,
        arg15: &mut sui::tx_context::TxContext
    ) : (turbos_clmm::position_nft::TurbosPositionNFT, sui::coin::Coin<CoinTypeA>, sui::coin::Coin<CoinTypeB>) {
        turbos_clmm::pool::check_version(arg14);
        assert!(sui::clock::timestamp_ms(arg13) <= arg12, 8);
        assert!(std::vector::length<sui::coin::Coin<CoinTypeA>>(&arg2) > 0, 4);
        assert!(std::vector::length<sui::coin::Coin<CoinTypeB>>(&arg3) > 0, 4);
        let v0 = turbos_clmm::i32::from_u32_neg(arg4, arg5);
        let v1 = turbos_clmm::i32::from_u32_neg(arg6, arg7);
        let v2 = sui::object::new(arg15);
        let v3 = sui::object::uid_to_inner(&v2);
        let v4 = mint_nft_with_return_<CoinTypeA, CoinTypeB, FeeType>(
            sui::object::id<turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>>(arg0),
            v3,
            arg1,
            arg15
        );
        let v5 = sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(&v4);
        let v6 = turbos_clmm::pool::get_position_key(v5, v0, v1);
        let (v7, v8, v9, v10, v11) = add_liquidity_with_return_<CoinTypeA, CoinTypeB, FeeType>(
            arg0,
            turbos_clmm::pool::merge_coin<CoinTypeA>(arg2),
            turbos_clmm::pool::merge_coin<CoinTypeB>(arg3),
            v5,
            v0,
            v1,
            arg8,
            arg9,
            arg13,
            arg15
        );
        assert!(v8 >= arg10 && v9 >= arg11, 5);
        let v12 = Position{
            id                  : v2, 
            tick_lower_index    : v0, 
            tick_upper_index    : v1, 
            liquidity           : v7, 
            fee_growth_inside_a : turbos_clmm::pool::get_position_fee_growth_inside_a<CoinTypeA, CoinTypeB, FeeType>(arg0, v6), 
            fee_growth_inside_b : turbos_clmm::pool::get_position_fee_growth_inside_b<CoinTypeA, CoinTypeB, FeeType>(arg0, v6), 
            tokens_owed_a       : 0, 
            tokens_owed_b       : 0, 
            reward_infos        : std::vector::empty<PositionRewardInfo>(),
        };
        copy_position<CoinTypeA, CoinTypeB, FeeType>(arg0, v6, &mut v12);
        sui::dynamic_object_field::add<address, Position>(&mut arg1.id, v5, v12);
        insert_user_position(arg1, v3, v5);
        let v13 = IncreaseLiquidityEvent{
            pool      : sui::object::id<turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>>(arg0), 
            amount_a  : v8, 
            amount_b  : v9, 
            liquidity : v7,
        };
        sui::event::emit<IncreaseLiquidityEvent>(v13);
        (v4, v10, v11)
    }

    public fun increase_liquidity_with_return_<CoinTypeA, CoinTypeB, FeeType>(
        pool: &mut Pool<CoinTypeA, CoinTypeB, FeeType>,
        positions: &mut Positions,
        coins_a: vector<Coin<CoinTypeA>>, 
        coins_b: vector<Coin<CoinTypeB>>, 
        nft: &mut TurbosPositionNFT,
        amount_a_desired: u64,
        amount_b_desired: u64,
        amount_a_min: u64,
        amount_b_min: u64,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
        ctx: &mut TxContext
    ): (Coin<CoinTypeA>, Coin<CoinTypeB>) {
        abort 0
    }

    public entry fun mint<CoinTypeA, CoinTypeB, FeeType>(
		pool: &mut Pool<CoinTypeA, CoinTypeB, FeeType>,
		positions: &mut Positions,
		coins_a: vector<Coin<CoinTypeA>>, 
		coins_b: vector<Coin<CoinTypeB>>, 
		tick_lower_index: u32,
		tick_lower_index_is_neg: bool,
        tick_upper_index: u32,
		tick_upper_index_is_neg: bool,
		amount_a_desired: u64,
        amount_b_desired: u64,
        amount_a_min: u64,
        amount_b_min: u64,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
		ctx: &mut TxContext
    ) {
        abort 0
    }

    public entry fun burn<CoinTypeA, CoinTypeB, FeeType>(
        positions: &mut Positions,
        nft: TurbosPositionNFT,
        versioned: &Versioned,
        _ctx: &mut TxContext
    ) {
        abort 0
    }

    public entry fun increase_liquidity<CoinTypeA, CoinTypeB, FeeType>(
		pool: &mut Pool<CoinTypeA, CoinTypeB, FeeType>,
		positions: &mut Positions,
		coins_a: vector<Coin<CoinTypeA>>, 
		coins_b: vector<Coin<CoinTypeB>>, 
		nft: &mut TurbosPositionNFT,
		amount_a_desired: u64,
        amount_b_desired: u64,
        amount_a_min: u64,
        amount_b_min: u64,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
		ctx: &mut TxContext
    ) {
        abort 0
    }

    public entry fun decrease_liquidity<CoinTypeA, CoinTypeB, FeeType>(
		pool: &mut Pool<CoinTypeA, CoinTypeB, FeeType>,
		positions: &mut Positions,
		nft: &mut TurbosPositionNFT,
		liquidity: u128,
        amount_a_min: u64,
        amount_b_min: u64,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
		ctx: &mut TxContext
    ) {
        abort 0
    }

    public fun collect_with_return_<CoinTypeA, CoinTypeB, FeeType>(
        pool: &mut Pool<CoinTypeA, CoinTypeB, FeeType>,
        positions: &mut Positions,
        nft: &mut TurbosPositionNFT,
        amount_a_max: u64,
        amount_b_max: u64,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
        ctx: &mut TxContext
    ): (Coin<CoinTypeA>, Coin<CoinTypeB>) {
        abort 0
    }

    public entry fun collect<CoinTypeA, CoinTypeB, FeeType>(
		pool: &mut Pool<CoinTypeA, CoinTypeB, FeeType>,
		positions: &mut Positions,
		nft: &mut TurbosPositionNFT,
        amount_a_max: u64,
        amount_b_max: u64,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
		ctx: &mut TxContext
    ) {
        abort 0
    }

    public fun collect_reward_with_return_<CoinTypeA, CoinTypeB, FeeType, RewardCoin>(
        pool: &mut Pool<CoinTypeA, CoinTypeB, FeeType>,
        positions: &mut Positions,
        nft: &mut TurbosPositionNFT,
        vault: &mut PoolRewardVault<RewardCoin>,
        reward_index: u64,
        amount_max: u64,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
        ctx: &mut TxContext
    ): Coin<RewardCoin> {
        abort 0
    }

    public entry fun collect_reward<CoinTypeA, CoinTypeB, FeeType, RewardCoin>(
		pool: &mut Pool<CoinTypeA, CoinTypeB, FeeType>,
		positions: &mut Positions,
		nft: &mut TurbosPositionNFT,
        vault: &mut PoolRewardVault<RewardCoin>,
        reward_index: u64,
        amount_max: u64,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
		ctx: &mut TxContext
    ) {
        abort 0
    }

    public fun get_position_info(
        positions: &Positions,
        nft_address: address,
    ): (I32, I32, u128) {
        let position = sui::dynamic_object_field::borrow<address, Position>(&positions.id, nft_address);
        (position.tick_lower_index, position.tick_upper_index, position.liquidity)
    }

    public entry fun burn<CoinTypeA, CoinTypeB, FeeType>(arg0: &mut Positions, arg1: turbos_clmm::position_nft::TurbosPositionNFT, arg2: &turbos_clmm::pool::Versioned, arg3: &mut sui::tx_context::TxContext) {
        turbos_clmm::pool::check_version(arg2);
        let v0 = sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(&arg1);
        let v1 = sui::dynamic_object_field::borrow_mut<address, Position>(&mut arg0.id, v0);
        assert!(v1.liquidity == 0 && v1.tokens_owed_a == 0 && v1.tokens_owed_b == 0, 6);
        let v2 = 0;
        while (v2 < std::vector::length<PositionRewardInfo>(&v1.reward_infos)) {
            assert!(std::vector::borrow<PositionRewardInfo>(&v1.reward_infos, v2).amount_owed == 0, 6);
            v2 = v2 + 1;
        };
        delete_user_position(arg0, v0);
        burn_nft(arg1);
    }
    
    public fun collect_reward_with_return_<CoinTypeA, CoinTypeB, FeeType, T3>(arg0: &mut turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>, arg1: &mut Positions, arg2: &mut turbos_clmm::position_nft::TurbosPositionNFT, arg3: &mut turbos_clmm::pool::PoolRewardVault<T3>, arg4: u64, arg5: u64, arg6: address, arg7: u64, arg8: &sui::clock::Clock, arg9: &turbos_clmm::pool::Versioned, arg10: &mut sui::tx_context::TxContext) : sui::coin::Coin<T3> {
        turbos_clmm::pool::check_version(arg9);
        assert!(sui::object::id<turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>>(arg0) == turbos_clmm::position_nft::pool_id(arg2), 15);
        assert!(sui::clock::timestamp_ms(arg8) <= arg7, 8);
        let v0 = sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(arg2);
        let v1 = sui::dynamic_object_field::borrow_mut<address, Position>(&mut arg1.id, v0);
        let v2 = if (turbos_clmm::pool::check_position_exists<CoinTypeA, CoinTypeB, FeeType>(arg0, v0, v1.tick_lower_index, v1.tick_upper_index)) {
            v0
        } else {
            sui::tx_context::sender(arg10)
        };
        if (v1.liquidity > 0) {
            let (_, _) = turbos_clmm::pool::burn<CoinTypeA, CoinTypeB, FeeType>(arg0, v2, v1.tick_lower_index, v1.tick_upper_index, 0, arg8, arg10);
            copy_position<CoinTypeA, CoinTypeB, FeeType>(arg0, turbos_clmm::pool::get_position_key(v2, v1.tick_lower_index, v1.tick_upper_index), v1);
        };
        assert!(arg4 < std::vector::length<PositionRewardInfo>(&v1.reward_infos), 10);
        let v5 = std::vector::borrow_mut<PositionRewardInfo>(&mut v1.reward_infos, arg4);
        let v6 = if (arg5 > v5.amount_owed) {
            v5.amount_owed
        } else {
            arg5
        };
        let v7 = turbos_clmm::pool::collect_reward_with_return_<CoinTypeA, CoinTypeB, FeeType, T3>(arg0, arg3, arg6, v2, v1.tick_lower_index, v1.tick_upper_index, v6, arg4, arg10);
        v5.amount_owed = v5.amount_owed - v6;
        let v8 = CollectRewardEvent{
            pool         : sui::object::id<turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>>(arg0), 
            amount       : sui::coin::value<T3>(&v7), 
            vault        : sui::object::id<turbos_clmm::pool::PoolRewardVault<T3>>(arg3), 
            reward_index : arg4, 
            recipient    : arg6,
        };
        sui::event::emit<CollectRewardEvent>(v8);
        v7
    }
    
    public(friend) fun migrate_position<CoinTypeA, CoinTypeB, FeeType>(arg0: &mut turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>, arg1: &mut Positions, arg2: vector<address>, arg3: address, arg4: &mut sui::tx_context::TxContext) {
        let v0 = std::vector::pop_back<address>(&mut arg2);
        let (v1, v2) = get_position_tick_info(arg1, v0);
        assert!(turbos_clmm::pool::check_position_exists<CoinTypeA, CoinTypeB, FeeType>(arg0, arg3, v1, v2), 11);
        assert!(!turbos_clmm::pool::check_position_exists<CoinTypeA, CoinTypeB, FeeType>(arg0, v0, v1, v2), 12);
        let v3 = turbos_clmm::pool::get_position_key(arg3, v1, v2);
        copy_position_with_address<CoinTypeA, CoinTypeB, FeeType>(arg0, arg1, v3, v0);
        turbos_clmm::pool::migrate_position<CoinTypeA, CoinTypeB, FeeType>(arg0, v3, turbos_clmm::pool::get_position_key(v0, v1, v2), arg4);
        while (std::vector::length<address>(&arg2) > 0) {
            clean_position(arg1, v1, v2, std::vector::pop_back<address>(&mut arg2));
        };
    }
    
    public entry fun mint<CoinTypeA, CoinTypeB, FeeType>(arg0: &mut turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>, arg1: &mut Positions, arg2: vector<sui::coin::Coin<CoinTypeA>>, arg3: vector<sui::coin::Coin<CoinTypeB>>, arg4: u32, arg5: bool, arg6: u32, arg7: bool, arg8: u64, arg9: u64, arg10: u64, arg11: u64, arg12: address, arg13: u64, arg14: &sui::clock::Clock, arg15: &turbos_clmm::pool::Versioned, arg16: &mut sui::tx_context::TxContext) {
        turbos_clmm::pool::check_version(arg15);
        let (v0, v1, v2) = mint_with_return_<CoinTypeA, CoinTypeB, FeeType>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg13, arg14, arg15, arg16);
        let v3 = v2;
        let v4 = v1;
        if (sui::coin::value<CoinTypeA>(&v4) == 0) {
            sui::coin::destroy_zero<CoinTypeA>(v4);
        } else {
            sui::transfer::public_transfer<sui::coin::Coin<CoinTypeA>>(v4, sui::tx_context::sender(arg16));
        };
        if (sui::coin::value<CoinTypeB>(&v3) == 0) {
            sui::coin::destroy_zero<CoinTypeB>(v3);
        } else {
            sui::transfer::public_transfer<sui::coin::Coin<CoinTypeB>>(v3, sui::tx_context::sender(arg16));
        };
        sui::transfer::public_transfer<turbos_clmm::position_nft::TurbosPositionNFT>(v0, arg12);
    }
    
    fun add_liquidity<CoinTypeA, CoinTypeB, FeeType>(arg0: &mut turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>, arg1: sui::coin::Coin<CoinTypeA>, arg2: sui::coin::Coin<CoinTypeB>, arg3: address, arg4: turbos_clmm::i32::I32, arg5: turbos_clmm::i32::I32, arg6: u64, arg7: u64, arg8: &sui::clock::Clock, arg9: &mut sui::tx_context::TxContext) : (u128, u64, u64) {
        abort 0
    }
    
    fun add_liquidity_with_return_<CoinTypeA, CoinTypeB, FeeType>(
        arg0: &mut turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>,
        arg1: sui::coin::Coin<CoinTypeA>,
        arg2: sui::coin::Coin<CoinTypeB>,
        arg3: address,
        arg4: turbos_clmm::i32::I32,
        arg5: turbos_clmm::i32::I32,
        arg6: u64,
        arg7: u64,
        arg8: &sui::clock::Clock,
        arg9: &mut sui::tx_context::TxContext
    ) : (u128, u64, u64, sui::coin::Coin<CoinTypeA>, sui::coin::Coin<CoinTypeB>) {
        let v0 = turbos_clmm::math_liquidity::get_liquidity_for_amounts(
            turbos_clmm::pool::get_pool_sqrt_price<CoinTypeA, CoinTypeB, FeeType>(arg0),
            turbos_clmm::math_tick::sqrt_price_from_tick_index(arg4),
            turbos_clmm::math_tick::sqrt_price_from_tick_index(arg5),
            (arg6 as u128),
            (arg7 as u128)
        );
        let (v1, v2) = turbos_clmm::pool::mint<CoinTypeA, CoinTypeB, FeeType>(arg0, arg3, arg4, arg5, v0, arg8, arg9);
        let (v3, v4) = turbos_clmm::pool::get_pool_balance<CoinTypeA, CoinTypeB, FeeType>(arg0);
        let (v5, v6) = turbos_clmm::pool::split_and_return_<CoinTypeA, CoinTypeB, FeeType>(arg0, arg1, v1, arg2, v2, arg9);
        let (v7, v8) = turbos_clmm::pool::get_pool_balance<CoinTypeA, CoinTypeB, FeeType>(arg0);
        assert!(v3 + v1 <= v7, 7);
        assert!(v4 + v2 <= v8, 7);
        (v0, v1, v2, v5, v6)
    }
    
    fun burn_nft(arg0: turbos_clmm::position_nft::TurbosPositionNFT) {
        turbos_clmm::position_nft::burn(arg0);
    }
    
    public entry fun burn_nft_directly(arg0: turbos_clmm::position_nft::TurbosPositionNFT) {
        turbos_clmm::position_nft::burn(arg0);
    }
    
    fun clean_position(arg0: &mut Positions, arg1: turbos_clmm::i32::I32, arg2: turbos_clmm::i32::I32, arg3: address) {
        let v0 = sui::dynamic_object_field::borrow_mut<address, Position>(&mut arg0.id, arg3);
        assert!(turbos_clmm::i32::eq(v0.tick_lower_index, arg1) && turbos_clmm::i32::eq(v0.tick_upper_index, arg2), 14);
        v0.liquidity = 0;
        v0.tick_lower_index = turbos_clmm::i32::zero();
        v0.tick_upper_index = turbos_clmm::i32::zero();
        v0.fee_growth_inside_a = 0;
        v0.fee_growth_inside_b = 0;
        v0.tokens_owed_a = 0;
        v0.tokens_owed_b = 0;
        let v1 = 0;
        while (v1 < std::vector::length<PositionRewardInfo>(&v0.reward_infos)) {
            let v2 = std::vector::borrow_mut<PositionRewardInfo>(&mut v0.reward_infos, v1);
            v2.reward_growth_inside = 0;
            v2.amount_owed = 0;
            v1 = v1 + 1;
        };
        if (sui::table::contains<address, sui::object::ID>(&arg0.user_position, arg3)) {
            sui::table::remove<address, sui::object::ID>(&mut arg0.user_position, arg3);
        };
    }
    
    public entry fun collect<CoinTypeA, CoinTypeB, FeeType>(arg0: &mut turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>, arg1: &mut Positions, arg2: &mut turbos_clmm::position_nft::TurbosPositionNFT, arg3: u64, arg4: u64, arg5: address, arg6: u64, arg7: &sui::clock::Clock, arg8: &turbos_clmm::pool::Versioned, arg9: &mut sui::tx_context::TxContext) {
        turbos_clmm::pool::check_version(arg8);
        let (v0, v1) = collect_with_return_<CoinTypeA, CoinTypeB, FeeType>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
        sui::transfer::public_transfer<sui::coin::Coin<CoinTypeA>>(v0, arg5);
        sui::transfer::public_transfer<sui::coin::Coin<CoinTypeB>>(v1, arg5);
    }
    
    public entry fun collect_reward<CoinTypeA, CoinTypeB, FeeType, T3>(arg0: &mut turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>, arg1: &mut Positions, arg2: &mut turbos_clmm::position_nft::TurbosPositionNFT, arg3: &mut turbos_clmm::pool::PoolRewardVault<T3>, arg4: u64, arg5: u64, arg6: address, arg7: u64, arg8: &sui::clock::Clock, arg9: &turbos_clmm::pool::Versioned, arg10: &mut sui::tx_context::TxContext) {
        turbos_clmm::pool::check_version(arg9);
        sui::transfer::public_transfer<sui::coin::Coin<T3>>(collect_reward_with_return_<CoinTypeA, CoinTypeB, FeeType, T3>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10), arg6);
    }
    
    public fun collect_with_return_<CoinTypeA, CoinTypeB, FeeType>(arg0: &mut turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>, arg1: &mut Positions, arg2: &mut turbos_clmm::position_nft::TurbosPositionNFT, arg3: u64, arg4: u64, arg5: address, arg6: u64, arg7: &sui::clock::Clock, arg8: &turbos_clmm::pool::Versioned, arg9: &mut sui::tx_context::TxContext) : (sui::coin::Coin<CoinTypeA>, sui::coin::Coin<CoinTypeB>) {
        turbos_clmm::pool::check_version(arg8);
        assert!(sui::object::id<turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>>(arg0) == turbos_clmm::position_nft::pool_id(arg2), 15);
        assert!(sui::clock::timestamp_ms(arg7) <= arg6, 8);
        let v0 = sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(arg2);
        let v1 = sui::dynamic_object_field::borrow_mut<address, Position>(&mut arg1.id, v0);
        let v2 = if (turbos_clmm::pool::check_position_exists<CoinTypeA, CoinTypeB, FeeType>(arg0, v0, v1.tick_lower_index, v1.tick_upper_index)) {
            v0
        } else {
            sui::tx_context::sender(arg9)
        };
        if (v1.liquidity > 0) {
            let (_, _) = turbos_clmm::pool::burn<CoinTypeA, CoinTypeB, FeeType>(arg0, v2, v1.tick_lower_index, v1.tick_upper_index, 0, arg7, arg9);
            copy_position<CoinTypeA, CoinTypeB, FeeType>(arg0, turbos_clmm::pool::get_position_key(v2, v1.tick_lower_index, v1.tick_upper_index), v1);
        };
        let v5 = v1.tokens_owed_a;
        let v6 = v1.tokens_owed_b;
        let v7 = if (arg3 > v5) {
            v5
        } else {
            arg3
        };
        let v8 = if (arg4 > v6) {
            v6
        } else {
            arg4
        };
        let (v9, v10) = turbos_clmm::pool::collect_v2<CoinTypeA, CoinTypeB, FeeType>(arg0, arg5, v2, v1.tick_lower_index, v1.tick_upper_index, v7, v8, arg9);
        let (v11, v12) = turbos_clmm::pool::split_out_and_return_<CoinTypeA, CoinTypeB, FeeType>(arg0, v9, v10, arg9);
        v1.tokens_owed_a = v1.tokens_owed_a - v7;
        v1.tokens_owed_b = v1.tokens_owed_b - v8;
        let v13 = CollectEvent{
            pool      : sui::object::id<turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>>(arg0), 
            amount_a  : v9, 
            amount_b  : v10, 
            recipient : arg5,
        };
        sui::event::emit<CollectEvent>(v13);
        (v11, v12)
    }
    
    fun copy_position<CoinTypeA, CoinTypeB, FeeType>(arg0: &turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>, arg1: std::string::String, arg2: &mut Position) {
        let (v0, v1, v2, v3, v4, v5) = turbos_clmm::pool::get_position_base_info<CoinTypeA, CoinTypeB, FeeType>(arg0, arg1);
        arg2.liquidity = v0;
        arg2.fee_growth_inside_a = v1;
        arg2.fee_growth_inside_b = v2;
        arg2.tokens_owed_a = v3;
        arg2.tokens_owed_b = v4;
        copy_reward_info(v5, &mut arg2.reward_infos);
    }
    
    fun copy_position_with_address<CoinTypeA, CoinTypeB, FeeType>(arg0: &turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>, arg1: &mut Positions, arg2: std::string::String, arg3: address) {
        copy_position<CoinTypeA, CoinTypeB, FeeType>(arg0, arg2, sui::dynamic_object_field::borrow_mut<address, Position>(&mut arg1.id, arg3));
    }
    
    fun copy_reward_info(arg0: &vector<turbos_clmm::pool::PositionRewardInfo>, arg1: &mut vector<PositionRewardInfo>) {
        let v0 = 0;
        while (v0 < std::vector::length<turbos_clmm::pool::PositionRewardInfo>(arg0)) {
            let (v1, v2) = turbos_clmm::pool::get_position_reward_info(std::vector::borrow<turbos_clmm::pool::PositionRewardInfo>(arg0, v0));
            try_init_reward_infos(arg1, v0);
            let v3 = std::vector::borrow_mut<PositionRewardInfo>(arg1, v0);
            v3.reward_growth_inside = v1;
            v3.amount_owed = v2;
            v0 = v0 + 1;
        };
    }
    
    public entry fun decrease_liquidity<CoinTypeA, CoinTypeB, FeeType>(arg0: &mut turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>, arg1: &mut Positions, arg2: &mut turbos_clmm::position_nft::TurbosPositionNFT, arg3: u128, arg4: u64, arg5: u64, arg6: u64, arg7: &sui::clock::Clock, arg8: &turbos_clmm::pool::Versioned, arg9: &mut sui::tx_context::TxContext) {
        turbos_clmm::pool::check_version(arg8);
        let (v0, v1) = decrease_liquidity_with_return_<CoinTypeA, CoinTypeB, FeeType>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
        let v2 = sui::tx_context::sender(arg9);
        sui::transfer::public_transfer<sui::coin::Coin<CoinTypeA>>(v0, v2);
        sui::transfer::public_transfer<sui::coin::Coin<CoinTypeB>>(v1, v2);
    }
    
    public fun decrease_liquidity_with_return_<CoinTypeA, CoinTypeB, FeeType>(
        pool: &mut turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>,
        positions: &mut Positions,
        nft: &mut turbos_clmm::position_nft::TurbosPositionNFT,
        liquidity: u128,
        amount_a_min: u64,
        amount_b_min: u64,
        deadline: u64,
        clock: &sui::clock::Clock,
        versioned: &turbos_clmm::pool::Versioned,
        ctx: &mut sui::tx_context::TxContext
    ) : (sui::coin::Coin<CoinTypeA>, sui::coin::Coin<CoinTypeB>) {
        turbos_clmm::pool::check_version(versioned);
        assert!(sui::object::id<turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>>(pool) == turbos_clmm::position_nft::pool_id(nft), 15);
        assert!(sui::clock::timestamp_ms(clock) <= deadline, 8);
        let v0 = sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(nft);
        let v1 = sui::dynamic_object_field::borrow_mut<address, Position>(&mut positions.id, v0);
        assert!(v1.liquidity >= liquidity, 9);
        let v2 = if (turbos_clmm::pool::check_position_exists<CoinTypeA, CoinTypeB, FeeType>(pool, v0, v1.tick_lower_index, v1.tick_upper_index)) {
            v0
        } else {
            sui::tx_context::sender(ctx)
        };
        let (v3, v4) = turbos_clmm::pool::burn<CoinTypeA, CoinTypeB, FeeType>(pool, v2, v1.tick_lower_index, v1.tick_upper_index, liquidity, clock, ctx);
        assert!(v3 >= amount_a_min && amount_b_min >= amount_b_min, 5);
        copy_position<CoinTypeA, CoinTypeB, FeeType>(pool, turbos_clmm::pool::get_position_key(v2, v1.tick_lower_index, v1.tick_upper_index), v1);
        let (v5, v6) = turbos_clmm::pool::split_out_and_return_<CoinTypeA, CoinTypeB, FeeType>(pool, v3, v4, ctx);

        let event = DecreaseLiquidityEvent{
            pool      : sui::object::id<turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>>(pool), 
            amount_a  : v3, 
            amount_b  : v4, 
            liquidity : liquidity,
        };
        sui::event::emit<DecreaseLiquidityEvent>(event);
        
        (v5, v6)
    }
    
    fun delete_user_position(arg0: &mut Positions, arg1: address) {
        if (sui::table::contains<address, sui::object::ID>(&arg0.user_position, arg1)) {
            sui::table::remove<address, sui::object::ID>(&mut arg0.user_position, arg1);
        };
    }
    
    fun get_mut_position(arg0: &mut Positions, arg1: address) : &mut Position {
        sui::dynamic_object_field::borrow_mut<address, Position>(&mut arg0.id, arg1)
    }
    
    public fun get_position_info(arg0: &Positions, arg1: address) : (turbos_clmm::i32::I32, turbos_clmm::i32::I32, u128) {
        let v0 = sui::dynamic_object_field::borrow<address, Position>(&arg0.id, arg1);
        (v0.tick_lower_index, v0.tick_upper_index, v0.liquidity)
    }
    
    fun get_position_tick_info(arg0: &mut Positions, arg1: address) : (turbos_clmm::i32::I32, turbos_clmm::i32::I32) {
        let v0 = sui::dynamic_object_field::borrow<address, Position>(&arg0.id, arg1);
        (v0.tick_lower_index, v0.tick_upper_index)
    }
    
    public entry fun increase_liquidity<CoinTypeA, CoinTypeB, FeeType>(arg0: &mut turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>, arg1: &mut Positions, arg2: vector<sui::coin::Coin<CoinTypeA>>, arg3: vector<sui::coin::Coin<CoinTypeB>>, arg4: &mut turbos_clmm::position_nft::TurbosPositionNFT, arg5: u64, arg6: u64, arg7: u64, arg8: u64, arg9: u64, arg10: &sui::clock::Clock, arg11: &turbos_clmm::pool::Versioned, arg12: &mut sui::tx_context::TxContext) {
        turbos_clmm::pool::check_version(arg11);
        let (v0, v1) = increase_liquidity_with_return_<CoinTypeA, CoinTypeB, FeeType>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);
        let v2 = v1;
        let v3 = v0;
        if (sui::coin::value<CoinTypeA>(&v3) == 0) {
            sui::coin::destroy_zero<CoinTypeA>(v3);
        } else {
            sui::transfer::public_transfer<sui::coin::Coin<CoinTypeA>>(v3, sui::tx_context::sender(arg12));
        };
        if (sui::coin::value<CoinTypeB>(&v2) == 0) {
            sui::coin::destroy_zero<CoinTypeB>(v2);
        } else {
            sui::transfer::public_transfer<sui::coin::Coin<CoinTypeB>>(v2, sui::tx_context::sender(arg12));
        };
    }
    
    public fun increase_liquidity_with_return_<CoinTypeA, CoinTypeB, FeeType>(arg0: &mut turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>, arg1: &mut Positions, arg2: vector<sui::coin::Coin<CoinTypeA>>, arg3: vector<sui::coin::Coin<CoinTypeB>>, arg4: &mut turbos_clmm::position_nft::TurbosPositionNFT, arg5: u64, arg6: u64, arg7: u64, arg8: u64, arg9: u64, arg10: &sui::clock::Clock, arg11: &turbos_clmm::pool::Versioned, arg12: &mut sui::tx_context::TxContext) : (sui::coin::Coin<CoinTypeA>, sui::coin::Coin<CoinTypeB>) {
        turbos_clmm::pool::check_version(arg11);
        assert!(sui::object::id<turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>>(arg0) == turbos_clmm::position_nft::pool_id(arg4), 15);
        assert!(sui::clock::timestamp_ms(arg10) <= arg9, 8);
        assert!(std::vector::length<sui::coin::Coin<CoinTypeA>>(&arg2) > 0, 4);
        assert!(std::vector::length<sui::coin::Coin<CoinTypeB>>(&arg3) > 0, 4);
        let v0 = sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(arg4);
        let v1 = sui::dynamic_object_field::borrow_mut<address, Position>(&mut arg1.id, v0);
        let v2 = if (turbos_clmm::pool::check_position_exists<CoinTypeA, CoinTypeB, FeeType>(arg0, v0, v1.tick_lower_index, v1.tick_upper_index)) {
            v0
        } else {
            sui::tx_context::sender(arg12)
        };
        let (v3, v4, v5, v6, v7) = add_liquidity_with_return_<CoinTypeA, CoinTypeB, FeeType>(arg0, turbos_clmm::pool::merge_coin<CoinTypeA>(arg2), turbos_clmm::pool::merge_coin<CoinTypeB>(arg3), v2, v1.tick_lower_index, v1.tick_upper_index, arg5, arg6, arg10, arg12);
        assert!(v4 >= arg7 && v5 >= arg8, 5);
        copy_position<CoinTypeA, CoinTypeB, FeeType>(arg0, turbos_clmm::pool::get_position_key(v2, v1.tick_lower_index, v1.tick_upper_index), v1);
        let v8 = IncreaseLiquidityEvent{
            pool      : sui::object::id<turbos_clmm::pool::Pool<CoinTypeA, CoinTypeB, FeeType>>(arg0), 
            amount_a  : v4, 
            amount_b  : v5, 
            liquidity : v3,
        };
        sui::event::emit<IncreaseLiquidityEvent>(v8);
        (v6, v7)
    }
    
    fun init(arg0: &mut sui::tx_context::TxContext) {
        init_(arg0);
    }
    
    fun init_(arg0: &mut sui::tx_context::TxContext) {
        let v0 = Positions{
            id              : sui::object::new(arg0), 
            nft_minted      : 0, 
            user_position   : sui::table::new<address, sui::object::ID>(arg0), 
            nft_name        : std::string::utf8(b"Turbos Position's NFT"), 
            nft_description : std::string::utf8(b"An NFT created by Turbos CLMM"), 
            nft_img_url     : std::string::utf8(b"https://ipfs.io/ipfs/QmTxRsWbrLG6mkjg375wW77Lfzm38qsUQjRBj3b2K3t8q1?filename=Turbos_nft.png"),
        };
        sui::transfer::share_object<Positions>(v0);
    }
    
    fun insert_user_position(arg0: &mut Positions, arg1: sui::object::ID, arg2: address) {
        if (!sui::table::contains<address, sui::object::ID>(&arg0.user_position, arg2)) {
            sui::table::add<address, sui::object::ID>(&mut arg0.user_position, arg2, arg1);
        };
    }
    
    fun mint_nft<CoinTypeA, CoinTypeB, FeeType>(arg0: sui::object::ID, arg1: sui::object::ID, arg2: &mut Positions, arg3: address, arg4: &mut sui::tx_context::TxContext) : address {
        let v0 = mint_nft_with_return_<CoinTypeA, CoinTypeB, FeeType>(arg0, arg1, arg2, arg4);
        sui::transfer::public_transfer<turbos_clmm::position_nft::TurbosPositionNFT>(v0, arg3);
        sui::object::id_address<turbos_clmm::position_nft::TurbosPositionNFT>(&v0)
    }
    
    fun mint_nft_with_return_<CoinTypeA, CoinTypeB, FeeType>(arg0: sui::object::ID, arg1: sui::object::ID, arg2: &mut Positions, arg3: &mut sui::tx_context::TxContext) : turbos_clmm::position_nft::TurbosPositionNFT {
        arg2.nft_minted = arg2.nft_minted + 1;
        turbos_clmm::position_nft::mint(arg2.nft_name, arg2.nft_description, arg2.nft_img_url, arg0, arg1, std::type_name::get<CoinTypeA>(), std::type_name::get<CoinTypeB>(), std::type_name::get<FeeType>(), arg3)
    }
    
    public(friend) fun modify_position_reward_inside(arg0: &mut Positions, arg1: address, arg2: u64, arg3: u128) {
        std::vector::borrow_mut<PositionRewardInfo>(&mut sui::dynamic_object_field::borrow_mut<address, Position>(&mut arg0.id, arg1).reward_infos, arg2).reward_growth_inside = arg3;
    }
    
    fun try_init_reward_infos(arg0: &mut vector<PositionRewardInfo>, arg1: u64) {
        if (arg1 == std::vector::length<PositionRewardInfo>(arg0)) {
            let v0 = PositionRewardInfo{
                reward_growth_inside : 0, 
                amount_owed          : 0,
            };
            std::vector::push_back<PositionRewardInfo>(arg0, v0);
        };
    }
    
    public(friend) fun update_nft_description(arg0: &mut Positions, arg1: std::string::String) {
        arg0.nft_description = arg1;
    }
    
    public(friend) fun update_nft_img_url(arg0: &mut Positions, arg1: std::string::String) {
        arg0.nft_img_url = arg1;
    }
    
    public(friend) fun update_nft_name(arg0: &mut Positions, arg1: std::string::String) {
        arg0.nft_name = arg1;
    }
}
