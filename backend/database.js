const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// Create a new database connection
const db = new sqlite3.Database(path.join(__dirname, 'rewards.db'), (err) => {
  if (err) {
    console.error('Database connection error:', err);
    process.exit(1);
  }
  console.log('Connected to SQLite database');
});

// Initialize database schema
db.serialize(() => {
  db.run(`CREATE TABLE IF NOT EXISTS rewards (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    walletAddress TEXT NOT NULL,
    landmarkId TEXT NOT NULL,
    points INTEGER NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);
});

// Database operations
const dbOperations = {
  createReward: (walletAddress, landmarkId, points) => {
    return new Promise((resolve, reject) => {
      const stmt = db.prepare('INSERT INTO rewards (walletAddress, landmarkId, points) VALUES (?, ?, ?)');
      stmt.run([walletAddress, landmarkId, points], function(err) {
        if (err) reject(err);
        else resolve(this.lastID);
      });
      stmt.finalize();
    });
  },

  getLeaderboard: () => {
    return new Promise((resolve, reject) => {
      db.all(
        `SELECT walletAddress as _id, SUM(points) as totalPoints 
         FROM rewards 
         GROUP BY walletAddress 
         ORDER BY totalPoints DESC 
         LIMIT 10`,
        (err, rows) => {
          if (err) reject(err);
          else resolve(rows);
        }
      );
    });
  }
};

module.exports = dbOperations;