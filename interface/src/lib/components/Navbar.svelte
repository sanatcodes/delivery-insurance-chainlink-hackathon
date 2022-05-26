<script lang="ts">
    import { browser } from "$app/env";
    import { page } from '$app/stores';
    import { Omni, Button, Divider, Ellipsis, Text, Menu, Spacer, Anchor } from "@kahi-ui/framework";
    import { account } from '$lib/stores/ethers'
    import ThemeBtn from "./ThemeBtn.svelte";
    
    let isConnectPending = false;
    async function requestAccount() {
        isConnectPending = true;
		await window.ethereum.request({ method: 'eth_requestAccounts' }).catch(() => {isConnectPending = false;})
        isConnectPending = false;
	}
</script>
<Omni.Container style="background: none">
    <Omni.Header>
        <Anchor href="/" style="text-decoration: none;">
            Parcelsure
        </Anchor>
        <Divider orientation="vertical" margin="small" />
    </Omni.Header>
    <Omni.Section style="justify-content: left">
        <Menu.Container
            orientation="horizontal"
        >
            <Anchor href="/get-insured" style="text-decoration: none;">
                <Menu.Button active={$page.url.pathname === '/get-insured'}>Get insured</Menu.Button>
            </Anchor>
            <Anchor href="/offer-insurance" style="text-decoration: none;">
                <Menu.Button active={$page.url.pathname === '/insure'}>Offer insurance</Menu.Button>
            </Anchor>
        </Menu.Container>
    </Omni.Section>
    <Spacer />
    <Omni.Footer>
        {#if !$account}  
            <Button palette="accent" on:click={requestAccount} disabled={isConnectPending}>
                {#if !isConnectPending}
                    Connect wallet
                {:else}
                    <Text is="span">
                        Connecting<Ellipsis />
                    </Text>
                {/if}
            </Button>
        {:else}
            {$account}
        {/if}
        <Divider orientation="vertical" margin="small" />
        {#if browser}
            <ThemeBtn></ThemeBtn>
        {/if}
    </Omni.Footer>
</Omni.Container>