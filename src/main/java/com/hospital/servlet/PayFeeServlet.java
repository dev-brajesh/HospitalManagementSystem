package com.hospital.servlet;

import com.hospital.dao.VisitDAO;
import com.hospital.model.Visit;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/payFee")
public class PayFeeServlet extends HttpServlet {

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

        Integer patientId = (Integer) session.getAttribute("userId");

        try {
            int visitId = Integer.parseInt(request.getParameter("visitId"));
            String feeType = request.getParameter("feeType"); // consultation | lab | medicine

            Visit visit = visitDAO.findById(visitId);
            // Ownership check — a patient can only pay for their own visit.
            if (visit == null || visit.getPatientId() != patientId) {
                response.sendRedirect(contextPath + "/Pages/patient.jsp");
                return;
            }

            visitDAO.payFee(visitId, feeType);
        } catch (NumberFormatException | SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect(contextPath + "/Pages/patient.jsp");
    }
}