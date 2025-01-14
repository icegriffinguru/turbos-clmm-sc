module turbos_clmm::swap_router {
    use sui::tx_context::{TxContext};
    use turbos_clmm::pool::{Self, Pool, Versioned};
	use sui::coin::{Coin};
    use sui::clock::{Self, Clock};

    public fun swap_a_b_with_return_<CoinTypeA, CoinTypeB, FeeType>(
        pool: &mut Pool<CoinTypeA, CoinTypeB, FeeType>,
        coins_a: vector<Coin<CoinTypeA>>, 
        amount: u64,
        amount_threshold: u64,
        sqrt_price_limit: u128,
        is_exact_in: bool,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
        ctx: &mut TxContext
    ): (Coin<CoinTypeB>, Coin<CoinTypeA>) {
        abort 0
    }

    public entry fun swap_a_b<CoinTypeA, CoinTypeB, FeeType>(
		pool: &mut Pool<CoinTypeA, CoinTypeB, FeeType>,
		coins_a: vector<Coin<CoinTypeA>>, 
		amount: u64,
        amount_threshold: u64,
        sqrt_price_limit: u128,
        is_exact_in: bool,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
		ctx: &mut TxContext
    ) {
        abort 0
    }

    public fun swap_b_a_with_return_<CoinTypeA, CoinTypeB, FeeType>(
        pool: &mut Pool<CoinTypeA, CoinTypeB, FeeType>,
        coins_b: vector<Coin<CoinTypeB>>, 
        amount: u64,
        amount_threshold: u64,
        sqrt_price_limit: u128,
        is_exact_in: bool,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
        ctx: &mut TxContext
    ): (Coin<CoinTypeA>, Coin<CoinTypeB>) {
        abort 0
    }

    public entry fun swap_b_a<CoinTypeA, CoinTypeB, FeeType>(
		pool: &mut Pool<CoinTypeA, CoinTypeB, FeeType>,
		coins_b: vector<Coin<CoinTypeB>>, 
		amount: u64,
        amount_threshold: u64,
        sqrt_price_limit: u128,
        is_exact_in: bool,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
		ctx: &mut TxContext
    ) {
        abort 0
    }

    public fun swap_a_b_b_c_with_return_<CoinTypeA, FeeTypeA, CoinTypeB, FeeTypeB, CoinTypeC>(
        pool_a: &mut Pool<CoinTypeA, CoinTypeB, FeeTypeA>,
        pool_b: &mut Pool<CoinTypeB, CoinTypeC, FeeTypeB>,
        coins_a: vector<Coin<CoinTypeA>>, 
        amount: u64,
        amount_threshold: u64,
        sqrt_price_limit_one: u128,
        sqrt_price_limit_two: u128,
        is_exact_in: bool,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
        ctx: &mut TxContext
    ): (Coin<CoinTypeC>, Coin<CoinTypeA>) {
        abort 0
    }

    // such as: pool a: BTC/USDC, pool b: USDC/ETH
    // if swap BTC to ETH,route is BTC -> USDC -> ETH,fee paid in BTC and USDC 
    // step one: swap BTC to USDC (a to b), step two: swap USDC to ETH (a to b)
    public entry fun swap_a_b_b_c<CoinTypeA, FeeTypeA, CoinTypeB, FeeTypeB, CoinTypeC>(
		pool_a: &mut Pool<CoinTypeA, CoinTypeB, FeeTypeA>,
        pool_b: &mut Pool<CoinTypeB, CoinTypeC, FeeTypeB>,
		coins_a: vector<Coin<CoinTypeA>>, 
		amount: u64,
        amount_threshold: u64,
        sqrt_price_limit_one: u128,
        sqrt_price_limit_two: u128,
        is_exact_in: bool,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
		ctx: &mut TxContext
    ) {
        abort 0
    }

    public fun swap_a_b_c_b_with_return_<CoinTypeA, FeeTypeA, CoinTypeB, FeeTypeB, CoinTypeC>(
        pool_a: &mut Pool<CoinTypeA, CoinTypeB, FeeTypeA>,
        pool_b: &mut Pool<CoinTypeC, CoinTypeB, FeeTypeB>,
        coins_a: vector<Coin<CoinTypeA>>, 
        amount: u64,
        amount_threshold: u64,
        sqrt_price_limit_one: u128,
        sqrt_price_limit_two: u128,
        is_exact_in: bool,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
        ctx: &mut TxContext
    ): (Coin<CoinTypeC>, Coin<CoinTypeA>) {
        abort 0
    }

    // such as: pool a: BTC/USDC, pool b: ETH/USDC
    // if swap BTC to ETH, route is BTC -> USDC -> ETH,fee paid in BTC and USDC 
    // step one: swap BTC to USDC (a to b), step two: swap USDC to ETH (b to a)
    public entry fun swap_a_b_c_b<CoinTypeA, FeeTypeA, CoinTypeB, FeeTypeB, CoinTypeC>(
		pool_a: &mut Pool<CoinTypeA, CoinTypeB, FeeTypeA>,
        pool_b: &mut Pool<CoinTypeC, CoinTypeB, FeeTypeB>,
		coins_a: vector<Coin<CoinTypeA>>, 
		amount: u64,
        amount_threshold: u64,
        sqrt_price_limit_one: u128,
        sqrt_price_limit_two: u128,
        is_exact_in: bool,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
		ctx: &mut TxContext
    ) {
        abort 0
    }

    public fun swap_b_a_b_c_with_return_<CoinTypeA, FeeTypeA, CoinTypeB, FeeTypeB, CoinTypeC>(
        pool_a: &mut Pool<CoinTypeB, CoinTypeA, FeeTypeA>,
        pool_b: &mut Pool<CoinTypeB, CoinTypeC, FeeTypeB>,
        coins_a: vector<Coin<CoinTypeA>>, 
        amount: u64,
        amount_threshold: u64,
        sqrt_price_limit_one: u128,
        sqrt_price_limit_two: u128,
        is_exact_in: bool,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
        ctx: &mut TxContext
    ): (Coin<CoinTypeC>, Coin<CoinTypeA>) {
        abort 0
    }

    // such as: pool a: USDC/BTC, pool b: USDC/ETH
    // if swap BTC to ETH, route is BTC -> USDC -> ETH, fee paid in BTC and USDC 
    // step one: swap BTC to USDC (b to a), step two: swap USDC to ETH (a to b)
    public entry fun swap_b_a_b_c<CoinTypeA, FeeTypeA, CoinTypeB, FeeTypeB, CoinTypeC>(
		pool_a: &mut Pool<CoinTypeB, CoinTypeA, FeeTypeA>,
        pool_b: &mut Pool<CoinTypeB, CoinTypeC, FeeTypeB>,
		coins_a: vector<Coin<CoinTypeA>>, 
		amount: u64,
        amount_threshold: u64,
        sqrt_price_limit_one: u128,
        sqrt_price_limit_two: u128,
        is_exact_in: bool,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
		ctx: &mut TxContext
    ) {
        abort 0
    }

    public fun swap_b_a_c_b_with_return_<CoinTypeA, FeeTypeA, CoinTypeB, FeeTypeB, CoinTypeC>(
        pool_a: &mut Pool<CoinTypeB, CoinTypeA, FeeTypeA>,
        pool_b: &mut Pool<CoinTypeC, CoinTypeB, FeeTypeB>,
        coins_a: vector<Coin<CoinTypeA>>, 
        amount: u64,
        amount_threshold: u64,
        sqrt_price_limit_one: u128,
        sqrt_price_limit_two: u128,
        is_exact_in: bool,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
        ctx: &mut TxContext
    ): (Coin<CoinTypeC>, Coin<CoinTypeA>) {
        abort 0
    }

    // such as: pool a: USDC/BTC, pool b: ETH/USDC
    // if swap BTC to ETH, route is BTC -> USDC -> ETH, fee paid in BTC and USDC 
    // step one: swap BTC to USDC (b to a), step two: swap USDC to ETH (b to a)
    public entry fun swap_b_a_c_b<CoinTypeA, FeeTypeA, CoinTypeB, FeeTypeB, CoinTypeC>(
		pool_a: &mut Pool<CoinTypeB, CoinTypeA, FeeTypeA>,
        pool_b: &mut Pool<CoinTypeC, CoinTypeB, FeeTypeB>,
		coins_a: vector<Coin<CoinTypeA>>, 
		amount: u64,
        amount_threshold: u64,
        sqrt_price_limit_one: u128,
        sqrt_price_limit_two: u128,
        is_exact_in: bool,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
		ctx: &mut TxContext
    ) {
        abort 0
    }

    fun check_amount_threshold(arg0: bool, arg1: bool, arg2: u64, arg3: u64, arg4: u64) {
        if (arg0) {
            let v0 = if (arg1 && arg4 > arg3) {
                true
            } else {
                let v1 = !arg1 && arg4 > arg2;
                v1
            };
            if (v0) {
                abort 4
            };
        } else {
            let v2 = if (arg1 && arg4 < arg2) {
                true
            } else {
                let v3 = !arg1 && arg4 < arg3;
                v3
            };
            if (v2) {
                abort 5
            };
        };
    }
    
    public entry fun swap_a_b<T0, T1, T2>(arg0: &mut turbos_clmm::pool::Pool<T0, T1, T2>, arg1: vector<0x2::coin::Coin<T0>>, arg2: u64, arg3: u64, arg4: u128, arg5: bool, arg6: address, arg7: u64, arg8: &0x2::clock::Clock, arg9: &turbos_clmm::pool::Versioned, arg10: &mut 0x2::tx_context::TxContext) {
        turbos_clmm::pool::check_version(arg9);
        let (v0, v1) = swap_a_b_with_return_<T0, T1, T2>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
        let v2 = v1;
        0x2::transfer::public_transfer<0x2::coin::Coin<T1>>(v0, arg6);
        if (0x2::coin::value<T0>(&v2) == 0) {
            0x2::coin::destroy_zero<T0>(v2);
        } else {
            0x2::transfer::public_transfer<0x2::coin::Coin<T0>>(v2, 0x2::tx_context::sender(arg10));
        };
    }
    
    public entry fun swap_a_b_b_c<T0, T1, T2, T3, T4>(arg0: &mut turbos_clmm::pool::Pool<T0, T2, T1>, arg1: &mut turbos_clmm::pool::Pool<T2, T4, T3>, arg2: vector<0x2::coin::Coin<T0>>, arg3: u64, arg4: u64, arg5: u128, arg6: u128, arg7: bool, arg8: address, arg9: u64, arg10: &0x2::clock::Clock, arg11: &turbos_clmm::pool::Versioned, arg12: &mut 0x2::tx_context::TxContext) {
        turbos_clmm::pool::check_version(arg11);
        let (v0, v1) = swap_a_b_b_c_with_return_<T0, T1, T2, T3, T4>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);
        let v2 = v1;
        0x2::transfer::public_transfer<0x2::coin::Coin<T4>>(v0, arg8);
        if (0x2::coin::value<T0>(&v2) == 0) {
            0x2::coin::destroy_zero<T0>(v2);
        } else {
            0x2::transfer::public_transfer<0x2::coin::Coin<T0>>(v2, 0x2::tx_context::sender(arg12));
        };
    }
    
    public fun swap_a_b_b_c_with_return_<T0, T1, T2, T3, T4>(arg0: &mut turbos_clmm::pool::Pool<T0, T2, T1>, arg1: &mut turbos_clmm::pool::Pool<T2, T4, T3>, arg2: vector<0x2::coin::Coin<T0>>, arg3: u64, arg4: u64, arg5: u128, arg6: u128, arg7: bool, arg8: address, arg9: u64, arg10: &0x2::clock::Clock, arg11: &turbos_clmm::pool::Versioned, arg12: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T4>, 0x2::coin::Coin<T0>) {
        turbos_clmm::pool::check_version(arg11);
        assert!(0x2::clock::timestamp_ms(arg10) <= arg9, 2);
        let (v0, v1, v2) = if (arg7) {
            let (v3, v4) = turbos_clmm::pool::swap<T0, T2, T1>(arg0, arg8, true, (arg3 as u128), arg7, arg5, arg10, arg12);
            let (v5, v6) = turbos_clmm::pool::swap<T2, T4, T3>(arg1, arg8, true, v4, arg7, arg6, arg10, arg12);
            assert!(v4 == v5, 6);
            let v7 = (v6 as u64);
            assert!(arg4 <= v7, 4);
            ((v3 as u64), (v4 as u64), v7)
        } else {
            let (v8, v9) = turbos_clmm::pool::swap<T2, T4, T3>(arg1, arg8, true, (arg3 as u128), arg7, arg6, arg10, arg12);
            let (v10, v11) = turbos_clmm::pool::swap<T0, T2, T1>(arg0, arg8, true, v8, arg7, arg5, arg10, arg12);
            assert!(v11 == v8, 6);
            let v12 = (v10 as u64);
            assert!(arg4 >= v12, 5);
            (v12, (v11 as u64), (v9 as u64))
        };
        turbos_clmm::pool::swap_coin_a_b_b_c_with_return_<T0, T1, T2, T3, T4>(arg0, arg1, turbos_clmm::pool::merge_coin<T0>(arg2), v0, v1, v2, arg12)
    }
    
    public entry fun swap_a_b_c_b<T0, T1, T2, T3, T4>(arg0: &mut turbos_clmm::pool::Pool<T0, T2, T1>, arg1: &mut turbos_clmm::pool::Pool<T4, T2, T3>, arg2: vector<0x2::coin::Coin<T0>>, arg3: u64, arg4: u64, arg5: u128, arg6: u128, arg7: bool, arg8: address, arg9: u64, arg10: &0x2::clock::Clock, arg11: &turbos_clmm::pool::Versioned, arg12: &mut 0x2::tx_context::TxContext) {
        turbos_clmm::pool::check_version(arg11);
        let (v0, v1) = swap_a_b_c_b_with_return_<T0, T1, T2, T3, T4>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);
        let v2 = v1;
        0x2::transfer::public_transfer<0x2::coin::Coin<T4>>(v0, arg8);
        if (0x2::coin::value<T0>(&v2) == 0) {
            0x2::coin::destroy_zero<T0>(v2);
        } else {
            0x2::transfer::public_transfer<0x2::coin::Coin<T0>>(v2, 0x2::tx_context::sender(arg12));
        };
    }
    
    public fun swap_a_b_c_b_with_return_<T0, T1, T2, T3, T4>(arg0: &mut turbos_clmm::pool::Pool<T0, T2, T1>, arg1: &mut turbos_clmm::pool::Pool<T4, T2, T3>, arg2: vector<0x2::coin::Coin<T0>>, arg3: u64, arg4: u64, arg5: u128, arg6: u128, arg7: bool, arg8: address, arg9: u64, arg10: &0x2::clock::Clock, arg11: &turbos_clmm::pool::Versioned, arg12: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T4>, 0x2::coin::Coin<T0>) {
        turbos_clmm::pool::check_version(arg11);
        assert!(0x2::clock::timestamp_ms(arg10) <= arg9, 2);
        let (v0, v1, v2) = if (arg7) {
            let (v3, v4) = turbos_clmm::pool::swap<T0, T2, T1>(arg0, arg8, true, (arg3 as u128), arg7, arg5, arg10, arg12);
            let (v5, v6) = turbos_clmm::pool::swap<T4, T2, T3>(arg1, arg8, false, v4, arg7, arg6, arg10, arg12);
            assert!(v4 == v6, 6);
            let v7 = (v5 as u64);
            assert!(arg4 <= v7, 4);
            ((v3 as u64), (v4 as u64), v7)
        } else {
            let (v8, v9) = turbos_clmm::pool::swap<T4, T2, T3>(arg1, arg8, false, (arg3 as u128), arg7, arg6, arg10, arg12);
            let (v10, v11) = turbos_clmm::pool::swap<T0, T2, T1>(arg0, arg8, true, v9, arg7, arg5, arg10, arg12);
            assert!(v11 == v9, 6);
            let v12 = (v10 as u64);
            assert!(arg4 >= v12, 5);
            (v12, (v11 as u64), (v8 as u64))
        };
        turbos_clmm::pool::swap_coin_a_b_c_b_with_return_<T0, T1, T2, T3, T4>(arg0, arg1, turbos_clmm::pool::merge_coin<T0>(arg2), v0, v1, v2, arg12)
    }
    
    public fun swap_a_b_with_return_<T0, T1, T2>(
        pool: &mut turbos_clmm::pool::Pool<T0, T1, T2>,
        coins: vector<0x2::coin::Coin<T0>>,
        swap_amount: u64,
        amount_threshold: u64,
        sqrt_price: u128,
        is_exact_in: bool,
        recipient: address,
        deadline: u64,
        arg8: &0x2::clock::Clock,
        arg9: &turbos_clmm::pool::Versioned,
        arg10: &mut 0x2::tx_context::TxContext
    ) : (0x2::coin::Coin<T1>, 0x2::coin::Coin<T0>) {
        turbos_clmm::pool::check_version(arg9);
        assert!(0x2::clock::timestamp_ms(arg8) <= deadline, 2);
        let (v0, v1) = turbos_clmm::pool::swap<T0, T1, T2>(
            pool,
            recipient,
            true,
            (swap_amount as u128),
            is_exact_in,
            sqrt_price,
            arg8,
            arg10
        );
        let v2 = (v0 as u64);
        let v3 = (v1 as u64);
        check_amount_threshold(is_exact_in, true, v2, v3, amount_threshold);
        turbos_clmm::pool::swap_coin_a_b_with_return_<T0, T1, T2>(pool, turbos_clmm::pool::merge_coin<T0>(coins), v2, v3, arg10)
    }
    
    public entry fun swap_b_a<T0, T1, T2>(arg0: &mut turbos_clmm::pool::Pool<T0, T1, T2>, arg1: vector<0x2::coin::Coin<T1>>, arg2: u64, arg3: u64, arg4: u128, arg5: bool, arg6: address, arg7: u64, arg8: &0x2::clock::Clock, arg9: &turbos_clmm::pool::Versioned, arg10: &mut 0x2::tx_context::TxContext) {
        turbos_clmm::pool::check_version(arg9);
        let (v0, v1) = swap_b_a_with_return_<T0, T1, T2>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
        let v2 = v1;
        0x2::transfer::public_transfer<0x2::coin::Coin<T0>>(v0, arg6);
        if (0x2::coin::value<T1>(&v2) == 0) {
            0x2::coin::destroy_zero<T1>(v2);
        } else {
            0x2::transfer::public_transfer<0x2::coin::Coin<T1>>(v2, 0x2::tx_context::sender(arg10));
        };
    }
    
    public entry fun swap_b_a_b_c<T0, T1, T2, T3, T4>(arg0: &mut turbos_clmm::pool::Pool<T2, T0, T1>, arg1: &mut turbos_clmm::pool::Pool<T2, T4, T3>, arg2: vector<0x2::coin::Coin<T0>>, arg3: u64, arg4: u64, arg5: u128, arg6: u128, arg7: bool, arg8: address, arg9: u64, arg10: &0x2::clock::Clock, arg11: &turbos_clmm::pool::Versioned, arg12: &mut 0x2::tx_context::TxContext) {
        turbos_clmm::pool::check_version(arg11);
        let (v0, v1) = swap_b_a_b_c_with_return_<T0, T1, T2, T3, T4>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);
        let v2 = v1;
        0x2::transfer::public_transfer<0x2::coin::Coin<T4>>(v0, arg8);
        if (0x2::coin::value<T0>(&v2) == 0) {
            0x2::coin::destroy_zero<T0>(v2);
        } else {
            0x2::transfer::public_transfer<0x2::coin::Coin<T0>>(v2, 0x2::tx_context::sender(arg12));
        };
    }
    
    public fun swap_b_a_b_c_with_return_<T0, T1, T2, T3, T4>(arg0: &mut turbos_clmm::pool::Pool<T2, T0, T1>, arg1: &mut turbos_clmm::pool::Pool<T2, T4, T3>, arg2: vector<0x2::coin::Coin<T0>>, arg3: u64, arg4: u64, arg5: u128, arg6: u128, arg7: bool, arg8: address, arg9: u64, arg10: &0x2::clock::Clock, arg11: &turbos_clmm::pool::Versioned, arg12: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T4>, 0x2::coin::Coin<T0>) {
        turbos_clmm::pool::check_version(arg11);
        assert!(0x2::clock::timestamp_ms(arg10) <= arg9, 2);
        let (v0, v1, v2) = if (arg7) {
            let (v3, v4) = turbos_clmm::pool::swap<T2, T0, T1>(arg0, arg8, false, (arg3 as u128), arg7, arg5, arg10, arg12);
            let (v5, v6) = turbos_clmm::pool::swap<T2, T4, T3>(arg1, arg8, true, v3, arg7, arg6, arg10, arg12);
            assert!(v3 == v5, 6);
            let v7 = (v6 as u64);
            assert!(arg4 <= v7, 4);
            ((v4 as u64), (v3 as u64), v7)
        } else {
            let (v8, v9) = turbos_clmm::pool::swap<T2, T4, T3>(arg1, arg8, true, (arg3 as u128), arg7, arg6, arg10, arg12);
            let (v10, v11) = turbos_clmm::pool::swap<T2, T0, T1>(arg0, arg8, false, v8, arg7, arg5, arg10, arg12);
            assert!(v10 == v8, 6);
            let v12 = (v11 as u64);
            assert!(arg4 >= v12, 5);
            (v12, (v10 as u64), (v9 as u64))
        };
        turbos_clmm::pool::swap_coin_b_a_b_c_with_return_<T0, T1, T2, T3, T4>(arg0, arg1, turbos_clmm::pool::merge_coin<T0>(arg2), v0, v1, v2, arg12)
    }
    
    public entry fun swap_b_a_c_b<T0, T1, T2, T3, T4>(arg0: &mut turbos_clmm::pool::Pool<T2, T0, T1>, arg1: &mut turbos_clmm::pool::Pool<T4, T2, T3>, arg2: vector<0x2::coin::Coin<T0>>, arg3: u64, arg4: u64, arg5: u128, arg6: u128, arg7: bool, arg8: address, arg9: u64, arg10: &0x2::clock::Clock, arg11: &turbos_clmm::pool::Versioned, arg12: &mut 0x2::tx_context::TxContext) {
        turbos_clmm::pool::check_version(arg11);
        let (v0, v1) = swap_b_a_c_b_with_return_<T0, T1, T2, T3, T4>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);
        let v2 = v1;
        0x2::transfer::public_transfer<0x2::coin::Coin<T4>>(v0, arg8);
        if (0x2::coin::value<T0>(&v2) == 0) {
            0x2::coin::destroy_zero<T0>(v2);
        } else {
            0x2::transfer::public_transfer<0x2::coin::Coin<T0>>(v2, 0x2::tx_context::sender(arg12));
        };
    }
    
    public fun swap_b_a_c_b_with_return_<T0, T1, T2, T3, T4>(arg0: &mut turbos_clmm::pool::Pool<T2, T0, T1>, arg1: &mut turbos_clmm::pool::Pool<T4, T2, T3>, arg2: vector<0x2::coin::Coin<T0>>, arg3: u64, arg4: u64, arg5: u128, arg6: u128, arg7: bool, arg8: address, arg9: u64, arg10: &0x2::clock::Clock, arg11: &turbos_clmm::pool::Versioned, arg12: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T4>, 0x2::coin::Coin<T0>) {
        turbos_clmm::pool::check_version(arg11);
        assert!(0x2::clock::timestamp_ms(arg10) <= arg9, 2);
        let (v0, v1, v2) = if (arg7) {
            let (v3, v4) = turbos_clmm::pool::swap<T2, T0, T1>(arg0, arg8, false, (arg3 as u128), arg7, arg5, arg10, arg12);
            let (v5, v6) = turbos_clmm::pool::swap<T4, T2, T3>(arg1, arg8, false, v3, arg7, arg6, arg10, arg12);
            assert!(v3 == v6, 6);
            let v7 = (v5 as u64);
            assert!(arg4 <= v7, 4);
            ((v4 as u64), (v3 as u64), v7)
        } else {
            let (v8, v9) = turbos_clmm::pool::swap<T4, T2, T3>(arg1, arg8, false, (arg3 as u128), arg7, arg6, arg10, arg12);
            let (v10, v11) = turbos_clmm::pool::swap<T2, T0, T1>(arg0, arg8, false, v9, arg7, arg5, arg10, arg12);
            assert!(v10 == v9, 6);
            let v12 = (v11 as u64);
            assert!(arg4 >= v12, 5);
            (v12, (v10 as u64), (v8 as u64))
        };
        turbos_clmm::pool::swap_coin_b_a_c_b_with_return_<T0, T1, T2, T3, T4>(arg0, arg1, turbos_clmm::pool::merge_coin<T0>(arg2), v0, v1, v2, arg12)
    }
    
    public fun swap_b_a_with_return_<T0, T1, T2>(arg0: &mut turbos_clmm::pool::Pool<T0, T1, T2>, arg1: vector<0x2::coin::Coin<T1>>, arg2: u64, arg3: u64, arg4: u128, arg5: bool, arg6: address, arg7: u64, arg8: &0x2::clock::Clock, arg9: &turbos_clmm::pool::Versioned, arg10: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T1>) {
        turbos_clmm::pool::check_version(arg9);
        assert!(0x2::clock::timestamp_ms(arg8) <= arg7, 2);
        let (v0, v1) = turbos_clmm::pool::swap<T0, T1, T2>(arg0, arg6, false, (arg2 as u128), arg5, arg4, arg8, arg10);
        let v2 = (v0 as u64);
        let v3 = (v1 as u64);
        check_amount_threshold(arg5, false, v2, v3, arg3);
        turbos_clmm::pool::swap_coin_b_a_with_return_<T0, T1, T2>(arg0, turbos_clmm::pool::merge_coin<T1>(arg1), v3, v2, arg10)
    }
}