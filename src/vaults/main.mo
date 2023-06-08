import Types "types";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Hash "mo:base/Hash";
import CkBtcLedger "canister:ckbtc_ledger";
import IrscLedger "canister:irsc_ledger";
import { init_position_figures ; toAccount; toSubaccount } "helpers";
import Error "mo:base/Error";

actor Vaults {

  var oracle = actor("be2us-64aaa-aaaaa-qaabq-cai") : Types.oracle;

  stable var ckbtcRate : Nat = 0;
  let liquidationRate : Nat = 135;
  var irscRate = 8225;
  var stabilityFee = 1;
  var liquidationFee = 5;

  var open_cdps = HashMap.HashMap<Principal, Types.CDP>(5, Principal.equal, Principal.hash);


  public query func getckBTCRate() : async Nat {
    ckbtcRate;
  };

  public shared ({ caller }) func create_cdp( _debtrate : Nat, _amount : Nat ) : async Result.Result<Types.CDP, Text> {
    
    // Check for an already open position.
    switch (open_cdps.get(caller)) {
      case null { 

        let balance = await CkBtcLedger.icrc1_balance_of(
          toAccount({ caller; canister = Principal.fromActor(Vaults) })
        );

        if (balance < _amount) {
          return #err("Not enough funds available in the Account. Make sure you send required ckBTC");
        };

        var btc_rate = await oracle.getBTC();
        
        Result.assertOk(btc_rate);
        let result_val = Result.toOption(btc_rate);
        switch(result_val) {
          case null { return #err("Something is wrong with the Oracle") };
          case (?num) {

            ckbtcRate := num;

            try {
              // if enough funds were sent, move them to the canisters default account
              let transferResult = await CkBtcLedger.icrc1_transfer(
                {
                  amount = _amount;
                  from_subaccount = ?toSubaccount(caller);
                  created_at_time = null;
                  fee = null;
                  memo = null;
                  to = {
                    owner = Principal.fromActor(Vaults);
                    subaccount = null;
                  };
                }
              );

              switch (transferResult) {
                case (#Err(transferError)) {
                  return #err("Couldn't transfer funds to default account:\n" # debug_show (transferError));
                };
                case (_) {};
              };
            } catch (error : Error) {
              return #err("Reject message: " # Error.message(error));
            };

            let calc = init_position_figures(liquidationRate + _debtrate, num, _amount);

            let new_pos : Types.CDP = {
              debtor = caller;
              amount = _amount;
              debt_rate = liquidationRate + _debtrate;
              entry_rate = num;
              liquidation_rate = calc.liquidation_rate;
              max_debt = calc.max_debt;
              debt_issued = 0;
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
  };

  public shared ({ caller }) func get_subAccount() : async Types.Account {
    toAccount({ caller; canister = Principal.fromActor(Vaults) });
  };

  public shared ({ caller }) func withdraw_from_subAccount() : async Text {
    let balance = await CkBtcLedger.icrc1_balance_of(
      toAccount({ caller; canister = Principal.fromActor(Vaults) })
    );

    try {

      let transferResult = await CkBtcLedger.icrc1_transfer(
        {
          amount = balance;
          from_subaccount = ?toSubaccount(caller);
          created_at_time = null;
          fee = null;
          memo = null;
          to = {
            owner = caller;
            subaccount = null;
          };
        }
      );

      switch (transferResult) {
        case (#Err(transferError)) {
          return ("Couldn't transfer funds to required account:\n" # debug_show (transferError));
        };
        case (_) {};
      };
    } catch (error : Error) {
      return ("Reject message: " # Error.message(error));
    };

    "Transferred " # debug_show(balance) # " back to your account";
  };

  public shared ({ caller }) func add_collateral( _amount : Nat ) : async Result.Result<Types.CDP, Text> {
    switch (open_cdps.get(caller)) {
      case null { #err("You need to have an active cdp first!") };
      case (?open_pos) {

        let balance = await CkBtcLedger.icrc1_balance_of(
          toAccount({ caller; canister = Principal.fromActor(Vaults) })
        );

        if (balance < _amount) {
          return #err("Not enough funds available in the Account. Make sure you send required ckBTC");
        };

        var btc_rate = await oracle.getBTC();        
        Result.assertOk(btc_rate);
        let result_val = Result.toOption(btc_rate);

        switch(result_val) {
          case null { #err("Something is wrong with the Oracle") };
          case (?num) {
            ckbtcRate := num;

            try {
              // if enough funds were sent, move them to the canisters default account
              let transferResult = await CkBtcLedger.icrc1_transfer(
                {
                  amount = _amount;
                  from_subaccount = ?toSubaccount(caller);
                  created_at_time = null;
                  fee = null;
                  memo = null;
                  to = {
                    owner = Principal.fromActor(Vaults);
                    subaccount = null;
                  };
                }
              );

            switch (transferResult) {
                case (#Err(transferError)) {
                  return #err("Couldn't transfer funds to default account:\n" # debug_show (transferError));
                };
                case (_) {};
              };
            } catch (error : Error) {
              return #err("Reject message: " # Error.message(error));
            };

            let new_amount = open_pos.amount + _amount;
            let avg = ((open_pos.amount * open_pos.entry_rate) + ( num * _amount )) / new_amount;
            let calc = init_position_figures(open_pos.debt_rate, avg, new_amount);
            
            let updated_pos : Types.CDP = {
              debtor = open_pos.debtor;
              amount = new_amount;
              debt_rate = open_pos.debt_rate;
              entry_rate = avg;
              liquidation_rate = calc.liquidation_rate;
              max_debt = calc.max_debt;
              debt_issued = open_pos.debt_issued;
              state = #active
            };

            ignore open_cdps.replace(caller, updated_pos);
            #ok(updated_pos);
          }
        }
      }
    };
  };

  public shared ({ caller }) func remove_collateral( _amount : Nat ) : async Result.Result<Types.CDP, Text> {
    switch (open_cdps.get(caller)) {
      case null { #err("You need to have an active cdp first!") };
      case (?open_pos) {
        
        if(open_pos.amount < _amount) {
          return #err("amount being removed is greater than the position!");
        };
        
        let new_amount : Nat = open_pos.amount - _amount;
        let calc = init_position_figures(open_pos.debt_rate, open_pos.entry_rate, new_amount);
        
        if(calc.max_debt <= open_pos.debt_issued) {
          return #err("Repay some of the debt first!");
        };

        let updated_pos : Types.CDP = {
          debtor = open_pos.debtor;
          amount = new_amount;
          debt_rate = open_pos.debt_rate;
          entry_rate = open_pos.entry_rate;
          liquidation_rate = calc.liquidation_rate;
          max_debt = calc.max_debt;
          debt_issued = open_pos.debt_issued;
          state = #active
        };

        ignore open_cdps.replace(caller, updated_pos);
        
        try {

          let transferResult = await CkBtcLedger.icrc1_transfer(
            {
              amount = _amount;
              from_subaccount = null;
              created_at_time = null;
              fee = null;
              memo = null;
              to = {
                owner = caller;
                subaccount = null;
              };
            }
          );

        switch (transferResult) {
            case (#Err(transferError)) {
              return #err("Couldn't transfer funds to default account:\n" # debug_show (transferError));
            };
            case (_) {};
          };
        } catch (error : Error) {
          return #err("Reject message: " # Error.message(error));
        };
        #ok(updated_pos);
      }
    };
  };

  public shared ({ caller }) func issue_debt( _amount : Nat ) : async Result.Result<Text, Text> {
        try {

          let transferResult = await IrscLedger.icrc1_transfer(
            {
              amount = _amount;
              from_subaccount = null;
              created_at_time = null;
              fee = null;
              memo = null;
              to = {
                owner = caller;
                subaccount = null;
              };
            }
          );

        switch (transferResult) {
            case (#Err(transferError)) {
              return #err("Couldn't mint IRSC :\n" # debug_show (transferError));
            };
            case (_) {};
          };
        } catch (error : Error) {
          return #err("Reject message: " # Error.message(error));
        };

      #ok("Successfully minted " # debug_show(_amount));
  }
};
