#!/bin/bash
geth --exec "web3.fromWei(eth.getBalance(eth.accounts[0]), 'ether')" attach
