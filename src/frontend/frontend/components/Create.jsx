import React, { useState } from 'react';

function Create() {
  const [numberInput, setNumberInput] = useState("");
  const [sliderInput, setSliderInput] = useState(137);

  const handleNumberChange = (e) => {
    setNumberInput(e.target.value);
  };

  const handleSliderChange = (e) => {
    setSliderInput(e.target.value);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    // handle form submission
  };

  return (
    <div className="bg-background flex items-center justify-center min-h-screen bg-gray-100">
      <form 
        className="bg-primary shadow-xl rounded-xl px-10 pt-10 pb-10 mb-4" 
        style={{ width: '400px' }} 
        onSubmit={handleSubmit}
      >
        <div className="mb-4">
          <h2 className="text-center text-blue-600 text-3xl font-bold mb-4">Create CDP</h2>

          <hr className="my-6 border-t border-gray-200" />
          
          <label 
            className="block text-gray-700 text-xl font-bold mb-2" 
            htmlFor="number-input"
          >
            Amount in BTC
          </label>
          <input 
            className="shadow appearance bg-secondary border rounded w-full py-2 px-3 text-background font-bold leading-tight focus:outline-none focus:shadow-outline" 
            id="number-input" 
            type="number"
            min={0.001}
            step={0.001}
            placeholder='0.001'
            value={numberInput}
            onChange={handleNumberChange} 
          />
          <span className='text-sm text-gray-700'>&#8764; 139&#8377;</span>
        </div>

        <hr className="my-6 border-t border-gray-200" />

        <div className="mb-4">
          <label 
            className="block text-gray-700 text-xl font-bold mb-1 mt-4" 
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
          <div className="flex justify-between text-sm text-gray-700 mt-2">
            <span>Min: 137%</span>
            <span>Current: {sliderInput}%</span>
            <span>Max: 160%</span>
          </div>
        </div>

        <div className="flex items-center justify-center">
          <button 
            className="bg-secondary hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-full shadow-lg transform transition-shadow duration-500 ease-in-out hover:shadow-2xl focus:outline-none" 
            type="submit"
          >
            Create
          </button>
        </div>
      </form>
    </div>
  )
}

export default Create;
