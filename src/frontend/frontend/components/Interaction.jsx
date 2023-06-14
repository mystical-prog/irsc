import React, { useState } from 'react';

const Interaction = () => {
  const data = {
    Entry_Rate: '25,00,000',
    Liquidation_Rate: '24,20,000',
    Amount: 10000,
    Safemint_Rate: '137%',
    Max_Issuable_IRSC : 64.9820,
    Issued_IRSC : 20.455,
    Volume : 11000,
  };

  const [activeTab, setActiveTab] = useState(0);
  const [sliderInput, setSliderInput] = useState(137);
  const [numberInput, setNumberInput] = useState("");

  const handleSliderChange = (e) => {
    setSliderInput(e.target.value);
  };

  const handleNumberChange = (e) => {
    setNumberInput(e.target.value);
  };

  const handleRemove = () => {
    alert("Remove");
  };
  
  const handleAdd = () => {
    alert("Add");
  };

  const handleIssue = () => {
    alert("Issue");
  };

  const handleRepay = () => {
    alert("Repay");
  };

  const handleClose = () => {
    alert("Close");
  };

  const handleAdjust = () => {
    alert("Adjust");
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
      <button className="px-4 py-2 rounded-lg bg-secondary text-silver" onClick={tab.func}>{tab.btnText}</button>
    </div>
  );

  return (
    <div className="flex flex-col items-center bg-gradient-to-r from-background to-purple p-6 rounded-lg shadow-lg h-screen">
      <h2 className="text-3xl font-bold text-silver font-primary my-6 border-b-2">CDP Interaction</h2>
      <div className="w-full flex justify-center md:divide-x md:divide-silver h-full">
        <div className="md:w-1/2 p-3 flex flex-col items-center">
          <h3 className="text-2xl font-semibold mb-8 border-b-2 text-center text-blue-500 text-silver font-primary w-full">Details</h3>
          
          {Object.entries(data).map(([key, value]) => (
            <div className="flex justify-between w-full mb-4 px-4 text-text font-primary font-bold" key={key}>
              <strong className="text-left">{key.replaceAll('_', ' ')} -</strong>
              <span className='text-secondary font-primary font-bold text-l'>{value}</span>
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
    </div>
  );
};

export default Interaction;