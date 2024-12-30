module turbos_clmm::position_nft {
    use std::vector;
    use sui::transfer;
    use sui::url::{Self, Url};
    use std::string::{Self, utf8, String};
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::display;
    use sui::package;
    use sui::tx_context::{Self, TxContext};
    use std::type_name::{TypeName};

    struct TurbosPositionNFT has key, store {
        id: UID,
        name: String,
        description: String,
        img_url: Url,
        pool_id: ID,
        position_id: ID,
        coin_type_a: TypeName,
        coin_type_b: TypeName,
        fee_type: TypeName,
    }

    public fun pool_id(nft: &TurbosPositionNFT): ID {
        abort 0
    }

    public fun position_id(nft: &TurbosPositionNFT): ID {
        abort 0
    }

    public(friend) fun mint(
        arg0: 0x1::string::String,
        arg1: 0x1::string::String,
        arg2: 0x1::string::String,
        arg3: 0x2::object::ID,
        arg4: 0x2::object::ID,
        arg5: 0x1::type_name::TypeName,
        arg6: 0x1::type_name::TypeName,
        arg7: 0x1::type_name::TypeName,
        arg8: &mut 0x2::tx_context::TxContext
    ) : TurbosPositionNFT {
        let v0 = TurbosPositionNFT{
            id          : 0x2::object::new(arg8), 
            name        : arg0, 
            description : arg1, 
            img_url     : 0x2::url::new_unsafe(0x1::string::to_ascii(arg2)), 
            pool_id     : arg3, 
            position_id : arg4, 
            coin_type_a : arg5, 
            coin_type_b : arg6, 
            fee_type    : arg7,
        };
        let v1 = MintNFTEvent{
            object_id : 0x2::object::uid_to_inner(&v0.id), 
            creator   : 0x2::tx_context::sender(arg8), 
            name      : v0.name,
        };
        0x2::event::emit<MintNFTEvent>(v1);
        v0
    }
}