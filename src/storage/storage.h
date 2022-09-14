//
// Created by JinHai on 2022/9/14.
//

#pragma once

#include "catalog.h"
#include <string>


namespace infinity {

class Infinity;

class Storage {
public:
    explicit Storage(std::string data_path);

    [[nodiscard]] std::unique_ptr<Catalog>& catalog() { return catalog_; }

    void Init();

private:
    std::string data_path_;
    std::unique_ptr<Catalog> catalog_;
};

}