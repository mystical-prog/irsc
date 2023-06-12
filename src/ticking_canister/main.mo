import Vaults "canister:vaults";
import Debug "mo:base/Debug";

actor {

    var debug_count : Nat = 0;
    
    system func heartbeat() : async () {
        let res = await Vaults.check_positions();
        debug_count += 1;
    };

    public func getCount() : async Nat {
        return debug_count;
    }
};