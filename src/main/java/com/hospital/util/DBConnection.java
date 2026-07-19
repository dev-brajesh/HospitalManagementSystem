package com.hospital.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL =
            "jdbc:mysql://localhost:3306/hospital_db";

    private static final String USERNAME = "root";
    private static final String PASSWORD = "";

    /**
     * Returns a live connection or throws — callers should NOT expect null back.
     * (Previously this swallowed the exception and returned null, which caused
     * silent NullPointerExceptions deeper in the DAOs.)
     */
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC driver not found on classpath", e);
        }

        System.out.println("[DBConnection] Connecting to: " + URL + " as user='" + USERNAME + "'");
        Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
        System.out.println("[DBConnection] Database Connected Successfully. AutoCommit=" + connection.getAutoCommit());
        return connection;
    }
}