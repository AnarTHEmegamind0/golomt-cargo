# Backend API Requirements - Mobile App Changes

## Overview

Энэхүү баримт бичигт mobile app-д хийгдсэн өөрчлөлтүүд болон шаардлагатай backend API-уудыг тодорхойлсон.

---

## 1. Vehicle Management (Машины удирдлага)

### Model: `Vehicle`

```json
{
  "id": "string",
  "plate_number": "string",
  "name": "string",
  "type": "TRUCK | VAN | CONTAINER",
  "is_active": "boolean",
  "created_at": "ISO8601 datetime",
  "updated_at": "ISO8601 datetime | null"
}
```

### Required APIs:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/vehicles` | Бүх машинуудын жагсаалт |
| POST | `/api/vehicles` | Шинэ машин үүсгэх |
| PUT | `/api/vehicles/{vehicleId}` | Машины мэдээлэл засах |
| DELETE | `/api/vehicles/{vehicleId}` | Машин устгах |

#### Request/Response Examples:

**POST /api/vehicles** - Create Vehicle
```json
// Request
{
  "plate_number": "1234УНБ",
  "name": "Ачааны машин 1",
  "type": "TRUCK"
}

// Response
{
  "data": {
    "id": "uuid",
    "plate_number": "1234УНБ",
    "name": "Ачааны машин 1",
    "type": "TRUCK",
    "is_active": true,
    "created_at": "2024-04-08T00:00:00Z"
  }
}
```

**PUT /api/vehicles/{vehicleId}** - Update Vehicle
```json
// Request (all fields optional)
{
  "plate_number": "string",
  "name": "string",
  "type": "TRUCK | VAN | CONTAINER",
  "is_active": false
}
```

---

## 2. Shipment Management (Ачилтын удирдлага)

### Model: `Shipment`

```json
{
  "id": "string",
  "vehicle_id": "string",
  "vehicle_plate_number": "string",
  "status": "DRAFT | DEPARTED | IN_TRANSIT | ARRIVED | COMPLETED",
  "created_at": "ISO8601 datetime",
  "departure_date": "ISO8601 datetime | null",
  "arrival_date": "ISO8601 datetime | null",
  "cargo_count": "integer",
  "note": "string | null",
  "cargo_ids": ["string"]
}
```

### Status Flow:
```
DRAFT -> DEPARTED -> IN_TRANSIT -> ARRIVED -> COMPLETED
```

### Required APIs:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/shipments` | Бүх ачилтуудын жагсаалт |
| GET | `/api/shipments/{shipmentId}` | Нэг ачилтын дэлгэрэнгүй |
| POST | `/api/shipments` | Шинэ ачилт үүсгэх |
| POST | `/api/shipments/{shipmentId}/cargos` | Ачилтад бараа нэмэх |
| DELETE | `/api/shipments/{shipmentId}/cargos` | Ачилтаас бараа хасах |
| POST | `/api/shipments/{shipmentId}/status` | Ачилтын статус өөрчлөх |

#### Request/Response Examples:

**GET /api/shipments?status=DRAFT** - List Shipments (filter by status)
```json
// Response
{
  "data": [
    {
      "id": "uuid",
      "vehicle_id": "vehicle-uuid",
      "vehicle_plate_number": "1234УНБ",
      "status": "DRAFT",
      "created_at": "2024-04-08T00:00:00Z",
      "departure_date": null,
      "cargo_count": 5,
      "cargo_ids": ["cargo-1", "cargo-2"]
    }
  ]
}
```

**POST /api/shipments** - Create Shipment
```json
// Request
{
  "vehicle_id": "vehicle-uuid",
  "departure_date": "2024-04-10T00:00:00Z",
  "note": "Тэмдэглэл"
}
```

**POST /api/shipments/{shipmentId}/cargos** - Add Cargos to Shipment
```json
// Request
{
  "cargo_ids": ["cargo-1", "cargo-2", "cargo-3"]
}
```

