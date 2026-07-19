package com.hospital.servlet;

import com.hospital.dao.VisitDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/pharmacyDispense")
public class PharmacyDispenseServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PharmacyDispenseServlet.class.getName());

    private final VisitDAO visitDAO = new VisitDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {

        HttpSession session = request.getSession(false);
        String contextPath = request.getContextPath();

        if (session == null || !"PHARMACY".equals(session.getAttribute("role"))) {
            response.sendRedirect(contextPath + "/Pages/login.jsp");
            return;
        }

        try {
            int visitId = Integer.parseInt(request.getParameter("visitId"));
            String costParam = request.getParameter("totalCost");
            BigDecimal totalCost = (costParam == null || costParam.isBlank())
                    ? BigDecimal.ZERO
                    : new BigDecimal(costParam);

            // Medicines were already prescribed by the doctor — pharmacy only fills
            // the order and records what it actually cost.
            visitDAO.dispenseMedicine(visitId, totalCost);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid visitId or totalCost submitted to /pharmacyDispense", e);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to dispense medicine", e);
        }

        response.sendRedirect(contextPath + "/Pages/pharmacy.jsp");
    }
}