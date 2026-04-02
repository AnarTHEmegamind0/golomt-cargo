type OpenAPIDetail = {
  tags?: string[];
  security?: Array<Record<string, string[]>>;
  description?: string;
  [key: string]: any;
};

type EndpointAudience = "customer" | "staff" | "shared";

export const customerBearerAuthScheme = "customerBearerAuth";
export const staffBearerAuthScheme = "staffBearerAuth";

const audienceTag: Record<EndpointAudience, string> = {
  customer: "Customer API",
  staff: "Staff/Admin API",
  shared: "Shared API",
};

const audienceDescription: Record<EndpointAudience, string> = {
  customer:
    "Customer endpoint. Use a customer bearer token. Admin bearer tokens are also accepted for support operations.",
  staff:
    "Staff/admin endpoint. Use a staff/admin bearer token from an admin, china_staff, or mongolia_staff account.",
  shared:
    "Shared endpoint. Use the bearer token that matches the signed-in account role: customer token for customers, staff/admin token for admin or staff accounts.",
};

const audienceSecurity: Record<EndpointAudience, Array<Record<string, string[]>>> = {
  customer: [{ [customerBearerAuthScheme]: [] }, { [staffBearerAuthScheme]: [] }],
  staff: [{ [staffBearerAuthScheme]: [] }],
  shared: [{ [customerBearerAuthScheme]: [] }, { [staffBearerAuthScheme]: [] }],
};

export const openApiTags = [
  {
    name: "Customer API",
    description:
      "Customer-facing endpoints. Customers should use customer bearer tokens. Admin tokens may still be accepted on some support-oriented endpoints.",
  },
  {
    name: "Staff/Admin API",
    description:
      "Operational endpoints for admin, China staff, and Mongolia staff accounts. These require staff/admin bearer tokens.",
  },
  {
    name: "Shared API",
    description:
      "Endpoints available to both customer and staff/admin roles. Use the bearer token that matches the signed-in account.",
  },
  {
    name: "Auth",
    description:
      "Authentication endpoints. Sign-in returns different bearer tokens depending on the signed-in account role.",
  },
  {
    name: "Staff/Admin Auth",
    description: "Administrative Better Auth endpoints that require a staff/admin bearer token.",
  },
];

export const withAudience = (audience: EndpointAudience, detail: OpenAPIDetail): any => ({
  ...detail,
  tags: [audienceTag[audience], ...(detail.tags ?? [])],
  security: audienceSecurity[audience],
  description: [audienceDescription[audience], detail.description].filter(Boolean).join(" "),
});

export const openApiSecuritySchemes = {
  customerBearerAuth: {
    type: "http",
    scheme: "bearer",
    description:
      "Bearer session token returned after POST /auth/sign-in/email with a customer account. Use this for customer and shared endpoints.",
  },
  staffBearerAuth: {
    type: "http",
    scheme: "bearer",
    description:
      "Bearer session token returned after POST /auth/sign-in/email with an admin, china_staff, or mongolia_staff account. Use this for staff/admin and shared endpoints.",
  },
} as const;
