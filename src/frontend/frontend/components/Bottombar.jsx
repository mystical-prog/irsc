import { useCanister } from '@connect2ic/react';
import React, {useState, useEffect} from 'react';

const Bottombar = () => {

  const [vaults] = useCanister("vaults");

  const [loaded, setLoaded] = useState(false);
  const [data, setData] = useState({
    BTC: '25,00,000',
    IRSC: '1',
    Liquidation_Penalty: '5%',
    Stability_Fee_Rate: '1%',
  });

  useEffect(() => {
    (async () => {
      const temp_btc = await vaults.getckBTCRate();
      data.BTC = Math.trunc(Number(temp_btc) / 100000000);
      const temp_irsc = await vaults.getIrscRate();
      data.IRSC = (Number(temp_irsc) / 100000000);
      const temp_liquidation = await vaults.getLiquidationRate();
      data.Liquidation_Penalty = String(Number(temp_liquidation)) + "%";
      const temp_stability = await vaults.getStabilityRate();
      data.Stability_Fee_Rate = String(Number(temp_stability) / 10) + "%";
      setLoaded(true);
    })();
  }, []);

  return (
    <div className="bg-gradient-to-r from-background to-purple border-t-2 border-silver fixed inset-x-0 bottom-0 text-silver p-2 shadow-lg">
      <div className="flex justify-around">
        {Object.entries(data).map(([key, value]) => (
          <div key={key} className="text-center">
            <div className="font-bold">{key.replaceAll('_', ' ')} - : {loaded ? value : "25,00,000"}</div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Bottombar;