**DELETE /api/shipments/{shipmentId}/cargos** - Remove Cargos from Shipment
```json
// Request
{
  "cargo_ids": ["cargo-1"]
}
```

**POST /api/shipments/{shipmentId}/status** - Update Status
```json
// Request
{
  "status": "DEPARTED"
}
```

---

## 3. Activity Logs (Үйлдлийн түүх)

### Model: `AdminActivityLog`

```json
{
  "id": "string",
  "admin_id": "string",
  "admin_name": "string",
  "action": "CREATE | UPDATE | DELETE | STATUS_CHANGE | RECEIVE | SHIP | ARRIVE | BAN | UNBAN | ROLE_CHANGE | PRICE_OVERRIDE | WEIGHT_RECORD | IMPORT",
  "target_type": "CARGO | USER | SHIPMENT | VEHICLE | BRANCH",
  "target_id": "string | null",
  "description": "string",
  "created_at": "ISO8601 datetime",
  "metadata": "object | null"
}
```

### Required API:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/logs` | Admin үйлдлийн түүх |

#### Query Parameters:
- `limit`: integer (optional) - хуудаслалт
- `offset`: integer (optional) - хуудаслалт
- `action`: string (optional) - filter by action type
- `targetType`: string (optional) - filter by target type

#### Response:
```json
{
  "data": [
    {
      "id": "uuid",
      "admin_id": "admin-uuid",
      "admin_name": "Админ нэр",
      "action": "CREATE",
      "target_type": "CARGO",
      "target_id": "cargo-uuid",
      "description": "Бараа шинээр бүртгэсэн",
      "created_at": "2024-04-08T10:00:00Z",
      "metadata": {}
    }
  ]
}
```

---

## 4. Finance Summary (Санхүүгийн тойм)

### Model: `FinanceSummary`

```json
{
  "total_revenue_mnt": "integer",
  "paid_amount_mnt": "integer",
  "unpaid_amount_mnt": "integer",
  "total_cargos": "integer",
  "paid_cargos": "integer",
  "unpaid_cargos": "integer",
  "avg_price_per_kg": "double",
  "avg_price_per_cbm": "double",
  "daily_revenues": [
    {
      "date": "YYYY-MM-DD",
      "revenue": "integer",
      "cargo_count": "integer"
    }
  ]
}
```

### Required API:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/finance/summary` | Санхүүгийн тойм |

#### Query Parameters:
- `startDate`: string (YYYY-MM-DD) - эхлэх огноо
- `endDate`: string (YYYY-MM-DD) - дуусах огноо

#### Response:
```json
{
  "data": {
    "total_revenue_mnt": 5000000,
    "paid_amount_mnt": 3500000,
    "unpaid_amount_mnt": 1500000,
    "total_cargos": 150,
    "paid_cargos": 100,
    "unpaid_cargos": 50,
    "avg_price_per_kg": 8500.50,
    "avg_price_per_cbm": 850000.00,
    "daily_revenues": [
      {
        "date": "2024-04-01",
        "revenue": 250000,
        "cargo_count": 10
      }
    ]
  }
}
```

---

## 5. Branch Management (Салбарын удирдлага)

### Required APIs (NEW):

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/branches` | Шинэ салбар үүсгэх |
| PUT | `/api/branches/{branchId}` | Салбар засах |
| DELETE | `/api/branches/{branchId}` | Салбар устгах |

#### POST /api/branches - Create Branch
```json
// Request
{
  "name": "Салбарын нэр",
  "code": "UB01",
  "address": "Хаяг",
  "phone": "99001122",
  "chinaAddress": "Хятад дахь хаяг"
}

