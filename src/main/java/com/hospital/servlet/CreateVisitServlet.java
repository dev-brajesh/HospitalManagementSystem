package com.hospital.servlet;

import com.hospital.dao.VisitDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/createVisit")
public class CreateVisitServlet extends HttpServlet {

    private final VisitDAO visitDAO = new VisitDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String contextPath = request.getContextPath();

        if (session == null || !"PATIENT".equals(session.getAttribute("role"))) {
            response.sendRedirect(contextPath + "/Pages/login.jsp");
            return;
        }

        Integer patientIdObj = (Integer) session.getAttribute("userId");
        String patientName = (String) session.getAttribute("fullName");
        String contactNumber = (String) session.getAttribute("phoneNumber");
        String symptoms = request.getParameter("symptoms");

        System.out.println("[CreateVisitServlet] doPost called. patientIdObj=" + patientIdObj
                + " patientName=" + patientName + " contactNumber=" + contactNumber
                + " symptoms=" + symptoms);

        if (patientIdObj == null) {
            // Session invalid — redirect to login
            response.sendRedirect(contextPath + "/Pages/login.jsp");
            return;
        }

        int patientId = patientIdObj;
        int newVisitId = -1;
        String errorDetail = null;

        try {
            newVisitId = visitDAO.createVisit(patientId, patientName, contactNumber, symptoms);
            System.out.println("[CreateVisitServlet] createVisit returned id=" + newVisitId
                    + " for patientId=" + patientId + " symptoms='" + symptoms + "'");
        } catch (Exception e) {
            // Catch EVERYTHING here (not just SQLException) so a bad DB connection,
            // null pointer, or driver issue doesn't fail silently.
            e.printStackTrace();
            errorDetail = e.getClass().getSimpleName() + ": " + e.getMessage();
        }

        if (newVisitId > 0) {
            response.sendRedirect(contextPath + "/Pages/emr.jsp?visitId=" + newVisitId);
        } else {
            request.getSession().setAttribute("flashError",
                    "Could not create visit — " + (errorDetail != null ? errorDetail : "please try again."));
            response.sendRedirect(contextPath + "/Pages/patient.jsp");
        }
    }
}