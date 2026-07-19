
package com.hospital.servlet;

import com.hospital.dao.VisitDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/labResult")
public class LabResultServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LabResultServlet.class.getName());

    private final VisitDAO visitDAO = new VisitDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {

        HttpSession session = request.getSession(false);
        String contextPath = request.getContextPath();

        if (session == null || !"LAB".equals(session.getAttribute("role"))) {
            response.sendRedirect(contextPath + "/Pages/login.jsp");
            return;
        }

        try {
            int visitId = Integer.parseInt(request.getParameter("visitId"));
            String resultText = request.getParameter("labResultText");

            // completeLabTest now only takes (visitId, resultText) — it always
            // routes the visit to LAB_PAYMENT and leaves paying it to the patient.
            visitDAO.completeLabTest(visitId, resultText);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid visitId submitted to /labResult", e);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to complete lab test", e);
        }

        response.sendRedirect(contextPath + "/Pages/lab.jsp");
    }
}