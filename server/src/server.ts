import express, { Application, Request, Response } from "express";
import morgan from "morgan";
import cookieParser from "cookie-parser";
import { pool } from "./config/db.config";

const app: Application = express();


(async () => {
  try {
    const client = await pool.connect();
    console.log("Connected to Neon PostgreSQL!");
    client.release();
  } catch (err) {
    console.error("Error connecting to Neon:", err);
  }
})();


app.get("/health",(req:Request,res:Response)=>{
  res.json({
    status:"ok"
  })
})





app.use(cookieParser());
app.use(morgan("dev"));
app.use(express.json());

export default app;
