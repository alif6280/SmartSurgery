package com.surgery.model;

import java.util.HashMap;
import java.util.Map;

public class Settings {
    private Map<String, String> values = new HashMap<>();

    public void set(String key, String value) {
        values.put(key, value);
    }

    public String get(String key) {
        return values.getOrDefault(key, "");
    }

    public String get(String key, String defaultVal) {
        return values.getOrDefault(key, defaultVal);
    }

    public boolean getBool(String key) {
        return "true".equalsIgnoreCase(values.getOrDefault(key, "false"));
    }

    public Map<String, String> getAll() {
        return values;
    }
}