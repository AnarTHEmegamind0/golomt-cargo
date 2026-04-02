import { Elysia } from "elysia";
import { customerCargoRoutes } from "~/routes/cargos/customer";
import { chinaCargoRoutes } from "~/routes/cargos/china-staff";
import { mongoliaCargoRoutes } from "~/routes/cargos/mongolia-staff";
import { paymentRoutes } from "~/routes/payments/routes";
import { branchRoutes } from "~/routes/branches/routes";
import { mockRoutes } from "~/routes/mock/routes";

export const apiRoutes = new Elysia({ prefix: "/api" })
  .use(customerCargoRoutes)
  .use(chinaCargoRoutes)
  .use(mongoliaCargoRoutes)
  .use(paymentRoutes)
  .use(branchRoutes)
  .use(mockRoutes);
