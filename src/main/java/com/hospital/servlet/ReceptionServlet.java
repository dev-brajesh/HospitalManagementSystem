package com.hospital.servlet;

import com.hospital.dao.VisitDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/reception")
public class ReceptionServlet extends HttpServlet {

    private final VisitDAO visitDAO = new VisitDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String contextPath = request.getContextPath();

        if (session == null || !"RECEPTIONIST".equals(session.getAttribute("role"))) {
            response.sendRedirect(contextPath + "/Pages/login.jsp");
            return;
        }

        try {
            int visitId = Integer.parseInt(request.getParameter("visitId"));
            int doctorId = Integer.parseInt(request.getParameter("doctorId"));
            String department = request.getParameter("department");
            String feeParam = request.getParameter("consultationFee");
            java.math.BigDecimal fee = (feeParam != null && !feeParam.isBlank()) ? new java.math.BigDecimal(feeParam) : VisitDAO.DEFAULT_CONSULTATION_FEE;

            visitDAO.assignDoctor(visitId, doctorId, department, fee);
        } catch (NumberFormatException | SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect(contextPath + "/Pages/reception.jsp");
    }
}