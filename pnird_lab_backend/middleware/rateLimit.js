const windowHits = new Map();

function getClientKey(req) {
  const forwardedFor = req.headers["x-forwarded-for"];
  if (typeof forwardedFor === "string" && forwardedFor.length > 0) {
    return forwardedFor.split(",")[0].trim();
  }

  return req.ip || req.connection?.remoteAddress || "unknown";
}

function createRateLimiter({ windowMs, max, message }) {
  return (req, res, next) => {
    const now = Date.now();
    const key = `${getClientKey(req)}:${req.baseUrl || ""}:${req.path || ""}`;

    const record = windowHits.get(key) || { count: 0, resetAt: now + windowMs };
    if (now > record.resetAt) {
      record.count = 0;
      record.resetAt = now + windowMs;
    }

    record.count += 1;
    windowHits.set(key, record);

    const retryAfterSeconds = Math.ceil((record.resetAt - now) / 1000);
    res.setHeader("X-RateLimit-Limit", String(max));
    res.setHeader("X-RateLimit-Remaining", String(Math.max(max - record.count, 0)));
    res.setHeader("X-RateLimit-Reset", String(Math.ceil(record.resetAt / 1000)));

    if (record.count > max) {
      res.setHeader("Retry-After", String(retryAfterSeconds));
      return res.status(429).json({
        message: message || "Too many requests. Please try again later.",
      });
    }

    next();
  };
}

module.exports = { createRateLimiter };
