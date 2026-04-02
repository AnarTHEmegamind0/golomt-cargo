import { createId } from "@paralleldrive/cuid2";
import { Elysia, t } from "elysia";

type MockItem = {
  id: string;
  name: string;
  note: string | null;
  done: boolean;
  createdAt: string;
};

const mockItems = new Map<string, MockItem>();

const mockItemIdParamsSchema = t.Object({
  id: t.String({ minLength: 1 }),
});

const createMockItemSchema = t.Object({
  name: t.String({ minLength: 1, maxLength: 100 }),
  note: t.Optional(t.Nullable(t.String({ maxLength: 300 }))),
});

const updateMockItemSchema = t.Object({
  name: t.Optional(t.String({ minLength: 1, maxLength: 100 })),
  note: t.Optional(t.Nullable(t.String({ maxLength: 300 }))),
  done: t.Optional(t.Boolean()),
});

const listMockItemsQuerySchema = t.Object({
  limit: t.Optional(t.Integer({ minimum: 1, maximum: 100 })),
});

export const mockRoutes = new Elysia().group("/mock-items", (app) =>
  app
    .get(
      "/",
      ({ query }) => {
        const limit = query.limit ?? 20;
        const data = Array.from(mockItems.values()).slice(0, limit);

        return {
          data,
          total: mockItems.size,
        };
      },
      {
        detail: {
          tags: ["Mock"],
          summary: "List mock items",
          description: "Simple in-memory list endpoint used to verify build-time OpenAPI generation",
        },
        query: listMockItemsQuerySchema,
      }
    )
    .post(
      "/",
      ({ body, status }) => {
        const item: MockItem = {
          id: createId(),
          name: body.name,
          note: body.note ?? null,
          done: false,
          createdAt: new Date().toISOString(),
        };

        mockItems.set(item.id, item);

        return status(201, {
          message: "Mock item created",
          data: item,
        });
      },
      {
        detail: {
          tags: ["Mock"],
          summary: "Create mock item",
        },
        body: createMockItemSchema,
      }
    )
    .get(
      "/:id",
      ({ params, status }) => {
        const item = mockItems.get(params.id);

        if (!item) {
          return status(404, {
            message: "Mock item not found",
          });
        }

        return {
          data: item,
        };
      },
      {
        detail: {
          tags: ["Mock"],
          summary: "Get mock item",
        },
        params: mockItemIdParamsSchema,
      }
    )
    .patch(
      "/:id",
      ({ params, body, status }) => {
        const current = mockItems.get(params.id);

        if (!current) {
          return status(404, {
            message: "Mock item not found",
          });
        }

        const updated: MockItem = {
          ...current,
          name: body.name ?? current.name,
          note: body.note === undefined ? current.note : body.note,
          done: body.done ?? current.done,
        };

        mockItems.set(updated.id, updated);

        return {
          message: "Mock item updated",
          data: updated,
        };
      },
      {
        detail: {
          tags: ["Mock"],
          summary: "Update mock item",
        },
        params: mockItemIdParamsSchema,
        body: updateMockItemSchema,
      }
    )
    .delete(
      "/:id",
      ({ params, status }) => {
        if (!mockItems.has(params.id)) {
          return status(404, {
            message: "Mock item not found",
          });
        }

        mockItems.delete(params.id);

        return {
          message: "Mock item deleted",
        };
      },
      {
        detail: {
          tags: ["Mock"],
          summary: "Delete mock item",
        },
        params: mockItemIdParamsSchema,
      }
    )
);
