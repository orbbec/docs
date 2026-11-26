@echo off
chcp 65001 >nul
REM OrbbecSDK v2 用户指南 - 一键构建脚本（中英文双语）
REM 用法：双击本文件，或在 OrbbecSDKv2_User_Guide 目录下执行 build_bilingual.bat
REM 作用：自动建虚拟环境、装依赖，把 zh/en 两套网页构建到与它们同级的 site 目录
REM 产物结构：site\index.html（外层总入口）+ site\.nojekyll + site\zh\ + site\en\

setlocal
set "SCRIPT_DIR=%~dp0"
set "VENV_DIR=%USERPROFILE%\.orbbec_docs_venv"
set "VENV_PY=%VENV_DIR%\Scripts\python.exe"

echo [1/4] 检查 Python ...
where py >nul 2>&1
if %errorlevel%==0 (
    set "PY=py"
) else (
    set "PY=python"
)

echo [2/4] 准备虚拟环境 ...
if not exist "%VENV_PY%" (
    echo 创建虚拟环境：%VENV_DIR%
    %PY% -m venv "%VENV_DIR%"
    if not exist "%VENV_PY%" (
        echo 创建虚拟环境失败，请确认已安装 Python 3。
        exit /b 1
    )
) else (
    echo 虚拟环境已存在，复用：%VENV_DIR%
)

echo [3/4] 安装依赖 ...
"%VENV_PY%" -m pip install -r "%SCRIPT_DIR%requirements.txt"
if %errorlevel% neq 0 (
    echo 依赖安装失败。
    exit /b 1
)

REM 产物目录：与 en/zh 同级的 site，与 ROS2 文档产物结构保持一致
set "SITE_DIR=%SCRIPT_DIR%site"

REM 外层总入口默认跳到英文站（要改成中文站，把下面的 en 改成 zh）
if not defined DEFAULT_LANG set "DEFAULT_LANG=en"

echo [4/4] 构建中文站(zh)与英文站(en) 到 %SITE_DIR% ...
REM 先清空旧产物，避免上次构建残留
if exist "%SITE_DIR%" rmdir /s /q "%SITE_DIR%"
mkdir "%SITE_DIR%"

"%VENV_PY%" -m sphinx -b html "%SCRIPT_DIR%zh" "%SITE_DIR%\zh"
if %errorlevel% neq 0 (
    echo 中文站构建失败。
    exit /b 1
)
"%VENV_PY%" -m sphinx -b html "%SCRIPT_DIR%en" "%SITE_DIR%\en"
if %errorlevel% neq 0 (
    echo 英文站构建失败。
    exit /b 1
)

REM 外层总入口：一个链接，0 秒自动跳到默认语言，之后靠页面内按钮切换 /en/ 与 /zh/
> "%SITE_DIR%\index.html" echo ^<!DOCTYPE html^>^<html^>^<head^>
>>"%SITE_DIR%\index.html" echo ^<meta http-equiv="refresh" content="0; url=%DEFAULT_LANG%/index.html"^>
>>"%SITE_DIR%\index.html" echo ^<link rel="canonical" href="%DEFAULT_LANG%/index.html"^>
>>"%SITE_DIR%\index.html" echo ^</head^>^<body^>Redirecting...^</body^>^</html^>

REM GitHub Pages 默认用 Jekyll 发布，会跳过下划线开头的目录（如 _static）；
REM 空的 .nojekyll 让它原样发布，CSS/JS/搜索索引才不会丢
type nul > "%SITE_DIR%\.nojekyll"

echo.
echo ========== 构建完成 ==========
echo 总入口：%SITE_DIR%\index.html （自动跳到 %DEFAULT_LANG%/index.html）
echo 中文首页：%SITE_DIR%\zh\index.html
echo 英文首页：%SITE_DIR%\en\index.html
echo 发布时把整个 site 目录作为站点根目录即可。
pause
