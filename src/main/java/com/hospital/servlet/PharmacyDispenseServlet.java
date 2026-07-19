package com.hospital.servlet;

import com.hospital.dao.PrescriptionDAO;
import com.hospital.dao.VisitDAO;
import com.hospital.model.Prescription;
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
    private final PrescriptionDAO prescriptionDAO = new PrescriptionDAO();

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

            // Parallel arrays from the dynamic medicine rows (see patientVisit.js)
            String[] names = request.getParameterValues("medicineName[]");
            String[] doses = request.getParameterValues("dose[]");
            String[] mornings = request.getParameterValues("morning[]");
            String[] afternoons = request.getParameterValues("afternoon[]");
            String[] evenings = request.getParameterValues("evening[]");
            String[] daysArr = request.getParameterValues("days[]");

            prescriptionDAO.deleteByVisitId(visitId); // clear any stale rows first

            if (names != null) {
                for (int i = 0; i < names.length; i++) {
                    if (names[i] == null || names[i].isBlank()) continue;

                    Prescription p = new Prescription();
                    p.setVisitId(visitId);
                    p.setMedicineName(names[i]);
                    p.setDose(doses != null && doses.length > i ? doses[i] : "");
                    p.setMorning(mornings != null && mornings.length > i);
                    p.setAfternoon(afternoons != null && afternoons.length > i);
                    p.setEvening(evenings != null && evenings.length > i);
                    int days = 1;
                    if (daysArr != null && daysArr.length > i && !daysArr[i].isBlank()) {
                        days = Integer.parseInt(daysArr[i]);
                    }
                    p.setDays(days);
                    prescriptionDAO.insertPrescription(p);
                }
            }

            visitDAO.dispenseMedicine(visitId, totalCost);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid visitId or totalCost submitted to /pharmacyDispense", e);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to dispense medicine", e);
        }

        response.sendRedirect(contextPath + "/Pages/pharmacy.jsp");
    }
}