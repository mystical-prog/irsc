import React from 'react';

const Bottombar = () => {
  const currencies = [
    { name: 'BTC', price: '25,00,000' },
    { name: 'IRSC', price: '0.99' },
    { name: 'Liquidation Penalty', price: '5%' },
    { name: 'Stability Fee Rate', price: '1.5%' },
    // Add more currencies as needed
  ];

  return (
    <div className="border-t-2 border-silver fixed inset-x-0 bottom-0 text-silver p-2 shadow-lg">
      <div className="flex justify-around">
        {currencies.map((currency, index) => (
          <div key={index} className="text-center">
            <div className="font-bold">{currency.name} : {currency.price}</div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Bottombar;
