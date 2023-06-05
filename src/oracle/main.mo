import Result "mo:base/Result";
import Types "types";
import Error "mo:base/Error";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import { decodeBody } "helpers";

actor {

  public func getBTC() : async Result.Result<Types.DecodedHttpResponse, Text> {
    // create managament canister actor reference
    let ic : Types.IC = actor ("aaaaa-aa");

    ExperimentalCycles.add(514_600_000);

    try {
      // make call to management canister to use https outcall feature
      let httpResponse = await ic.http_request({
        url = "https://api.coinbase.com/v2/prices/BTC-USD/spot";
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
      return #ok(decodeBody(httpResponse));

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

};
