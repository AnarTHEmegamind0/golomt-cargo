import { Elysia } from "elysia";
import { db } from "~/db";

export const database = new Elysia({ name: "@[database]" }).decorate("db", db);
