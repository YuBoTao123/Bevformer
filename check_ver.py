import torch
import subprocess
import mmcv
from mmcv.utils import get_build_config

def check_compatibility():
    print("===== 环境一致性检查 =====")
    
    # 获取 mmcv 构建信息
    try:
        build_info = get_build_config()
        cuda_build = build_info.get('CUDA_VERSION', '未知')
        gcc_build = build_info.get('GCC_VERSION', '未知')
        torch_build = build_info.get('TORCH_VERSION', '未知')
        abi_build = build_info.get('CXX_ABI', '未知')
    except:
        print("警告: 无法获取 mmcv 构建信息")
        cuda_build = gcc_build = torch_build = abi_build = "未知"
    
    # 检查 CUDA 版本
    cuda_runtime = torch.version.cuda
    print(f"1. CUDA 版本:")
    print(f"   - 运行时: {cuda_runtime}")
    print(f"   - mmcv 构建: {cuda_build}")
    
    # 检查 GCC 版本
    gcc_runtime = subprocess.check_output("gcc --version | head -n1", shell=True).decode().strip()
    print(f"2. GCC 版本:")
    print(f"   - 运行时: {gcc_runtime}")
    print(f"   - mmcv 构建: {gcc_build}")
    
    # 检查 PyTorch 版本
    torch_runtime = torch.__version__
    print(f"3. PyTorch 版本:")
    print(f"   - 运行时: {torch_runtime}")
    print(f"   - mmcv 构建: {torch_build}")
    
    # 检查 ABI 兼容性
    abi_runtime = str(torch._C._GLIBCXX_USE_CXX11_ABI)
    print(f"4. CXX ABI 兼容性:")
    print(f"   - PyTorch ABI: {abi_runtime}")
    print(f"   - mmcv ABI: {abi_build}")
    
    print("==========================")
    
    # 给出建议
    if cuda_build != "未知" and cuda_runtime != cuda_build:
        print("警告: CUDA 版本不一致!")
        print(f"建议: pip install mmcv-full=={mmcv.__version__} -f https://download.openmmlab.com/mmcv/dist/cu{cuda_runtime.replace('.', '')}/torch{torch_runtime.split('+')[0]}/index.html")
    
    if gcc_build != "未知" and gcc_build not in gcc_runtime:
        print("警告: GCC 版本可能不一致!")
        print(f"建议: 设置环境变量 CC=/usr/bin/gcc-{gcc_build.split('.')[0]} CXX=/usr/bin/g++-{gcc_build.split('.')[0]}")

check_compatibility()