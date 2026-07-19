<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.hospital.dao.VisitDAO" %>
<%@ page import="com.hospital.dao.DoctorDAO" %>
<%@ page import="com.hospital.dao.PrescriptionDAO" %>
<%@ page import="com.hospital.model.Visit" %>
<%@ page import="com.hospital.model.Doctor" %>
<%@ page import="com.hospital.model.Prescription" %>
<%@ page import="java.util.List" %>

<%
    String userRole = (String) session.getAttribute("role");
    if (userRole == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Integer sessionUserId = (Integer) session.getAttribute("userId");

    Visit visit = null;
    try {
        String visitIdParam = request.getParameter("visitId");
        if (visitIdParam != null && !visitIdParam.isBlank()) {
            visit = new VisitDAO().findById(Integer.parseInt(visitIdParam));
        } else if ("PATIENT".equalsIgnoreCase(userRole)) {
            visit = new VisitDAO().findActiveVisitForPatient(sessionUserId);
        }
    } catch (Exception e) {
        visit = null;
    }

    // A patient may only ever see their own visit.
    if (visit != null && "PATIENT".equalsIgnoreCase(userRole) && visit.getPatientId() != sessionUserId) {
        visit = null;
    }

    if (visit == null) {
        response.sendRedirect("PATIENT".equalsIgnoreCase(userRole) ? "patient.jsp" : userRole.toLowerCase() + ".jsp");
        return;
    }

    boolean isReceptionist = "RECEPTIONIST".equalsIgnoreCase(userRole);
    boolean isDoctor       = "DOCTOR".equalsIgnoreCase(userRole);
    boolean isLab          = "LAB".equalsIgnoreCase(userRole);
    boolean isPharmacy     = "PHARMACY".equalsIgnoreCase(userRole);

    // Whether THIS role can act on THIS visit right now (role + correct stage + ownership where relevant).
    boolean canActReception = isReceptionist && "REGISTRATION".equals(visit.getStatus()) && visit.getAssignedDoctorId() == null;
    boolean canActDoctor    = isDoctor && "DOCTOR".equals(visit.getStatus())
            && visit.getAssignedDoctorId() != null
            && visit.getAssignedDoctorId().equals(sessionUserId);
    boolean canActLab       = isLab && "LAB".equals(visit.getStatus());
    boolean canActPharmacy  = isPharmacy && "PHARMACY".equals(visit.getStatus());

    Doctor assignedDoctor = null;
    List<Doctor> doctorList = null;
    try {
        if (visit.getAssignedDoctorId() != null) {
            assignedDoctor = new DoctorDAO().findById(visit.getAssignedDoctorId());
        }
        if (canActReception) {
            doctorList = new DoctorDAO().findAll();
        }
    } catch (Exception e) {
        // leave null, page still renders
    }

    String lockBadge = "inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full bg-slate-900/10 text-slate-700 whitespace-nowrap";
    String backHref = "PATIENT".equalsIgnoreCase(userRole) ? "patient.jsp" : userRole.toLowerCase() + ".jsp";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EMR · <%= visit.getVisitNumber() %> · Bharatpur Hospital</title>
    <link rel="stylesheet" href="../css/output.css">
</head>

<body class="min-h-screen bg-linear-to-br from-cyan-50 to-emerald-100 py-8 px-4">
<div class="max-w-5xl mx-auto bg-white border border-emerald-200 rounded-2xl shadow-xl overflow-hidden">

    <header class="bg-linear-to-r from-emerald-700 to-teal-600 text-white px-6 md:px-8 py-5">
        <div class="flex flex-col md:flex-row md:justify-between md:items-start gap-4">
            <div>
                <h1 class="text-2xl md:text-3xl font-extrabold tracking-tight">BHARATPUR HOSPITAL</h1>
                <p class="text-emerald-50 text-sm md:text-base mt-1">Electronic Medical Record</p>
            </div>
            <div class="text-sm md:text-base space-y-1 md:text-right">
                <p><span class="text-emerald-100">Visit Number :</span>
                    <span class="font-semibold text-white"><%= visit.getVisitNumber() %></span></p>
                <p><span class="text-emerald-100">Date :</span>
                    <span class="font-semibold text-white"><%= visit.getVisitDate() %></span></p>
                <p><span class="text-emerald-100">Status :</span>
                    <span class="font-semibold text-white"><%= visit.getStatus() %></span></p>
            </div>
        </div>
    </header>

    <div class="p-6 space-y-5">

        <!-- 1. Registration (always read-only here — created at intake) -->
        <section class="bg-white border border-emerald-200 rounded-2xl overflow-hidden">
            <div class="bg-emerald-500 px-5 py-3">
                <h2 class="text-white text-lg font-semibold">Patient Registration</h2>
            </div>
            <div class="grid grid-cols-2 gap-4 p-5">
                <div>
                    <p class="text-sm font-semibold text-slate-500">Patient Name</p>
                    <p class="text-slate-800 font-medium"><%= visit.getPatientName() %></p>
                </div>
                <div>
                    <p class="text-sm font-semibold text-slate-500">Contact Number</p>
                    <p class="text-slate-800 font-medium"><%= visit.getContactNumber() != null ? visit.getContactNumber() : "-" %></p>
                </div>
                <div class="col-span-2">
                    <p class="text-sm font-semibold text-slate-500">Symptoms</p>
                    <p class="text-slate-800 font-medium"><%= visit.getSymptoms() != null ? visit.getSymptoms() : "-" %></p>
                </div>
            </div>
        </section>

        <!-- 2. Reception -->
        <section class="bg-white border border-emerald-200 rounded-2xl overflow-hidden <%= isReceptionist ? "ring-2 ring-emerald-500 ring-offset-2" : "" %>">
            <div class="bg-gradient-to-r from-emerald-50 to-cyan-50 border-b border-emerald-200 px-5 py-3 flex justify-between items-center">
                <h2 class="text-xl font-bold text-emerald-700">Reception</h2>
                <% if (!isReceptionist) { %><span class="<%= lockBadge %>">🔒 Receptionist Only</span><% } %>
            </div>

            <% if (canActReception) { %>
            <form action="${pageContext.request.contextPath}/reception" method="post" class="p-5 grid grid-cols-2 gap-4">
                <input type="hidden" name="visitId" value="<%= visit.getId() %>">
                <div>
                    <label class="block text-slate-700 font-semibold mb-2">Assign Doctor</label>
                    <select name="doctorId" required class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none">
                        <option value="" disabled selected>Select doctor</option>
                        <% if (doctorList != null) { for (Doctor d : doctorList) { %>
                        <option value="<%= d.getDoctorId() %>">
                            <%= d.getFullName() %><%= d.getSpecialization() != null ? " (" + d.getSpecialization() + ")" : "" %>
                        </option>
                        <% } } %>
                    </select>
                </div>
                <div>
                    <label class="block text-slate-700 font-semibold mb-2">Department</label>
                    <input type="text" name="department" required class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none">
                </div>
                <div>
                    <label class="block text-slate-700 font-semibold mb-2">Consultation Fee (Rs.)</label>
                    <input type="number" step="0.01" min="0" name="consultationFee" required class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none">
                </div>
                <div class="col-span-2 flex justify-end">
                    <button type="submit" class="bg-emerald-500 hover:bg-emerald-600 text-white font-bold px-6 py-3 rounded-xl">
                        Assign &amp; Send to Payment
                    </button>
                </div>
            </form>
            <% } else { %>
            <div class="grid grid-cols-2 gap-4 p-5">
                <div>
                    <p class="text-sm font-semibold text-slate-500">Department</p>
                    <p class="text-slate-800 font-medium"><%= visit.getDepartment() != null ? visit.getDepartment() : "Not yet assigned" %></p>
                </div>
                <div>
                    <p class="text-sm font-semibold text-slate-500">Assigned Doctor</p>
                    <p class="text-slate-800 font-medium"><%= assignedDoctor != null ? assignedDoctor.getFullName() : "Not yet assigned" %></p>
                </div>
                <div>
                    <p class="text-sm font-semibold text-slate-500">Consultation Fee</p>
                    <p class="text-slate-800 font-medium">Rs. <%= visit.getConsultationFee() != null ? visit.getConsultationFee() : "0.00" %></p>
                </div>
                <div>
                    <p class="text-sm font-semibold text-slate-500">Payment Status</p>
                    <% if (visit.getAssignedDoctorId() == null) { %>
                    <span class="text-slate-400 text-sm">-</span>
                    <% } else if (visit.isConsultationPaid()) { %>
                    <span class="inline-block px-3 py-1 text-xs font-semibold rounded-full bg-emerald-100 text-emerald-700">Paid</span>
                    <% } else { %>
                    <span class="inline-block px-3 py-1 text-xs font-semibold rounded-full bg-amber-100 text-amber-700">Awaiting patient payment</span>
                    <% } %>
                </div>
            </div>
            <% } %>
        </section>

        <!-- 3. Doctor Consultation -->
        <section class="bg-white border border-emerald-200 rounded-2xl overflow-hidden <%= isDoctor ? "ring-2 ring-emerald-500 ring-offset-2" : "" %>">
            <div class="bg-gradient-to-r from-emerald-50 to-cyan-50 border-b border-emerald-200 px-5 py-3 flex justify-between items-center">
                <h2 class="text-xl font-bold text-emerald-700">Doctor Consultation</h2>
                <% if (!isDoctor) { %><span class="<%= lockBadge %>">🔒 Doctor Only</span><% } %>
            </div>

            <% if (canActDoctor) { %>
            <form action="${pageContext.request.contextPath}/doctorConsult" method="post" class="p-5 grid grid-cols-2 gap-4">
                <input type="hidden" name="visitId" value="<%= visit.getId() %>">
                <div class="col-span-2">
                    <label class="block text-slate-700 font-semibold mb-2">Diagnosis / Notes</label>
                    <textarea name="diagnosis" rows="3" required class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none"></textarea>
                </div>
                <div>
                    <label class="block text-slate-700 font-semibold mb-2">Lab Test Name (if referring)</label>
                    <input type="text" name="labTestName" class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none">
                </div>
                <div>
                    <label class="block text-slate-700 font-semibold mb-2">Lab Fee (Rs.)</label>
                    <input type="number" step="0.01" min="0" name="labFee" class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none">
                </div>
                <div class="col-span-2 flex justify-end gap-3">
                    <button type="submit" name="action" value="lab" class="bg-cyan-500 hover:bg-cyan-600 text-white font-bold px-6 py-3 rounded-xl">
                        Send to Lab
                    </button>
                    <button type="submit" name="action" value="pharmacy" class="bg-emerald-500 hover:bg-emerald-600 text-white font-bold px-6 py-3 rounded-xl">
                        Send to Pharmacy
                    </button>
                </div>
            </form>
            <% } else if (visit.getDiagnosis() == null) { %>
            <p class="p-5 text-slate-400 text-sm">Not reached yet.</p>
            <% } else { %>
            <div class="grid grid-cols-2 gap-4 p-5">
                <div class="col-span-2">
                    <p class="text-sm font-semibold text-slate-500">Diagnosis</p>
                    <p class="text-slate-800 font-medium"><%= visit.getDiagnosis() %></p>
                </div>
                <div>
                    <p class="text-sm font-semibold text-slate-500">Lab Test Requested</p>
                    <p class="text-slate-800 font-medium"><%= visit.getLabTestName() != null ? visit.getLabTestName() : "None — sent straight to pharmacy" %></p>
                </div>
            </div>
            <% } %>
        </section>

        <!-- 4. Laboratory -->
        <% if (visit.getLabTestName() != null || canActLab) { %>
        <section class="bg-white border border-emerald-200 rounded-2xl overflow-hidden <%= isLab ? "ring-2 ring-emerald-500 ring-offset-2" : "" %>">
            <div class="bg-gradient-to-r from-emerald-50 to-cyan-50 border-b border-emerald-200 px-5 py-3 flex justify-between items-center">
                <h2 class="text-xl font-bold text-emerald-700">Laboratory</h2>
                <% if (!isLab) { %><span class="<%= lockBadge %>">🔒 Lab Only</span><% } %>
            </div>

            <% if (canActLab) { %>
            <form action="${pageContext.request.contextPath}/labResult" method="post" class="p-5 space-y-4">
                <input type="hidden" name="visitId" value="<%= visit.getId() %>">
                <div>
                    <p class="text-sm font-semibold text-slate-500 mb-1">Test</p>
                    <p class="text-slate-800 font-medium"><%= visit.getLabTestName() %> (Rs. <%= visit.getLabFee() %>)</p>
                </div>
                <div>
                    <label class="block text-slate-700 font-semibold mb-2">Result / Findings</label>
                    <textarea name="labResultText" rows="3" required class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none"></textarea>
                </div>
                <div class="flex justify-end">
                    <button type="submit" class="bg-emerald-500 hover:bg-emerald-600 text-white font-bold px-6 py-3 rounded-xl">
                        Complete &amp; Send to Payment
                    </button>
                </div>
            </form>
            <% } else { %>
            <div class="grid grid-cols-2 gap-4 p-5">
                <div>
                    <p class="text-sm font-semibold text-slate-500">Test</p>
                    <p class="text-slate-800 font-medium"><%= visit.getLabTestName() %></p>
                </div>
                <div>
                    <p class="text-sm font-semibold text-slate-500">Lab Fee</p>
                    <p class="text-slate-800 font-medium">Rs. <%= visit.getLabFee() != null ? visit.getLabFee() : "0.00" %></p>
                </div>
                <div class="col-span-2">
                    <p class="text-sm font-semibold text-slate-500">Result</p>
                    <p class="text-slate-800 font-medium"><%= visit.getLabResultText() != null ? visit.getLabResultText() : "Pending" %></p>
                </div>
                <div>
                    <p class="text-sm font-semibold text-slate-500">Payment Status</p>
                    <% if (visit.isLabPaid()) { %>
                    <span class="inline-block px-3 py-1 text-xs font-semibold rounded-full bg-emerald-100 text-emerald-700">Paid</span>
                    <% } else if (visit.getLabResultText() != null) { %>
                    <span class="inline-block px-3 py-1 text-xs font-semibold rounded-full bg-amber-100 text-amber-700">Awaiting patient payment</span>
                    <% } %>
                </div>
            </div>
            <% } %>
        </section>
        <% } %>

        <!-- 5. Pharmacy -->
        <section class="bg-white border border-emerald-200 rounded-2xl overflow-hidden <%= isPharmacy ? "ring-2 ring-emerald-500 ring-offset-2" : "" %>">
            <div class="bg-gradient-to-r from-emerald-50 to-cyan-50 border-b border-emerald-200 px-5 py-3 flex justify-between items-center">
                <h2 class="text-xl font-bold text-emerald-700">Pharmacy</h2>
                <% if (!isPharmacy) { %><span class="<%= lockBadge %>">🔒 Pharmacy Only</span><% } %>
            </div>

            <% if (canActPharmacy) { %>
            <form action="${pageContext.request.contextPath}/pharmacyDispense" method="post" class="p-5 space-y-4">
                <input type="hidden" name="visitId" value="<%= visit.getId() %>">

                <table class="w-full text-sm border border-emerald-200 rounded-xl overflow-hidden">
                    <thead class="bg-emerald-100 text-emerald-900">
                    <tr>
                        <th class="p-2 text-left">Medicine</th>
                        <th class="p-2 text-left">Dose</th>
                        <th class="p-2 text-center">Morning</th>
                        <th class="p-2 text-center">Afternoon</th>
                        <th class="p-2 text-center">Evening</th>
                        <th class="p-2 text-left">Days</th>
                        <th class="p-2"></th>
                    </tr>
                    </thead>
                    <tbody id="medicineBody">
                    <tr id="noMedicineRow">
                        <td colspan="7" class="p-5 text-center text-slate-400">No medicine added</td>
                    </tr>
                    </tbody>
                </table>

                <button type="button" id="addMedicineBtn"
                        class="border-2 border-emerald-300 text-emerald-700 font-semibold px-4 py-2 rounded-xl hover:bg-emerald-50">
                    + Add Medicine
                </button>

                <div>
                    <label class="block text-slate-700 font-semibold mb-2">Total Cost (Rs.)</label>
                    <input type="number" step="0.01" min="0" name="totalCost" required
                           class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none">
                </div>

                <div class="flex justify-end">
                    <button type="submit" class="bg-emerald-500 hover:bg-emerald-600 text-white font-bold px-6 py-3 rounded-xl">
                        Dispense &amp; Send to Payment
                    </button>
                </div>
            </form>
            <script src="../js/patientVisit.js"></script>
            <% } else if (visit.getPharmacyTotalCost() == null) { %>
            <p class="p-5 text-slate-400 text-sm">Not reached yet.</p>
            <% } else {
                List<Prescription> prescriptions = null;
                try {
                    prescriptions = new PrescriptionDAO().findByVisitId(visit.getId());
                } catch (Exception e) { /* leave null, section still renders */ }
            %>
            <div class="p-5 space-y-4">
                <% if (prescriptions != null && !prescriptions.isEmpty()) { %>
                <table class="w-full text-sm border border-emerald-200 rounded-xl overflow-hidden">
                    <thead class="bg-emerald-100 text-emerald-900">
                    <tr>
                        <th class="p-2 text-left">Medicine</th>
                        <th class="p-2 text-left">Dose</th>
                        <th class="p-2 text-center">M</th>
                        <th class="p-2 text-center">A</th>
                        <th class="p-2 text-center">E</th>
                        <th class="p-2 text-left">Days</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Prescription p : prescriptions) { %>
                    <tr class="border-t border-emerald-100">
                        <td class="p-2"><%= p.getMedicineName() %></td>
                        <td class="p-2"><%= p.getDose() %></td>
                        <td class="p-2 text-center"><%= p.isMorning() ? "✓" : "" %></td>
                        <td class="p-2 text-center"><%= p.isAfternoon() ? "✓" : "" %></td>
                        <td class="p-2 text-center"><%= p.isEvening() ? "✓" : "" %></td>
                        <td class="p-2"><%= p.getDays() %></td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } %>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm font-semibold text-slate-500">Total Cost</p>
                        <p class="text-slate-800 font-medium">Rs. <%= visit.getPharmacyTotalCost() %></p>
                    </div>
                    <div>
                        <p class="text-sm font-semibold text-slate-500">Payment Status</p>
                        <% if (visit.isMedicinePaid()) { %>
                        <span class="inline-block px-3 py-1 text-xs font-semibold rounded-full bg-emerald-100 text-emerald-700">Paid</span>
                        <% } else { %>
                        <span class="inline-block px-3 py-1 text-xs font-semibold rounded-full bg-amber-100 text-amber-700">Awaiting patient payment</span>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } %>
        </section>
    </div>

    <div class="px-6 py-5 bg-slate-50 border-t border-emerald-100 flex justify-end">
        <a href="<%= backHref %>" class="border-2 border-emerald-300 text-emerald-700 font-semibold px-5 py-2.5 rounded-xl hover:bg-emerald-50 transition">
            Back to Dashboard
        </a>
    </div>
</div>
</body>
</html>