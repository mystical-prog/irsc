import Types "types";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Hash "mo:base/Hash";
import CkBtcLedger "canister:ckbtc_ledger";
import IrscLedger "canister:irsc_ledger";
import { init_position_figures ; toAccount; toSubaccount } "helpers";
import Error "mo:base/Error";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

actor Vaults {

  var oracle = actor("be2us-64aaa-aaaaa-qaabq-cai") : Types.oracle;

  var ckbtcRate : Nat = 0;
  let liquidationRate : Nat = 135;
  var irscRate = 1_00_000_000;
  var stabilityRate = 1;
  var liquidationFeeRate = 5;

  var closed_cdps_count = 0;
  var liquidated_cdps_count = 0;

  var open_cdps = HashMap.HashMap<Principal, Types.CDP>(5, Principal.equal, Principal.hash);
  var closed_cdps = HashMap.HashMap<Text, Types.CDP>(1, Text.equal, Text.hash);
  var liquidated_cdps = HashMap.HashMap<Text, Types.CDP>(1, Text.equal, Text.hash);

  public query func getckBTCRate() : async Nat {
    ckbtcRate;
  };

  public shared ({ caller }) func create_cdp( _debtrate : Nat, _amount : Nat ) : async Result.Result<Types.CDP, Text> {
    
    assert _amount > 0;
    assert _debtrate > 0;

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

            let calc = await init_position_figures(liquidationRate + _debtrate, num, _amount, 0);

            let new_pos : Types.CDP = {
              debtor = caller;
              amount = _amount;
              volume = _amount;
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

  public shared ({ caller }) func withdraw_from_subAccount_ckBTC() : async Text {
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

    "Transferred " # debug_show(balance) # " ckBTC back to your account";
  };

  public shared ({ caller }) func withdraw_from_subAccount_irsc() : async Text {
    let balance = await IrscLedger.icrc1_balance_of(
      toAccount({ caller; canister = Principal.fromActor(Vaults) })
    );

    try {

      let transferResult = await IrscLedger.icrc1_transfer(
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

    "Transferred " # debug_show(balance) # " IRSC back to your account";
  };

  public shared ({ caller }) func add_collateral( _amount : Nat ) : async Result.Result<Types.CDP, Text> {
    
    assert _amount > 0;

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
            let calc = await init_position_figures(open_pos.debt_rate, avg, new_amount, open_pos.debt_issued);
            let new_volume = open_pos.volume + _amount;

            let updated_pos : Types.CDP = {
              debtor = open_pos.debtor;
              amount = new_amount;
              volume = new_volume;
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
    
    assert _amount > 0;

    switch (open_cdps.get(caller)) {
      case null { #err("You need to have an active cdp first!") };
      case (?open_pos) {
        
        if(open_pos.amount < _amount) {
          return #err("amount being removed is greater than the position!");
        };
        
        let new_amount : Nat = open_pos.amount - _amount;
        let calc = await init_position_figures(open_pos.debt_rate, open_pos.entry_rate, new_amount, open_pos.debt_issued);
        
        if(calc.max_debt <= open_pos.debt_issued) {
          return #err("Repay some of the debt first!");
        };

        let updated_pos : Types.CDP = {
          debtor = open_pos.debtor;
          amount = new_amount;
          volume = open_pos.volume;
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

  public shared ({ caller }) func issue_debt( _amount : Nat ) : async Result.Result<Types.CDP, Text> {
    
    assert _amount > 0;
    
    switch (open_cdps.get(caller)) {
      case null { #err("You need to have an active cdp first!") };
      case (?open_pos) {

        if(open_pos.debt_issued + _amount > open_pos.max_debt) {
          return #err("You cannot issue more than max debt alloted on the position!");
        };

        let new_debt_issued = open_pos.debt_issued + _amount;
        let calc = await init_position_figures(open_pos.debt_rate, open_pos.entry_rate, open_pos.amount, new_debt_issued);

        let updated_pos : Types.CDP = {
          debtor = caller;
          debt_rate = open_pos.debt_rate;
          entry_rate = open_pos.entry_rate;
          liquidation_rate = calc.liquidation_rate;
          amount = open_pos.amount;
          volume = open_pos.volume;
          max_debt = open_pos.max_debt;
          debt_issued = new_debt_issued;
          state = #active;
        };

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

        ignore open_cdps.replace(caller, updated_pos);
        #ok(updated_pos);
      };
    }
  };

  public shared ({ caller }) func repay_debt( _amount : Nat ) : async Result.Result<Types.CDP, Text> {
    
    assert _amount > 0;
    
    switch (open_cdps.get(caller)) {
      case null { #err("You need to have an open position first!") };
      case (?open_pos) { 

        let balance = await IrscLedger.icrc1_balance_of(
          toAccount({ caller; canister = Principal.fromActor(Vaults) })
        );

        if (balance < _amount) {
          return #err("Not enough funds available in the Account. Make sure you send required IRSC");
        };

        try {
          // if enough funds were sent, move them to the canisters default account
          let transferResult = await IrscLedger.icrc1_transfer(
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

        let new_debt_issued : Nat = open_pos.debt_issued - _amount;

        if(new_debt_issued < 1) {
          return #err("Try to close the position instead");
        };

        let calc = await init_position_figures(open_pos.debt_rate, open_pos.entry_rate, open_pos.amount, new_debt_issued);
        
        let updated_pos : Types.CDP = {
          debtor = caller;
          debt_rate = open_pos.debt_rate;
          entry_rate = open_pos.entry_rate;
          liquidation_rate = calc.liquidation_rate;
          amount = open_pos.amount;
          volume = open_pos.volume;
          max_debt = open_pos.max_debt;
          debt_issued = new_debt_issued;
          state = #active;
        };

        ignore open_cdps.replace(caller, updated_pos);
        #ok(updated_pos);
      }
    };
  };

  public shared ({ caller }) func close_position() : async Result.Result<Types.CDP, Text> {
    switch (open_cdps.get(caller)) {
      case null { #err("You need to have an open position first!") };
      case (?open_pos) { 

        let balance = await IrscLedger.icrc1_balance_of(
          toAccount({ caller; canister = Principal.fromActor(Vaults) })
        );

        if (balance < open_pos.debt_issued) {
          return #err("Not enough funds available in the Account. Make sure you send required IRSC");
        };

        if(open_pos.debt_issued > 0){
          try {
            // if enough funds were sent, move them to the canisters default account
            let transferResult = await IrscLedger.icrc1_transfer(
              {
                amount = open_pos.debt_issued;
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
                return #err("Couldn't transfer IRSC to default account:\n" # debug_show (transferError));
              };
              case (_) {};
            };
          } catch (error : Error) {
            return #err("Reject message: " # Error.message(error));
          };
        };

        let stabilityFee = (open_pos.volume * stabilityRate) / 100;

        assert stabilityFee > 0;

        if(open_pos.amount > 0) {
          try {
            let transferResult = await CkBtcLedger.icrc1_transfer(
              {
                amount = open_pos.amount - stabilityFee;
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
                return #err("Couldn't transfer ckBTC to required account:\n" # debug_show (transferError));
              };
              case (_) {};
              };
            } catch (error : Error) {
              return #err("Reject message: " # Error.message(error));
          };
        };

        var btc_rate = await oracle.getBTC();
        
        Result.assertOk(btc_rate);
        let result_val = Result.toOption(btc_rate);
        switch(result_val) {
          case null { return #err("Something is wrong with the Oracle") };
          case (?num) {
            assert num > 0;

            if(num < open_pos.liquidation_rate) {
              return #err("Your position is liquidated, cannot close it!");
            };

            let updated_pos : Types.CDP = {
              debtor = caller;
              debt_rate = open_pos.debt_rate;
              entry_rate = open_pos.entry_rate;
              liquidation_rate = open_pos.liquidation_rate;
              amount = open_pos.amount;
              volume = open_pos.volume;
              max_debt = open_pos.max_debt;
              debt_issued = open_pos.debt_issued;
              state = #closed;
            };

            ignore open_cdps.remove(caller);
            closed_cdps.put(Nat.toText(closed_cdps_count), updated_pos);
            closed_cdps_count := closed_cdps_count + 1;
            #ok(updated_pos);
          } 
        }
      }
    };
  };

  public func check_positions() : async Text {

    var btc_rate = await oracle.getBTC();        
    Result.assertOk(btc_rate);
    let result_val = Result.toOption(btc_rate);

    switch(result_val) {
      case null { return "Something is wrong with the APIs" };
      case (?num) {
        assert num > 0;
        ckbtcRate := num;

        for(cdp in open_cdps.vals()) {
          if(cdp.liquidation_rate < num) {
            let liquid_cdp : Types.CDP = {
              debtor = cdp.debtor;
              debt_rate = cdp.debt_rate;
              entry_rate = cdp.entry_rate;
              liquidation_rate = cdp.liquidation_rate;
              amount = cdp.amount;
              volume = cdp.volume;
              max_debt = cdp.max_debt;
              debt_issued = cdp.debt_issued;
              state = #liquidated;
            };
            ignore open_cdps.remove(cdp.debtor);
            liquidated_cdps.put(Nat.toText(liquidated_cdps_count), liquid_cdp);
            liquidated_cdps_count := liquidated_cdps_count + 1;
          };
        };
      }
    };
    "Positions Checked";
  };
};