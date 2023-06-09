import Result "mo:base/Result";
import Types "types";
import Error "mo:base/Error";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import { decodePrice } "helpers";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Random "mo:base/Random";

actor {

  // returns BTC price in INR
  public func getBTC() : async Result.Result<Nat, Text> {
    // create managament canister actor reference
    let ic : Types.IC = actor ("aaaaa-aa");

    ExperimentalCycles.add(514_600_000);

    try {
      // make call to management canister to use https outcall feature
      let httpResponse = await ic.http_request({
        url = "https://api.coinbase.com/v2/prices/BTC-INR/spot";
        method = #get;
        max_response_bytes = ?5000 : ?Nat64;
        body = null;
        transform = ?{
          function = transform;
          context = [];
        };
        headers = [
          { name = "User-Agent"; value = "irsc_oracle_canister" },
        ];
      });

      return #ok(decodePrice(httpResponse));

    } catch error {
      return #err("Reject message: " # Error.message(error));
    };
  };

  public query func transform({
    context : [Nat8];
    response : Types.http_response;
  }) : async Types.http_response {
    {
      response with headers = []; // not intersted in the headers
    };
  };

  public func updateIRSC( rate : Nat ) : async Nat {

    let random = Random.Finite(await Random.blob());
    
    switch (random.byte()) {
      case null { rate };
      case (?num) {
        if( num % 3 == 0) {
          return (rate);
        } else if ( num % 3 == 1 ) {
          return (rate + 5_00_000);
        } else {
          return (rate - 5_00_000);
        }
      };
    };
  }
};
