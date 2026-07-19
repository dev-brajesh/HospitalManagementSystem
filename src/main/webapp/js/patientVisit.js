document.addEventListener("DOMContentLoaded", () => {
    const addMedicineBtn = document.getElementById("addMedicineBtn");
    const medicineBody = document.getElementById("medicineBody");

    if (!addMedicineBtn || !medicineBody) return;

    function getNoMedicineRow() {
        return document.getElementById("noMedicineRow");
    }

    function showNoMedicineRowIfEmpty() {
        const hasRows = medicineBody.querySelectorAll("tr:not(#noMedicineRow)").length > 0;
        if (!hasRows && !getNoMedicineRow()) {
            const emptyRow = document.createElement("tr");
            emptyRow.id = "noMedicineRow";
            emptyRow.className = "border-t border-emerald-200";
            emptyRow.innerHTML = `
                <td colspan="7" class="p-5 text-center text-slate-400">
                    No medicine added
                </td>`;
            medicineBody.appendChild(emptyRow);
        }
    }

    addMedicineBtn.addEventListener("click", () => {
        const noMedicineRow = getNoMedicineRow();
        if (noMedicineRow) noMedicineRow.remove();

        const row = document.createElement("tr");
        row.className = "border-t border-emerald-200";
        row.innerHTML = `
            <td class="p-2">
                <input type="text" name="medicineName[]" placeholder="Medicine Name" aria-label="Medicine Name"
                       class="w-full rounded-lg border border-emerald-300 px-3 py-2 outline-none">
            </td>
            <td class="p-2">
                <input type="text" name="dose[]" placeholder="1 Tablet" aria-label="Dose"
                       class="w-full rounded-lg border border-emerald-300 px-3 py-2 outline-none">
            </td>
            <td class="p-2 text-center">
                <input type="checkbox" name="morning[]" aria-label="Morning dose">
            </td>
            <td class="p-2 text-center">
                <input type="checkbox" name="afternoon[]" aria-label="Afternoon dose">
            </td>
            <td class="p-2 text-center">
                <input type="checkbox" name="evening[]" aria-label="Evening dose">
            </td>
            <td class="p-2">
                <input type="number" name="days[]" min="1" placeholder="Days" aria-label="Number of days"
                       class="w-20 rounded-lg border border-emerald-300 px-2 py-2 outline-none">
            </td>
            <td class="p-2 text-center">
                <button type="button" class="removeMedicineBtn text-rose-600 font-bold text-lg hover:text-rose-700" aria-label="Remove medicine">
                    &times;
                </button>
            </td>`;
        medicineBody.appendChild(row);
    });

    medicineBody.addEventListener("click", (e) => {
        const removeBtn = e.target.closest(".removeMedicineBtn");
        if (!removeBtn) return;

        removeBtn.closest("tr").remove();
        showNoMedicineRowIfEmpty();
    });
});