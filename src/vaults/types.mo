module {
  public type Subaccount = Blob;
  public type Account = {
    owner : Principal;
    subaccount : ?Subaccount;
  };
  public type CDP = {
    debtor : Principal;
    debt_rate : Nat;
    entry_rate : Nat;
    liquidation_rate : Nat;
    amount : Nat;
    max_debt : Nat;
    debt_issued : Nat;
    state : { #active; #closed; #liquidated };
  };
  public type Helper_Return1 = {
    max_debt : Nat;
    liquidation_rate : Nat;
  }
}