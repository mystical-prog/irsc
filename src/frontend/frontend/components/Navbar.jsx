import React from 'react';

const Navbar = () => {

  return (
    <nav className="border-b-2 border-silver flex items-center justify-between w-full h-16 bg-gradient-to-r from-background to-purple text-white px-6 relative overflow-hidden">
      <div className="text-2xl font-bold font-primary text-silver">IRSC - Backed by ckBTC</div>
      <button className="bg-white text-silver border-silver border-2 rounded shadow-md px-6 py-2 font-bold">Connect</button>
    </nav>
  );
}

export default Navbar;
