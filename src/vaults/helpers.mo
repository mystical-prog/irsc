import Types "types";
import Nat "mo:base/Nat";

module {
    public func calculate_figures( debt_rate : Nat, entry_rate : Nat, amount : Nat ) : Types.Helper_Return1 {

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
    }
};