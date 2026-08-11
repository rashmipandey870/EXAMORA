package com.examora.model;

import java.util.ArrayList;
import java.util.List;

public class Unit {
    private int id;
    private int subjectId;
    private String name;
    private String description;
    private List<Topic> topics = new ArrayList<>();

    public Unit() {}

    public Unit(int id, int subjectId, String name, String description) {
        this.id = id;
        this.subjectId = subjectId;
        this.name = name;
        this.description = description;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getSubjectId() {
        return subjectId;
    }

    public void setSubjectId(int subjectId) {
        this.subjectId = subjectId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
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
}
