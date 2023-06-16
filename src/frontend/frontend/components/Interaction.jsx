import React, { useState } from 'react';
import { useCanister } from '@connect2ic/react';

const Interaction = () => {

  const [vaults] = useCanister("vaults");

  const [data, setData] = useState({
    Entry_Rate: '25,00,000',
    Liquidation_Rate: '24,20,000',
    Amount: 10000,
    Safemint_Rate: '137%',
    Max_Issuable_IRSC : 64.9820,
    Issued_IRSC : 20.455,
    Volume : 11000,
  });

  const [activeTab, setActiveTab] = useState(0);
  const [sliderInput, setSliderInput] = useState(137);
  const [numberInput, setNumberInput] = useState("");
  const [init, setInit] = useState(false);
  const [loaded, setLoaded] = useState(true);

  const handleFetch = async () => {
    setInit(false);
    setLoaded(false);
    const res = await vaults.get_current_cdp();
    console.log(res);
    if(res.ok) {
      data.Max_Issuable_IRSC = Number(res.ok.max_debt) / 100000000;
      data.Issued_IRSC = Number(res.ok.debt_issued) / 100000000;
      data.Volume = Number(res.ok.volume) / 100000000;
      data.Amount = Number(res.ok.amount) / 100000000;
      data.Entry_Rate = Math.trunc(Number(res.ok.entry_rate) / 100000000);
      data.Liquidation_Rate = Math.trunc(Number(res.ok.liquidation_rate) / 100000000);
      data.Safemint_Rate = String(Number(res.ok.debt_rate)) + "%";
      setLoaded(true);
      setInit(true);
    } else {
      alert("You don't have any active positions!");
      window.location.href = "/create";
    }
  }

  const handleSliderChange = (e) => {
    setSliderInput(e.target.value);
  };

  const handleNumberChange = (e) => {
    setNumberInput(e.target.value);
  };

  const handleRemove = async () => {
    if(loaded) {
      setLoaded(false);
      const res = await vaults.remove_collateral(Number(numberInput) * 100000000);
      if(res.ok){
        data.Max_Issuable_IRSC = Number(res.ok.max_debt) / 100000000;
        data.Issued_IRSC = Number(res.ok.debt_issued) / 100000000;
        data.Volume = Number(res.ok.volume) / 100000000;
        data.Amount = Number(res.ok.amount) / 100000000;
        data.Entry_Rate = Math.trunc(Number(res.ok.entry_rate) / 100000000);
        data.Liquidation_Rate = Math.trunc(Number(res.ok.liquidation_rate) / 100000000);
        data.Safemint_Rate = String(Number(res.ok.debt_rate)) + "%";
        alert("Operation performed successfully!");
        setLoaded(true);
      } else {
        alert("Couldn't perform the operation!" + res.err.toString());
        setLoaded(true);
      }
    }
  };
  
  const handleAdd = async () => {
    if(loaded == true) {
      setLoaded(false);
      const res = await vaults.add_collateral(Number(numberInput) * 100000000);
      if(res.ok){
        data.Max_Issuable_IRSC = Number(res.ok.max_debt) / 100000000;
        data.Issued_IRSC = Number(res.ok.debt_issued) / 100000000;
        data.Volume = Number(res.ok.volume) / 100000000;
        data.Amount = Number(res.ok.amount) / 100000000;
        data.Entry_Rate = Math.trunc(Number(res.ok.entry_rate) / 100000000);
        data.Liquidation_Rate = Math.trunc(Number(res.ok.liquidation_rate) / 100000000);
        data.Safemint_Rate = String(Number(res.ok.debt_rate)) + "%";
        alert("Operation performed successfully!");
        setLoaded(true);
      } else {
        alert("Couldn't perform the operation!" + res.err.toString());
        setLoaded(true);
      }
    }
  };

  const handleIssue = async () => {
    if(loaded == true) {
      setLoaded(false);
      const res = await vaults.issue_debt(Number(numberInput) * 100000000);
      console.log(res);
      if(res.ok){
        data.Max_Issuable_IRSC = Number(res.ok.max_debt) / 100000000;
        data.Issued_IRSC = Number(res.ok.debt_issued) / 100000000;
        data.Volume = Number(res.ok.volume) / 100000000;
        data.Amount = Number(res.ok.amount) / 100000000;
        data.Entry_Rate = Math.trunc(Number(res.ok.entry_rate) / 100000000);
        data.Liquidation_Rate = Math.trunc(Number(res.ok.liquidation_rate) / 100000000);
        data.Safemint_Rate = String(Number(res.ok.debt_rate)) + "%";
        alert("Operation performed successfully!");
        setLoaded(true);
      } else {
        alert("Couldn't perform the operation!" + res.err.toString());
        setLoaded(true);
      }
    }
  };

  const handleRepay = async () => {
    if(loaded) {
      setLoaded(false);
      const res = await vaults.repay_debt(Number(numberInput) * 100000000);
      if(res.ok){
        data.Max_Issuable_IRSC = Number(res.ok.max_debt) / 100000000;
        data.Issued_IRSC = Number(res.ok.debt_issued) / 100000000;
        data.Volume = Number(res.ok.volume) / 100000000;
        data.Amount = Number(res.ok.amount) / 100000000;
        data.Entry_Rate = Math.trunc(Number(res.ok.entry_rate) / 100000000);
        data.Liquidation_Rate = Math.trunc(Number(res.ok.liquidation_rate) / 100000000);
        data.Safemint_Rate = String(Number(res.ok.debt_rate)) + "%";
        alert("Operation performed successfully!");
        setLoaded(true);
      } else {
        alert("Couldn't perform the operation!" + res.err.toString());
        setLoaded(true);
      }
    }
  };

  const handleClose = async () => {
    if(loaded) {
      setLoaded(false);
      const res = await vaults.repay_debt(Number(numberInput) * 100000000);
      if(res.ok){
        alert("Position closed successfully!");
        setLoaded(true);
        window.location.href = "/create";
      } else {
        alert("Couldn't perform the operation!" + res.err.toString());
        setLoaded(true);
      }
    }
  };

  const handleAdjust = async () => {
    if(loaded) {
      setLoaded(false);
      const res = await vaults.adjust_debtRate(Number(sliderInput - 135));
      if(res.ok){
        data.Max_Issuable_IRSC = Number(res.ok.max_debt) / 100000000;
        data.Issued_IRSC = Number(res.ok.debt_issued) / 100000000;
        data.Volume = Number(res.ok.volume) / 100000000;
        data.Amount = Number(res.ok.amount) / 100000000;
        data.Entry_Rate = Math.trunc(Number(res.ok.entry_rate) / 100000000);
        data.Liquidation_Rate = Math.trunc(Number(res.ok.liquidation_rate) / 100000000);
        data.Safemint_Rate = String(Number(res.ok.debt_rate)) + "%";
        alert("Operation performed successfully!");
        setLoaded(true);
      } else {
        alert("Couldn't perform the operation!" + res.err.toString());
        setLoaded(true);
      }
    }
  };

  const tabs = [
    { name: 'Issue IRSC', fieldLabel: 'Amount', btnText: 'Issue', func: handleIssue},
    { name: 'Repay IRSC', fieldLabel: 'Amount', btnText: 'Repay', func: handleRepay},
    { name: 'Add ckBTC', fieldLabel: 'Amount', btnText: 'Add', func: handleAdd},
    { name: 'Remove ckBTC', fieldLabel: 'Amount', btnText: 'Remove', func: handleRemove},
    { name: 'Close CDP', btnText: 'Close', func: handleClose},
    { name: 'Adjust Safemint', fieldLabel: 'Safemint', btnText: 'Adjust', isSlider: true, func:handleAdjust},
  ];

  const TabForm = ({ tab }) => (
    <div className="w-full flex flex-col items-center">
      {tab.fieldLabel && (
        <div className="w-2/3 flex flex-col mb-3">
          <label className="mb-3 mt-3 font-semibold text-text font-primary font-bold">{tab.fieldLabel} :</label>
          {tab.isSlider ? (
            <>
                <input 
                    className="shadow bg-background h-1.5 w-full border rounded cursor-pointer appearance-none rounded-lg"
                    id="slider-input" 
                    type="range" 
                    min="137" 
                    max="160"
                    step="1"
                    value={sliderInput}
                    onChange={handleSliderChange}
                />
                <div className="flex justify-between text-sm text-text mt-2 font-primary font-bold">
                    <span>Min: 137%</span>
                    <span>Current: {sliderInput}%</span>
                    <span>Max: 160%</span>
                </div>
            </>
          ) : (
            <input 
                className="shadow appearance-none bg-secondary border rounded w-full py-2 px-3 text-background font-bold font-primary leading-tight focus:outline-none focus:shadow-outline" 
                id="number-input" 
                type="number"
                min={0.0001}
                step={0.0001}
                placeholder='0.0001'
                value={numberInput}
                onChange={handleNumberChange} 
            />
          )}
        </div>
      )}
      <button className="px-4 py-2 rounded-lg bg-secondary text-silver" onClick={tab.func}>{loaded ? tab.btnText : "Loading.."}</button>
    </div>
  );

  return (
    <div className="flex flex-col items-center bg-gradient-to-r from-background to-purple p-6 rounded-lg shadow-lg h-screen">
      { init ? 
      <h2 className="text-3xl font-bold text-silver font-primary my-6 border-b-2">CDP Interaction</h2>
      :
      <button className="px-4 py-2 rounded-lg bg-secondary text-silver" onClick={handleFetch}>{ loaded ? "Fetch" : "Loading.." }</button>
      }
      { init ? 
      <div className="w-full flex justify-center md:divide-x md:divide-silver h-full">
        <div className="md:w-1/2 p-3 flex flex-col items-center">
          <h3 className="text-2xl font-semibold mb-8 border-b-2 text-center text-blue-500 text-silver font-primary w-full">Details</h3>
          
          {Object.entries(data).map(([key, value]) => (
            <div className="flex justify-between w-full mb-4 px-4 text-text font-primary font-bold" key={key}>
              <strong className="text-left">{key.replaceAll('_', ' ')} -</strong>
              <span className='text-secondary font-primary font-bold text-l'>{loaded ? value : ""}</span>
            </div>
          ))}
        </div>
        <div className="md:w-1/2 p-3 flex flex-col items-center">
          <h3 className="text-2xl font-semibold mb-4 text-center w-full text-silver font-primary font-bold border-b-2">Interaction</h3>
          <div className="mb-4 flex justify-center w-full">
            {tabs.map((tab, index) => (
              <button
                key={tab.name}
                className={`mx-1 py-2 px-4 rounded ${index === activeTab ? 'bg-primary text-silver font-primary font-bold' : 'bg-metal text-silver font-primary font-bold'}`}
                onClick={() => setActiveTab(index)}
              >
                {tab.name}
              </button>
            ))}
          </div>
          <div className={`form-${activeTab} w-full flex justify-center`}>
            <TabForm tab={tabs[activeTab]} />
          </div>
        </div>
      </div>
      : "" }
    </div>
  );
};

export default Interaction;