// Response
{
  "data": {
    "id": "uuid",
    "name": "Салбарын нэр",
    "code": "UB01",
    "address": "Хаяг",
    "phone": "99001122",
    "chinaAddress": "Хятад дахь хаяг",
    "isActive": true
  }
}
```

#### PUT /api/branches/{branchId} - Update Branch
```json
// Request (all optional)
{
  "name": "string",
  "code": "string",
  "address": "string",
  "phone": "string",
  "chinaAddress": "string",
  "isActive": false
}
```

---

## 6. Cargo Dimensions Recording (Барааны хэмжээс бүртгэх)

### Required API (NEW):

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/cargos/{cargoId}/record-dimensions` | Барааны хэмжээс бүртгэх |

#### Request:
```json
{
  "heightCm": 30,
  "widthCm": 40,
  "lengthCm": 50,
  "isFragile": true,
  "calculatedFeeMnt": 15000,
  "overrideFeeMnt": 12000
}
```

---

## Summary of All New API Endpoints

### Шинээр хэрэгтэй API-ууд:

```
# Vehicle Management
GET     /api/vehicles
POST    /api/vehicles
PUT     /api/vehicles/{vehicleId}
DELETE  /api/vehicles/{vehicleId}

# Shipment Management
GET     /api/shipments
GET     /api/shipments/{shipmentId}
POST    /api/shipments
POST    /api/shipments/{shipmentId}/cargos
DELETE  /api/shipments/{shipmentId}/cargos
POST    /api/shipments/{shipmentId}/status

# Activity Logs
GET     /api/admin/logs

# Finance
GET     /api/admin/finance/summary

# Branch Management (CRUD extensions)
POST    /api/branches
PUT     /api/branches/{branchId}
DELETE  /api/branches/{branchId}

# Cargo Dimensions
POST    /api/cargos/{cargoId}/record-dimensions
```

---

## Frontend Changes Summary

### Шинэ хуудсууд:
1. **Admin Vehicles Page** - Машинуудын удирдлага
2. **Admin Shipments Page** - Ачилтуудын удирдлага
3. **Admin Logs Page** - Үйлдлийн түүх
4. **Admin Finance Page** - Санхүүгийн тойм
5. **Admin Branches Page** - Салбарын удирдлага

### Шинэ моделиуд:
- `Vehicle` - Машины модел
- `Shipment` - Ачилтын модел
- `AdminActivityLog` - Үйлдлийн түүхийн модел
- `FinanceSummary` - Санхүүгийн тоймын модел
- `DailyRevenue` - Өдөр тутмын орлогын модел
- `PricingCalculation` - Үнийн тооцоолол

### Шинэ providers:
- `adminVehiclesProvider` - Машинуудын state
- `adminShipmentsProvider` - Ачилтуудын state
- `adminLogsProvider` - Үйлдлийн түүхийн state
- `adminFinanceProvider` - Санхүүгийн state
- `adminBranchesProvider` - Салбаруудын state

---

## Notes for Backend Team

1. **Authorization**: Бүх `/api/admin/*` endpoints болон `/api/vehicles`, `/api/shipments` endpoints нь зөвхөн admin role-тай хэрэглэгчид хандах ёстой.

2. **Activity Logging**: Бүх admin үйлдлүүд (cargo receive, ship, arrive, user ban/unban, etc.) автоматаар activity log-д бичигдэх ёстой.

3. **Status Transitions**: Shipment status transitions нь дарааллаар явагдах ёстой (DRAFT -> DEPARTED -> IN_TRANSIT -> ARRIVED -> COMPLETED).

4. **Cascade Effects**:
   - Vehicle устгахад тухайн vehicle-тэй холбоотой active shipment байвал устгахыг зөвшөөрөхгүй байх
   - Shipment status өөрчлөгдөхөд дотор нь байгаа cargo-уудын status-ыг шинэчлэх (жишээ: DEPARTED болоход cargo-ууд "shipped" болох)

5. **Finance Calculations**:
   - `avg_price_per_kg` болон `avg_price_per_cbm` нь тухайн хугацааны дундаж үнийг тооцоолох
   - `daily_revenues` нь сүүлийн 30 хоногийн өдөр тутмын орлогыг буцаах (эсвэл startDate/endDate параметрээр)
