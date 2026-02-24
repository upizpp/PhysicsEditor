# 使用说明

本软件通过读取JSON文件来生成场景，JSON文件格式为：

```json
{
    "variables": {
        ...
    },
    "scene": [
        ...
    ]
}
```

其可分为两个部分，

- **variables**，用于定义变量，变量值是一个表达式，变量之间可以有一定的依赖关系，但不能循环依赖（无法求值）。
- **scene**，场景对象的集合，所有场景中的一切（粒子，磁场，电场等）都由此定义。

## variables

例：

```json
"variables": {
    "q": "1.0",
    "m": "1.0",
    "B": "1.0",
    "R": "100.0", // 单位：像素
    "v": "2 * q * B * R / m",
    "theta": "PI / 2.0",
    "g": "9.8",
    "a": "g * sin(theta)"
}
```

在运行时，变量将自动计算。

### 特殊变量

- **UpdateFrequency** - 帧更新频率，默认值为*10*，值越大越容易卡顿，但模拟精度越高。
- **DecelerationRatio** - 时间缩放，默认值为*0.2*，同样是为了调整模拟精度而定的，`1gs = 1s * DecelerationRatio`，gs表示**模拟秒**。

### 内置 常数 / 函数

- **PI** - 圆周率π，约为3.14159265358。
- **TAU** - 圆周率τ=2π，约为6.28318530718。
- **asin(x)** - 反正弦函数
- **sin(x)** - 正弦函数
- **sinh(x)** - 双曲正弦函数
- **acos(x)** - 反余弦函数
- **cos(x)** - 余弦函数
- **cosh(x)** - 双曲余弦函数
- **atan(k)** - 反正切函数
- **atan2(y, x)** - 二元反正切函数
- **tan(x)** - 正切函数
- **tanh(x)** - 双曲正切函数
- **pow(x, p)** - 指数函数
- **log(x)** - 自然对数函数
- **randi()** - 随机整数
- **randf()** - 随机实数
- **exp(x)** - 以e为底的指数函数
- **floor(x)** - 向下取整函数
- **ceil(x)** - 向上取整函数
- **abs(x)** - 绝对值函数

## scene

每个scene对象必须有一个name属性和一个type属性。  
name是该对象的名称，便于编辑器区分（实际上可以重复）。  
type是该对象的类型，目前支持的种类有：

- **object** - 粒子
- **magnetic** - 磁场
- **electric** - 电场
- **baffle** - 挡板

对于后三个，还必须有一个shape属性，用于定义对象的形状，目前支持的形状有：

- **matrix** - 矩形
- **circle** - 圆形

除此之外，每个对象还可以有properties属性，用于定义对象的属性。

每个对象还可以有properties属性，用于定义对象的属性。  
比如说：position等等，具体见[https://docs.godotengine.org/zh-cn/3.5/classes/class_node2d.html#id3]。

特别的，一些object还可以有一些特殊的属性。

### type = object

- **mass** - 质量，默认值为*1.0*。
- **charge** - 电量，默认值为*0.0*。
- **velocity** - 初速度，默认值为*Vector(0, 0)*。
- **no_gravitation** - 是否不受万有引力，默认为*false*。
- **no_coulomb** - 是否不受库仑力，默认为*false*。
- **gravitation** - 是否产生引力场，默认为*false*。
- **coulomb** - 是否产生电场，默认为*false*。
- **track** - 是否记录轨迹，默认不记录，如果记录请填`{}`，如果要修改颜色，可以填`{"default_color":"Color(r,g,b,a)"}`，其中r，g，b，a是0~1之间的值，a可选，更多属性见[https://docs.godotengine.org/zh-cn/3.5/classes/class_line2d.html#id3]

### type = magnetic

- **strength** - 磁力强度，默认值为*1.0*。
- **direction** - 磁力方向，默认值为*0*，*0*表示叉磁场，*1*表示点磁场。

### type = electric

- **strength** - 电场强度，默认值为*100.0*。
- **direction_degrees** - 电场方向，默认值为*0*，单位为角度，逆时针为正方形，有效显示范围为0~360°。

### shape = matrix

- **size** - 矩形大小，默认值为*Vector(128, 128)*。

### shape = circle

- **radius** - 圆形半径，默认值为*64*。

### shape = matrix && type = baffle

- **length** - 挡板长度，默认值为*128*。

注意，以上所有属性都可以是一个表达式，如：

```json
{
    "name": "field",
    "type": "magnetic",
    "shape": "matrix",
    "properties": {
        "position": "Vector2( 640, 320 )",
        "size": "Vector2( x, y )",
        "strength": "B * 2.0",
        "direction": "1"
    },
},
```

表达式中可以出现前面在variables中定义的变量。  
运行时，表达式将自动计算。

如果发现json中出现了`"__bind__": null`，是编辑器实现上导致的，属于正常现象，请忽略。

## 一个简单的例子：

```json
{
    "variables": {
        "q": "1.0",
        "B": "1.0"
    },
    "scene": [
        {
            "name": "field",
            "type": "magnetic",
            "properties": {
                "position": "Vector2( 640, 320 )",
                "size": "Vector2( 1280, 640 )",
                "strength": "B",
                "direction": "1"
            },
            "shape": "matrix"
        },
        {
            "name": "test",
            "type": "object",
            "properties": {
                "radius": "8.0",
                "position": "Vector2( 369, 164 )",
                "velocity": "Vector2( 500, 0 )",
                "charge": "q",
                "track": {
                    "default_color": "Color(0.0,0.0,0.0)"
                }
            }
        }
    ]
}
```
