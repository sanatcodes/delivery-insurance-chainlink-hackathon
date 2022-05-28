<script lang="ts">
import { Parcelsure } from "$lib/stores/ethers";
import {
        Container, Heading, Form, Stack, TextInput, NumberInput, Text, Button
    } from "@kahi-ui/framework";
import { parseEther } from "ethers/lib/utils";

let payoutPercentage: number;
let premiumPercentage: number;
let maxDelayDays: number;
let capital: number;

</script>
<Container padding="small" style="display: flex; justify-content: center">
    <Form.FieldSet margin_top="large">
        <Form.Legend><Heading palette="informative">Offer package insurance 💰</Heading></Form.Legend>
    
        <Stack.Container spacing="medium">
            <Form.Control style="gap: 0"
            >
                <Form.Label>Daily payout percentage (%)</Form.Label>
                <Text is="small">You will pay this percentage of the package value to the insuree per delayed day</Text>
                <NumberInput bind:value={payoutPercentage} placeholder="00.00" />
            </Form.Control>
    
            <Form.Control style="gap: 0"
            >
                <Form.Label>Your premium (%)</Form.Label>
                <Text is="small">Your insuree will have to pay you this percentage on their package value when buying your insurance</Text>
                <NumberInput bind:value={premiumPercentage} placeholder="00.00" />
            </Form.Control>

            <Form.Control style="gap: 0"
            >
                <Form.Label>Maximum payout days (d)</Form.Label>
                <Text is="small">This is the maximum amount of delays you are willing to reimburse</Text>
                <NumberInput bind:value={maxDelayDays} placeholder="00" />
            </Form.Control>

            <Form.Control style="gap: 0"
            >
                <Form.Label>Payout capital (ETH)</Form.Label>
                <Text is="small">The capital you are willing to provide for payouts</Text>
                <NumberInput bind:value={capital} placeholder="00.00" />
            </Form.Control>
        </Stack.Container>
        <Button sizing="massive" margin_top="small" style="width: 100%" palette="affirmative" 
            on:click={() => $Parcelsure?.createProduct(
                Math.floor(payoutPercentage*100),
                Math.floor(premiumPercentage*100),
                maxDelayDays,
                { value: parseEther(String(capital)) }    
                )
        }>Insure</Button>
    </Form.FieldSet>
    
</Container>

