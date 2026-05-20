// MongoDB initialization script for TF-SDK API
// Creates collections and indexes for API usage, metrics, and developer portal

// ── Operational collections ────────────────────────────────────────────────
db.createCollection('api_usage_logs');
db.createCollection('api_metrics_hourly');
db.createCollection('qod_sessions');
db.createCollection('traffic_influence_subscriptions');
db.createCollection('location_queries');
db.createCollection('device_status_queries');
db.createCollection('number_verification_checks');
db.createCollection('sim_swap_checks');
db.createCollection('ue_profiles');

db.api_usage_logs.createIndex({ timestamp: -1 });
db.api_metrics_hourly.createIndex({ hour: -1 });
db.qod_sessions.createIndex({ timestamp: -1 });
db.traffic_influence_subscriptions.createIndex({ timestamp: -1 });
db.location_queries.createIndex({ timestamp: -1 });
db.device_status_queries.createIndex({ timestamp: -1 });
db.number_verification_checks.createIndex({ timestamp: -1 });
db.sim_swap_checks.createIndex({ timestamp: -1 });
db.ue_profiles.createIndex({ timestamp: -1 });

// ── Developer portal collections ───────────────────────────────────────────

// invokers: one document per registered application
// approval_status: pending | approved | rejected | suspended
db.createCollection('invokers');
db.invokers.createIndex({ invoker_id: 1 }, { unique: true });
db.invokers.createIndex({ approval_status: 1 });
db.invokers.createIndex({ submitted_at: -1 });
db.invokers.createIndex({ 'submitted_by.email': 1 });

// api_subscriptions: which invoker requested which CAMARA API
// status: pending | approved | rejected | revoked
db.createCollection('api_subscriptions');
db.api_subscriptions.createIndex({ invoker_id: 1, api_name: 1 }, { unique: true });
db.api_subscriptions.createIndex({ status: 1 });
db.api_subscriptions.createIndex({ submitted_at: -1 });

// audit_logs: immutable record of every governance action
db.createCollection('audit_logs');
db.audit_logs.createIndex({ timestamp: -1 });
db.audit_logs.createIndex({ invoker_id: 1, timestamp: -1 });
db.audit_logs.createIndex({ action: 1, timestamp: -1 });

print('MongoDB collections and indexes created for TF-SDK API and developer portal');
