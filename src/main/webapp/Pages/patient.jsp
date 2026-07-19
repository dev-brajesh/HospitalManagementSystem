<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.hospital.dao.VisitDAO" %>
<%@ page import="com.hospital.dao.DoctorDAO" %>
<%@ page import="com.hospital.model.Visit" %>
<%@ page import="com.hospital.model.Doctor" %>

<%
    String userRole = (String) session.getAttribute("role");

    if (userRole == null || !"PATIENT".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String fullName = (String) session.getAttribute("fullName");
    if (fullName == null) fullName = "Patient";

    Integer patientId = (Integer) session.getAttribute("userId");

    VisitDAO visitDAO = new VisitDAO();
    DoctorDAO doctorDAO = new DoctorDAO();
    Visit visit = null;
    Doctor assignedDoctor = null;

    try {
        visit = visitDAO.findActiveVisitForPatient(patientId);
        if (visit != null && visit.getAssignedDoctorId() != null) {
            assignedDoctor = doctorDAO.findById(visit.getAssignedDoctorId());
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    String[] stageKeys   = { "REGISTRATION", "DOCTOR", "LAB", "PHARMACY" };
    String[] stageLabels = { "Reception", "Doctor", "Lab", "Pharmacy" };

    int currentIndex = 0;
    int patientsAhead = 0;
    int estimatedMinutes = 0;
    String currentStageLabel = "Reception";

    // Waiting for reception to even open the EMR and assign a doctor — the very first
    // state a brand-new visit sits in. Separate from "awaitingDoctorPayment" below,
    // which only applies once reception has already acted.
    boolean waitingForReception = false;

    if (visit != null) {
        String normalizedStatus = visit.getStatus();
        if ("LAB_PAYMENT".equals(normalizedStatus)) normalizedStatus = "LAB";
        if ("PHARMACY_PAYMENT".equals(normalizedStatus)) normalizedStatus = "PHARMACY";

        waitingForReception = "REGISTRATION".equals(visit.getStatus()) && visit.getAssignedDoctorId() == null;

        // Reception has effectively "accepted" the patient the moment a doctor is assigned,
        // even though the visit's DB status stays REGISTRATION until the consultation fee is
        // paid (payment is what actually flips it to DOCTOR — see VisitDAO.payFee).
        boolean awaitingDoctorPayment =
                "REGISTRATION".equals(visit.getStatus()) && visit.getAssignedDoctorId() != null;

        if (awaitingDoctorPayment) {
            normalizedStatus = "DOCTOR";
        }

        for (int i = 0; i < stageKeys.length; i++) {
            if (stageKeys[i].equals(normalizedStatus)) {
                currentIndex = i;
                break;
            }
        }

        try {
            if (awaitingDoctorPayment
                    || ("DOCTOR".equals(visit.getStatus()) && visit.getAssignedDoctorId() != null)) {
                patientsAhead = visitDAO.countPatientsAheadForDoctor(visit.getAssignedDoctorId(), visit.getId());
            } else if ("REGISTRATION".equals(visit.getStatus())
                    || "LAB".equals(visit.getStatus())
                    || "PHARMACY".equals(visit.getStatus())) {
                patientsAhead = visitDAO.countPatientsAhead(visit.getStatus(), visit.getId());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        int avgStageMinutes = 10;
        try {
            avgStageMinutes = visitDAO.getAverageStageDurationMinutes(normalizedStatus);
        } catch (Exception e) {
            e.printStackTrace();
        }
        estimatedMinutes = patientsAhead * avgStageMinutes;

        currentStageLabel = waitingForReception
                ? "Waiting for Reception"
                : awaitingDoctorPayment
                  ? "Doctor Consultation (awaiting payment)"
                  : stageLabels[currentIndex];
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Visit · Bharatpur Hospital</title>
    <link rel="stylesheet" href="../css/output.css">
</head>

<body class="min-h-screen bg-linear-to-br from-cyan-50 to-emerald-100 py-8 px-4">
<div class="max-w-3xl mx-auto space-y-5">

    <div class="bg-white border border-emerald-200 rounded-2xl shadow-xl overflow-hidden">
        <div class="bg-linear-to-r from-emerald-700 to-teal-600 text-white px-6 md:px-8 py-5 flex flex-col md:flex-row md:justify-between md:items-center gap-3">
            <div>
                <h1 class="text-2xl md:text-3xl font-extrabold tracking-tight">BHARATPUR HOSPITAL</h1>
                <p class="text-emerald-50 text-sm md:text-base mt-1">My Dashboard</p>
            </div>
            <div class="text-sm md:text-base md:text-right">
                <p><span class="text-emerald-100">Welcome,</span>
                    <span class="font-semibold text-white"><%= fullName %></span></p>
                <a href="${pageContext.request.contextPath}/auth?action=logout"
                   class="inline-block mt-2 text-xs font-semibold text-white/90 hover:text-white underline underline-offset-2">
                    Logout
                </a>
            </div>
        </div>
    </div>

    <% if (visit == null) { %>

    <div class="bg-white border border-emerald-200 rounded-2xl shadow-xl p-8 text-center">
        <h2 class="text-lg font-bold text-slate-700 mb-2">You don't have an active visit</h2>
        <p class="text-slate-500 text-sm mb-6">Tell us what's bringing you in, then check in at reception.</p>

        <form action="${pageContext.request.contextPath}/createVisit" method="post" class="max-w-md mx-auto text-left">
            <label for="symptoms" class="block text-sm font-semibold text-slate-700 mb-2">Symptoms</label>
            <textarea id="symptoms" name="symptoms" rows="3" placeholder="Describe how you're feeling..."
                      class="w-full rounded-xl border-2 border-emerald-300 px-3 py-2 outline-none focus:border-emerald-500 mb-4"></textarea>

            <button type="submit"
                    class="w-full bg-emerald-500 hover:bg-emerald-600 active:scale-95 transition text-white font-bold px-8 py-3 rounded-xl">
                Start New Visit
            </button>
        </form>
    </div>

    <% } else { %>

    <div class="bg-white border border-emerald-200 rounded-2xl shadow-xl p-6">
        <div class="flex justify-between items-center mb-6">
            <h2 class="text-lg font-bold text-slate-700">Your Visit Progress <span class="text-sm font-normal text-slate-400">(<%= visit.getVisitNumber() %>)</span></h2>
            <a href="emr.jsp?visitId=<%= visit.getId() %>"
               class="text-sm font-semibold text-emerald-600 hover:text-emerald-700 hover:underline">
                View Full EMR &rarr;
            </a>
        </div>

        <div class="flex items-center">
            <% for (int i = 0; i < stageKeys.length; i++) {
                boolean done = i < currentIndex;
                boolean active = i == currentIndex;

                String circleClasses = done
                        ? "bg-emerald-500 text-white"
                        : active
                          ? "bg-emerald-500 text-white ring-4 ring-emerald-200"
                          : "bg-slate-200 text-slate-500";

                String labelClasses = active
                        ? "text-emerald-700 font-bold"
                        : done
                          ? "text-slate-600 font-semibold"
                          : "text-slate-400";
            %>
            <div class="flex flex-col items-center flex-1">
                <div class="w-10 h-10 rounded-full flex items-center justify-center font-bold text-sm <%= circleClasses %>">
                    <%= done ? "&#10003;" : String.valueOf(i + 1) %>
                </div>
                <span class="mt-2 text-xs md:text-sm text-center <%= labelClasses %>"><%= stageLabels[i] %></span>
            </div>

            <% if (i < stageKeys.length - 1) { %>
            <div class="flex-1 h-1 mb-6 rounded <%= done ? "bg-emerald-500" : "bg-slate-200" %>"></div>
            <% } %>
            <% } %>
        </div>
    </div>

    <div class="bg-white border border-emerald-200 rounded-2xl shadow-xl overflow-hidden">
        <div class="bg-gradient-to-r from-emerald-50 to-cyan-50 border-b border-emerald-200 px-5 py-3">
            <h2 class="text-xl font-bold text-emerald-700">Current Status: <%= currentStageLabel %></h2>
        </div>

        <% if (waitingForReception) { %>
        <!-- Fresh visit, nobody at reception has opened the EMR yet — show this instead
             of jumping to blank "doctor not assigned" fields, which read as broken. -->
        <div class="p-6 flex items-start gap-4">
            <div class="w-12 h-12 rounded-full bg-amber-100 text-amber-600 flex items-center justify-center text-xl font-bold flex-shrink-0">
                &#8987;
            </div>
            <div>
                <p class="text-slate-800 font-semibold mb-1">Waiting for reception to accept your visit</p>
                <p class="text-slate-500 text-sm mb-3">
                    Your symptoms have been recorded. Please stay nearby - a receptionist will call you shortly to assign a doctor.
                </p>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm font-semibold text-slate-500">Patients Ahead of You</p>
                        <p class="text-slate-800 font-medium"><%= patientsAhead %></p>
                    </div>
                    <div>
                        <p class="text-sm font-semibold text-slate-500">Estimated Waiting Time</p>
                        <p class="text-emerald-700 font-bold text-lg"><%= estimatedMinutes %> minutes</p>
                    </div>
                </div>
            </div>
        </div>
        <% } else { %>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 p-5">
            <div>
                <p class="text-sm font-semibold text-slate-500">Assigned Doctor</p>
                <p class="text-slate-800 font-medium">
                    <%= assignedDoctor != null ? assignedDoctor.getFullName() : "Not yet assigned" %>
                </p>
            </div>
            <div>
                <p class="text-sm font-semibold text-slate-500">Department</p>
                <p class="text-slate-800 font-medium">
                    <%= assignedDoctor != null && assignedDoctor.getSpecialization() != null
                            ? assignedDoctor.getSpecialization() : "Not yet assigned" %>
                </p>
            </div>
            <div>
                <p class="text-sm font-semibold text-slate-500">Patients Ahead of You</p>
                <p class="text-slate-800 font-medium"><%= patientsAhead %></p>
            </div>
            <div>
                <p class="text-sm font-semibold text-slate-500">Estimated Waiting Time</p>
                <p class="text-emerald-700 font-bold text-lg"><%= estimatedMinutes %> minutes</p>
            </div>

            <!-- Consultation fee: shows once reception has assigned a doctor -->
            <% if (visit.getAssignedDoctorId() != null) { %>
            <div class="md:col-span-2 flex items-center justify-between bg-slate-50 rounded-xl p-3">
                <div>
                    <p class="text-sm font-semibold text-slate-500">Consultation Fee</p>
                    <p class="text-slate-800 font-medium">Rs. <%= visit.getConsultationFee() %></p>
                </div>
                <% if (visit.isConsultationPaid()) { %>
                <span class="px-3 py-1 text-xs font-semibold rounded-full bg-emerald-100 text-emerald-700">Paid</span>
                <% } else { %>
                <a href="payment.jsp?visitId=<%= visit.getId() %>&feeType=consultation"
                   class="bg-amber-500 hover:bg-amber-600 text-white text-sm font-semibold px-4 py-1.5 rounded-lg">Pay Now</a>
                <% } %>
            </div>
            <% } %>

            <!-- Lab fee: shows once lab results are in and awaiting payment -->
            <% if (visit.getLabTestName() != null && ("LAB_PAYMENT".equals(visit.getStatus()) || visit.isLabPaid())) { %>
            <div class="md:col-span-2 flex items-center justify-between bg-slate-50 rounded-xl p-3">
                <div>
                    <p class="text-sm font-semibold text-slate-500">Lab Fee (<%= visit.getLabTestName() %>)</p>
                    <p class="text-slate-800 font-medium">Rs. <%= visit.getLabFee() %></p>
                </div>
                <% if (visit.isLabPaid()) { %>
                <span class="px-3 py-1 text-xs font-semibold rounded-full bg-emerald-100 text-emerald-700">Paid</span>
                <% } else { %>
                <a href="payment.jsp?visitId=<%= visit.getId() %>&feeType=lab"
                   class="bg-amber-500 hover:bg-amber-600 text-white text-sm font-semibold px-4 py-1.5 rounded-lg">Pay Now</a>
                <% } %>
            </div>
            <% } %>

            <!-- Pharmacy bill: shows once pharmacist has entered the cost -->
            <% if (visit.getPharmacyTotalCost() != null && ("PHARMACY_PAYMENT".equals(visit.getStatus()) || visit.isMedicinePaid())) { %>
            <div class="md:col-span-2 flex items-center justify-between bg-slate-50 rounded-xl p-3">
                <div>
                    <p class="text-sm font-semibold text-slate-500">Pharmacy Bill</p>
                    <p class="text-slate-800 font-medium">Rs. <%= visit.getPharmacyTotalCost() %></p>
                </div>
                <% if (visit.isMedicinePaid()) { %>
                <span class="px-3 py-1 text-xs font-semibold rounded-full bg-emerald-100 text-emerald-700">Paid</span>
                <% } else { %>
                <a href="payment.jsp?visitId=<%= visit.getId() %>&feeType=medicine"
                   class="bg-amber-500 hover:bg-amber-600 text-white text-sm font-semibold px-4 py-1.5 rounded-lg">Pay Now</a>
                <% } %>
            </div>
            <% } %>
        </div>
        <% } %>

        <div class="px-5 pb-5">
            <p class="text-xs text-slate-400">
                This page updates as your visit moves through each stage. Please stay nearby - you'll be called when it's your turn.
            </p>
        </div>
    </div>

    <% } %>

</div>
</body>
</html>