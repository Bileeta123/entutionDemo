class TableSchema {
  final String tableName;
  final List<ColumnSchema> columns;

  TableSchema({required this.tableName, required this.columns});

  factory TableSchema.fromJson(Map<String, dynamic> json) {
    var list = json['columns'] as List;
    List<ColumnSchema> columnsList =
        list.map((i) => ColumnSchema.fromJson(i)).toList();
    return TableSchema(
      tableName: json['tableName'],
      columns: columnsList,
    );
  }
}

class ColumnSchema {
  final String columnName;
  final String dataType;

  ColumnSchema({required this.columnName, required this.dataType});

  factory ColumnSchema.fromJson(Map<String, dynamic> json) {
    return ColumnSchema(
      columnName: json['columnName'],
      dataType: json['dataType'],
    );
  }
}
