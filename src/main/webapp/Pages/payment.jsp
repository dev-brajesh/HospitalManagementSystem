<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.hospital.dao.VisitDAO" %>
<%@ page import="com.hospital.dao.DoctorDAO" %>
<%@ page import="com.hospital.model.Visit" %>
<%@ page import="com.hospital.model.Doctor" %>
<%@ page import="java.math.BigDecimal" %>

<%
  String userRole = (String) session.getAttribute("role");
  if (userRole == null || !"PATIENT".equalsIgnoreCase(userRole)) {
    response.sendRedirect("login.jsp");
    return;
  }
  Integer patientId = (Integer) session.getAttribute("userId");

  int visitId = Integer.parseInt(request.getParameter("visitId"));
  String feeType = request.getParameter("feeType"); // consultation | lab | medicine

  VisitDAO visitDAO = new VisitDAO();
  Visit visit = visitDAO.findById(visitId);

  if (visit == null || visit.getPatientId() != patientId) {
    response.sendRedirect("patient.jsp");
    return;
  }

  // Dynamic content per fee type
  String pageTitle;
  BigDecimal amount;
  String[][] detailRows; // {label, value}

  if ("consultation".equals(feeType)) {
    Doctor doctor = visit.getAssignedDoctorId() != null
            ? new DoctorDAO().findById(visit.getAssignedDoctorId()) : null;
    pageTitle = "Consultation Fee";
    amount = visit.getConsultationFee();
    detailRows = new String[][] {
            { "Doctor", doctor != null ? doctor.getFullName() : "-" },
            { "Department", visit.getDepartment() != null ? visit.getDepartment() : "-" },
            { "Visit No.", visit.getVisitNumber() }
    };
  } else if ("lab".equals(feeType)) {
    pageTitle = "Laboratory Fee";
    amount = visit.getLabFee();
    detailRows = new String[][] {
            { "Test", visit.getLabTestName() != null ? visit.getLabTestName() : "-" },
            { "Visit No.", visit.getVisitNumber() }
    };
  } else if ("medicine".equals(feeType)) {
    pageTitle = "Pharmacy Bill";
    amount = visit.getPharmacyTotalCost();
    detailRows = new String[][] {
            { "Diagnosis", visit.getDiagnosis() != null ? visit.getDiagnosis() : "-" },
            { "Visit No.", visit.getVisitNumber() }
    };
  } else {
    response.sendRedirect("patient.jsp");
    return;
  }
  if (amount == null) amount = BigDecimal.ZERO;
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= pageTitle %> · Bharatpur Hospital</title>
  <link rel="stylesheet" href="../css/output.css">
</head>
<body class="min-h-screen bg-linear-to-br from-cyan-50 to-emerald-100 py-8 px-4">
<div class="max-w-md mx-auto">

  <div class="bg-white border border-emerald-200 rounded-2xl shadow-xl overflow-hidden">
    <div class="bg-linear-to-r from-emerald-700 to-teal-600 text-white px-6 py-5">
      <h1 class="text-xl font-extrabold tracking-tight">BHARATPUR HOSPITAL</h1>
      <p class="text-emerald-50 text-sm mt-1">Payment Portal</p>
    </div>

    <div class="p-6">
      <h2 class="text-lg font-bold text-slate-700 mb-4"><%= pageTitle %></h2>

      <div class="space-y-2 mb-5">
        <% for (String[] row : detailRows) { %>
        <div class="flex justify-between text-sm">
          <span class="text-slate-500"><%= row[0] %></span>
          <span class="text-slate-800 font-medium"><%= row[1] %></span>
        </div>
        <% } %>
      </div>

      <div class="bg-emerald-50 border border-emerald-200 rounded-xl p-4 mb-6 flex justify-between items-center">
        <span class="text-slate-600 font-semibold">Amount Due</span>
        <span class="text-2xl font-extrabold text-emerald-700">Rs. <%= amount %></span>
      </div>

      <form action="${pageContext.request.contextPath}/payFee" method="post">
        <input type="hidden" name="visitId" value="<%= visit.getId() %>">
        <input type="hidden" name="feeType" value="<%= feeType %>">
        <button type="submit"
                class="w-full bg-emerald-500 hover:bg-emerald-600 active:scale-95 transition text-white font-bold px-8 py-3 rounded-xl">
          Pay Now
        </button>
      </form>

      <a href="patient.jsp" class="block text-center text-xs text-slate-400 mt-4 hover:text-slate-600">
        Cancel and go back
      </a>
    </div>
  </div>
</div>
</body>
</html>