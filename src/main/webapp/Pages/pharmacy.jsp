<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.hospital.dao.VisitDAO" %>
<%@ page import="com.hospital.model.Visit" %>
<%@ page import="java.util.List" %>

<%
    String userRole = (String) session.getAttribute("role");
    if (userRole == null || !"PHARMACY".equalsIgnoreCase(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
    String pharmacistName = (String) session.getAttribute("fullName");
    if (pharmacistName == null) pharmacistName = "Pharmacy Staff";

    List<Visit> queue = null;
    try {
        queue = new VisitDAO().findVisitsByStatus("PHARMACY");
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pharmacy Dashboard</title>
    <link rel="stylesheet" href="../css/output.css">
</head>
<body class="min-h-screen bg-gradient-to-br from-cyan-50 to-emerald-100 py-8 px-4">
<div class="max-w-5xl mx-auto">

    <header class="bg-linear-to-r from-emerald-700 to-teal-600 text-white px-6 md:px-8 py-5 rounded-2xl shadow-xl">
        <div class="flex flex-col md:flex-row md:justify-between md:items-center gap-4">
            <div>
                <h1 class="text-3xl font-extrabold tracking-tight">BHARATPUR HOSPITAL</h1>
                <p class="text-emerald-100 mt-1">Electronic Medical Record</p>
            </div>
            <div class="text-left md:text-right">
                <h2 class="text-2xl font-bold">Pharmacy Dashboard</h2>
                <p class="text-emerald-100">Welcome, <%= pharmacistName %></p>
                <a href="${pageContext.request.contextPath}/auth?action=logout"
                   class="inline-block mt-1 text-xs font-semibold text-white/90 hover:text-white underline underline-offset-2">
                    Logout
                </a>
            </div>
        </div>
    </header>

    <div class="h-6"></div>

    <div class="bg-white rounded-2xl shadow-xl border border-emerald-200 overflow-hidden">
        <div class="bg-emerald-500 text-white px-6 py-4">
            <h2 class="text-xl font-bold">Pharmacy Queue</h2>
            <p class="text-emerald-100 text-sm">Patients waiting to receive prescribed medicines</p>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full">
                <thead class="bg-emerald-100 text-emerald-900">
                <tr>
                    <th class="px-6 py-4 text-left">S.No</th>
                    <th class="px-6 py-4 text-left">Visit No</th>
                    <th class="px-6 py-4 text-left">Patient Name</th>
                    <th class="px-6 py-4 text-left">Diagnosis</th>
                    <th class="px-6 py-4 text-center">Action</th>
                </tr>
                </thead>
                <tbody>
                <% if (queue == null || queue.isEmpty()) { %>
                <tr><td colspan="5" class="p-6 text-center text-slate-400">No patients waiting on medicine</td></tr>
                <% } else {
                    int sno = 1;
                    for (Visit v : queue) { %>
                <tr class="border-t border-emerald-100">
                    <td class="px-6 py-4"><%= sno++ %></td>
                    <td class="px-6 py-4"><%= v.getVisitNumber() %></td>
                    <td class="px-6 py-4"><%= v.getPatientName() %></td>
                    <td class="px-6 py-4 text-slate-500 text-sm"><%= v.getDiagnosis() != null ? v.getDiagnosis() : "-" %></td>
                    <td class="px-6 py-4 text-center">
                        <a href="emr.jsp?visitId=<%= v.getId() %>"
                           class="bg-emerald-500 hover:bg-emerald-600 text-white text-sm font-semibold px-4 py-1.5 rounded-lg">
                            Open EMR
                        </a>
                    </td>
                </tr>
                <%   }
                } %>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>