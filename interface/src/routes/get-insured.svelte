<script lang="ts">
    import { Parcelsure} from "$lib/stores/ethers";
    import { onMount } from "svelte";
    import { Button, Card, Container, Divider, NumberInput, Text, TextInput } from '@kahi-ui/framework';
    import { utils, BigNumber } from "ethers";
import { formatBytes32String, formatEther, parseEther } from "ethers/lib/utils";

    let products: any = [];
    $: {
        products = $Parcelsure?.getAllProducts().then((p: any) => products = p);
    }
    let trackingId: string;
    let packageValue: number;
</script>
<Container padding="small" style="display: flex; justify-content: center">
{#if products.length > 0}
    {#each products as prod}
        <Card.Container margin="small" style="display: inline-block">
            <Card.Header>
                Product #{prod.productId}   
            </Card.Header>


            <Card.Section >
                <Divider style="margin: 0"/>
                <Text palette="informative" is="span">Daily delay payout: </Text> 
                <b>{prod.dailyDelayPayoutPercentage/100}%</b> of package value
                <br>
                <Text palette="informative" is="span">Premium: </Text> 
                <b>{prod.premiumPercentage/100}%</b> of package value
                <br>
                {formatEther(prod.availCapital)} ETH available for payouts
                <br>
                <br>
                Tracking ID:
                <TextInput bind:value={trackingId} placeholder="123456789ABCDE"></TextInput>
                <br>
                Package value (ETH)
                <NumberInput bind:value={packageValue} placeholder="00.00"></NumberInput>
                <br>
            </Card.Section>

            <Card.Footer>
 
                <Button style="width: 100%" palette="affirmative" 
                    on:click={() => $Parcelsure?.createPolicy(
                            prod.productId,
                            formatBytes32String(trackingId),
                            parseEther(String(packageValue)),
                            { value: parseEther(String(prod.premiumPercentage / 10000 * packageValue)) }    
                        )}
                >Buy insurance</Button>
            </Card.Footer>
        </Card.Container>
    {/each}
{:else}
    No insurance products available!
{/if}
</Container>