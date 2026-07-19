<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.Arrays" %>

<%
    // Which role button should be active on page load. Defaults to DOCTOR,
    // but honors ?role=... so links like the post-registration redirect
    // (login.jsp?role=patient&registered=true) land on the right tab.
    HashSet<String> knownRoles = new HashSet<>(Arrays.asList(
            "DOCTOR", "PATIENT", "LAB", "RECEPTIONIST", "PHARMACY"));

    String selectedRole = request.getParameter("role");
    if (selectedRole == null || selectedRole.trim().isEmpty()) {
        selectedRole = "DOCTOR";
    } else {
        selectedRole = selectedRole.trim().toUpperCase();
    }
    if (!knownRoles.contains(selectedRole)) {
        selectedRole = "DOCTOR";
    }

    String activeClasses = "role-btn flex-1 py-2 rounded-lg bg-emerald-500 text-white font-semibold transition";
    String inactiveClasses = "role-btn flex-1 py-2 rounded-lg text-slate-600 transition";
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../css/output.css">
    <title>Hospital Login</title>
</head>

<body>

<div class="min-h-screen bg-linear-to-br from-cyan-50 to-emerald-100 flex items-center justify-center">

    <div class="w-[90%] md:w-112.5">

        <!-- Heading -->
        <h2 class="text-3xl font-bold text-slate-700 mb-4">
            Login As
        </h2>

        <% if ("invalid".equals(request.getParameter("error"))) { %>
        <div class="mb-4 bg-red-100 border border-red-300 text-red-700 px-4 py-3 rounded-xl text-sm">Invalid username or password.</div>
        <% } %>
        <% if ("role".equals(request.getParameter("error"))) { %>
        <div class="mb-4 bg-red-100 border border-red-300 text-red-700 px-4 py-3 rounded-xl text-sm">Wrong role selected for this account.</div>
        <% } %>
        <% if ("true".equals(request.getParameter("registered"))) { %>
        <div class="mb-4 bg-emerald-100 border border-emerald-300 text-emerald-800 px-4 py-3 rounded-xl text-sm">Registration successful! Please login.</div>
        <% } %>

        <!-- Main Card -->
        <div class="bg-white border border-emerald-200 rounded-2xl shadow-xl overflow-hidden">

            <!-- Roles -->
            <div class="bg-slate-100 border-b border-emerald-200 p-2">

                <div class="flex gap-2">

                    <button type="button"
                            id="doctorBtn"
                            data-role="DOCTOR"
                            class="<%= "DOCTOR".equals(selectedRole) ? activeClasses : inactiveClasses %>">
                        Doctor
                    </button>

                    <button type="button"
                            id="patientBtn"
                            data-role="PATIENT"
                            class="<%= "PATIENT".equals(selectedRole) ? activeClasses : inactiveClasses %>">
                        Patient
                    </button>

                    <button type="button"
                            id="labBtn"
                            data-role="LAB"
                            class="<%= "LAB".equals(selectedRole) ? activeClasses : inactiveClasses %>">
                        Lab
                    </button>

                    <button type="button"
                            id="receptionBtn"
                            data-role="RECEPTIONIST"
                            class="<%= "RECEPTIONIST".equals(selectedRole) ? activeClasses : inactiveClasses %>">
                        Reception
                    </button>

                    <button type="button"
                            id="pharmacistBtn"
                            data-role="PHARMACY"
                            class="<%= "PHARMACY".equals(selectedRole) ? activeClasses : inactiveClasses %>">
                        Pharmacy
                    </button>


                </div>

            </div>

            <!-- Login Form -->
            <div class="p-5">

                <form id="loginForm"
                      action="${pageContext.request.contextPath}/auth"
                      method="post"
                      class="space-y-5">

                    <input type="hidden" name="action" value="login">
                    <input type="hidden" name="role" id="role" value="<%= selectedRole %>">

                    <!-- Username -->
                    <div>

                        <label
                                for="username"
                                class="block text-slate-700 font-semibold mb-2">

                            Username

                        </label>

                        <input
                                id="username"
                                name="username"
                                type="text"
                                required
                                placeholder="Enter username"
                                class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none focus:border-emerald-500 transition">

                    </div>

                    <!-- Password -->
                    <div>

                        <label
                                for="password"
                                class="block text-slate-700 font-semibold mb-2">

                            Password

                        </label>

                        <div class="relative">

                            <input
                                    id="password"
                                    name="password"
                                    type="password"
                                    required
                                    placeholder="Enter password"
                                    class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 pr-12 outline-none focus:border-emerald-500 transition">

                            <button
                                    type="button"
                                    onclick="showPassword()"
                                    class="absolute right-4 top-1/2 -translate-y-1/2">

                                <svg
                                        id="eyeIcon"
                                        class="w-6 h-6"
                                        viewBox="0 0 24 24"
                                        fill="none"
                                        xmlns="http://www.w3.org/2000/svg">

                                    <path
                                            d="M1 12C1 12 5 4 12 4C19 4 23 12 23 12"
                                            stroke="#334155"
                                            stroke-width="2"
                                            stroke-linecap="round"
                                            stroke-linejoin="round"/>

                                    <path
                                            d="M1 12C1 12 5 20 12 20C19 20 23 12 23 12"
                                            stroke="#334155"
                                            stroke-width="2"
                                            stroke-linecap="round"
                                            stroke-linejoin="round"/>

                                    <circle
                                            cx="12"
                                            cy="12"
                                            r="3"
                                            stroke="#334155"
                                            stroke-width="2"/>

                                    <path
                                            id="slash"
                                            d="M3 3L21 21"
                                            stroke="#334155"
                                            stroke-width="2"
                                            stroke-linecap="round"/>

                                </svg>

                            </button>

                        </div>

                    </div>

                    <!-- Login -->
                    <button
                            id="loginBtn"
                            type="submit"
                            class="w-full bg-emerald-500 active:scale-95 transition text-white font-bold py-3 rounded-xl">

                        Login

                    </button>

                </form>

            </div>

        </div>

        <p class="text-center text-sm text-slate-500 mt-4">
            New patient?
            <a href="patientRegistration.jsp" class="text-emerald-600 font-semibold hover:underline">Register here</a>
        </p>

    </div>

</div>
<script src="../js/login.js"></script>
</body>
</html>