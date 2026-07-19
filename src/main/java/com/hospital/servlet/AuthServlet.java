package com.hospital.servlet;

import com.hospital.dao.*;
import com.hospital.model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/auth")
public class AuthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if ("logout".equals(request.getParameter("action"))) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/Pages/login.jsp");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/Pages/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (!"login".equals(action)) {
            response.sendRedirect(request.getContextPath() + "/Pages/login.jsp");
            return;
        }

        String role = request.getParameter("role");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String contextPath = request.getContextPath();

        if (role == null || username == null || password == null
                || role.isBlank() || username.isBlank() || password.isBlank()) {
            response.sendRedirect(contextPath + "/Pages/login.jsp?error=invalid");
            return;
        }

        try {
            boolean authenticated = authenticate(request, role.trim().toUpperCase(), username.trim(), password);
            if (authenticated) {
                response.sendRedirect(contextPath + dashboardForRole(role.trim().toUpperCase()));
            } else {
                response.sendRedirect(contextPath + "/Pages/login.jsp?error=invalid");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(contextPath + "/Pages/login.jsp?error=invalid");
        }
    }

    private boolean authenticate(HttpServletRequest request, String role, String username, String password)
            throws SQLException {

        HttpSession session = request.getSession(true);

        switch (role) {
            case "PATIENT" -> {
                Patient patient = new PatientDAO().findByUsername(username);
                if (patient == null || !password.equals(patient.getPassword())) return false;
                session.setAttribute("role", "PATIENT");
                session.setAttribute("userId", patient.getPatientId());
                session.setAttribute("fullName", patient.getFirstName() + " " + patient.getLastName());
                session.setAttribute("phoneNumber", patient.getPhoneNumber());
                return true;
            }
            case "DOCTOR" -> {
                Doctor doctor = new DoctorDAO().findByUsername(username);
                if (doctor == null || !password.equals(doctor.getPassword())) return false;
                session.setAttribute("role", "DOCTOR");
                session.setAttribute("userId", doctor.getDoctorId());
                session.setAttribute("fullName", doctor.getFullName());
                return true;
            }
            case "RECEPTIONIST" -> {
                Receptionist receptionist = new ReceptionistDAO().findByUsername(username);
                if (receptionist == null || !password.equals(receptionist.getPassword())) return false;
                session.setAttribute("role", "RECEPTIONIST");
                session.setAttribute("userId", receptionist.getReceptionistId());
                session.setAttribute("fullName", receptionist.getFullName());
                return true;
            }
            case "LAB" -> {
                LabStaff labStaff = new LabStaffDAO().findByUsername(username);
                if (labStaff == null || !password.equals(labStaff.getPassword())) return false;
                session.setAttribute("role", "LAB");
                session.setAttribute("userId", labStaff.getLabId());
                session.setAttribute("fullName", labStaff.getFullName());
                return true;
            }
            case "PHARMACY" -> {
                Pharmacist pharmacist = new PharmacistDAO().findByUsername(username);
                if (pharmacist == null || !password.equals(pharmacist.getPassword())) return false;
                session.setAttribute("role", "PHARMACY");
                session.setAttribute("userId", pharmacist.getPharmacistId());
                session.setAttribute("fullName", pharmacist.getFullName());
                return true;
            }
            default -> {
                return false;
            }
        }
    }

    private String dashboardForRole(String role) {
        return switch (role) {
            case "PATIENT" -> "/Pages/patient.jsp";
            case "DOCTOR" -> "/Pages/doctor.jsp";
            case "RECEPTIONIST" -> "/Pages/reception.jsp";
            case "LAB" -> "/Pages/lab.jsp";
            case "PHARMACY" -> "/Pages/pharmacy.jsp";
            default -> "/Pages/login.jsp";
        };
    }
}
