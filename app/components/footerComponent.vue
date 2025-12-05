<template>
    <footer>
        <li class="mentionsLegales"><NuxtLink to="mentions-legales/">Mentions légales</NuxtLink></li>
        <li class="nirdLink"><a href="https://nird.forge.apps.education.fr" target="_blank">Nird.fr</a></li>
    </footer>
</template>


<script>

</script>


<style>

    footer{
        display: flex;
        flex-direction: row;
        font-family: sans-serif;
        position: fixed;
        bottom: 0px;
        left: 0px;
        width: 100%;
    }

    .mentionsLegales a{
        text-decoration: None;
        color: #666; /* Satan shall rull over this world soon to be damned \/0\/ */ 
    }

    .nirdLink a{
        text-decoration: None;
        color: #666; /* Satan shall rull over this world soon to be damned \/0\/ */
    }

    .mentionsLegales, .nirdLink{
        margin: 10px 10px;
        list-style-type: None;
    }

    

</style>
