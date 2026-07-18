<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String userRole = (String) session.getAttribute("role");

    if (userRole == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bharatpur Hospital · EMR</title>
    <link rel="stylesheet" href="../css/output.css">
</head>

<body class="min-h-screen bg-linear-to-br from-cyan-50 to-emerald-100 py-8 px-4">
<div class="max-w-5xl mx-auto bg-white border border-emerald-200 rounded-2xl shadow-xl overflow-hidden">

    <header class="bg-linear-to-r from-emerald-700 to-teal-600 text-white px-6 md:px-8 py-5">
        <div class="flex flex-col md:flex-row md:justify-between md:items-start gap-4">
            <div>
                <h1 class="text-2xl md:text-3xl font-extrabold tracking-tight">BHARATPUR HOSPITAL</h1>
                <p class="text-emerald-50 text-sm md:text-base mt-1">Electronic Medical Record</p>
            </div>
            <div class="text-sm md:text-base space-y-1 md:text-right">
                <p>
                    <span class="text-emerald-100">Visit Number :</span>
                    <span id="visitNumber" class="font-semibold text-white">XX</span>
                </p>
                <p>
                    <span class="text-emerald-100">Date :</span>
                    <span id="visitDate" class="font-semibold text-white">XX</span>
                </p>
            </div>
        </div>
    </header>

    <form id="emrForm" action="#" method="post">

        <input type="hidden" name="visitId" id="visitId">
        <input type="hidden" name="visitNumber" id="visitNumberInput">
        <input type="hidden" name="userRole" id="userRole" value="<%= userRole %>">
        <input type="hidden" name="labTestRequired" id="labTestRequired" value="false">

        <!-- 1. Patient Registration -->
        <section class="bg-white border border-emerald-200 rounded-2xl shadow-xl overflow-hidden">
            <div class="bg-emerald-500 px-5 py-3 flex items-center justify-between">
                <h2 class="text-white text-lg font-semibold">Patient Registration</h2>
                <div class="flex items-center gap-2">
                    <label for="language" class="text-sm font-medium text-white">Language</label>
                    <select id="language" name="language"
                            class="rounded-lg border border-emerald-300 bg-white px-2 py-1 text-sm outline-none">
                        <option value="English">English</option>
                        <option value="Nepali">Nepali</option>
                    </select>
                </div>
            </div>

            <div class="grid grid-cols-2 gap-4 p-5">
                <div>
                    <label for="patientName" class="mb-1 block text-sm font-semibold text-slate-700">Patient Name</label>
                    <input id="patientName" name="patientName" placeholder="Enter name"
                           class="w-full rounded-xl border-2 border-emerald-300 px-3 py-2 outline-none focus:border-emerald-500">
                </div>

                <div>
                    <label for="contactNumber" class="mb-1 block text-sm font-semibold text-slate-700">Contact Number</label>
                    <input id="contactNumber" name="contactNumber" type="tel" placeholder="Enter contact number"
                           class="w-full rounded-xl border-2 border-emerald-300 px-3 py-2 outline-none focus:border-emerald-500">
                </div>

                <div class="col-span-2">
                    <label for="symptoms" class="mb-1 block text-sm font-semibold text-slate-700">Symptoms</label>
                    <textarea id="symptoms" name="symptoms" rows="3"
                              placeholder="Describe symptoms..."
                              class="w-full resize-y rounded-xl border-2 border-emerald-300 px-3 py-2 outline-none focus:border-emerald-500"></textarea>
                </div>

                <div class="col-span-2 flex justify-end">
                    <button type="submit"
                            class="rounded-xl bg-emerald-500 px-6 py-2 font-semibold text-white hover:bg-emerald-600 active:scale-95">
                        Submit Registration
                    </button>
                </div>
            </div>
        </section>

        <!-- 2. Reception -->
        <div class="bg-white border border-emerald-200 rounded-2xl shadow-xl overflow-hidden mt-5">
            <div class="bg-gradient-to-r from-emerald-50 to-cyan-50 border-b border-emerald-200 px-5 py-3">
                <h2 class="text-xl font-bold text-emerald-700">Reception</h2>
                <p class="text-sm text-emerald-600">Department Assignment & Queue Management</p>
            </div>

            <div class="p-5">
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label for="visitNumberInputBox" class="block text-slate-700 font-semibold mb-2">Patient Visit Number</label>
                        <input id="visitNumberInputBox" readonly placeholder="Generated Automatically"
                               class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 bg-slate-50 outline-none">
                    </div>

                    <div>
                        <label for="visitDateInput" class="block text-slate-700 font-semibold mb-2">Visit Date</label>
                        <input id="visitDateInput" type="date" readonly placeholder="Loaded Automatically"
                               class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 bg-slate-50 outline-none">
                    </div>

                    <div>
                        <label for="department" class="block text-slate-700 font-semibold mb-2">Department</label>
                        <select id="department"
                                class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none">
                            <option selected disabled>Select Department</option>
                            <option>General Medicine</option>
                            <option>ENT</option>
                            <option>Orthopedics</option>
                            <option>Pediatrics</option>
                            <option>Gynecology</option>
                            <option>Dermatology</option>
                            <option>Ophthalmology</option>
                        </select>
                    </div>

                    <div>
                        <label for="doctorName" class="block text-slate-700 font-semibold mb-2">Assigned Doctor</label>
                        <input id="doctorName" readonly placeholder="Assigned Automatically"
                               class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 bg-slate-50 outline-none">
                    </div>

                    <div>
                        <label for="patientsAhead" class="block text-slate-700 font-semibold mb-2">Patients Ahead</label>
                        <input id="patientsAhead" readonly placeholder="Calculated Automatically"
                               class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 bg-slate-50 outline-none">
                    </div>

                    <div>
                        <label for="waitingTime" class="block text-slate-700 font-semibold mb-2">Estimated Waiting Time</label>
                        <input id="waitingTime" readonly placeholder="Calculated Automatically"
                               class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 bg-slate-50 outline-none">
                    </div>

                    <div class="col-span-2 flex justify-end">
                        <button type="button"
                                class="bg-emerald-500 hover:bg-emerald-600 text-white font-bold px-6 py-3 rounded-xl">
                            Send to Doctor Queue
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- 3. Doctor Consultation -->
        <div class="bg-white border border-emerald-200 rounded-2xl shadow-xl overflow-hidden mt-5">
            <div class="bg-gradient-to-r from-emerald-50 to-cyan-50 border-b border-emerald-200 px-5 py-3">
                <h2 class="text-xl font-bold text-emerald-700">Doctor Consultation</h2>
                <p class="text-sm text-emerald-600">Diagnosis, Investigation & Treatment</p>
            </div>

            <div class="p-5">
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label for="doctorVisitNumber" class="block text-slate-700 font-semibold mb-2">Patient Visit Number</label>
                        <input id="doctorVisitNumber" readonly placeholder="Loaded Automatically"
                               class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 bg-slate-50 outline-none">
                    </div>

                    <div>
                        <label for="doctorPatientsAhead" class="block text-slate-700 font-semibold mb-2">Patients Ahead</label>
                        <input id="doctorPatientsAhead" readonly placeholder="Calculated Automatically"
                               class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 bg-slate-50 outline-none">
                    </div>

                    <div>
                        <label for="doctorEstWait" class="block text-slate-700 font-semibold mb-2">Estimated Waiting Time</label>
                        <input id="doctorEstWait" readonly placeholder="Calculated Automatically"
                               class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 bg-slate-50 outline-none">
                    </div>

                    <div class="col-span-2">
                        <label for="diagnosis" class="block text-slate-700 font-semibold mb-2">Diagnosis</label>
                        <textarea id="diagnosis" rows="3" placeholder="Enter diagnosis..."
                                  class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none"></textarea>
                    </div>

                    <div class="col-span-2">
                        <label for="clinicalNotes" class="block text-slate-700 font-semibold mb-2">Clinical Notes</label>
                        <textarea id="clinicalNotes" rows="4" placeholder="Enter clinical notes..."
                                  class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none"></textarea>
                    </div>

                    <div>
                        <label for="labTest" class="block text-slate-700 font-semibold mb-2">Laboratory Test</label>
                        <textarea id="labTest" rows="2" placeholder="Enter requested test..."
                                  class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none"></textarea>
                    </div>

                    <div>
                        <label for="followUp" class="block text-slate-700 font-semibold mb-2">Follow-up Date</label>
                        <input id="followUp" type="date" placeholder="Select date"
                               class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none">
                    </div>

                    <!-- Prescription (entered by Doctor) -->
                    <div class="col-span-2">
                        <label class="block text-slate-700 font-semibold mb-2">Prescription</label>

                        <div class="border border-emerald-300 rounded-xl overflow-hidden">
                            <table class="w-full text-sm">
                                <thead class="bg-emerald-50">
                                <tr>
                                    <th class="p-3 text-left">Medicine Name</th>
                                    <th class="p-3 text-left">Dose</th>
                                    <th class="p-3 text-center">Morning</th>
                                    <th class="p-3 text-center">Afternoon</th>
                                    <th class="p-3 text-center">Evening</th>
                                    <th class="p-3 text-center">Days</th>
                                    <th class="p-3 text-center">Remove</th>
                                </tr>
                                </thead>
                                <tbody id="medicineBody">
                                <tr id="noMedicineRow" class="border-t border-emerald-200">
                                    <td colspan="7" class="p-5 text-center text-slate-400">
                                        No medicine added
                                    </td>
                                </tr>
                                </tbody>
                            </table>

                            <div class="bg-emerald-50 border-t border-emerald-200 px-3 py-2 flex justify-end">
                                <button type="button"
                                        id="addMedicineBtn"
                                        class="text-sm font-semibold text-emerald-700 border-2 border-emerald-300 rounded-lg px-3 py-1.5 bg-white hover:bg-emerald-100">
                                    + Add Medicine
                                </button>
                            </div>
                        </div>
                    </div>

                    <div class="col-span-2 flex justify-end gap-3">
                        <button type="button"
                                id="sendToLabBtn"
                                class="bg-amber-500 hover:bg-amber-600 text-white font-bold px-6 py-3 rounded-xl">
                            Send to Lab
                        </button>
                        <button type="button"
                                id="sendToPharmacyBtn"
                                class="bg-emerald-500 hover:bg-emerald-600 text-white font-bold px-6 py-3 rounded-xl">
                            Send to Pharmacy
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- 4. Laboratory -->
        <section id="section-lab" data-access-role="lab"
                 class="bg-white border border-emerald-200 rounded-2xl shadow-xl overflow-hidden mt-5">
            <div class="bg-gradient-to-r from-emerald-50 to-cyan-50 border-b border-emerald-200 px-5 py-3 flex justify-between items-center">
                <div>
                    <h2 class="text-xl font-bold text-emerald-700">Laboratory</h2>
                    <p class="text-sm text-emerald-600">Investigation & Result Management</p>
                </div>
                <span class="text-xs font-semibold px-3 py-1 rounded-full bg-amber-100 text-amber-800">Lab</span>
            </div>

            <div class="p-5">
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label for="labVisitNumber" class="block text-sm font-semibold text-slate-700 mb-2">Patient Visit Number</label>
                        <input id="labVisitNumber" readonly placeholder="Loaded Automatically"
                               class="w-full bg-slate-50 border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none">
                    </div>

                    <div>
                        <label for="labTestDisplay" class="block text-sm font-semibold text-slate-700 mb-2">Requested Test</label>
                        <input id="labTestDisplay" readonly placeholder="Waiting for Doctor Request"
                               class="w-full bg-slate-50 border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none">
                    </div>

                    <div>
                        <label for="labPatientsAhead" class="block text-sm font-semibold text-slate-700 mb-2">Patients Ahead</label>
                        <input id="labPatientsAhead" readonly placeholder="Calculated Automatically"
                               class="w-full bg-slate-50 border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none">
                    </div>

                    <div>
                        <label for="labEstWait" class="block text-sm font-semibold text-slate-700 mb-2">Estimated Waiting Time</label>
                        <input id="labEstWait" readonly placeholder="Calculated Automatically"
                               class="w-full bg-slate-50 border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none">
                    </div>

                    <div class="col-span-2">
                        <label for="labResultBox" class="block text-sm font-semibold text-slate-700 mb-2">Laboratory Result</label>
                        <textarea id="labResultBox" name="labResultText" rows="4"
                                  placeholder="Enter laboratory result"
                                  class="w-full border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none resize-y"></textarea>
                    </div>

                    <div class="col-span-2 flex justify-end gap-3">
                        <button type="button"
                                class="bg-amber-500 hover:bg-amber-600 text-white font-bold px-6 py-3 rounded-xl">
                            Mark Completed
                        </button>
                        <button type="button"
                                class="bg-emerald-500 hover:bg-emerald-600 text-white font-bold px-6 py-3 rounded-xl">
                            Send Result
                        </button>
                    </div>
                </div>
            </div>
        </section>

        <!-- 5. Pharmacy -->
        <section id="section-pharmacy" data-access-role="pharmacy"
                 class="bg-white border border-emerald-200 rounded-2xl shadow-xl overflow-hidden mt-5">
            <div class="bg-gradient-to-r from-emerald-50 to-cyan-50 border-b border-emerald-200 px-5 py-3 flex justify-between items-center">
                <div>
                    <h2 class="text-xl font-bold text-emerald-700">Pharmacy</h2>
                    <p class="text-sm text-emerald-600">Prescription Dispensing</p>
                </div>
                <span class="text-xs font-semibold px-3 py-1 rounded-full bg-rose-100 text-rose-800">Pharmacy</span>
            </div>

            <div class="p-5">
                <div class="grid grid-cols-2 gap-4 mb-5">
                    <div>
                        <label for="pharmacyVisitNumber" class="block text-sm font-semibold text-slate-700 mb-2">Patient Visit Number</label>
                        <input id="pharmacyVisitNumber" readonly placeholder="Loaded Automatically"
                               class="w-full bg-slate-50 border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none">
                    </div>

                    <div>
                        <label for="pharmacyPatientsAhead" class="block text-sm font-semibold text-slate-700 mb-2">Patients Ahead</label>
                        <input id="pharmacyPatientsAhead" readonly placeholder="Calculated Automatically"
                               class="w-full bg-slate-50 border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none">
                    </div>

                    <div>
                        <label for="pharmacyEstWait" class="block text-sm font-semibold text-slate-700 mb-2">Estimated Waiting Time</label>
                        <input id="pharmacyEstWait" readonly placeholder="Calculated Automatically"
                               class="w-full bg-slate-50 border-2 border-emerald-300 rounded-xl px-4 py-3 outline-none">
                    </div>
                </div>

                <p class="block text-sm font-semibold text-slate-700 mb-2">Prescribed Medicines (from Doctor)</p>

                <div class="border border-emerald-300 rounded-xl overflow-hidden">
                    <table class="w-full text-sm">
                        <thead class="bg-emerald-50">
                        <tr>
                            <th class="p-3 text-left">Medicine</th>
                            <th class="p-3 text-left">Dose</th>
                            <th class="p-3 text-center">Schedule</th>
                            <th class="p-3 text-center">Days</th>
                            <th class="p-3 text-center">Status</th>
                        </tr>
                        </thead>
                        <tbody id="pharmacyMedicineBody">
                        <tr class="border-t border-emerald-200">
                            <td colspan="5" class="p-5 text-center text-slate-400">
                                No prescription available
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>

                <div class="mt-5 flex justify-between items-center border-t border-emerald-100 pt-4">
                    <div>
                        <span class="text-sm font-semibold text-slate-700">Total:</span>
                        <span class="font-bold text-emerald-700">NPR <span id="pharmacyTotalCost">0</span></span>
                    </div>

                    <div class="flex items-center gap-4">
                        <label class="flex items-center gap-2 text-sm font-semibold text-slate-700">
                            <input type="checkbox" id="medicinePayment" class="w-4 h-4">
                            Paid
                        </label>
                        <button type="button"
                                id="dispenseMedicineBtn"
                                class="bg-emerald-500 hover:bg-emerald-600 text-white font-semibold px-5 py-2 rounded-xl">
                            Dispense
                        </button>
                    </div>
                </div>
            </div>
        </section>

        <!-- Save -->
        <div class="px-6 py-5 bg-slate-50 border-t border-emerald-100 flex justify-end gap-3">
            <button type="button"
                    id="refreshStatusBtn"
                    class="border-2 border-emerald-300 text-emerald-700 font-semibold px-5 py-2.5 rounded-xl hover:bg-emerald-50 transition">
                Refresh Status
            </button>
            <button type="submit"
                    id="saveBtn"
                    class="bg-emerald-500 hover:bg-emerald-600 active:scale-95 transition text-white font-bold px-6 py-2.5 rounded-xl shadow-md">
                Save
            </button>
        </div>

    </form>
</div>

<script src="../js/patientVisit.js"></script>
</body>
</html>