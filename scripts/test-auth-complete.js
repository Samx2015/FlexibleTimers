"use strict";

var assert = require("assert");
var completion = require("../assets/flexible-timers/auth-complete.js");

assert.strictEqual(
  completion.buildReturnURL(
    "https://xintechllc.com/XTimers/auth/complete.html?code=one%2Btime",
    "xtimers-auth://auth/callback"
  ),
  "xtimers-auth://auth/callback?code=one%2Btime"
);

assert.strictEqual(
  completion.buildReturnURL(
    "https://xintechllc.com/XTimers/auth/complete-pro.html?error=access_denied&error_description=Cancelled",
    "xtimers-pro-auth://auth/callback"
  ),
  "xtimers-pro-auth://auth/callback?error=access_denied&error_description=Cancelled"
);

assert.strictEqual(
  completion.buildReturnURL(
    "https://xintechllc.com/XTimers/auth/complete.html#access_token=legacy",
    "xtimers-auth://auth/callback"
  ),
  "xtimers-auth://auth/callback#access_token=legacy"
);

assert.strictEqual(
  completion.buildReturnURL(
    "https://xintechllc.com/XTimers/auth/complete.html",
    "xtimers-auth://auth/callback"
  ),
  null
);

assert.strictEqual(
  completion.buildReturnURL(
    "https://xintechllc.com/XTimers/auth/complete.html?code=redacted",
    "malicious-app://steal/callback"
  ),
  null
);

console.log("OAuth completion page routing checks passed.");
