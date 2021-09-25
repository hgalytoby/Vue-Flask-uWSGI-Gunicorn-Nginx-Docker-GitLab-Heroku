<template>
    <img alt="Vue logo" src="./assets/logo.png"/>
    <HelloWorld msg="Hello Vue 3 + Vite"/>
    <h1>{{ data.flask1 }}</h1>
    <button @click="api('/api1/', 'flask1')">Flask1 Api</button>
    <h1>{{ data.flask2 }}</h1>
    <button @click="api('/api2/', 'flask2')">Flask2 Api</button>
</template>

<script>
    import HelloWorld from './components/HelloWorld.vue'
    import axios from 'axios'
    import {reactive} from 'vue'

    export default {
        name: 'App',
        components: {HelloWorld},
        setup() {
            let data = reactive({
                flask1: '',
                flask2: ''
            })

            function api(url, flask) {
                axios.get(url).then(
                    response => {
                        data[flask] = response.data
                    },
                    error => {
                        alert(error)
                    }
                )
            }

            return {
                api,
                data
            }
        }
    }
</script>

<style>
    #app {
        font-family: Avenir, Helvetica, Arial, sans-serif;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        text-align: center;
        color: #2c3e50;
        margin-top: 60px;
    }
</style>