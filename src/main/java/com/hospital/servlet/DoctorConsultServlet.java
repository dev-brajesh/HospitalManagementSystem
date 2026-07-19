package com.hospital.servlet;

import com.hospital.dao.VisitDAO;
import com.hospital.model.Visit;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/doctorConsult")
public class DoctorConsultServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(DoctorConsultServlet.class.getName());

    private final VisitDAO visitDAO = new VisitDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {

        HttpSession session = request.getSession(false);
        String contextPath = request.getContextPath();

        if (session == null || !"DOCTOR".equals(session.getAttribute("role"))) {
            response.sendRedirect(contextPath + "/Pages/login.jsp");
            return;
        }

        Integer sessionDoctorId = (Integer) session.getAttribute("userId");

        try {
            int visitId = Integer.parseInt(request.getParameter("visitId"));

            Visit visit = visitDAO.findById(visitId);
            // A doctor may only act on their own assigned visit, in the DOCTOR stage.
            if (visit == null
                    || visit.getAssignedDoctorId() == null
                    || !visit.getAssignedDoctorId().equals(sessionDoctorId)
                    || !"DOCTOR".equals(visit.getStatus())) {
                response.sendRedirect(contextPath + "/Pages/doctor.jsp");
                return;
            }

            String diagnosis = request.getParameter("diagnosis");
            String action = request.getParameter("action"); // "lab" or "pharmacy"

            String labTestName = null;
            BigDecimal labFee = BigDecimal.ZERO;
            String nextStatus;

            if ("lab".equals(action)) {
                labTestName = request.getParameter("labTestName");
                String feeParam = request.getParameter("labFee");
                labFee = (feeParam == null || feeParam.isBlank()) ? BigDecimal.ZERO : new BigDecimal(feeParam);
                nextStatus = "LAB";
            } else {
                nextStatus = "PHARMACY";
            }

            visitDAO.completeConsultation(visitId, diagnosis, labTestName, labFee, nextStatus);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid visitId submitted to /doctorConsult", e);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to complete consultation", e);
        }

        response.sendRedirect(contextPath + "/Pages/doctor.jsp");
    }
}