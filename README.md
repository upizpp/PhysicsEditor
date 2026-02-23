# PhysicsEditor

PhysicsEditor 是一个基于 Godot 引擎的物理场景编辑器，允许用户创建和模拟带电粒子在磁场，电场中的运动现象。它提供了直观的图形界面来设计场景，并支持通过 Python 脚本生成复杂的物理布局。

## 特性

- **可视化编辑**：通过拖拽操作轻松构建物理场景。
- **多类型对象支持**：包括质点、磁场、电场和挡板等。
- **参数配置**：每个对象都可自定义其物理属性如质量、电荷、速度等。
- **轨迹追踪**：可以开启轨迹显示以观察物体运动路径。
- **变量系统**：便于管理和统一控制多个对象的共享属性。
- **脚本生成器**：利用 Python 脚本快速批量生成场景。

## 安装与运行

### 环境要求

- [Godot Engine](https://godotengine.org/) 3.5.x 
- Python 3.x（用于脚本生成功能）

### 获取源码

```bash
git clone https://github.com/upizpp/PhysicsEditor.git
cd PhysicsEditor
```

### 加载项目

1. 启动 Godot 引擎。
2. 选择“导入”并指定项目根目录下的 [project.godot](project.godot) 文件。
3. 成功导入后点击“编辑”开始使用。

### 示例演示

在 `export/examples/` 目录中有几个预置的示例文件可供参考。你可以直接加载这些 .json 文件来体验编辑器的功能。

## 使用指南

### 新建场景

1. 主界面点击“新建”按钮创建空白场景。
2. 给场景命名并保存。
3. 从左侧工具栏选取所需对象种类（质点、磁场等）。
4. 设定形状及各项参数。
5. 可选地激活轨迹追踪等功能。

### 修改已有场景

1. 使用“打开”功能载入现有的 .json 场景文档。
2. 对象属性调整或新增删除均可在此基础上进行。
3. 别忘了最后保存所做的变更。

### 输出场景

编辑完毕后可通过菜单项“保存”或者“另存为”将成果导出成标准 JSON 格式文件。

### Python 脚本应用

若需借助代码自动化产生大量类似结构的场景，在 `python/generator.py` 中编写相应逻辑即可。例如：

```python
from generator import Scene, PhysicsObject, MatrixMagneticField

scene = Scene()
scene["B"] = "1.0"
scene["q"] = "1.0"

# 添加具有轨迹记录功能的物理实体
scene.add_object(PhysicsObject("my_object", position=(640, 320), charge="q", track=True))

# 加入矩阵形式的磁场
scene.add_object(MatrixMagneticField("my_field", strength="B", position=(640, 320)))

scene.save("output_scene.json")
```

执行上述脚本就能获得一个新的场景描述文件。

## 项目结构概览

```
PhysicsEditor/
├── addons/                 # 第三方插件资源
├── assets/                 # 图像素材、字体等静态资料
├── export/                 # 工具脚本及范例输出
│   └── examples/           # 内建示范案例集合
├── objects/                # 游戏内部各节点组件定义
│   ├── autoload/           # 自动加载全局实例
│   ├── scenes/             # 场景相关元素封装
│   └── 2d/                 # 二维物理行为实现
├── python/                 # 辅助性的 Python 工具包
├── test/                   # 测试代码及其他验证手段
└── README.md               # 当前这份说明文档
```

## 授权许可

该项目遵循 Apache 授权协议发布。详情请参阅 [LICENSE](LICENSE) 文件。

## 致谢名单

向所有参与者和支持者致以诚挚谢意！特别感谢 Godot 社区给予的强大技术支持以及开放图标的慷慨分享。
