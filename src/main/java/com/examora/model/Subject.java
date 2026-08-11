package com.examora.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Subject represents a broad category of study containing specific topics.
 * 
 * WHAT: Model POJO mapping to the 'subjects' table in MySQL.
 * WHY: Groups topics into structural modules (e.g., DBMS, Operating Systems).
 * HOW: Declares attributes (id, examId, name) and maintains a List of child Topic objects.
 * WHERE: Placed in the com.examora.model package.
 */
public class Subject {
    private int id;
    private int examId;
    private String name;
    private List<Topic> topics = new ArrayList<>();
    private List<Unit> units = new ArrayList<>();

    // Constructors
    public Subject() {}

    public Subject(int id, int examId, String name) {
        this.id = id;
        this.examId = examId;
        this.name = name;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getExamId() {
        return examId;
    }

    public void setExamId(int examId) {
        this.examId = examId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<Topic> getTopics() {
        return topics;
    }

    public void setTopics(List<Topic> topics) {
        this.topics = topics;
    }

    public void addTopic(Topic topic) {
        this.topics.add(topic);
    }

    public List<Unit> getUnits() {
        return units;
    }

    public void setUnits(List<Unit> units) {
        this.units = units;
    }

    public void addUnit(Unit unit) {
        this.units.add(unit);
    }
}
