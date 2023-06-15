import React from "react";
import { BrowserRouter as Router, Route, Routes} from "react-router-dom";
/*
 * Connect2ic provides essential utilities for IC app development
 */
import { createClient } from "@connect2ic/core"
import { defaultProviders } from "@connect2ic/core/providers"
import { Connect2ICProvider } from "@connect2ic/react"
import "@connect2ic/core/style.css"
/*
 * Import canister definitions like this:
 */
 import * as vaults from "../.dfx/local/canisters/vaults";
/*
 * Some examples to get you started
 */
import Create from "./components/Create"
import Navbar from "./components/Navbar"
import Bottombar from "./components/Bottombar"
import Interaction from "./components/Interaction";

function App() {

  return (
    <div className="App">
      <Navbar />
      <Router>
        <Routes>
          <Route path="/create" element={<Create />} />
          <Route path="/interact" element={<Interaction />} />
        </Routes>
      </Router>
      <Bottombar />
    </div>
  )
}

const client = createClient({
  canisters: {
    vaults
  },
  providers: defaultProviders,
  globalProviderConfig: {
    /*
     * Disables dev mode in production
     * Should be enabled when using local canisters
     */
    dev: import.meta.env.DEV,
  },
})

export default () => (
  <Connect2ICProvider client={client}>
    <App />
  </Connect2ICProvider>
)
