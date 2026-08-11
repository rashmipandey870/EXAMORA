package com.examora.model;

public class SubTopic {
    private int id;
    private int topicId;
    private String name;
    private String description;

    public SubTopic() {}

    public SubTopic(int id, int topicId, String name, String description) {
        this.id = id;
        this.topicId = topicId;
        this.name = name;
        this.description = description;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getTopicId() {
        return topicId;
    }

    public void setTopicId(int topicId) {
        this.topicId = topicId;
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
}
