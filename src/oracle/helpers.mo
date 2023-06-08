import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Types "types";
import Debug "mo:base/Debug";
import Char "mo:base/Char";
import Nat "mo:base/Nat";

module {

  // returns the price from a Http Body
  public func decodePrice(response : Types.http_response) : Nat {
    switch (Text.decodeUtf8(Blob.fromArray(response.body))) {
      case null { 0 };
      case (?decoded) {
        var temp = "";
        for (char in decoded.chars()) {
          if (Char.isDigit(char)){
            temp := temp # Char.toText(char);
          };
        };
        switch (Nat.fromText(temp)) {
          case null { 0 };
          case (?num) {
            if(Text.size(temp) == 17) {
              return num / 100;
            } else if(Text.size(temp) == 16) {
              return num / 10;
            } else if(Text.size(temp) == 15) {
              return num;
            } else if(Text.size(temp) == 18) {
              return num / 1000;
            } else {
              return 0;
            }
          } 
        };
        };
    };
  };
};
