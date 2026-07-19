<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Laboratory Dashboard</title>

    <link rel="stylesheet" href="../css/output.css">
</head>

<body class="min-h-screen bg-gradient-to-br from-cyan-50 to-emerald-100 py-8 px-4">

<div class="max-w-7xl mx-auto">

    <!-- ================= HEADER ================= -->

    <header class="bg-linear-to-r from-emerald-700 to-teal-600 text-white px-6 md:px-8 py-5 rounded-2xl shadow-xl">

        <div class="flex flex-col md:flex-row md:justify-between md:items-center gap-4">

            <div>

                <h1 class="text-3xl font-extrabold tracking-tight">
                    BHARATPUR HOSPITAL
                </h1>

                <p class="text-emerald-100 mt-1">
                    Electronic Medical Record
                </p>

            </div>

            <div class="text-left md:text-right">

                <h2 class="text-2xl font-bold">
                    Laboratory Dashboard
                </h2>

                <p class="text-emerald-100">
                    Welcome, Laboratory Staff
                </p>

            </div>

        </div>

    </header>

    <!-- Gap -->

    <div class="h-6"></div>

    <!-- ================= LAB QUEUE ================= -->

    <div class="bg-white rounded-2xl shadow-xl border border-emerald-200 overflow-hidden">

        <!-- Queue Header -->

        <div class="bg-emerald-500 text-white px-6 py-4 flex justify-between items-center">

            <div>

                <h2 class="text-xl font-bold">
                    Laboratory Test Queue
                </h2>

                <p class="text-emerald-100 text-sm">
                    Patients referred by doctors for laboratory investigation
                </p>

            </div>

            <input
                    type="text"
                    placeholder="Search Patient..."
                    class="w-64 rounded-lg px-4 py-2 text-gray-700 outline-none">

        </div>

        <!-- Queue Table -->

        <div class="overflow-x-auto">

            <table class="w-full">

                <thead class="bg-emerald-100 text-emerald-900">

                <tr>

                    <th class="px-6 py-4 text-left">
                        S.No
                    </th>

                    <th class="px-6 py-4 text-left">
                        Visit No
                    </th>

                    <th class="px-6 py-4 text-left">
                        Patient ID
                    </th>

                    <th class="px-6 py-4 text-left">
                        Patient Name
                    </th>

                    <th class="px-6 py-4 text-left">
                        Test Name
                    </th>

                    <th class="px-6 py-4 text-left">
                        Status
                    </th>

                    <th class="px-6 py-4 text-center">
                        Action
                    </th>

                </tr>

                </thead>

                <tbody id="laboratoryQueue">

                <!--
                    Empty.
                    Patient rows will be loaded automatically
                    after doctor requests a laboratory test.
                -->

                </tbody>

            </table>

        </div>

    </div>

</div>

</body>

</html>