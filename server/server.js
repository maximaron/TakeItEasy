const express = require('express');
const mysql = require('mysql2');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const bodyParser = require('body-parser');
const os = require('os');
const app = express();
const port = 3000;
const secret = 'your_jwt_secret';

app.use(bodyParser.json());

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'take_it_easy'
});

db.connect(err => {
    if (err) {
        console.error('Database connection failed: ' + err.stack);
        return;
    }
    console.log('Connected to database.');

    const createUsersTableQuery = `
        CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100),
            email VARCHAR(100) UNIQUE,
            birth_date DATE,
            gender ENUM('Male', 'Female', 'Other'),
            password VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    `;
    const createMemoriesTableQuery = `
        CREATE TABLE IF NOT EXISTS memories (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT,
            event VARCHAR(255),
            emotion VARCHAR(255),
            details TEXT,
            occurred_at DATETIME,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id)
        )
    `;

    db.query(createUsersTableQuery, (err, result) => {
        if (err) {
            console.error('Failed to create users table: ' + err.message);
            return;
        }
        console.log('Users table exists or was created successfully.');
    });

    db.query(createMemoriesTableQuery, (err, result) => {
        if (err) {
            console.error('Failed to create memories table: ' + err.message);
            return;
        }
        console.log('Memories table exists or was created successfully.');
    });
});

app.post('/register', async (req, res) => {
    const { name, email, birth_date, gender, password } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);

    const query = 'INSERT INTO users (name, email, birth_date, gender, password) VALUES (?, ?, ?, ?, ?)';
    db.query(query, [name, email, birth_date, gender, hashedPassword], (err, result) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.status(201).json({ message: 'User registered successfully!' });
    });
});

app.post('/login', (req, res) => {
    const { email, password } = req.body;

    const query = 'SELECT * FROM users WHERE email = ?';
    db.query(query, [email], async (err, results) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        if (results.length === 0 || !await bcrypt.compare(password, results[0].password)) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        const token = jwt.sign({ id: results[0].id }, secret);
        res.json({ token, name: results[0].name });
    });
});

app.post('/memories', (req, res) => {
    const { token, event, emotion, details, occurred_at } = req.body;
    const decoded = jwt.verify(token, secret);

    const query = 'INSERT INTO memories (user_id, event, emotion, details, occurred_at) VALUES (?, ?, ?, ?, ?)';
    db.query(query, [decoded.id, event, emotion, details, occurred_at], (err, result) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.status(201).json({ message: 'Memory added successfully!' });
    });
});

app.get('/memories', (req, res) => {
    const { token, date } = req.query;
    const decoded = jwt.verify(token, secret);

    const query = 'SELECT * FROM memories WHERE user_id = ? AND DATE(created_at) = ?';
    db.query(query, [decoded.id, date], (err, results) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.json(results);
    });
});

app.get('/event', (req, res) => {
    const { token, id } = req.query;
    const decoded = jwt.verify(token, secret);

    const query = 'SELECT * FROM memories WHERE user_id = ? AND id = ?';
    db.query(query, [decoded.id, id], (err, results) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        if (results.length === 0) {
            return res.status(404).json({ message: 'Event not found' });
        }
        res.json(results[0]);
    });
});

app.put('/event', (req, res) => {
    const { token, id, event, emotion, details, occurred_at } = req.body;
    const decoded = jwt.verify(token, secret);

    const query = 'UPDATE memories SET event = ?, emotion = ?, details = ?, occurred_at = ? WHERE user_id = ? AND id = ?';
    db.query(query, [event, emotion, details, occurred_at, decoded.id, id], (err, result) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.json({ message: 'Event updated successfully!' });
    });
});

app.delete('/event', (req, res) => {
    const { token, id } = req.body;
    const decoded = jwt.verify(token, secret);

    const query = 'DELETE FROM memories WHERE user_id = ? AND id = ?';
    db.query(query, [decoded.id, id], (err, result) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.json({ message: 'Event deleted successfully!' });
    });
});

function getLocalExternalIP() {
    const interfaces = os.networkInterfaces();
    for (const name of Object.keys(interfaces)) {
        for (const net of interfaces[name]) {
            if (net.family === 'IPv4' && !net.internal) {
                return net.address;
            }
        }
    }
    return '0.0.0.0';
}

const localExternalIP = getLocalExternalIP();
app.listen(port, () => {
    console.log(`Server is running at http:${localExternalIP}:${port}`);
});
