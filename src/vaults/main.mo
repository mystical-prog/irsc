actor {

  stable var ckbtcRate = 26_00_000;
  stable var irscRate = 8225;
  stable var stabilityFee = 1;
  stable var liquidationFee = 5;

  public query func ckBTCRate() : async Nat {
    ckbtcRate;
  };
};
