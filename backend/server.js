require('dotenv').config();
const express = require('express');
const { AptosClient } = require('aptos');
const dbOperations = require('./database');

const app = express();
const PORT = process.env.PORT || 3000;

// Initialize Aptos client
const aptosClient = new AptosClient('https://fullnode.mainnet.aptoslabs.com/v1');

// Middleware
app.use(express.json());

// API Routes
app.post('/api/claim-reward', async (req, res) => {
  try {
    const { walletAddress, landmarkId } = req.body;
    
    // NFT transfer logic using Aptos SDK
    const transaction = await aptosClient.generateTransaction(
      process.env.CREATOR_ADDRESS,
      {
        function: `${process.env.MODULE_ADDRESS}::nft_transfer::mint_and_transfer`,
        type_arguments: [],
        arguments: [walletAddress]
      }
    );

    // Update user rewards in database
    await dbOperations.createReward(walletAddress, landmarkId, 100);

    res.json({ success: true, message: 'NFT reward claimed successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/leaderboard', async (req, res) => {
  try {
    const leaderboard = await dbOperations.getLeaderboard();
    
    res.json(leaderboard);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});