import CkBtcLedger "canister:ckbtc_ledger";
import IrscLedger "canister:irsc_ledger";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Error "mo:base/Error";

actor Marketplace {
    stable var active_count : Nat = 0;
    stable var settled_count : Nat = 0;
    stable let vaults_principal : Text = "bd3sg-teaaa-aaaaa-qaaba-cai";

    public type Listing = {
        ckbtc_amount : Nat;
        irsc_amount : Nat;
    };  

    public type Subaccount = Blob;

    public type Account = {
        owner : Principal;
        subaccount : ?Subaccount;
    };

    var active_listing = HashMap.HashMap<Text, Listing>(1, Text.equal, Text.hash);
    var settled_listing = HashMap.HashMap<Text, Listing>(1, Text.equal, Text.hash);
    
    public shared ({ caller }) func list( ckbtc_amount : Nat, irsc_amount : Nat ) : async Result.Result<Listing, Text> {
        if(caller != Principal.fromText(vaults_principal)) {
            return #err("Only vaults canister can create a new listing!");
        };

        let new_list : Listing = {
            ckbtc_amount = ckbtc_amount;
            irsc_amount = irsc_amount;
        };

        active_count := active_count + 1;
        active_listing.put(Nat.toText(active_count), new_list);
        #ok(new_list);
    };

    public shared ({ caller }) func buy( listing_id : Nat ) : async Result.Result<Text, Text> {
        switch(active_listing.get(Nat.toText(listing_id))) {
            case null { return #err("Please enter a valid listing id") };
            case (?listing) {

                let balance = await IrscLedger.icrc1_balance_of(
                    toAccount({ caller; canister = Principal.fromActor(Marketplace) })
                );

                if (balance < listing.irsc_amount) {
                    return #err("Not enough funds available in the Account. Make sure you send required IRSC");
                };

                try {
                    // if enough funds were sent, burn them
                    let transferResult = await IrscLedger.icrc1_transfer(
                        {
                        amount = listing.irsc_amount;
                        from_subaccount = ?toSubaccount(caller);
                        created_at_time = null;
                        fee = null;
                        memo = null;
                        to = {
                            owner = Principal.fromText(vaults_principal);
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

                try {
                    // Transfer ckBTC to the buyer
                    let transferResult = await CkBtcLedger.icrc1_transfer(
                        {
                        amount = listing.ckbtc_amount;
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
                        return #err("Couldn't transfer funds to required account:\n" # debug_show (transferError));
                        };
                        case (_) {};
                    };
                } catch (error : Error) {
                return #err("Reject message: " # Error.message(error));
                };

            };
        };
        
        let removed = active_listing.remove(Nat.toText(listing_id));
        switch(removed) {
            case null { return #err("Something is wrong with the listing") };
            case (?remov) {
                settled_count := settled_count + 1;
                settled_listing.put(Nat.toText(settled_count), remov);
                #ok("Listing purchase successfull!");
            };
        }
    };

    public shared ({ caller }) func get_subAccount() : async Account {
        toAccount({ caller; canister = Principal.fromActor(Marketplace) });
    };

    func toSubaccount(p : Principal) : Subaccount {
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

    func toAccount({ caller : Principal; canister : Principal }) : Account {
        {
        owner = canister;
        subaccount = ?toSubaccount(caller);
        };
    };

};