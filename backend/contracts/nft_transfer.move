module nft_transfer {
    use std::signer;
    use std::vector;
    use aptos_framework::account;
    use aptos_framework::event;
    use aptos_framework::timestamp;

    struct NFTReward has key {
        points: u64,
        landmarks: vector<u64>,
        mint_events: event::EventHandle<MintEvent>,
    }

    struct MintEvent has drop, store {
        receiver: address,
        landmark_id: u64,
        points: u64,
        timestamp: u64,
    }

    public fun initialize(account: &signer) {
        let nft_reward = NFTReward {
            points: 0,
            landmarks: vector::empty<u64>(),
            mint_events: account::new_event_handle<MintEvent>(account),
        };
        move_to(account, nft_reward);
    }

    public fun mint_and_transfer(
        creator: &signer,
        receiver: address,
        landmark_id: u64,
        points: u64,
    ) acquires NFTReward {
        let creator_addr = signer::address_of(creator);
        let nft_reward = borrow_global_mut<NFTReward>(creator_addr);

        // Update points and landmarks
        nft_reward.points = nft_reward.points + points;
        vector::push_back(&mut nft_reward.landmarks, landmark_id);

        // Emit mint event
        event::emit_event(&mut nft_reward.mint_events, MintEvent {
            receiver,
            landmark_id,
            points,
            timestamp: timestamp::now_microseconds(),
        });
    }

    public fun get_points(addr: address): u64 acquires NFTReward {
        let nft_reward = borrow_global<NFTReward>(addr);
        nft_reward.points
    }

    public fun get_landmarks(addr: address): vector<u64> acquires NFTReward {
        let nft_reward = borrow_global<NFTReward>(addr);
        *&nft_reward.landmarks
    }
}