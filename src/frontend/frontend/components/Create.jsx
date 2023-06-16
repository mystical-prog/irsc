import React, { useState } from 'react';
import { useCanister } from '@connect2ic/react';

function Create() {

  const [vaults] = useCanister("vaults");
  const [numberInput, setNumberInput] = useState("");
  const [sliderInput, setSliderInput] = useState(137);

  const handleNumberChange = (e) => {
    setNumberInput(e.target.value);
  };

  const handleSliderChange = (e) => {
    setSliderInput(e.target.value);
  };

  const handleSubAccount = async () => {
    const res = await vaults.get_subAccount();
    console.log(res);
  };

  const handleSubmit = async () => {
    if(sliderInput > 136 && sliderInput < 161 && numberInput >= 0.001){
      const res = await vaults.create_cdp(Number(sliderInput - 135), Number(numberInput * 10**8));
      
      //
      // Put an if res.ok check here!!
      //
      
      console.log(res);
      if(res.ok) {
        alert("Succesfully created your position!!");
      }
    } else {
      alert("Please enter valid values to create a CDP!")
    }
  };

  return (
    <div className="bg-gradient-to-r from-background to-purple flex items-center justify-center min-h-screen bg-gray-100">
      <div 
        className="bg-primary shadow-xl rounded-xl px-10 pt-10 pb-10 mb-4 border-2 border-silver" 
        style={{ width: '400px' }} 
      >
        <div className="mb-4">
          <h2 className="text-center text-blue-600 text-3xl font-bold mb-4 font-primary">Create CDP</h2>

          <hr className="my-6 border-t border-gray-200" />
          
          <label 
            className="block text-gray-700 text-xl font-bold mb-2 font-primary" 
            htmlFor="number-input"
          >
            Amount in BTC
          </label>
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
          <span className='text-sm text-gray-700 font-primary font-bold'>&#8764; 139</span><span className='text-sm text-gray-700 font-bold'>&#8377;</span>
        </div>

        <hr className="my-6 border-t border-gray-200" />

        <div className="mb-4">
          <label 
            className="block text-gray-700 text-xl font-bold mb-1 mt-4 font-primary" 
            htmlFor="slider-input"
          >
            Safemint Rate
          </label>
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
          <div className="flex justify-between text-sm text-gray-700 mt-2 font-primary font-bold">
            <span>Min: 137%</span>
            <span>Current: {sliderInput}%</span>
            <span>Max: 160%</span>
          </div>
        </div>

        <div className="flex items-center justify-center">
          <button 
            className="font-primary bg-secondary hover:bg-blue-700 text-white font-bold py-2 px-8 rounded-full shadow-lg transform transition-shadow duration-500 ease-in-out hover:shadow-2xl focus:outline-none" 
            type="submit"
            onClick={handleSubmit}
          >
            Create
          </button>
        </div>
      </div>
    </div>
  );
}

export default Create;
