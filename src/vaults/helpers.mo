import Types "types";
import Nat "mo:base/Nat";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Nat8 "mo:base/Nat8";

module {

    public func init_position_figures( debt_rate : Nat, entry_rate : Nat, amount : Nat ) : Types.Helper_Return1 {

        let half_value : Nat = (amount * entry_rate) / 2;

        let sur : Nat = (half_value * (debt_rate - 100)) / 100;

        let col_value : Nat = half_value + sur;
        let max_debt : Nat = half_value - sur;

        let liq_value : Nat = half_value + (( half_value * 35 ) / 100 );

        let liquidation_rate : Nat = (entry_rate * liq_value) / col_value;

        let return_val : Types.Helper_Return1 = {
            max_debt = max_debt / 100_000_000;
            liquidation_rate = liquidation_rate;
        };

        return_val;
    };

    public func toSubaccount(p : Principal) : Types.Subaccount {

        let bytes = Blob.toArray(Principal.toBlob(p));
        let size = bytes.size();

        assert size <= 29;

        let a = Array.tabulate<Nat8>(
        32,
        func(i : Nat) : Nat8 {
            if (i + size < 31) {
            0;
            } else if (i + size == 31) {
            Nat8.fromNat(size);
            } else {
            bytes[i + size - 32];
            };
        },
        );
        Blob.fromArray(a);
    };

    public func toAccount({ caller : Principal; canister : Principal }) : Types.Account {
        {
        owner = canister;
        subaccount = ?toSubaccount(caller);
        };
    };
};