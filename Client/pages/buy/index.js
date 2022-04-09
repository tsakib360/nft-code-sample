import { useRouter } from 'next/router';
import React, { useEffect, useState } from 'react'
import { useMoralis } from 'react-moralis';
import Moralis from 'moralis';
import Web3 from 'web3';
import { contactAddress, contractABI } from '../../contract';

const web3 = new Web3(Web3.givenProvider);

function Dashboard() {
    const {isAuthenticated, logout, user} = useMoralis();
    const router = useRouter();
    const [tokenId, setTokenId] = useState(0);
    // useEffect(() => {
    //     if(!isAuthenticated) router.push('/');
    // }, [isAuthenticated]);
    const onSubmit = async (e) => {
        e.preventDefault();
        try {
            const contract = new web3.eth.Contract(contractABI, contactAddress);
            
            const addList = await contract.methods.purchase(contactAddress, tokenId, 1).send({ from: user.get("ethAddress"), value: 10000000000000000 });
            console.log(addList);
            
        } catch (err) {
            console.error(err);
            alert(err);
        }
    }
  return (
    <div className="flex w-screen h-screen items-center justify-center">
        <form onSubmit={onSubmit}>
            <div className="mt-3">
                <input type="text" className="border-[1px] p-2 text-lg border-black w-full" 
                placeholder="Token ID" value={tokenId} onChange={e => setTokenId(e.target.value)} />
            </div>
            <button className="mt-5 w-full p-5 bg-green-700 text-white text-lg rounded-xl animate-pulse">List Now</button>
            <button onClick={logout} className="mt-5 w-full p-5 bg-red-700 text-white text-lg rounded-xl">Logout</button>
        </form>
    </div>
  )
}

export default Dashboard;