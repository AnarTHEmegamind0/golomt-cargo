import { createId } from "@paralleldrive/cuid2";
import { adminActivityLog } from "~/db/schema";
import type {
  AdminActivityAction,
  AdminActivityTargetType,
} from "~/db/schema/constants/operations";

export const insertAdminActivityLog = async (input: {
  db: any;
  actorUserId?: string | null;
  actorRole?: string | null;
  action: AdminActivityAction;
  targetType: AdminActivityTargetType;
  targetId?: string | null;
  description: string;
  metadata?: Record<string, unknown> | null;
}) => {
  await input.db.insert(adminActivityLog).values({
    id: createId(),
    actorUserId: input.actorUserId ?? null,
    actorRole: input.actorRole ?? null,
    action: input.action,
    targetType: input.targetType,
    targetId: input.targetId ?? null,
    description: input.description,
    metadataJson: input.metadata ? JSON.stringify(input.metadata) : null,
  });
};
