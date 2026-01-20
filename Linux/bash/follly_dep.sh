#!/bin/bash
# save as install_folly_complete.sh

set -e

echo "=== 安装所有依赖项 ==="

# 更新系统
sudo apt-get update

# 安装编译工具
sudo apt-get install -y git cmake build-essential automake libtool \
    pkg-config curl wget unzip

# 安装 Folly 所有依赖
sudo apt-get install -y \
    libboost-all-dev \
    libdouble-conversion-dev \
    libgflags-dev \
    libgoogle-glog-dev \
    libevent-dev \
    libssl-dev \
    liblz4-dev \
    liblzma-dev \
    libsnappy-dev \
    zlib1g-dev \
    libiberty-dev \
    libaio-dev \
    libjemalloc-dev \
    libunwind-dev \
    libfmt-dev \
    libsodium-dev \
    libzstd-dev \
    libbz2-dev \
    python3-dev \
    libdwarf-dev \
    libelf-dev \
    libdw-dev \
    libfastfloat-dev \  # 新增：FastFloat 库
    libre2-dev \        # 新增：re2 正则表达式库
    libbenchmark-dev    # 新增：Google Benchmark

echo "=== 安装可选依赖 ==="
sudo apt-get install -y \
    libgtest-dev \
    libgmock-dev \
    liburing-dev

echo "=== 克隆并编译 Folly ==="

# 克隆 Folly
if [ ! -d "folly" ]; then
    git clone https://github.com/facebook/folly.git
fi
cd folly

# 使用稳定版本（避免最新版的兼容性问题）
git checkout v2024.08.19.00

# 更新子模块
git submodule update --init --recursive

echo "=== 配置 CMake ==="
mkdir -p build
cd build

# 配置 CMake，显式指定 FastFloat 路径
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DFOLLY_USE_FASTFLOAT=ON \
    -DFastFloat_DIR=/usr/local/lib/cmake/FastFloat \
    -DCMAKE_PREFIX_PATH=/usr/local

echo "=== 开始编译 ==="
make -j$(nproc)

echo "=== 安装到系统 ==="
sudo make install

echo "=== 更新库缓存 ==="
sudo ldconfig

echo "=== 验证安装 ==="
cd ../..
cat > test_folly.cpp << 'EOF'
#include <iostream>
#include <folly/String.h>
#include <folly/Format.h>
#include <folly/container/F14Map.h>

int main() {
    // 测试 String 功能
    std::string s = "test,folly,installation";
    std::vector<std::string> parts;
    folly::split(",", s, parts);
    
    for (const auto& part : parts) {
        std::cout << folly::format("Part: {}", part) << std::endl;
    }
    
    // 测试 F14 哈希表
    folly::F14FastMap<std::string, int> map;
    map["hello"] = 1;
    map["world"] = 2;
    
    std::cout << "Map size: " << map.size() << std::endl;
    return 0;
}
EOF

echo "编译测试程序..."
g++ -std=c++17 test_folly.cpp \
    -lfolly \
    -lglog \
    -ldouble-conversion \
    -lssl -lcrypto \
    -lfmt \
    -pthread \
    -o test_folly

if [ -f ./test_folly ]; then
    echo "测试程序编译成功！运行测试："
    ./test_folly
    echo "=== Folly 安装成功！ ==="
else
    echo "测试程序编译失败，请检查错误信息。"
fi