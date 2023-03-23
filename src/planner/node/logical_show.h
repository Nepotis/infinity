//
// Created by JinHai on 2022/7/30.
//

#pragma once

#include "planner/logical_node.h"

#include "storage/table.h"

namespace infinity {

enum class ShowType {
    kInvalid,
    kShowTables,
    kShowViews,
    kShowColumn,
    kIntermediate,
};

String
ToString(ShowType type);

class LogicalShow: public LogicalNode {
public:
    explicit
    LogicalShow(u64 node_id,
                ShowType type,
                String schema_name,
                u64 table_index)
        : LogicalNode(node_id, LogicalNodeType::kShow),
        scan_type_(type),
        schema_name_(std::move(schema_name)),
        table_index_(table_index)
        {}

    [[nodiscard]] inline Vector<ColumnBinding>
    GetColumnBindings() const final {
        return {};
    }

    String
    ToString(i64& space) final;

    inline String
    name() final {
        return "LogicalShow";
    }

    [[nodiscard]] ShowType
    scan_type() const {
        return scan_type_;
    }

    [[nodiscard]] inline u64
    table_index() const {
        return table_index_;
    }

    [[nodiscard]] inline const String&
    schema_name() const {
        return schema_name_;
    }

private:
    ShowType scan_type_{ShowType::kInvalid};
    String schema_name_;
    u64 table_index_{};

};

}