import Types "types";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Hash "mo:base/Hash";
import oracle "canister:oracle";

actor {

  var ckbtcRate = 26_00_000;
  var irscRate = 8225;
  var stabilityFee = 1;
  var liquidationFee = 5;

  var open_cdps = HashMap.HashMap<Principal, Types.CDP>(5, Principal.equal, Principal.hash);


  public query func ckBTCRate() : async Nat {
    ckbtcRate;
  };

  public shared ({ caller }) func create_cdp( _debtrate : Nat, _amount : Nat ) : async Result.Result<Types.CDP, Text> {
    
    // Check for an already open position.
    switch (open_cdps.get(caller)) {
      case null { 

        var btc_rate = await oracle.getBTC();
        Result.assertOk(btc_rate);
        let result_val = Result.toOption(btc_rate);
        switch(result_val) {
          case null { return #err("Something is wrong with the Oracle") };
          case (?num) {
            
            let new_pos : Types.CDP = {
              debtor = caller;
              amount = _amount;
              debt_rate = _debtrate;
              entry_rate = num;
              liquidation_rate = 25000;
              max_debt = 10;
              debt_issued = 2;
              state = #active
            };

            open_cdps.put(caller, new_pos);
            return #ok(new_pos);
          }
        }
       };
      case (?pos) {
        return #err("You already have an open position!");
      }
    }
  };

  public shared ({ caller }) func get_current_cdp() : async ?Types.CDP {
    open_cdps.get(caller);
  }
};
