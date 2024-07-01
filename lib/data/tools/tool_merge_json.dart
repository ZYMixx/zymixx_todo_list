import 'dart:convert';

class ToolMergeJson {
  String mergeJsonAndMap(String jsonString, Map<String, dynamic> dataToAdd) {
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    jsonMap.addAll(dataToAdd);
    String updatedJsonString = json.encode(jsonMap);
    return updatedJsonString;
  }
}
