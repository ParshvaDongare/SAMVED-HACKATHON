# Solapur Smart Roads (SSR)

Welcome to the **Solapur Smart Roads** (SSR) repository. 
This project comprises a comprehensive system for managing road repairs, complaints, and ticket assignments involving a Flutter mobile app for field workers and a Web Dashboard for administrative roles, integrating AI services for automated damage detection and assessment.

## Project Structure

- **`/mobile`** & **`/Flutter UI`**: The Flutter mobile application tailored for field operators (`citizen`, `je`, `mukadam`, `contractor`). Includes location tracking, camera reports, and job order executions.
- **`/web-dashboard`** & **`/WebD UI`**: The web-based React/Next.js dashboard meant for administrative, engineering, and oversight roles such as `ae`, `de`, `ee`, `commissioner`, etc.
- **`/ai-service`**: AI integration to process uploaded images for damage detection, severity tiering, and calculating SSIM (Structural Similarity Index) scores.
- **`/services`** & **`/supabase`**: Real-time database schema, backend services, and APIs to route role-based actions and handle ticket data models.

## Architecture & Role Model
The system enforces strict real-world role divisions:
1. **Citizens**: Report potholes and damages from the app.
2. **Junior Engineers (JE)**: Geofence check-ins, measure damages, and assign work to internal work gangs (Mukadams) or Private Contractors.
3. **Execution (Mukadam/Contractor)**: Fulfill job orders, capture execution proof (app uses AI verification), and request auditing.
4. **Administration**: Analyze progress, dashboards, and automated billing through the web application.

## Development

Currently there are specific implementations plans available directly in the markdown documents located in the root directory:
- `implementation_plan.md` (Flutter App details)
- `implementation_plan_web_dashboard.md` (Web Dashboard layout details)
- `FLUTTER_APP_SPEC.md`
- `Dashboards Plan.md`
- `Web Dashboards.md`

### Getting Started

Read through the specific plans and setup processes in the core service directories (`/web-dashboard`, `/mobile`, etc.) for building and running each component.
