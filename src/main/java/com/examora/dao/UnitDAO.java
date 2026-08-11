package com.examora.dao;

import com.examora.model.Unit;
import com.examora.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UnitDAO {

    public List<Unit> getUnitsBySubjectId(int subjectId) {
        List<Unit> units = new ArrayList<>();
        String sql = "SELECT id, subject_id, name FROM units WHERE subject_id = ? ORDER BY id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, subjectId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Unit unit = new Unit();
                    unit.setId(rs.getInt("id"));
                    unit.setSubjectId(rs.getInt("subject_id"));
                    unit.setName(rs.getString("name"));
                    units.add(unit);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching units for subject: " + e.getMessage());
            e.printStackTrace();
        }
        return units;
    }
}
