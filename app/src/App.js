import React, { useState, useRef } from "react";
import { useAragonApi } from "@aragon/api-react";
import {
  Main,
  AddressField,
  AppView,
  AppBar,
  Button,
  Card,
  Field,
  SidePanel,
  TextInput,
  Text,
  TabBar,
  TransactionBadge,
  TransactionProgress
} from "@aragon/ui";
import styled from "styled-components";
import AppLayout from "./components/AppLayout";
import GenericInputPanel from "./components/GenericInputPanel";

function App() {
  const { api, appState } = useAragonApi();
  const [hatAddress, setHatAddress] = useState("");
  const [hatId, setHatId] = useState("");
  const [proxyAddress, setProxyAddress] = useState("");
  const [newTokenAddress, setNewTokenAddress] = useState("");
  const [newTokenIdentifier, setNewTokenIdentifier] = useState("");
  const [selected, setSelected] = useState(0);
  const [transactionProgressVisible, setTransactionProgressVisible] = useState(
    false
  );
  const CHANGE_HATS = "Hats";
  const CHANGE_ALLOC = "Allocation Strategy";
  const MANAGE_TOKENS = "Tokens";
  const MANAGE_PROXY = "Proxy";

  const [activeTx, setActiveTx] = useState(false);
  const [sidePanel, setSidePanel] = useState(undefined);
  const navItems = [CHANGE_HATS, CHANGE_ALLOC, MANAGE_TOKENS, MANAGE_PROXY];
  const tabs = [{
    tabName: CHANGE_HATS,
    tabComponent: {
      submitLabel: 'Change Hat',
      handleSubmit: (hatAddress, hatId) => {
        return api.changeContractHat(hatAddress, hatId).subscribe(
          txHash => {
            setActiveTx(txHash);
            setTransactionProgressVisible(true);
            console.log(`Success! Change hat Txn in tx ${txHash}`);
          },
          err => console.log(`Txn failed: ${err}`)
        );
      },
      inputs: [
        { id: 1, label: "contract address to change", type: "text" },
        { id: 2, label: "new hat id", type: "text" }
      ],
      title: 'Change Contract Hat',
      description: `This action will change the hat for the specified contract address to the specified hat`
    }
  },
    {
      tabName: CHANGE_ALLOC,
      tabComponent: {
        submitLabel: 'Change Strategy',
        handleSubmit: (hatAddress, hatId) => {
          return api.changeContractHat(hatAddress, hatId).subscribe(
            txHash => {
              setActiveTx(txHash);
              setTransactionProgressVisible(true);
              console.log(`Success! Change hat Txn in tx ${txHash}`);
            },
            err => console.log(`Txn failed: ${err}`)
          );
        },
        inputs: [
          { id: 1, label: "new allocation strategy address", type: "text" },
        ],
        title: 'Change Allocation Strategy',
        description: `This action will change the hat for the specified contract address to the specified hat`
      }
    },
    {
      tabName: MANAGE_TOKENS,
      tabComponent: {
        submitLabel: 'Change Hat',
        handleSubmit: (hatAddress, hatId) => {
          return api.changeContractHat(hatAddress, hatId).subscribe(
            txHash => {
              setActiveTx(txHash);
              setTransactionProgressVisible(true);
            },
            err => console.log(`Txn failed: ${err}`)
          );
        },
        inputs: [
          { id: 1, label: "contract address", type: "text" },
          { id: 2, label: "hat id", type: "text" }
        ],
        title: 'Change Contract Hat',
        description: `This action will change the hat for the specified contract address to the specified hat`
      }
    },
    {
      tabName: MANAGE_PROXY,
      tabComponent: {
        submitLabel: 'Upgrade Proxy',
        handleSubmit: (proxyAddress) => {
          return api.updateProxyAddress(proxyAddress).subscribe(
            txHash => {
              setActiveTx(txHash);
              setTransactionProgressVisible(true);
            },
            err => console.log(`Txn failed: ${err}`)
          );
        },
        inputs: [
          { id: 1, label: "new proxy address", type: "text" }
        ],
        title: 'Update Proxy Contract',
        description: `This action will update the proxy contract of the specified token to a new Logic Contract`
      }
    }]
  const { isSyncing } = appState;
  const tabNames = tabs.map(tab => tab.tabName);
  const selectedTabComponent = tabs[selected].tabComponent;
  const {title, description, inputs, submitLabel, handleSubmit} = selectedTabComponent;
  return (
    <Main>
      <AppLayout
        title="rToken Admin"
        tabs={
          <TabBar items={tabNames} selected={selected} onChange={setSelected} />
        }
      >
        <BaseLayout>
          <Card height={"50%"} width={"50%"}>
            <GenericInputPanel
              actionTitle={title}
              actionDescription={description}
              inputFieldList={inputs}
              submitLabel={submitLabel}
              handleSubmit={handleSubmit}
            />
          </Card>
        </BaseLayout>
      </AppLayout>
    </Main>
  );
}

const ActiveTxLayout = styled.div`
  padding-top: 20px;
`;

const CardLayout = styled.div`
  padding: 20px;
  align-items: center;
  justify-content: left;
  height: 100vh;
  flex-direction: column;
`;

const BaseLayout = styled.div`
  padding: 20px;
  align-items: center;
  justify-content: left;
  height: 100vh;
  flex-direction: row;
`;

const Buttons = styled.div`
  display: grid;
  grid-auto-flow: column;
  grid-gap: 40px;
  margin-top: 20px;
`;

const Syncing = styled.div.attrs({ children: "Syncing…" })`
  position: absolute;
  top: 15px;
  right: 20px;
`;

export default App;
