import React, { useState } from 'react'
import { useAragonApi } from '@aragon/api-react'
import { Main, AddressField, AppView, AppBar, Button, Card, CardLayout, Field, TextInput, Text, TabBar } from '@aragon/ui'
import styled from 'styled-components'

function App() {
  
  const { api, appState } = useAragonApi();
  const [hatAddress, setHatAddress] = useState("");
  const [hatId, setHatId] = useState("");
  const [proxyAddress, setProxyAddress] = useState("");
  const [newTokenAddress, setNewTokenAddress] = useState("");
  const [newTokenIdentifier, setNewTokenIdentifier] = useState("");
  const [selected, setSelected] = useState(0)
  const navItems = ['Hats', 'Allocation Strategy',  'Tokens', 'Proxy'];
  const {isSyncing} = appState;
    return (
      <Main>
        <AppView appBar={
          <AppBar title="rToken Admin App">
            <TabBar
                items={navItems}
                selected={selected}
                onChange={setSelected}
            />
          </AppBar>
        }>
        
        <BaseLayout>
            {selected == 0 && (
              <Card width="100%">
                  <div style={{padding:20}}>
                  <Text>Change Contract Hat</Text>
                  <Field label="Enter contract Address:">
                    <TextInput onChange={(e) => {setHatAddress(e.target.value)}} name={"hatAddress"}></TextInput>
                    <AddressField address={hatAddress} />
                  </Field>


                  <Field label="Enter new HatId:">
                    <TextInput onChange={(e) => {setHatId(e.target.value)}} name={"hatId"}></TextInput>
                  </Field>
                  <Button mode="strong" onClick={async () => {
                    console.log(hatAddress); 
                    console.log(hatId); 
                    await api.changeContractHat(hatAddress, hatId).subscribe(
                      txHash => console.log(`Success! Change hat Txn in tx ${txHash}`),
                      err => console.log(`Txn failed: ${err}`)
                    )
                  }}>
                    Change Contract Hat
                  </Button>
                  </div>
              </Card>
            )}
            
            


            {selected == 1 && (
              <Card width="100%">
                  <Text>Change Allocation Strategy</Text>
                  <Field label="Enter new Proxy Address:">
                    <TextInput onChange={(e) => {setProxyAddress(e.target.value)}} name={"proxyAddress"}></TextInput>
                  </Field>
                  
                  <Button mode="strong" onClick={async () => await api.upgradeProxyAddress(proxyAddress).subscribe()}>Submit New Proxy</Button>
              </Card>
            )}

            {selected == 2 && (
              <Card width="100%">
                  <Text>Add rToken</Text>
                  <Field label="Enter rToken Address:">
                    <TextInput onChange={(e) => {setNewTokenAddress(e.target.value)}} name={"newTokenAddress"}></TextInput>
                    <AddressField address={newTokenAddress} />
                  </Field>


                  <Field label="Enter Identifier:">
                    <TextInput onChange={(e) => {setNewTokenIdentifier(e.target.value)}} name={"newTokenIdentifier"}></TextInput>
                  </Field>
                  <Button mode="strong" onClick={async () => {
                    await api.addToken(newTokenIdentifier, newTokenAddress)
                    .subscribe(
                      txHash => console.log(`Success! Add Token Txn: ${txHash}`),
                      err => console.log(`Add Token failed: ${err}`)
                    )
                  }}>Add New Token</Button>
              </Card>
            )}
            {selected == 3 && (
              <Card width="100%">
                  <Text>Upgrade Proxy Contract</Text>
                  <Field label="Enter new Proxy Address:">
                    <TextInput onChange={(e) => {setProxyAddress(e.target.value)}} name={"proxyAddress"}></TextInput>
                  </Field>
                  
                  <Button mode="strong" onClick={async () => await api.upgradeProxyAddress(proxyAddress).subscribe()}>Submit New Proxy</Button>
              </Card>
            )}
            </BaseLayout>
        </AppView> 
      </Main>
    )
  
}

const BaseLayout = styled.div`
  padding:20px;
  align-items: center;
  justify-content: left;
  height: 100vh;
  flex-direction: row;
`

const Buttons = styled.div`
  display: grid;
  grid-auto-flow: column;
  grid-gap: 40px;
  margin-top: 20px;
`

const Syncing = styled.div.attrs({ children: 'Syncing…' })`
  position: absolute;
  top: 15px;
  right: 20px;
`

export default App