# Aion Animal Roulette

![Four Animals in a Row](img/readme-image.png)

This is the repository for the [Aion Animal Roulette Demo](https://aion-roulette.netlify.com)! Feel free to clone, fork, change, and do whatever you want to with this repo! Everything here is built on top of the [Aion Network](https://aion.network).

## Prerequisites

1. Install [Node.js & NPM](https://nodejs.org/en/) if you haven't already NPM comes pre-packaged with Node, so you only have to follow the one link.
2. Once you've got NPM on your computer, install **Webpack**, **Webpack CLI**, and **http-server**:

    ```bash
    npm i -g webpack webpack-cli http-server
    ```

3. Grab your Nodesmith URL. If you don't have Nodesmith setup, [follow our setup guide](https://learn.aion.network/docs/nodesmith).

    Your URL should look something like this: `https://api.nodesmith.io/v1/aion/testnet/jsonrpc?apiKey=abcdef123456abcdf123456abcdef123456`. Make sure you select **Testnet (Mastery)** from the dropdown menu, otherwise you'll be building your dApp on the _Mainnet_ network.

4. Finally, get the latest version of the AIWA Chrome extension install. You can also install AIWA on the Brave browser. If you don't have AIWA setup, [follow our setup guide](https://learn.aion.network/docs/aiwa).

## Install

1. Clone this repository:

    ```bash
    git clone https://github.com/aion-kimcodeashian/aion-roulette-final.git
    ```

2. Open `src/js/index.js` and edit line 48 with your **Nodesmith URL**. It should look something like this:

    ```javascript
    47  // Fallback Nodesmith Connection
    48  web3 = new Web3(new Web3.providers.HttpProvider("https://api.nodesmith.io/v1/aion/testnet/jsonrpc?apiKey=abcdef123456abcdf123456abcdef123456"));
    49
    50 // Contract Instance
    ```

3. Install all the NPM dependencies:

    ```bash
    npm install
    ```

4. Start the local HTTP Server:

    ```bash
    http-server
    ```

5. Go to [http://localhost:8080/](http://localhost:8080/)

## Rebuilding after Making Changes

1. When you make any changes to the code you'll have to rebuild the project:

    ```bash
    npm run-script build
    ```

2. Then just refresh your [browser to see your changes](http://localhost:8080/)!
