import express from "express";
import cors from "cors";
import { routes } from "./routes/index.js";
import "dotenv/config";

const api = express();

const PORT = process.env.API_PORT || 3001;

api.use(express.json());
api.use(cors());

routes.forEach(({ path, router }) => {
  api.use(path, router);
});

api.listen(PORT, () => {
  console.log(`API rodando em http://localhost:${PORT}`);
});

api.get("/", (req, res) => {
  res.send("HELLO WORLD!");
});
