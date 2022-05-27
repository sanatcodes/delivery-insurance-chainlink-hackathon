<script lang="ts">

import {
        Container,
        Figure,
        Box,
        Text,
        Stack
    } from "@kahi-ui/framework";

    const  clLogo = 'images/cl.png'
    const  hadhatLogo = 'images/hardhat.png'
    const  ipfsLogo = 'images/ipfs.png'
    const   polygonLogo = 'images/polygon.png'
    const   svelteLogo = 'images/svelte.png'


</script>

<!-- <Container>
    <Text sizing="massive">
       Never get a parcel
    </Text>
    <Box palette="accent" width="50">
        <Text sizing="massive">
           late
        </Text>
    </Box>
</Container> -->

<style>
    .homepage_container{
        display: flex;
        flex-direction: row;
        margin: 100px 40px 20px 40px;
        padding: 20px 20px 20px;
        gap: 20vh;
        align-items: center;
    }

    .homepage_pic{
        margin-top:8vh;
        max-width: 30%;
        height:auto;
    }

    .homepage_copy{
        font-size:2em;
        font-weight: bold;
        line-height: 2.0em;
    }

    .callToActionBtn{
        background-color:#597384;
        margin-top: 5vh;
        width: 35%;
        border-radius:10px;
        font-size: 20px;
    }
    
    .homepage_pic2{
        max-width: 30%;
        height:auto;
    }
    .tool_pictures{
        display: flex;
        justify-content: space-evenly;
        align-items: center;
    }

    .tools_text{
        margin: auto;
        width: 20%;
        padding: 10px;
        font-size: 20px;
        font-weight: bold;
    }

    li{
        list-style-type: none;
    }

  

</style>

<div class="homepage_container">
    <div class="homepage_copy">
        <Stack.Container>
            <Text sizing="massive">
                Don't worry<br>
                about recieving<br>
                parcels late <br>
                again!
            </Text>
            <button class="callToActionBtn">
                Get Insured
            </button>
        </Stack.Container>
    </div>

    <div class="homepage_pic">
        <img src="https://cdn-icons-png.flaticon.com/512/679/679922.png">
    </div>
</div>

<div class="homepage_container">
    <div class="homepage_pic2">
        <img src="https://cdn-icons-png.flaticon.com/512/5675/5675009.png"/>
    </div>        
    <div class="homepage_copy">
        <Text sizing="huge">
            A decentralised <br> insurance protocol <br>built on Etherium
        </Text>
    </div>
</div>

<div class="tools_text">
    <h2>
        Powered by
    </h2>
</div>
<div class="tool_pictures">
    <li>
        <img src={polygonLogo}/>  
    </li>
    <li>
        <img src={ipfsLogo}/>    
    </li>
    <li>
        <img src={clLogo}/>  
    </li>
    <li>
        <img src={svelteLogo}/>   
    </li>
    <li>
        <img src={hadhatLogo}/>  
    </li>
</div> 

