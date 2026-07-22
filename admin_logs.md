11. Admin — Appointment Metadata View (website, HTML/JS)

Admin operates through a separate website interface (HTML + JavaScript), not the mobile app. This section covers a new admin page for viewing specialist consultation appointments. Scope is intentionally limited to metadata — do not expose consultation content. Finalized field breakdown below (specialist side only; volunteer side is Section 12.2).

11.1 List view (default page)

FieldNotesAppointment IDPatient NameDoctor's NameDateStatusPending, Approved, Cancelled, Expired, Completed

Booking flow implied by this status set: patient requests a slot (Pending) → specialist accepts (Approved) or the request times out unanswered (Expired) → appointment occurs (Completed) or is called off (Cancelled).

11.2 Detail view ("View Detail")

FieldNotesAppointment IDPatient Namerenamed from "Name" for consistency with list viewDoctor's NameDateTimePlatforme.g. Zoom, in-personStatussame enum as 11.1Logged attimestamp of the patient's initial consultation requestCancellation Reasonshown only when Status = Cancelled; patient must provide a reason before cancelling, which frees the slot back to the specialist. Stored as free text (MVP default — can move to a preset-reason lookup table later if patterns emerge worth standardizing)

11.3 What admin cannot view (deferred, not built yet)


Zoom meeting transcript or recording content
Any clinical notes or chat content tied to the appointment


This is explicitly deferred pending confirmation of Zoom plan support (transcripts require a paid Business/Enterprise tier with cloud recording enabled) and a compliance decision on access rules. When built, transcript/content access should NOT be standing admin access — it should be an exception-based, logged action (reason required, tied to a dispute/complaint reference), similar in spirit to the emergency pending flow in the Specialist review system. Do not build this now; only build the metadata views described in 11.1/11.2.

11.4 Implementation notes


This is a website page (HTML/JS), separate codebase/context from the Flutter mobile app — do not assume shared UI components with dashboard_screen.dart or other mobile files.
Backend query for both list and detail views should explicitly select only the metadata fields listed above — do not return full appointment objects if the underlying API/database model includes content fields, to avoid accidentally leaking content via an overly broad API response even if the UI doesn't render it.
Cancellation flow (patient-initiated): patient submits a required reason → appointment status changes to Cancelled → slot is freed and becomes available to the specialist again.
Reschedule is not yet implemented — do not build reschedule-related fields or history for MVP.



12. Admin — Oversight (Logs)

New nav divider on the admin website titled "OVERSIGHT", placed after the top management group (Dashboard, Users, Manage Specialists, Manage Volunteers) and before "PAGE CONTENT." Contains two separate pages — Specialist Logs and Volunteer Logs — kept apart because the underlying data shapes differ (appointment-based vs. chat-session-based), mirroring the same Specialist/Volunteer separation used throughout this spec. Do not merge them into a single page with a dynamic filter.

12.1 Specialist Logs (page 1)

This page uses the exact list view / detail view breakdown defined in Section 11.1 / 11.2 — it is the same page, just reached via the "OVERSIGHT" nav rather than described twice. Do not build a second, differently-shaped view.

Filter: dropdown (top right) to filter by Status (Pending, Approved, Cancelled, Expired, Completed).

Explicitly out of scope (same deferral as Section 11.3): Zoom transcript/recording content, clinical notes. Do not build content access here.

12.2 Volunteer Logs (page 2)

Records every chat session between a volunteer and a user. Separate page from Specialist Logs due to differing data shape — no slot type, no payment/booking status, no "appointment" concept. Field breakdown below is provisional and should be revisited to mirror the same list/detail split once the volunteer chat data model is finalized.

Fields shown (list view):


Session ID
Volunteer name/ID
User name/ID (or anonymized identifier, depending on privacy design — confirm before build)
Date
Status (active, completed)


Detail view (provisional — confirm before build):


Session ID, Volunteer name/ID, User name/ID, Date, Time, Expertise tag(s) relevant to the session, Status, Logged at


Filter: dropdown (top right) to filter by expertise tag, date range, or specific volunteer.

Explicitly out of scope: actual chat message content. Metadata only, same permission-gated model as Specialist Logs — standing access to session metadata, exception-based/logged access only if content access is ever built later.

12.3 Backend rule

Both log pages must query metadata-only fields explicitly (do not return full session/appointment objects if the underlying model includes content fields), consistent with the rule already established in Section 11.3.