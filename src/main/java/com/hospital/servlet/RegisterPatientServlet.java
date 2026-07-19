package com.hospital.servlet;

import com.hospital.dao.PatientDAO;
import com.hospital.model.Patient;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/registerPatient")
public class RegisterPatientServlet extends HttpServlet {

    private final PatientDAO patientDAO = new PatientDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        Patient patient = new Patient();
        patient.setFirstName(request.getParameter("firstName"));
        patient.setLastName(request.getParameter("lastName"));
        patient.setDateOfBirth(request.getParameter("dateOfBirth"));
        patient.setGender(request.getParameter("gender"));
        patient.setBloodGroup(request.getParameter("bloodGroup"));
        patient.setPhoneNumber(request.getParameter("phoneNumber"));
        patient.setEmail(request.getParameter("email"));
        patient.setAddress(request.getParameter("address"));
        patient.setEmergencyContactNumber(request.getParameter("emergencyContactNumber"));
        patient.setUsername(request.getParameter("username"));
        patient.setPassword(request.getParameter("password"));

        System.out.println("[RegisterPatientServlet] Raw submitted username='" + patient.getUsername()
                + "' email='" + patient.getEmail() + "'");

        String validationError = validate(patient);
        if (validationError != null) {
            System.out.println("[RegisterPatientServlet] Validation failed: " + validationError);
            request.setAttribute("errorMessage", validationError);
            request.getRequestDispatcher("/Pages/patientRegistration.jsp").forward(request, response);
            return;
        }

        try {
            if (patientDAO.usernameOrEmailExists(patient.getUsername(), patient.getEmail())) {
                System.out.println("[RegisterPatientServlet] Duplicate check returned TRUE — blocking registration");
                request.setAttribute("errorMessage",
                        "That username or email is already registered. Please choose another.");
                request.getRequestDispatcher("/Pages/patientRegistration.jsp").forward(request, response);
                return;
            }

            boolean inserted = patientDAO.insertPatient(patient);
            System.out.println("[RegisterPatientServlet] insertPatient returned: " + inserted);

            if (inserted) {
                response.sendRedirect(request.getContextPath() + "/Pages/login.jsp?role=patient&registered=true");
            } else {
                request.setAttribute("errorMessage", "Registration failed. Please try again.");
                request.getRequestDispatcher("/Pages/patientRegistration.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage",
                    "Something went wrong while saving your registration. Please try again.");
            request.getRequestDispatcher("/Pages/patientRegistration.jsp").forward(request, response);
        }
    }

    private String validate(Patient p) {
        if (isBlank(p.getFirstName())) return "First name is required.";
        if (isBlank(p.getLastName())) return "Last name is required.";
        if (isBlank(p.getDateOfBirth())) return "Date of birth is required.";
        if (isBlank(p.getGender())) return "Gender is required.";
        if (isBlank(p.getPhoneNumber())) return "Phone number is required.";
        if (isBlank(p.getEmail()) || !p.getEmail().contains("@")) return "A valid email is required.";
        if (isBlank(p.getUsername())) return "Username is required.";
        if (isBlank(p.getPassword()) || p.getPassword().length() < 6)
            return "Password must be at least 6 characters.";
        return null;
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}