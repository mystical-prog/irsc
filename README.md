## 3rd Place Winner of the Main Track at Buidl Bitcoin Hackathon!

> [Medium of Encode Club](https://medium.com/encode-club/internet-computer-buidl-bitcoin-hackathon-powered-by-encode-summary-and-winners-3ecb2daf6921) 

Our platform stands as a resilient fusion of Bitcoin (BTC) and the Internet Computer (ICP), offering a host of functionalities in a secure and transparent environment. This includes everything from initiating Collateralized Debt Positions (CDP), managing collateral, altering your Safe-mint rate, to handling debt issuance, repayment, and ultimately closing your positions. We've integrated an Oracle into our system, leveraging HTTP/S outcalls to fetch up-to-the-minute Bitcoin prices from the well-regarded Coinbase API, ensuring precision in pricing. Furthermore, our system employs the CKBTC Ledger, further reinforcing the integrity and efficiency of our platform.

To learn more about the project check the following links out - 

- [Demo](https://www.youtube.com/watch?v=BSCID3GLWhM)
- [Pitchdeck](https://drive.google.com/file/d/1PyNwZLvI7l5dgb2ILo05B2xscZsWD_PG/view?usp=sharing)

### Mainnet Deployed Canister Links - 

- [Creation Frontend](https://idqav-oaaaa-aaaao-avbpq-cai.icp0.io/create/)
- [Interaction Frontend](https://idqav-oaaaa-aaaao-avbpq-cai.icp0.io/interact/)
- [Vaults](https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.icp0.io/?id=lge36-tiaaa-aaaao-avbea-cai)
- [Marketplace](https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.icp0.io/?id=kfisy-hqaaa-aaaao-avbcq-cai)
- [Oracle](https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.icp0.io/?id=klk7q-4aaaa-aaaao-avbdq-cai)
- [IRSC Ledger](https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.icp0.io/?id=kcjum-kiaaa-aaaao-avbca-cai)

```The frontend of the dApp on mainnet was not tested because of time crunch, but can be taken care of later, it works fine on the local development, as demonstrated in the demo.```

### For testing out the project

```bash
# Clone the repo
git clone https://github.com/mystical-prog/irsc.git

# For running the canisters locally just perform the below command in the root dir
npm run start
```

Once the command is successfully exectuded, locate the frontend canister from the urls given in the console. <br />
For the Create Screen - `http://localhost:{port}/create/?canisterId={asset_canister_id}` <br />
For the Interaction Screen - `http://localhost:{port}/interact/?canisterId={asset_canister_id}` <br />
