import express, { Application, Request, Response } from "express";
import morgan from "morgan";
import cookieParser from "cookie-parser";

const app: Application = express();


app.use(cookieParser());
app.use(morgan("dev"));
app.use(express.json());

export default app;
