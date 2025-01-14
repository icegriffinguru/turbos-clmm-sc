module turbos_clmm::pool {
	use std::vector;
    use std::type_name;
	use sui::pay;
    use sui::event;
    use sui::transfer;
    use std::string::{Self, String};
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_object_field as dof;
	use sui::dynamic_field as df;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
	use turbos_clmm::math_tick;
	use turbos_clmm::math_swap;
    use turbos_clmm::string_tools;
	use turbos_clmm::i32::{Self, I32};
	use turbos_clmm::i128::{Self, I128};
	use turbos_clmm::math_liquidity;
	use turbos_clmm::math_sqrt_price;
    use turbos_clmm::math_u64;
    use turbos_clmm::full_math_u128;
    use turbos_clmm::math_u128;
	use turbos_clmm::math_bit;
    use sui::table::{Self, Table};
    use sui::clock::{Self, Clock};

    struct Versioned has key, store {
        id: UID,
        version: u64,
    }

	struct Tick has key, store {
		id: UID,
        liquidity_gross: u128,
        liquidity_net: I128,
        fee_growth_outside_a: u128,
		fee_growth_outside_b: u128,
        reward_growths_outside: vector<u128>,
        initialized: bool,
    }

    struct PositionRewardInfo has store {
        reward_growth_inside: u128,
        amount_owed: u64,
    }

    struct Position has key, store {
        id: UID,
		// the amount of liquidity owned by this position
        liquidity: u128,
		// fee growth per unit of liquidity as of the last update to liquidity or fees owed
        fee_growth_inside_a: u128,
        fee_growth_inside_b: u128,
		// the fees owed to the position owner in token0/token1
        tokens_owed_a: u64,
        tokens_owed_b: u64,
        reward_infos: vector<PositionRewardInfo>,
    }

    struct PoolRewardVault<phantom RewardCoin> has key, store {
        id: UID,
        coin: Balance<RewardCoin>,
    }
    
    struct PoolRewardInfo has key, store {
        id: UID,
        vault: address,
        vault_coin_type: String,
        emissions_per_second: u128,
        growth_global: u128,
        manager: address,
    }

    struct Pool<phantom CoinTypeA, phantom CoinTypeB, phantom FeeType> has key, store {
        id: UID,
        coin_a: Balance<CoinTypeA>,
        coin_b: Balance<CoinTypeB>,
        protocol_fees_a: u64,
        protocol_fees_b: u64,
        sqrt_price: u128,
        tick_current_index: I32,
        tick_spacing: u32,
        max_liquidity_per_tick: u128,
        fee: u32,
        fee_protocol: u32,
        unlocked: bool,
        fee_growth_global_a: u128,
        fee_growth_global_b: u128,
        liquidity: u128,
		tick_map: Table<I32, u256>,
        deploy_time_ms: u64,
        reward_infos: vector<PoolRewardInfo>,
        reward_last_updated_time_ms: u64,
    }

    struct ComputeSwapState has copy, drop {
        amount_a: u128,
        amount_b: u128, 
        amount_specified_remaining: u128,
        amount_calculated: u128,
        sqrt_price: u128,
        tick_current_index: I32,
        fee_growth_global: u128,
        protocol_fee: u128,
        liquidity: u128,
        fee_amount: u128,
    }

    public fun version(versioned: &Versioned): u64 {
       abort 0
    }

    public fun check_version(versioned: &Versioned) {
        abort 0
    }

	public fun position_tick(tick: I32): (I32, u8) {
		abort 0
    }

	public fun get_tick<CoinTypeA, CoinTypeB, FeeType>(
        pool: &Pool<CoinTypeA, CoinTypeB, FeeType>,
        index: I32
    ): &Tick {
        abort 0
	}

    public fun get_position<CoinTypeA, CoinTypeB, FeeType>(
        pool: &Pool<CoinTypeA, CoinTypeB, FeeType>,
        owner: address,
        tick_lower_index: I32,
        tick_upper_index: I32,
    ): &Position {
        abort 0
    }

    public fun check_position_exists<CoinTypeA, CoinTypeB, FeeType>(
        pool: &Pool<CoinTypeA, CoinTypeB, FeeType>,
        owner: address,
        tick_lower_index: I32,
        tick_upper_index: I32,
    ): bool {
        abort 0
    }

    public fun get_position_key(
        owner: address,
        tick_lower_index: I32,
        tick_upper_index: I32,
    ): String {
        abort 0
    }

    public fun get_pool_fee<CoinTypeA, CoinTypeB, FeeType>(
        pool: &Pool<CoinTypeA, CoinTypeB, FeeType>,
    ): u32 {
        abort 0
    }

    public fun get_pool_sqrt_price<CoinTypeA, CoinTypeB, FeeType>(
        pool: &Pool<CoinTypeA, CoinTypeB, FeeType>,
    ): u128 {
        abort 0
    }

    public fun get_pool_tick_spacing<CoinTypeA, CoinTypeB, FeeType>(
        pool: &Pool<CoinTypeA, CoinTypeB, FeeType>,
    ): u32 {
        abort 0
    }

    public fun get_pool_current_index<CoinTypeA, CoinTypeB, FeeType>(
        pool: &Pool<CoinTypeA, CoinTypeB, FeeType>,
    ): I32 {
        abort 0
    }

    public fun get_position_fee_growth_inside_a<CoinTypeA, CoinTypeB, FeeType>(
        pool: &Pool<CoinTypeA, CoinTypeB, FeeType>,
        key: String
    ): u128 {
        abort 0
    }

    // position.liquidity,
    // position.fee_growth_inside_a,
    // position.fee_growth_inside_b,
    // position.tokens_owed_a,
    // position.tokens_owed_b,
    // &position.reward_infos
    public fun get_position_base_info<CoinTypeA, CoinTypeB, FeeType>(
        pool: &Pool<CoinTypeA, CoinTypeB, FeeType>,
        key: String
    ): (u128, u128, u128, u64, u64, &vector<PositionRewardInfo>) {
        abort 0
    }

    public fun get_position_reward_infos<CoinTypeA, CoinTypeB, FeeType>(
        pool: &Pool<CoinTypeA, CoinTypeB, FeeType>,
        key: String
    ): &vector<PositionRewardInfo> {
        abort 0
    }

    public fun get_position_reward_info(
        reawrd_info: &PositionRewardInfo
    ): (u128, u64) {
        abort 0
    }

    public fun get_position_fee_growth_inside_b<CoinTypeA, CoinTypeB, FeeType>(
        pool: &Pool<CoinTypeA, CoinTypeB, FeeType>,
        key: String
    ): u128 {
        abort 0
    }

    public fun get_pool_balance<CoinTypeA, CoinTypeB, FeeType>(
		pool: &Pool<CoinTypeA, CoinTypeB, FeeType>, 
	): (u64, u64) {
        abort 0
    }

    public(friend) fun swap<T0, T1, T2>(
        pool: &mut Pool<T0, T1, T2>,
        recipient: address,
        arg2: bool,
        swap_amount: u128,
        is_exact_in: bool,
        sqrt_price: u128,
        arg6: &0x2::clock::Clock,
        arg7: &mut 0x2::tx_context::TxContext
    ) : (u128, u128) {
        let v0 = compute_swap_result<T0, T1, T2>(pool, recipient, arg2, swap_amount, is_exact_in, sqrt_price, false, arg6, arg7);
        (v0.amount_a, v0.amount_b)
    }
    
    public fun get_position_key(arg0: address, arg1: turbos_clmm::i32::I32, arg2: turbos_clmm::i32::I32) : 0x1::string::String {
        turbos_clmm::string_tools::get_position_key(arg0, turbos_clmm::i32::abs_u32(arg1), turbos_clmm::i32::is_neg(arg1), turbos_clmm::i32::abs_u32(arg2), turbos_clmm::i32::is_neg(arg2))
    }
    
    public(friend) fun add_reward<T0, T1, T2, T3>(arg0: &mut Pool<T0, T1, T2>, arg1: &mut PoolRewardVault<T3>, arg2: u64, arg3: 0x2::coin::Coin<T3>, arg4: u64, arg5: &0x2::clock::Clock, arg6: &mut 0x2::tx_context::TxContext) {
        assert!(arg2 < 0x1::vector::length<PoolRewardInfo>(&arg0.reward_infos), 13);
        next_pool_reward_infos<T0, T1, T2>(arg0, 0x2::clock::timestamp_ms(arg5));
        let v0 = 0x1::vector::borrow<PoolRewardInfo>(&arg0.reward_infos, arg2);
        assert!(v0.manager == 0x2::tx_context::sender(arg6), 17);
        assert!(v0.vault == 0x2::object::id_address<PoolRewardVault<T3>>(arg1), 14);
        0x2::balance::join<T3>(&mut arg1.coin, 0x2::coin::into_balance<T3>(0x2::coin::split<T3>(&mut arg3, arg4, arg6)));
        if (0x2::coin::value<T3>(&arg3) == 0) {
            0x2::coin::destroy_zero<T3>(arg3);
        } else {
            0x2::transfer::public_transfer<0x2::coin::Coin<T3>>(arg3, 0x2::tx_context::sender(arg6));
        };
        let v1 = AddRewardEvent{
            pool           : 0x2::object::id<Pool<T0, T1, T2>>(arg0), 
            reward_index   : arg2, 
            reward_vault   : v0.vault, 
            reward_manager : v0.manager, 
            amount         : arg4,
        };
        0x2::event::emit<AddRewardEvent>(v1);
    }
    
    public(friend) fun burn<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: address, arg2: turbos_clmm::i32::I32, arg3: turbos_clmm::i32::I32, arg4: u128, arg5: &0x2::clock::Clock, arg6: &mut 0x2::tx_context::TxContext) : (u64, u64) {
        if (0x2::object::id_address<Pool<T0, T1, T2>>(arg0) != 0x2::address::from_u256(60148000886971066743225759181777648498219832128502871752008364769916836265492)) {
            assert!(arg0.unlocked, 8);
        };
        let (v0, v1) = modify_position<T0, T1, T2>(arg0, arg1, arg2, arg3, turbos_clmm::i128::neg_from(arg4), arg5, arg6);
        let v2 = (turbos_clmm::i128::abs_u128(v0) as u64);
        let v3 = (turbos_clmm::i128::abs_u128(v1) as u64);
        let v4 = BurnEvent{
            pool             : 0x2::object::id<Pool<T0, T1, T2>>(arg0), 
            owner            : arg1, 
            tick_lower_index : arg2, 
            tick_upper_index : arg3, 
            amount_a         : v2, 
            amount_b         : v3, 
            liquidity_delta  : arg4,
        };
        0x2::event::emit<BurnEvent>(v4);
        (v2, v3)
    }
    
    public fun check_position_exists<T0, T1, T2>(arg0: &Pool<T0, T1, T2>, arg1: address, arg2: turbos_clmm::i32::I32, arg3: turbos_clmm::i32::I32) : bool {
        0x2::dynamic_object_field::exists_<0x1::string::String>(&arg0.id, get_position_key(arg1, arg2, arg3))
    }
    
    fun check_ticks(arg0: turbos_clmm::i32::I32, arg1: turbos_clmm::i32::I32) {
        assert!(turbos_clmm::i32::lt(arg0, arg1), 5);
        assert!(turbos_clmm::i32::gte(arg0, turbos_clmm::i32::neg_from(443636)), 5);
        assert!(turbos_clmm::i32::lte(arg1, turbos_clmm::i32::from(443636)), 5);
    }
    
    public fun check_version(arg0: &Versioned) {
        assert!(arg0.version == 9, 23);
    }
    
    fun clean_position<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: 0x1::string::String) {
        let v0 = get_position_mut_by_key<T0, T1, T2>(arg0, arg1);
        let v1 = 0;
        while (v1 < 3) {
            let v2 = 0x1::vector::borrow_mut<PositionRewardInfo>(&mut v0.reward_infos, v1);
            v2.reward_growth_inside = 0;
            v2.amount_owed = 0;
            v1 = v1 + 1;
        };
        v0.liquidity = 0;
        v0.fee_growth_inside_a = 0;
        v0.fee_growth_inside_b = 0;
        v0.tokens_owed_a = 0;
        v0.tokens_owed_b = 0;
    }
    
    fun clear_tick<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: turbos_clmm::i32::I32, arg2: &mut 0x2::tx_context::TxContext) {
        let v0 = 0x2::dynamic_field::borrow_mut<turbos_clmm::i32::I32, Tick>(&mut arg0.id, arg1);
        v0.liquidity_gross = 0;
        v0.liquidity_net = turbos_clmm::i128::zero();
        v0.fee_growth_outside_a = 0;
        v0.fee_growth_outside_b = 0;
        v0.initialized = false;
    }
    
    public(friend) fun collect<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: address, arg2: turbos_clmm::i32::I32, arg3: turbos_clmm::i32::I32, arg4: u64, arg5: u64, arg6: &mut 0x2::tx_context::TxContext) : (u64, u64) {
        let v0 = get_position_mut<T0, T1, T2>(arg0, 0x2::tx_context::sender(arg6), arg2, arg3);
        let v1 = if (arg4 > v0.tokens_owed_a) {
            v0.tokens_owed_a
        } else {
            arg4
        };
        let v2 = if (arg5 > v0.tokens_owed_b) {
            v0.tokens_owed_b
        } else {
            arg5
        };
        if (v1 > 0) {
            v0.tokens_owed_a = v0.tokens_owed_a - v1;
        };
        if (v2 > 0) {
            v0.tokens_owed_b = v0.tokens_owed_b - v2;
        };
        let v3 = CollectEvent{
            pool             : 0x2::object::id<Pool<T0, T1, T2>>(arg0), 
            recipient        : arg1, 
            tick_lower_index : arg2, 
            tick_upper_index : arg3, 
            amount_a         : v1, 
            amount_b         : v2,
        };
        0x2::event::emit<CollectEvent>(v3);
        (v1, v2)
    }
    
    public(friend) fun collect_protocol_fee<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: u64, arg2: u64, arg3: address, arg4: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public(friend) fun collect_protocol_fee_with_return_<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: u64, arg2: u64, arg3: address, arg4: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T1>) {
        let v0 = if (arg1 > arg0.protocol_fees_a) {
            arg0.protocol_fees_a
        } else {
            arg1
        };
        let v1 = if (arg2 > arg0.protocol_fees_b) {
            arg0.protocol_fees_b
        } else {
            arg2
        };
        if (v0 > 0) {
            arg0.protocol_fees_a = arg0.protocol_fees_a - v0;
        };
        if (v1 > 0) {
            arg0.protocol_fees_b = arg0.protocol_fees_b - v1;
        };
        let (v2, v3) = split_out_and_return_<T0, T1, T2>(arg0, v0, v1, arg4);
        let v4 = CollectProtocolFeeEvent{
            pool      : 0x2::object::id<Pool<T0, T1, T2>>(arg0), 
            recipient : arg3, 
            amount_a  : v0, 
            amount_b  : v1,
        };
        0x2::event::emit<CollectProtocolFeeEvent>(v4);
        (v2, v3)
    }
    
    public(friend) fun collect_reward<T0, T1, T2, T3>(arg0: &mut Pool<T0, T1, T2>, arg1: &mut PoolRewardVault<T3>, arg2: address, arg3: turbos_clmm::i32::I32, arg4: turbos_clmm::i32::I32, arg5: u64, arg6: u64, arg7: &mut 0x2::tx_context::TxContext) : u64 {
        abort 0
    }
    
    public(friend) fun collect_reward_v2<T0, T1, T2, T3>(arg0: &mut Pool<T0, T1, T2>, arg1: &mut PoolRewardVault<T3>, arg2: address, arg3: address, arg4: turbos_clmm::i32::I32, arg5: turbos_clmm::i32::I32, arg6: u64, arg7: u64, arg8: &mut 0x2::tx_context::TxContext) : u64 {
        abort 0
    }
    
    public(friend) fun collect_reward_with_return_<T0, T1, T2, T3>(arg0: &mut Pool<T0, T1, T2>, arg1: &mut PoolRewardVault<T3>, arg2: address, arg3: address, arg4: turbos_clmm::i32::I32, arg5: turbos_clmm::i32::I32, arg6: u64, arg7: u64, arg8: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<T3> {
        assert!(0x1::vector::borrow<PoolRewardInfo>(&arg0.reward_infos, arg7).vault == 0x2::object::id_address<PoolRewardVault<T3>>(arg1), 14);
        let v0 = get_position_mut<T0, T1, T2>(arg0, arg3, arg4, arg5);
        assert!(arg7 < 0x1::vector::length<PositionRewardInfo>(&v0.reward_infos), 13);
        let v1 = 0x1::vector::borrow_mut<PositionRewardInfo>(&mut v0.reward_infos, arg7);
        let v2 = if (arg6 > v1.amount_owed) {
            v1.amount_owed
        } else {
            arg6
        };
        if (v2 > 0) {
            v1.amount_owed = v1.amount_owed - v2;
        };
        assert!(v2 <= 0x2::balance::value<T3>(&arg1.coin), 18);
        let v3 = CollectRewardEvent{
            pool             : 0x2::object::id<Pool<T0, T1, T2>>(arg0), 
            recipient        : arg2, 
            tick_lower_index : arg4, 
            tick_upper_index : arg5, 
            amount           : v2, 
            vault            : 0x2::object::id<PoolRewardVault<T3>>(arg1), 
            reward_index     : arg7,
        };
        0x2::event::emit<CollectRewardEvent>(v3);
        0x2::coin::from_balance<T3>(0x2::balance::split<T3>(&mut arg1.coin, v2), arg8)
    }
    
    public(friend) fun collect_v2<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: address, arg2: address, arg3: turbos_clmm::i32::I32, arg4: turbos_clmm::i32::I32, arg5: u64, arg6: u64, arg7: &mut 0x2::tx_context::TxContext) : (u64, u64) {
        let v0 = get_position_mut<T0, T1, T2>(arg0, arg2, arg3, arg4);
        let v1 = if (arg5 > v0.tokens_owed_a) {
            v0.tokens_owed_a
        } else {
            arg5
        };
        let v2 = if (arg6 > v0.tokens_owed_b) {
            v0.tokens_owed_b
        } else {
            arg6
        };
        if (v1 > 0) {
            v0.tokens_owed_a = v0.tokens_owed_a - v1;
        };
        if (v2 > 0) {
            v0.tokens_owed_b = v0.tokens_owed_b - v2;
        };
        let v3 = CollectEvent{
            pool             : 0x2::object::id<Pool<T0, T1, T2>>(arg0), 
            recipient        : arg1, 
            tick_lower_index : arg3, 
            tick_upper_index : arg4, 
            amount_a         : v1, 
            amount_b         : v2,
        };
        0x2::event::emit<CollectEvent>(v3);
        (v1, v2)
    }
    
    public(friend) fun compute_swap_result<T0, T1, T2>(
        pool: &mut Pool<T0, T1, T2>,
        recipient: address,
        a_to_b: bool,
        swap_amount: u128,
        is_exact_in: bool,
        sqrt_price: u128,
        arg6: bool,
        arg7: &0x2::clock::Clock,
        arg8: &mut 0x2::tx_context::TxContext
    ) : ComputeSwapState {
        assert!(pool.unlocked, 8);
        assert!(swap_amount != 0, 7);
        if (sqrt_price < 4295048016 || sqrt_price > 79226673515401279992447579055) {
            abort 19
        };
        let v0 = if (a_to_b && sqrt_price > pool.sqrt_price) {
            true
        } else {
            let v1 = !a_to_b && sqrt_price < pool.sqrt_price;
            v1
        };
        if (v0) {
            abort 20
        };
        let v2 = next_pool_reward_infos<T0, T1, T2>(pool, 0x2::clock::timestamp_ms(arg7));
        let v3 = if (a_to_b) {
            pool.fee_growth_global_a
        } else {
            pool.fee_growth_global_b
        };
        let v4 = ComputeSwapState{
            amount_a                   : 0, 
            amount_b                   : 0, 
            amount_specified_remaining : swap_amount, 
            amount_calculated          : 0, 
            sqrt_price                 : pool.sqrt_price, 
            tick_current_index         : pool.tick_current_index, 
            fee_growth_global          : v3, 
            protocol_fee               : 0, 
            liquidity                  : pool.liquidity, 
            fee_amount                 : 0,
        };
        while (v4.amount_specified_remaining > 0 && v4.sqrt_price != sqrt_price) {
            let (v5, v6) = next_initialized_tick_within_one_word<T0, T1, T2>(pool, v4.tick_current_index, a_to_b);
            let v7 = v5;
            if (turbos_clmm::i32::lt(v5, turbos_clmm::i32::neg_from(443636))) {
                v7 = turbos_clmm::i32::neg_from(443636);
            } else {
                if (turbos_clmm::i32::gt(v5, turbos_clmm::i32::from(443636))) {
                    v7 = turbos_clmm::i32::from(443636);
                };
            };
            let v8 = turbos_clmm::math_tick::sqrt_price_from_tick_index(v7);
            let v9 = if (a_to_b && v8 < sqrt_price || v8 > sqrt_price) {
                sqrt_price
            } else {
                v8
            };
            let (v10, v11, v12, v13) = turbos_clmm::math_swap::compute_swap(v4.sqrt_price, v9, v4.liquidity, v4.amount_specified_remaining, is_exact_in, pool.fee);
            let v14 = v13;
            v4.sqrt_price = v10;
            if (is_exact_in) {
                v4.amount_specified_remaining = v4.amount_specified_remaining - v11 - v13;
                v4.amount_calculated = v4.amount_calculated + v12;
            } else {
                v4.amount_specified_remaining = v4.amount_specified_remaining - v12;
                v4.amount_calculated = v4.amount_calculated + v11 + v13;
            };
            v4.fee_amount = v4.fee_amount + v13;
            if (pool.fee_protocol > 0) {
                let v15 = v13 * (pool.fee_protocol as u128) / 1000000;
                v14 = v13 - v15;
                v4.protocol_fee = turbos_clmm::math_u128::wrapping_add(v4.protocol_fee, v15);
            };
            if (v4.liquidity > 0) {
                v4.fee_growth_global = turbos_clmm::math_u128::wrapping_add(v4.fee_growth_global, turbos_clmm::full_math_u128::mul_div_floor(v14, 18446744073709551616, v4.liquidity));
            };
            if (v4.sqrt_price == v8) {
                if (v6) {
                    let v16 = if (a_to_b) {
                        v4.fee_growth_global
                    } else {
                        pool.fee_growth_global_a
                    };
                    let v17 = if (a_to_b) {
                        pool.fee_growth_global_b
                    } else {
                        v4.fee_growth_global
                    };
                    let v18 = cross_tick<T0, T1, T2>(pool, v7, v16, v17, &v2, arg6, arg8);
                    let v19 = v18;
                    if (a_to_b) {
                        v19 = turbos_clmm::i128::neg(v18);
                    };
                    v4.liquidity = turbos_clmm::math_liquidity::add_delta(v4.liquidity, v19);
                };
                let v20 = if (a_to_b) {
                    turbos_clmm::i32::sub(v7, turbos_clmm::i32::from(1))
                } else {
                    v7
                };
                v4.tick_current_index = v20;
                continue
            };
            if (v4.sqrt_price != v4.sqrt_price) {
                v4.tick_current_index = turbos_clmm::math_tick::tick_index_from_sqrt_price(v4.sqrt_price);
                continue
            };
        };
        if (!arg6) {
            if (!turbos_clmm::i32::eq(v4.tick_current_index, pool.tick_current_index)) {
                pool.sqrt_price = v4.sqrt_price;
                pool.tick_current_index = v4.tick_current_index;
            } else {
                pool.sqrt_price = v4.sqrt_price;
            };
            if (pool.liquidity != v4.liquidity) {
                pool.liquidity = v4.liquidity;
            };
            if (a_to_b) {
                pool.fee_growth_global_a = v4.fee_growth_global;
                if (v4.protocol_fee > 0) {
                    pool.protocol_fees_a = pool.protocol_fees_a + (v4.protocol_fee as u64);
                };
            } else {
                pool.fee_growth_global_b = v4.fee_growth_global;
                if (v4.protocol_fee > 0) {
                    pool.protocol_fees_b = pool.protocol_fees_b + (v4.protocol_fee as u64);
                };
            };
        };
        let (v21, v22) = if (a_to_b == is_exact_in) {
            (swap_amount - v4.amount_specified_remaining, v4.amount_calculated)
        } else {
            (v4.amount_calculated, swap_amount - v4.amount_specified_remaining)
        };
        v4.amount_a = v21;
        v4.amount_b = v22;
        let v23 = SwapEvent{
            pool               : 0x2::object::id<Pool<T0, T1, T2>>(pool), 
            recipient          : recipient, 
            amount_a           : (v4.amount_a as u64), 
            amount_b           : (v4.amount_b as u64), 
            liquidity          : v4.liquidity, 
            tick_current_index : v4.tick_current_index, 
            tick_pre_index     : pool.tick_current_index, 
            sqrt_price         : v4.sqrt_price, 
            protocol_fee       : (v4.protocol_fee as u64), 
            fee_amount         : (v4.fee_amount as u64), 
            a_to_b             : a_to_b, 
            is_exact_in        : is_exact_in,
        };
        0x2::event::emit<SwapEvent>(v23);
        v4
    }

    fun cross_tick<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: turbos_clmm::i32::I32, arg2: u128, arg3: u128, arg4: &vector<u128>, arg5: bool, arg6: &mut 0x2::tx_context::TxContext) : turbos_clmm::i128::I128 {
        let v0 = if (!0x2::dynamic_field::exists_<turbos_clmm::i32::I32>(&arg0.id, arg1)) {
            init_tick<T0, T1, T2>(arg0, arg1, arg6)
        } else {
            0x2::dynamic_field::borrow_mut<turbos_clmm::i32::I32, Tick>(&mut arg0.id, arg1)
        };
        if (!arg5) {
            v0.fee_growth_outside_a = turbos_clmm::math_u128::wrapping_sub(arg2, v0.fee_growth_outside_a);
            v0.fee_growth_outside_b = turbos_clmm::math_u128::wrapping_sub(arg3, v0.fee_growth_outside_b);
            let v1 = 0;
            while (v1 < 0x1::vector::length<u128>(arg4)) {
                let v2 = 0x1::vector::borrow_mut<u128>(&mut v0.reward_growths_outside, v1);
                *v2 = turbos_clmm::math_u128::wrapping_sub(*0x1::vector::borrow<u128>(arg4, v1), *v2);
                v1 = v1 + 1;
            };
        };
        v0.liquidity_net
    }
    
    public(friend) fun deploy_pool<T0, T1, T2>(arg0: u32, arg1: u32, arg2: u128, arg3: u32, arg4: &0x2::clock::Clock, arg5: &mut 0x2::tx_context::TxContext) : Pool<T0, T1, T2> {
        Pool<T0, T1, T2>{
            id                          : 0x2::object::new(arg5), 
            coin_a                      : 0x2::balance::zero<T0>(), 
            coin_b                      : 0x2::balance::zero<T1>(), 
            protocol_fees_a             : 0, 
            protocol_fees_b             : 0, 
            sqrt_price                  : arg2, 
            tick_current_index          : turbos_clmm::math_tick::tick_index_from_sqrt_price(arg2), 
            tick_spacing                : arg1, 
            max_liquidity_per_tick      : turbos_clmm::math_tick::max_liquidity_per_tick(arg1), 
            fee                         : arg0, 
            fee_protocol                : arg3, 
            unlocked                    : true, 
            fee_growth_global_a         : 0, 
            fee_growth_global_b         : 0, 
            liquidity                   : 0, 
            tick_map                    : 0x2::table::new<turbos_clmm::i32::I32, u256>(arg5), 
            deploy_time_ms              : 0x2::clock::timestamp_ms(arg4), 
            reward_infos                : 0x1::vector::empty<PoolRewardInfo>(), 
            reward_last_updated_time_ms : 0,
        }
    }
    
    fun flip_tick<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: turbos_clmm::i32::I32, arg2: &mut 0x2::tx_context::TxContext) {
        assert!(turbos_clmm::i32::eq(turbos_clmm::i32::mod_euclidean(arg1, arg0.tick_spacing), turbos_clmm::i32::zero()), 12);
        let (v0, v1) = position_tick(turbos_clmm::i32::div(arg1, turbos_clmm::i32::from(arg0.tick_spacing)));
        try_init_tick_word<T0, T1, T2>(arg0, v0);
        let v2 = get_tick_word_mut<T0, T1, T2>(arg0, v0);
        *v2 = *v2 ^ 1 << v1;
    }
    
    public fun get_flash_swap_receipt_info<T0, T1>(arg0: &FlashSwapReceipt<T0, T1>) : (0x2::object::ID, bool, u64) {
        (arg0.pool_id, arg0.a_to_b, arg0.pay_amount)
    }
    
    public fun get_pool_balance<T0, T1, T2>(arg0: &Pool<T0, T1, T2>) : (u64, u64) {
        (0x2::balance::value<T0>(&arg0.coin_a), 0x2::balance::value<T1>(&arg0.coin_b))
    }
    
    public fun get_pool_current_index<T0, T1, T2>(arg0: &Pool<T0, T1, T2>) : turbos_clmm::i32::I32 {
        arg0.tick_current_index
    }
    
    public fun get_pool_fee<T0, T1, T2>(arg0: &Pool<T0, T1, T2>) : u32 {
        arg0.fee
    }
    
    public fun get_pool_sqrt_price<T0, T1, T2>(arg0: &Pool<T0, T1, T2>) : u128 {
        arg0.sqrt_price
    }
    
    public fun get_pool_tick_spacing<T0, T1, T2>(arg0: &Pool<T0, T1, T2>) : u32 {
        arg0.tick_spacing
    }
    
    public fun get_position<T0, T1, T2>(arg0: &Pool<T0, T1, T2>, arg1: address, arg2: turbos_clmm::i32::I32, arg3: turbos_clmm::i32::I32) : &Position {
        get_position_by_key<T0, T1, T2>(arg0, get_position_key(arg1, arg2, arg3))
    }
    
    public fun get_position_base_info<T0, T1, T2>(arg0: &Pool<T0, T1, T2>, arg1: 0x1::string::String) : (u128, u128, u128, u64, u64, &vector<PositionRewardInfo>) {
        let v0 = get_position_by_key<T0, T1, T2>(arg0, arg1);
        (v0.liquidity, v0.fee_growth_inside_a, v0.fee_growth_inside_b, v0.tokens_owed_a, v0.tokens_owed_b, &v0.reward_infos)
    }
    
    fun get_position_by_key<T0, T1, T2>(arg0: &Pool<T0, T1, T2>, arg1: 0x1::string::String) : &Position {
        0x2::dynamic_object_field::borrow<0x1::string::String, Position>(&arg0.id, arg1)
    }
    
    public fun get_position_fee_growth_inside_a<T0, T1, T2>(arg0: &Pool<T0, T1, T2>, arg1: 0x1::string::String) : u128 {
        get_position_by_key<T0, T1, T2>(arg0, arg1).fee_growth_inside_a
    }
    
    public fun get_position_fee_growth_inside_b<T0, T1, T2>(arg0: &Pool<T0, T1, T2>, arg1: 0x1::string::String) : u128 {
        get_position_by_key<T0, T1, T2>(arg0, arg1).fee_growth_inside_b
    }
    
    fun get_position_mut<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: address, arg2: turbos_clmm::i32::I32, arg3: turbos_clmm::i32::I32) : &mut Position {
        get_position_mut_by_key<T0, T1, T2>(arg0, get_position_key(arg1, arg2, arg3))
    }
    
    fun get_position_mut_by_key<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: 0x1::string::String) : &mut Position {
        0x2::dynamic_object_field::borrow_mut<0x1::string::String, Position>(&mut arg0.id, arg1)
    }
    
    public fun get_position_reward_info(arg0: &PositionRewardInfo) : (u128, u64) {
        (arg0.reward_growth_inside, arg0.amount_owed)
    }
    
    public fun get_position_reward_infos<T0, T1, T2>(arg0: &Pool<T0, T1, T2>, arg1: 0x1::string::String) : &vector<PositionRewardInfo> {
        &get_position_by_key<T0, T1, T2>(arg0, arg1).reward_infos
    }
    
    public fun get_tick<T0, T1, T2>(arg0: &Pool<T0, T1, T2>, arg1: turbos_clmm::i32::I32) : &Tick {
        assert!(0x2::dynamic_field::exists_<turbos_clmm::i32::I32>(&arg0.id, arg1), 0);
        0x2::dynamic_field::borrow<turbos_clmm::i32::I32, Tick>(&arg0.id, arg1)
    }
    
    fun get_tick_word<T0, T1, T2>(arg0: &Pool<T0, T1, T2>, arg1: turbos_clmm::i32::I32) : u256 {
        *0x2::table::borrow<turbos_clmm::i32::I32, u256>(&arg0.tick_map, arg1)
    }
    
    fun get_tick_word_mut<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: turbos_clmm::i32::I32) : &mut u256 {
        0x2::table::borrow_mut<turbos_clmm::i32::I32, u256>(&mut arg0.tick_map, arg1)
    }
    
    fun init(arg0: &mut 0x2::tx_context::TxContext) {
        let v0 = Versioned{
            id      : 0x2::object::new(arg0), 
            version : 9,
        };
        0x2::transfer::share_object<Versioned>(v0);
    }
    
    public(friend) fun init_reward<T0, T1, T2, T3>(arg0: &mut Pool<T0, T1, T2>, arg1: u64, arg2: address, arg3: &mut 0x2::tx_context::TxContext) : PoolRewardVault<T3> {
        assert!(arg1 < 3, 13);
        assert!(arg1 == 0x1::vector::length<PoolRewardInfo>(&arg0.reward_infos), 13);
        let v0 = PoolRewardVault<T3>{
            id   : 0x2::object::new(arg3), 
            coin : 0x2::balance::zero<T3>(),
        };
        let v1 = PoolRewardInfo{
            id                   : 0x2::object::new(arg3), 
            vault                : 0x2::object::id_address<PoolRewardVault<T3>>(&v0), 
            vault_coin_type      : 0x1::string::from_ascii(0x1::type_name::into_string(0x1::type_name::get<T3>())), 
            emissions_per_second : 0, 
            growth_global        : 0, 
            manager              : arg2,
        };
        0x1::vector::insert<PoolRewardInfo>(&mut arg0.reward_infos, v1, arg1);
        let v2 = InitRewardEvent{
            pool           : 0x2::object::id<Pool<T0, T1, T2>>(arg0), 
            reward_index   : arg1, 
            reward_vault   : 0x2::object::id_address<PoolRewardVault<T3>>(&v0), 
            reward_manager : arg2,
        };
        0x2::event::emit<InitRewardEvent>(v2);
        v0
    }
    
    fun init_tick<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: turbos_clmm::i32::I32, arg2: &mut 0x2::tx_context::TxContext) : &mut Tick {
        let v0 = 0x1::vector::empty<u128>();
        let v1 = 0;
        while (v1 < 3) {
            0x1::vector::push_back<u128>(&mut v0, 0);
            v1 = v1 + 1;
        };
        let v2 = Tick{
            id                     : 0x2::object::new(arg2), 
            liquidity_gross        : 0, 
            liquidity_net          : turbos_clmm::i128::zero(), 
            fee_growth_outside_a   : 0, 
            fee_growth_outside_b   : 0, 
            reward_growths_outside : v0, 
            initialized            : false,
        };
        0x2::dynamic_field::add<turbos_clmm::i32::I32, Tick>(&mut arg0.id, arg1, v2);
        0x2::dynamic_field::borrow_mut<turbos_clmm::i32::I32, Tick>(&mut arg0.id, arg1)
    }
    
    public(friend) fun merge_coin<T0>(arg0: vector<0x2::coin::Coin<T0>>) : 0x2::coin::Coin<T0> {
        assert!(0x1::vector::length<0x2::coin::Coin<T0>>(&arg0) > 0, 21);
        let v0 = 0x1::vector::pop_back<0x2::coin::Coin<T0>>(&mut arg0);
        0x2::pay::join_vec<T0>(&mut v0, arg0);
        v0
    }
    
    public(friend) fun migrate_position<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: 0x1::string::String, arg2: 0x1::string::String, arg3: &mut 0x2::tx_context::TxContext) {
        let v0 = get_position_by_key<T0, T1, T2>(arg0, arg1);
        let v1 = 0x1::vector::empty<PositionRewardInfo>();
        let v2 = 0;
        while (v2 < 3) {
            let v3 = 0x1::vector::borrow<PositionRewardInfo>(&v0.reward_infos, v2);
            let v4 = PositionRewardInfo{
                reward_growth_inside : v3.reward_growth_inside, 
                amount_owed          : v3.amount_owed,
            };
            0x1::vector::push_back<PositionRewardInfo>(&mut v1, v4);
            v2 = v2 + 1;
        };
        let v5 = Position{
            id                  : 0x2::object::new(arg3), 
            liquidity           : v0.liquidity, 
            fee_growth_inside_a : v0.fee_growth_inside_a, 
            fee_growth_inside_b : v0.fee_growth_inside_b, 
            tokens_owed_a       : v0.tokens_owed_a, 
            tokens_owed_b       : v0.tokens_owed_b, 
            reward_infos        : v1,
        };
        save_position<T0, T1, T2>(arg0, arg2, v5);
        clean_position<T0, T1, T2>(arg0, arg1);
        let v6 = MigratePositionEvent{
            pool    : 0x2::object::id<Pool<T0, T1, T2>>(arg0), 
            old_key : arg1, 
            new_key : arg2,
        };
        0x2::event::emit<MigratePositionEvent>(v6);
    }
    
    public(friend) fun mint<T0, T1, T2>(
        arg0: &mut Pool<T0, T1, T2>,
        arg1: address,
        arg2: turbos_clmm::i32::I32,
        arg3: turbos_clmm::i32::I32,
        arg4: u128,
        arg5: &0x2::clock::Clock,
        arg6: &mut 0x2::tx_context::TxContext
    ) : (u64, u64) {
        if (0x2::object::id_address<Pool<T0, T1, T2>>(arg0) != 0x2::address::from_u256(60148000886971066743225759181777648498219832128502871752008364769916836265492)) {
            assert!(arg0.unlocked, 8);
        };
        assert!(arg4 > 0, 1);
        try_init_position<T0, T1, T2>(arg0, arg1, arg2, arg3, arg6);
        let (v0, v1) = modify_position<T0, T1, T2>(arg0, arg1, arg2, arg3, turbos_clmm::i128::from(arg4), arg5, arg6);
        assert!(!turbos_clmm::i128::is_neg(v0) && !turbos_clmm::i128::is_neg(v1), 3);
        let v2 = (turbos_clmm::i128::abs_u128(v0) as u64);
        let v3 = (turbos_clmm::i128::abs_u128(v1) as u64);
        let v4 = MintEvent{
            pool             : 0x2::object::id<Pool<T0, T1, T2>>(arg0), 
            owner            : arg1, 
            tick_lower_index : arg2, 
            tick_upper_index : arg3, 
            amount_a         : v2, 
            amount_b         : v3, 
            liquidity_delta  : arg4,
        };
        0x2::event::emit<MintEvent>(v4);
        (v2, v3)
    }
    
    fun modify_position<T0, T1, T2>(
        arg0: &mut Pool<T0, T1, T2>,
        arg1: address,
        arg2: turbos_clmm::i32::I32,
        arg3: turbos_clmm::i32::I32,
        arg4: turbos_clmm::i128::I128,
        arg5: &0x2::clock::Clock,
        arg6: &mut 0x2::tx_context::TxContext
    ) : (
        turbos_clmm::i128::I128, turbos_clmm::i128::I128
    ) {
        check_ticks(arg2, arg3);
        update_position<T0, T1, T2>(arg0, arg1, arg2, arg3, arg4, arg5, arg6);
        let v0 = turbos_clmm::i128::zero();
        let v1 = turbos_clmm::i128::zero();
        if (!turbos_clmm::i128::eq(arg4, turbos_clmm::i128::zero())) {
            if (turbos_clmm::i32::lt(arg0.tick_current_index, arg2)) {
                v0 = turbos_clmm::math_sqrt_price::get_amount_a_delta(turbos_clmm::math_tick::sqrt_price_from_tick_index(arg2), turbos_clmm::math_tick::sqrt_price_from_tick_index(arg3), arg4);
            } else {
                if (turbos_clmm::i32::lt(arg0.tick_current_index, arg3)) {
                    v0 = turbos_clmm::math_sqrt_price::get_amount_a_delta(arg0.sqrt_price, turbos_clmm::math_tick::sqrt_price_from_tick_index(arg3), arg4);
                    v1 = turbos_clmm::math_sqrt_price::get_amount_b_delta(turbos_clmm::math_tick::sqrt_price_from_tick_index(arg2), arg0.sqrt_price, arg4);
                    arg0.liquidity = turbos_clmm::math_liquidity::add_delta(arg0.liquidity, arg4);
                } else {
                    v1 = turbos_clmm::math_sqrt_price::get_amount_b_delta(turbos_clmm::math_tick::sqrt_price_from_tick_index(arg2), turbos_clmm::math_tick::sqrt_price_from_tick_index(arg3), arg4);
                };
            };
        };
        (v0, v1)
    }
    
    public(friend) fun modify_position_reward_inside<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: turbos_clmm::i32::I32, arg2: turbos_clmm::i32::I32, arg3: address, arg4: u64, arg5: u128) {
        0x1::vector::borrow_mut<PositionRewardInfo>(&mut get_position_mut<T0, T1, T2>(arg0, arg3, arg1, arg2).reward_infos, arg4).reward_growth_inside = arg5;
    }
    
    public(friend) fun modify_tick<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: turbos_clmm::i32::I32) {
        if (turbos_clmm::i32::lte(arg1, arg0.tick_current_index)) {
            modify_tick_reward_outside<T0, T1, T2>(arg0, arg1, 0, 0x1::vector::borrow<PoolRewardInfo>(&arg0.reward_infos, 0).growth_global);
        } else {
            modify_tick_reward_outside<T0, T1, T2>(arg0, arg1, 0, 0);
        };
    }
    
    public(friend) fun modify_tick_reward<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: turbos_clmm::i32::I32, arg2: turbos_clmm::i32::I32) {
        if (turbos_clmm::i32::lte(arg1, arg0.tick_current_index)) {
            modify_tick_reward_outside<T0, T1, T2>(arg0, arg1, 0, 0x1::vector::borrow<PoolRewardInfo>(&arg0.reward_infos, 0).growth_global);
        } else {
            modify_tick_reward_outside<T0, T1, T2>(arg0, arg1, 0, 0);
        };
        if (turbos_clmm::i32::lte(arg2, arg0.tick_current_index)) {
            modify_tick_reward_outside<T0, T1, T2>(arg0, arg2, 0, 0x1::vector::borrow<PoolRewardInfo>(&arg0.reward_infos, 0).growth_global);
        } else {
            modify_tick_reward_outside<T0, T1, T2>(arg0, arg2, 0, 0);
        };
    }
    
    fun modify_tick_reward_outside<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: turbos_clmm::i32::I32, arg2: u64, arg3: u128) {
        let v0 = 0x1::vector::borrow_mut<u128>(&mut 0x2::dynamic_field::borrow_mut<turbos_clmm::i32::I32, Tick>(&mut arg0.id, arg1).reward_growths_outside, arg2);
        *v0 = arg3;
        let v1 = ModifyTickRewardEvent{
            pool       : 0x2::object::id<Pool<T0, T1, T2>>(arg0), 
            old_reward : *v0, 
            new_reward : *v0,
        };
        0x2::event::emit<ModifyTickRewardEvent>(v1);
    }
    
    fun next_fee_growth_inside<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: turbos_clmm::i32::I32, arg2: turbos_clmm::i32::I32, arg3: turbos_clmm::i32::I32, arg4: &mut 0x2::tx_context::TxContext) : (u128, u128) {
        let v0 = get_tick<T0, T1, T2>(arg0, arg1);
        let v1 = get_tick<T0, T1, T2>(arg0, arg2);
        let (v2, v3) = if (!v0.initialized) {
            (arg0.fee_growth_global_a, arg0.fee_growth_global_b)
        } else {
            if (turbos_clmm::i32::gte(arg3, arg1)) {
                (v0.fee_growth_outside_a, v0.fee_growth_outside_b)
            } else {
                (turbos_clmm::math_u128::wrapping_sub(arg0.fee_growth_global_a, v0.fee_growth_outside_a), turbos_clmm::math_u128::wrapping_sub(arg0.fee_growth_global_b, v0.fee_growth_outside_b))
            }
        };
        let (v4, v5) = if (!v0.initialized) {
            (0, 0)
        } else {
            if (turbos_clmm::i32::lt(arg3, arg2)) {
                (v1.fee_growth_outside_a, v1.fee_growth_outside_b)
            } else {
                (turbos_clmm::math_u128::wrapping_sub(arg0.fee_growth_global_a, v1.fee_growth_outside_a), turbos_clmm::math_u128::wrapping_sub(arg0.fee_growth_global_b, v1.fee_growth_outside_b))
            }
        };
        (turbos_clmm::math_u128::wrapping_sub(turbos_clmm::math_u128::wrapping_sub(arg0.fee_growth_global_a, v2), v4), turbos_clmm::math_u128::wrapping_sub(turbos_clmm::math_u128::wrapping_sub(arg0.fee_growth_global_b, v3), v5))
    }
    
    fun next_initialized_tick_within_one_word<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: turbos_clmm::i32::I32, arg2: bool) : (turbos_clmm::i32::I32, bool) {
        let v0 = turbos_clmm::i32::div(arg1, turbos_clmm::i32::from(arg0.tick_spacing));
        let v1 = v0;
        if (turbos_clmm::i32::lt(arg1, turbos_clmm::i32::zero()) && !turbos_clmm::i32::eq(turbos_clmm::i32::mod_euclidean(arg1, arg0.tick_spacing), turbos_clmm::i32::zero())) {
            v1 = turbos_clmm::i32::sub(v0, turbos_clmm::i32::from(1));
        };
        let (v2, v3) = if (arg2) {
            let (v4, v5) = position_tick(v1);
            try_init_tick_word<T0, T1, T2>(arg0, v4);
            let v6 = get_tick_word<T0, T1, T2>(arg0, v4) & (1 << v5) - 1 + (1 << v5);
            let v7 = if (v6 != 0) {
                turbos_clmm::i32::mul(turbos_clmm::i32::sub(v1, turbos_clmm::i32::from(((v5 - turbos_clmm::math_bit::most_significant_bit(v6)) as u32))), turbos_clmm::i32::from(arg0.tick_spacing))
            } else {
                turbos_clmm::i32::mul(turbos_clmm::i32::sub(v1, turbos_clmm::i32::from((v5 as u32))), turbos_clmm::i32::from(arg0.tick_spacing))
            };
            (v12, v7)
        } else {
            let (v8, v9) = position_tick(turbos_clmm::i32::add(v1, turbos_clmm::i32::from(1)));
            try_init_tick_word<T0, T1, T2>(arg0, v8);
            let v10 = get_tick_word<T0, T1, T2>(arg0, v8) & ((1 << v9) - 1 ^ 115792089237316195423570985008687907853269984665640564039457584007913129639935);
            let v11 = if (v10 != 0) {
                turbos_clmm::i32::mul(turbos_clmm::i32::add(turbos_clmm::i32::add(v1, turbos_clmm::i32::from(1)), turbos_clmm::i32::sub(turbos_clmm::i32::from((turbos_clmm::math_bit::least_significant_bit(v10) as u32)), turbos_clmm::i32::from((v9 as u32)))), turbos_clmm::i32::from(arg0.tick_spacing))
            } else {
                turbos_clmm::i32::mul(turbos_clmm::i32::add(turbos_clmm::i32::add(v1, turbos_clmm::i32::from(1)), turbos_clmm::i32::from(((255 - v9) as u32))), turbos_clmm::i32::from(arg0.tick_spacing))
            };
            (v13, v11)
        };
        (v3, v2)
    }
    
    fun next_pool_reward_infos<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: u64) : vector<u128> {
        let v0 = arg0.reward_last_updated_time_ms;
        assert!(arg1 >= v0, 15);
        let v1 = 0x1::vector::empty<u128>();
        let v2 = (arg1 - v0) / 1000;
        let v3 = 0;
        while (v3 < 0x1::vector::length<PoolRewardInfo>(&arg0.reward_infos)) {
            let v4 = 0x1::vector::borrow_mut<PoolRewardInfo>(&mut arg0.reward_infos, v3);
            if (arg0.liquidity == 0 || v2 == 0) {
                0x1::vector::insert<u128>(&mut v1, v4.growth_global, v3);
            } else {
                v4.growth_global = turbos_clmm::math_u128::wrapping_add(v4.growth_global, turbos_clmm::full_math_u128::mul_div_floor((v2 as u128), v4.emissions_per_second, arg0.liquidity));
                0x1::vector::insert<u128>(&mut v1, v4.growth_global, v3);
            };
            v3 = v3 + 1;
        };
        let v5 = 0x1::vector::length<u128>(&v1);
        while (v5 < 3) {
            0x1::vector::push_back<u128>(&mut v1, 0);
            v5 = v5 + 1;
        };
        arg0.reward_last_updated_time_ms = arg1;
        v1
    }
    
    fun next_reward_growths_inside<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: turbos_clmm::i32::I32, arg2: turbos_clmm::i32::I32, arg3: turbos_clmm::i32::I32, arg4: &mut 0x2::tx_context::TxContext) : vector<u128> {
        let v0 = 0x1::vector::empty<u128>();
        let v1 = get_tick<T0, T1, T2>(arg0, arg1);
        let v2 = get_tick<T0, T1, T2>(arg0, arg2);
        let v3 = 0;
        while (v3 < 0x1::vector::length<PoolRewardInfo>(&arg0.reward_infos)) {
            let v4 = 0x1::vector::borrow<PoolRewardInfo>(&arg0.reward_infos, v3);
            let v5 = *0x1::vector::borrow<u128>(&v2.reward_growths_outside, v3);
            let v6 = if (!v1.initialized) {
                v4.growth_global
            } else {
                if (turbos_clmm::i32::gte(arg3, arg1)) {
                    *0x1::vector::borrow<u128>(&v1.reward_growths_outside, v3)
                } else {
                    turbos_clmm::math_u128::wrapping_sub(v4.growth_global, *0x1::vector::borrow<u128>(&v1.reward_growths_outside, v3))
                }
            };
            let v7 = if (!v2.initialized) {
                0
            } else {
                if (turbos_clmm::i32::lt(arg3, arg2)) {
                    v5
                } else {
                    turbos_clmm::math_u128::wrapping_sub(v4.growth_global, v5)
                }
            };
            0x1::vector::insert<u128>(&mut v0, turbos_clmm::math_u128::wrapping_sub(turbos_clmm::math_u128::wrapping_sub(v4.growth_global, v6), v7), v3);
            v3 = v3 + 1;
        };
        v0
    }
    
    public fun position_tick(arg0: turbos_clmm::i32::I32) : (turbos_clmm::i32::I32, u8) {
        (turbos_clmm::i32::shr(arg0, 8), (turbos_clmm::i32::abs_u32(turbos_clmm::i32::mod_euclidean(arg0, 256)) as u8))
    }
    
    public(friend) fun remove_reward<T0, T1, T2, T3>(arg0: &mut Pool<T0, T1, T2>, arg1: &mut PoolRewardVault<T3>, arg2: u64, arg3: u64, arg4: address, arg5: &0x2::clock::Clock, arg6: &mut 0x2::tx_context::TxContext) {
        assert!(arg2 < 0x1::vector::length<PoolRewardInfo>(&arg0.reward_infos), 13);
        next_pool_reward_infos<T0, T1, T2>(arg0, 0x2::clock::timestamp_ms(arg5));
        let v0 = 0x1::vector::borrow<PoolRewardInfo>(&arg0.reward_infos, arg2);
        assert!(v0.manager == 0x2::tx_context::sender(arg6), 17);
        assert!(v0.vault == 0x2::object::id_address<PoolRewardVault<T3>>(arg1), 14);
        assert!(arg3 <= 0x2::balance::value<T3>(&arg1.coin), 16);
        0x2::transfer::public_transfer<0x2::coin::Coin<T3>>(0x2::coin::from_balance<T3>(0x2::balance::split<T3>(&mut arg1.coin, arg3), arg6), arg4);
        let v1 = RemoveRewardEvent{
            pool           : 0x2::object::id<Pool<T0, T1, T2>>(arg0), 
            reward_index   : arg2, 
            reward_vault   : v0.vault, 
            reward_manager : v0.manager, 
            amount         : arg3, 
            recipient      : arg4,
        };
        0x2::event::emit<RemoveRewardEvent>(v1);
    }
    
    fun save_position<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: 0x1::string::String, arg2: Position) {
        0x2::dynamic_object_field::add<0x1::string::String, Position>(&mut arg0.id, arg1, arg2);
    }
    
    public(friend) fun split_and_return_<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: 0x2::coin::Coin<T0>, arg2: u64, arg3: 0x2::coin::Coin<T1>, arg4: u64, arg5: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T1>) {
        transfer_in<T0, T1, T2>(arg0, 0x2::coin::split<T0>(&mut arg1, arg2, arg5), 0x2::coin::split<T1>(&mut arg3, arg4, arg5));
        (arg1, arg3)
    }
    
    public(friend) fun split_and_transfer<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: 0x2::coin::Coin<T0>, arg2: u64, arg3: 0x2::coin::Coin<T1>, arg4: u64, arg5: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public(friend) fun split_out_and_return_<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: u64, arg2: u64, arg3: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T1>) {
        (0x2::coin::from_balance<T0>(0x2::balance::split<T0>(&mut arg0.coin_a, arg1), arg3), 0x2::coin::from_balance<T1>(0x2::balance::split<T1>(&mut arg0.coin_b, arg2), arg3))
    }
    
    public(friend) fun swap_coin_a_b<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: 0x2::coin::Coin<T0>, arg2: u64, arg3: u64, arg4: address, arg5: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public(friend) fun swap_coin_a_b_b_c<T0, T1, T2, T3, T4>(arg0: &mut Pool<T0, T2, T1>, arg1: &mut Pool<T2, T4, T3>, arg2: 0x2::coin::Coin<T0>, arg3: u64, arg4: u64, arg5: u64, arg6: address, arg7: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public(friend) fun swap_coin_a_b_b_c_with_return_<T0, T1, T2, T3, T4>(arg0: &mut Pool<T0, T2, T1>, arg1: &mut Pool<T2, T4, T3>, arg2: 0x2::coin::Coin<T0>, arg3: u64, arg4: u64, arg5: u64, arg6: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T4>, 0x2::coin::Coin<T0>) {
        0x2::balance::join<T0>(&mut arg0.coin_a, 0x2::coin::into_balance<T0>(0x2::coin::split<T0>(&mut arg2, arg3, arg6)));
        0x2::balance::join<T2>(&mut arg1.coin_a, 0x2::coin::into_balance<T2>(0x2::coin::from_balance<T2>(0x2::balance::split<T2>(&mut arg0.coin_b, arg4), arg6)));
        (0x2::coin::from_balance<T4>(0x2::balance::split<T4>(&mut arg1.coin_b, arg5), arg6), arg2)
    }
    
    public(friend) fun swap_coin_a_b_c_b<T0, T1, T2, T3, T4>(arg0: &mut Pool<T0, T2, T1>, arg1: &mut Pool<T4, T2, T3>, arg2: 0x2::coin::Coin<T0>, arg3: u64, arg4: u64, arg5: u64, arg6: address, arg7: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public(friend) fun swap_coin_a_b_c_b_with_return_<T0, T1, T2, T3, T4>(arg0: &mut Pool<T0, T2, T1>, arg1: &mut Pool<T4, T2, T3>, arg2: 0x2::coin::Coin<T0>, arg3: u64, arg4: u64, arg5: u64, arg6: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T4>, 0x2::coin::Coin<T0>) {
        0x2::balance::join<T0>(&mut arg0.coin_a, 0x2::coin::into_balance<T0>(0x2::coin::split<T0>(&mut arg2, arg3, arg6)));
        0x2::balance::join<T2>(&mut arg1.coin_b, 0x2::coin::into_balance<T2>(0x2::coin::from_balance<T2>(0x2::balance::split<T2>(&mut arg0.coin_b, arg4), arg6)));
        (0x2::coin::from_balance<T4>(0x2::balance::split<T4>(&mut arg1.coin_a, arg5), arg6), arg2)
    }
    
    public(friend) fun swap_coin_a_b_with_return_<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: 0x2::coin::Coin<T0>, arg2: u64, arg3: u64, arg4: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T1>, 0x2::coin::Coin<T0>) {
        0x2::balance::join<T0>(&mut arg0.coin_a, 0x2::coin::into_balance<T0>(0x2::coin::split<T0>(&mut arg1, arg2, arg4)));
        (0x2::coin::from_balance<T1>(0x2::balance::split<T1>(&mut arg0.coin_b, arg3), arg4), arg1)
    }
    
    public(friend) fun swap_coin_b_a<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: 0x2::coin::Coin<T1>, arg2: u64, arg3: u64, arg4: address, arg5: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public(friend) fun swap_coin_b_a_b_c<T0, T1, T2, T3, T4>(arg0: &mut Pool<T2, T0, T1>, arg1: &mut Pool<T2, T4, T3>, arg2: 0x2::coin::Coin<T0>, arg3: u64, arg4: u64, arg5: u64, arg6: address, arg7: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public(friend) fun swap_coin_b_a_b_c_with_return_<T0, T1, T2, T3, T4>(arg0: &mut Pool<T2, T0, T1>, arg1: &mut Pool<T2, T4, T3>, arg2: 0x2::coin::Coin<T0>, arg3: u64, arg4: u64, arg5: u64, arg6: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T4>, 0x2::coin::Coin<T0>) {
        0x2::balance::join<T0>(&mut arg0.coin_b, 0x2::coin::into_balance<T0>(0x2::coin::split<T0>(&mut arg2, arg3, arg6)));
        0x2::balance::join<T2>(&mut arg1.coin_a, 0x2::coin::into_balance<T2>(0x2::coin::from_balance<T2>(0x2::balance::split<T2>(&mut arg0.coin_a, arg4), arg6)));
        (0x2::coin::from_balance<T4>(0x2::balance::split<T4>(&mut arg1.coin_b, arg5), arg6), arg2)
    }
    
    public(friend) fun swap_coin_b_a_c_b<T0, T1, T2, T3, T4>(arg0: &mut Pool<T2, T0, T1>, arg1: &mut Pool<T4, T2, T3>, arg2: 0x2::coin::Coin<T0>, arg3: u64, arg4: u64, arg5: u64, arg6: address, arg7: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public(friend) fun swap_coin_b_a_c_b_with_return_<T0, T1, T2, T3, T4>(arg0: &mut Pool<T2, T0, T1>, arg1: &mut Pool<T4, T2, T3>, arg2: 0x2::coin::Coin<T0>, arg3: u64, arg4: u64, arg5: u64, arg6: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T4>, 0x2::coin::Coin<T0>) {
        0x2::balance::join<T0>(&mut arg0.coin_b, 0x2::coin::into_balance<T0>(0x2::coin::split<T0>(&mut arg2, arg3, arg6)));
        0x2::balance::join<T2>(&mut arg1.coin_b, 0x2::coin::into_balance<T2>(0x2::coin::from_balance<T2>(0x2::balance::split<T2>(&mut arg0.coin_a, arg4), arg6)));
        (0x2::coin::from_balance<T4>(0x2::balance::split<T4>(&mut arg1.coin_a, arg5), arg6), arg2)
    }
    
    public(friend) fun swap_coin_b_a_with_return_<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: 0x2::coin::Coin<T1>, arg2: u64, arg3: u64, arg4: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T1>) {
        0x2::balance::join<T1>(&mut arg0.coin_b, 0x2::coin::into_balance<T1>(0x2::coin::split<T1>(&mut arg1, arg2, arg4)));
        (0x2::coin::from_balance<T0>(0x2::balance::split<T0>(&mut arg0.coin_a, arg3), arg4), arg1)
    }
    
    public(friend) fun toggle_pool_status<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: &mut 0x2::tx_context::TxContext) {
        arg0.unlocked = !arg0.unlocked;
        let v0 = TogglePoolStatusEvent{
            pool   : 0x2::object::id<Pool<T0, T1, T2>>(arg0), 
            status : arg0.unlocked,
        };
        0x2::event::emit<TogglePoolStatusEvent>(v0);
    }
    
    public(friend) fun transfer_in<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: 0x2::coin::Coin<T0>, arg2: 0x2::coin::Coin<T1>) {
        0x2::balance::join<T0>(&mut arg0.coin_a, 0x2::coin::into_balance<T0>(arg1));
        0x2::balance::join<T1>(&mut arg0.coin_b, 0x2::coin::into_balance<T1>(arg2));
    }
    
    public(friend) fun transfer_out<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: u64, arg2: u64, arg3: address, arg4: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    fun try_init_position<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: address, arg2: turbos_clmm::i32::I32, arg3: turbos_clmm::i32::I32, arg4: &mut 0x2::tx_context::TxContext) {
        let v0 = get_position_key(arg1, arg2, arg3);
        if (!0x2::dynamic_object_field::exists_<0x1::string::String>(&arg0.id, v0)) {
            let v1 = 0x1::vector::empty<PositionRewardInfo>();
            let v2 = 0;
            while (v2 < 3) {
                let v3 = PositionRewardInfo{
                    reward_growth_inside : 0, 
                    amount_owed          : 0,
                };
                0x1::vector::push_back<PositionRewardInfo>(&mut v1, v3);
                v2 = v2 + 1;
            };
            let v4 = Position{
                id                  : 0x2::object::new(arg4), 
                liquidity           : 0, 
                fee_growth_inside_a : 0, 
                fee_growth_inside_b : 0, 
                tokens_owed_a       : 0, 
                tokens_owed_b       : 0, 
                reward_infos        : v1,
            };
            0x2::dynamic_object_field::add<0x1::string::String, Position>(&mut arg0.id, v0, v4);
        };
    }
    
    fun try_init_tick_word<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: turbos_clmm::i32::I32) {
        if (!0x2::table::contains<turbos_clmm::i32::I32, u256>(&arg0.tick_map, arg1)) {
            0x2::table::add<turbos_clmm::i32::I32, u256>(&mut arg0.tick_map, arg1, 0);
        };
    }
    
    public(friend) fun update_pool_fee_protocol<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: u32) {
        arg0.fee_protocol = arg1;
        let v0 = UpdatePoolFeeProtocolEvent{
            pool         : 0x2::object::id<Pool<T0, T1, T2>>(arg0), 
            fee_protocol : arg1,
        };
        0x2::event::emit<UpdatePoolFeeProtocolEvent>(v0);
    }
    
    fun update_position<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: address, arg2: turbos_clmm::i32::I32, arg3: turbos_clmm::i32::I32, arg4: turbos_clmm::i128::I128, arg5: &0x2::clock::Clock, arg6: &mut 0x2::tx_context::TxContext) {
        let v0 = arg0.tick_current_index;
        let v1 = false;
        let v2 = false;
        let v3 = next_pool_reward_infos<T0, T1, T2>(arg0, 0x2::clock::timestamp_ms(arg5));
        if (!turbos_clmm::i128::eq(arg4, turbos_clmm::i128::zero())) {
            let v4 = update_tick<T0, T1, T2>(arg0, arg2, v0, arg4, false, v3, arg6);
            v1 = v4;
            let v5 = update_tick<T0, T1, T2>(arg0, arg3, v0, arg4, true, v3, arg6);
            v2 = v5;
            if (v4) {
                flip_tick<T0, T1, T2>(arg0, arg2, arg6);
            };
            if (v5) {
                flip_tick<T0, T1, T2>(arg0, arg3, arg6);
            };
        };
        let (v6, v7) = next_fee_growth_inside<T0, T1, T2>(arg0, arg2, arg3, v0, arg6);
        update_position_metadata<T0, T1, T2>(arg0, get_position_key(arg1, arg2, arg3), arg4, v6, v7, next_reward_growths_inside<T0, T1, T2>(arg0, arg2, arg3, v0, arg6), arg6);
        if (turbos_clmm::i128::is_neg(arg4)) {
            if (v1) {
                clear_tick<T0, T1, T2>(arg0, arg2, arg6);
            };
            if (v2) {
                clear_tick<T0, T1, T2>(arg0, arg3, arg6);
            };
        };
    }
    
    fun update_position_metadata<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: 0x1::string::String, arg2: turbos_clmm::i128::I128, arg3: u128, arg4: u128, arg5: vector<u128>, arg6: &mut 0x2::tx_context::TxContext) {
        let v0 = get_position_mut_by_key<T0, T1, T2>(arg0, arg1);
        let v1 = if (turbos_clmm::i128::eq(arg2, turbos_clmm::i128::zero())) {
            assert!(v0.liquidity > 0, 6);
            v0.liquidity
        } else {
            turbos_clmm::math_liquidity::add_delta(v0.liquidity, arg2)
        };
        let v2 = (turbos_clmm::full_math_u128::mul_div_floor(turbos_clmm::math_u128::wrapping_sub(arg3, v0.fee_growth_inside_a), v0.liquidity, 18446744073709551616) as u64);
        let v3 = (turbos_clmm::full_math_u128::mul_div_floor(turbos_clmm::math_u128::wrapping_sub(arg4, v0.fee_growth_inside_b), v0.liquidity, 18446744073709551616) as u64);
        v0.fee_growth_inside_a = arg3;
        v0.fee_growth_inside_b = arg4;
        if (v2 > 0 || v3 > 0) {
            v0.tokens_owed_a = turbos_clmm::math_u64::wrapping_add(v0.tokens_owed_a, v2);
            v0.tokens_owed_b = turbos_clmm::math_u64::wrapping_add(v0.tokens_owed_b, v3);
        };
        let v4 = 0;
        while (v4 < 0x1::vector::length<PoolRewardInfo>(&arg0.reward_infos)) {
            let v5 = *0x1::vector::borrow<u128>(&arg5, v4);
            let v6 = 0x1::vector::borrow_mut<PositionRewardInfo>(&mut v0.reward_infos, v4);
            v6.reward_growth_inside = v5;
            v6.amount_owed = turbos_clmm::math_u64::wrapping_add(v6.amount_owed, (turbos_clmm::full_math_u128::mul_div_floor(turbos_clmm::math_u128::wrapping_sub(v5, v6.reward_growth_inside), v0.liquidity, 18446744073709551616) as u64));
            v4 = v4 + 1;
        };
        if (!turbos_clmm::i128::eq(arg2, turbos_clmm::i128::zero())) {
            v0.liquidity = v1;
        };
    }
    
    public(friend) fun update_reward_emissions<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: u64, arg2: u128, arg3: &0x2::clock::Clock, arg4: &mut 0x2::tx_context::TxContext) {
        next_pool_reward_infos<T0, T1, T2>(arg0, 0x2::clock::timestamp_ms(arg3));
        assert!(arg1 < 0x1::vector::length<PoolRewardInfo>(&arg0.reward_infos), 13);
        let v0 = 0x1::vector::borrow_mut<PoolRewardInfo>(&mut arg0.reward_infos, arg1);
        assert!(v0.manager == 0x2::tx_context::sender(arg4), 17);
        v0.emissions_per_second = arg2 << 64;
        let v1 = UpdateRewardEmissionsEvent{
            pool                        : 0x2::object::id<Pool<T0, T1, T2>>(arg0), 
            reward_index                : arg1, 
            reward_vault                : v0.vault, 
            reward_manager              : v0.manager, 
            reward_emissions_per_second : arg2,
        };
        0x2::event::emit<UpdateRewardEmissionsEvent>(v1);
    }
    
    public(friend) fun update_reward_manager<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: u64, arg2: address, arg3: &mut 0x2::tx_context::TxContext) {
        assert!(arg1 < 3, 13);
        assert!(arg1 < 0x1::vector::length<PoolRewardInfo>(&arg0.reward_infos), 13);
        0x1::vector::borrow_mut<PoolRewardInfo>(&mut arg0.reward_infos, arg1).manager = arg2;
        let v0 = UpdateRewardManagerEvent{
            pool           : 0x2::object::id<Pool<T0, T1, T2>>(arg0), 
            reward_index   : arg1, 
            reward_manager : arg2,
        };
        0x2::event::emit<UpdateRewardManagerEvent>(v0);
    }
    
    fun update_tick<T0, T1, T2>(arg0: &mut Pool<T0, T1, T2>, arg1: turbos_clmm::i32::I32, arg2: turbos_clmm::i32::I32, arg3: turbos_clmm::i128::I128, arg4: bool, arg5: vector<u128>, arg6: &mut 0x2::tx_context::TxContext) : bool {
        let v0 = if (!0x2::dynamic_field::exists_<turbos_clmm::i32::I32>(&arg0.id, arg1)) {
            init_tick<T0, T1, T2>(arg0, arg1, arg6)
        } else {
            0x2::dynamic_field::borrow_mut<turbos_clmm::i32::I32, Tick>(&mut arg0.id, arg1)
        };
        let v1 = v0.liquidity_gross;
        let v2 = turbos_clmm::math_liquidity::add_delta(v1, arg3);
        assert!(v2 <= arg0.max_liquidity_per_tick, 11);
        if (v1 == 0) {
            if (turbos_clmm::i32::lte(arg1, arg2)) {
                v0.fee_growth_outside_a = arg0.fee_growth_global_a;
                v0.fee_growth_outside_b = arg0.fee_growth_global_b;
                v0.reward_growths_outside = arg5;
            };
            v0.initialized = true;
        };
        v0.liquidity_gross = v2;
        let v3 = if (arg4) {
            turbos_clmm::i128::sub(v0.liquidity_net, arg3)
        } else {
            turbos_clmm::i128::add(v0.liquidity_net, arg3)
        };
        v0.liquidity_net = v3;
        v2 == 0 != v1 == 0
    }
    
    public(friend) fun upgrade(arg0: &mut Versioned) {
        let v0 = arg0.version;
        assert!(v0 < 9, 22);
        arg0.version = 9;
        let v1 = UpgradeEvent{
            old_version : v0, 
            new_version : 9,
        };
        0x2::event::emit<UpgradeEvent>(v1);
    }
    
    public fun version(arg0: &Versioned) : u64 {
        arg0.version
    }
}