import mysql from "mysql2";
import { dbConfig } from "../config/config.js";

const pool = mysql.createPool({
  host: dbConfig.host,
  user: dbConfig.user,
  password: dbConfig.pass,
  database: dbConfig.name,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 50,
  connectTimeout: 10000,
});

export default pool.promise();
