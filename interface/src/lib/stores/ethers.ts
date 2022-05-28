import { ethers, BigNumber } from 'ethers'
import { writable, derived, type Writable } from 'svelte/store'
import contractAbi from "$lib/abis/Parcelsure.json"

export const account: Writable<string> = writable()
export const provider = derived(account, ($account) => {
	if ($account) {
		return new ethers.providers.Web3Provider(window.ethereum);
	}
})
export const Parcelsure = derived(provider, $provider => {
    if (!$provider) return;       
    const signer = $provider.getSigner();
    return new ethers.Contract("0x1d35279437626a664231D762231D160Fc121E5C5", contractAbi, signer)
})
//Metamask ETH balance
export const walletBalance = writable();