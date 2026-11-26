#!/usr/bin/env bash
# OrbbecSDK v2 用户指南 - 一键构建脚本（中英文双语）
# 用法：cd 到 OrbbecSDKv2_User_Guide 目录后执行  ./build_bilingual.sh
# 作用：自动建虚拟环境、装依赖，把 zh/en 两套网页构建到与它们同级的 site 目录
# 产物结构：site/index.html（外层总入口）+ site/.nojekyll + site/zh/ + site/en/

set -e

# 脚本所在目录（无论从哪个路径调用，都能找到 en/zh/requirements.txt）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 虚拟环境放在用户主目录，不在仓库内，避免污染 git 工作区
VENV_DIR="$HOME/.orbbec_docs_venv"
VENV_PY="$VENV_DIR/bin/python"

echo "[1/4] 检查 Python 3 ..."
if ! command -v python3 >/dev/null 2>&1; then
    echo "错误：未找到 python3，请先安装 Python 3。"
    exit 1
fi

echo "[2/4] 准备虚拟环境 ..."
if [ ! -x "$VENV_PY" ]; then
    echo "创建虚拟环境：$VENV_DIR"
    if ! python3 -m venv "$VENV_DIR" 2>/dev/null; then
        echo ""
        echo "创建虚拟环境失败：系统缺少 python3-venv。"
        echo "请先执行（把 3.10 换成你的 Python 版本，可用 python3 --version 查看）："
        echo "    sudo apt install python3.10-venv"
        echo "然后重新运行本脚本。"
        exit 1
    fi
else
    echo "虚拟环境已存在，复用：$VENV_DIR"
fi

echo "[3/4] 安装依赖 ..."
"$VENV_PY" -m pip install -r "$SCRIPT_DIR/requirements.txt"

# 产物目录：与 en/zh 同级的 site，与 ROS2 文档产物结构保持一致
SITE_DIR="$SCRIPT_DIR/site"

# 外层总入口默认跳到英文站（要改成中文站，把下面的 en 改成 zh）
DEFAULT_LANG="${DEFAULT_LANG:-en}"

echo "[4/4] 构建中文站(zh)与英文站(en) 到 $SITE_DIR ..."
# 先清空旧产物，避免上次构建残留（与 ROS2 build_versions.py 的 prepare_site_dir 一致）
rm -rf "$SITE_DIR"
mkdir -p "$SITE_DIR"

"$VENV_PY" -m sphinx -b html "$SCRIPT_DIR/zh" "$SITE_DIR/zh"
"$VENV_PY" -m sphinx -b html "$SCRIPT_DIR/en" "$SITE_DIR/en"

# 外层总入口：一个链接，0 秒自动跳到默认语言，之后靠页面内按钮切换 /en/ 与 /zh/
cat > "$SITE_DIR/index.html" <<EOF
<!DOCTYPE html><html><head>
<meta http-equiv="refresh" content="0; url=${DEFAULT_LANG}/index.html">
<link rel="canonical" href="${DEFAULT_LANG}/index.html">
</head><body>Redirecting...</body></html>
EOF

# GitHub Pages 默认用 Jekyll 发布，会跳过下划线开头的目录（如 _static）；
# 空的 .nojekyll 让它原样发布，CSS/JS/搜索索引才不会丢
touch "$SITE_DIR/.nojekyll"

echo ""
echo "========== 构建完成 =========="
echo "总入口：$SITE_DIR/index.html （自动跳到 $DEFAULT_LANG/index.html）"
echo "中文首页：$SITE_DIR/zh/index.html"
echo "英文首页：$SITE_DIR/en/index.html"
echo "发布时把整个 site 目录作为站点根目录即可。"
