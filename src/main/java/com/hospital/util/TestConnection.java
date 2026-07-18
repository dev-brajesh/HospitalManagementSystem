package com.hospital.util;

import java.sql.Connection;

public class TestConnection {
    public static void main(String[] args) {
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("Database connection successful: " + conn.getMetaData().getURL());
            }
        } catch (Exception e) {
            System.err.println("Database connection failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}