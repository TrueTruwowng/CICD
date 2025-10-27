# Deployment with H2 Database

## Quick Start (No MySQL Required!)

The application now uses **H2 in-memory database** instead of MySQL. This means:

✅ **No MySQL deployment needed**
✅ **Faster startup** (no waiting for database)
✅ **Simpler configuration** (no database credentials)
✅ **Zero external dependencies**

## Deploy Application

```cmd
scripts\deploy-h2.cmd
```

This will:
1. Build Maven package with H2 configuration
2. Build Docker image
3. Deploy to Kubernetes
4. Show live logs

## Access Application

**After deployment completes:**

```cmd
# Option 1: Use port 8081 (recommended)
kubectl port-forward svc/my-sso 8081:8080
```
Open: http://localhost:8081

```cmd
# Option 2: Use custom port
scripts\access-app-alt-port.cmd
```

## H2 Console (Database Admin)

Access H2 database console at:
- URL: http://localhost:8081/h2-console
- JDBC URL: `jdbc:h2:mem:testdb`
- Username: `sa`
- Password: (leave empty)

## Notes

- **Data is not persistent** - All data is lost when pod restarts (in-memory database)
- **Perfect for development/testing** - No need to manage external database
- **For production**, consider switching back to MySQL/PostgreSQL with persistent volume

## Advantages of H2

1. **Instant startup** - No database initialization time
2. **No configuration** - Works out of the box
3. **Lightweight** - Uses less memory
4. **Self-contained** - Everything in one pod

## Switching Back to MySQL (if needed)

If you need persistent data later:
1. Uncomment MySQL configuration in `application.yml`
2. Deploy MySQL: `kubectl apply -f k8s/mysql-*.yaml`
3. Update deployment to use MySQL env variables

---

Created: October 27, 2025

