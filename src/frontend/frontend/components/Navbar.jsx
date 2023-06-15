import React from 'react';
import { ConnectButton, ConnectDialog } from '@connect2ic/react';

const Navbar = () => {

  return (
    <nav className="border-b-2 border-silver flex items-center justify-between w-full h-16 bg-gradient-to-r from-background to-purple text-white px-6 relative overflow-hidden">
      <div className="text-2xl font-bold font-primary text-silver">IRSC - Backed by ckBTC</div>
      <div className="bg-white text-silver rounded shadow-md px-6 py-2 font-bold"><ConnectButton /></div>
      <ConnectDialog />
    </nav>
  );
}

export default Navbar;
