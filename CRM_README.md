# Invoice Processor CRM

AI-Powered Customer Relationship Management System for Real Estate Property Management

## Project Info

- **Repository**: invoice-processor-po-crm
- **Base Project**: InvoiceFlow (Invoice & PO Management)
- **New Features**: Residents, Leads, Maintenance Requests, AI Communication
- **Branch Strategy**: 
  - `main` - Production ready code
  - `develop` - Active development (work here!)

## Status

🚧 Under Development - Phase 1

### Implementation Phases

- [x] Phase 0: Project setup and new repository
- [ ] Phase 1: Database schema and migrations
- [ ] Phase 2: Backend operations
- [ ] Phase 3: Frontend pages
- [ ] Phase 4: Twilio integration
- [ ] Phase 5: AI agent

## Quick Start
```bash
# Install dependencies
npm install

# Run database migrations
wasp db migrate-dev

# Start development server
wasp start
```

## Environment Variables Required

See `.env.server.example` for required variables.

## Development Workflow

1. Work on `develop` branch
2. Commit frequently with clear messages
3. When ready for production, merge to `main`

---

**Last Updated**: $(date +%Y-%m-%d)
**Current Branch**: develop
