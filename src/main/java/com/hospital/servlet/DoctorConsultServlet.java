package com.hospital.servlet;

import com.hospital.dao.PrescriptionDAO;
import com.hospital.dao.VisitDAO;
import com.hospital.model.Prescription;
import com.hospital.model.Visit;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/doctorConsult")
public class DoctorConsultServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(DoctorConsultServlet.class.getName());

    private final VisitDAO visitDAO = new VisitDAO();
    private final PrescriptionDAO prescriptionDAO = new PrescriptionDAO();

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

            // Whether this is the SECOND time the doctor is seeing this visit — i.e. it already has
            // a diagnosis (set on the first consult) and has come back from a paid lab test.
            // This is derived from server-side state, not a client-submitted field, so it can't be spoofed.
            boolean isPostLabConsult = visit.getDiagnosis() != null;

            if (isPostLabConsult) {
                // Doctor already diagnosed and referred to lab earlier. Now reviewing lab results
                // and prescribing medicine — diagnosis/lab fields are untouched.
                savePrescriptions(request, visitId);
                visitDAO.sendToPharmacyAfterLab(visitId);
            } else {
                String diagnosis = request.getParameter("diagnosis");
                String action = request.getParameter("action"); // "lab" or "pharmacy"

                if ("lab".equals(action)) {
                    String labTestName = request.getParameter("labTestName");
                    visitDAO.completeConsultation(visitId, diagnosis, labTestName, "LAB");
                } else {
                    // No lab needed — doctor prescribes medicine directly and sends to pharmacy.
                    savePrescriptions(request, visitId);
                    visitDAO.completeConsultation(visitId, diagnosis, null, "PHARMACY");
                }
            }
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid visitId or days value submitted to /doctorConsult", e);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to complete consultation", e);
        }

        response.sendRedirect(contextPath + "/Pages/doctor.jsp");
    }

    /**
     * Reads the parallel medicine-row arrays from the consult form (see patientVisit.js)
     * and saves them as the visit's prescriptions. Clears any previous rows first so a
     * resubmission doesn't duplicate entries.
     */
    private void savePrescriptions(HttpServletRequest request, int visitId) throws SQLException {
        String[] names = request.getParameterValues("medicineName[]");
        String[] doses = request.getParameterValues("dose[]");
        String[] mornings = request.getParameterValues("morning[]");
        String[] afternoons = request.getParameterValues("afternoon[]");
        String[] evenings = request.getParameterValues("evening[]");
        String[] daysArr = request.getParameterValues("days[]");

        prescriptionDAO.deleteByVisitId(visitId); // clear any stale rows first

        if (names == null) return;

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
}