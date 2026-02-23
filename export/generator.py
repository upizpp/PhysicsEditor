from itertools import product
from math import sin, cos, pi
import json
from collections.abc import Iterable

X = 0
Y = 1
R = 0
G = 1
B = 2
A = 3

DIR_CROSS = 0
DIR_DOT = 1


def _is_evaluable(obj):
    return (
        isinstance(obj, Iterable)
        and not isinstance(obj, str)
        and not isinstance(obj, dict)
        and not isinstance(obj, list)
    )


def _is_evaluable_in(obj):
    if isinstance(obj, dict):
        return any(_is_evaluable_in(v) for v in obj.values())
    elif isinstance(obj, list):
        return any(_is_evaluable_in(v) for v in obj)
    else:
        return _is_evaluable(obj)


class Scene:
    data = {}

    def __init__(self, path=None):
        if path == None:
            self.data = {"variables": {}, "scene": []}
        else:
            self.data = json.load(open(path))

    def get_variables(self):
        return self.data["variables"]

    def __setitem__(self, key, value):
        self.data["variables"][key] = value

    def __getitem__(self, key):
        return self.data["variables"][key]

    def save(self, path):
        print(self.data)
        json.dump(self.data, open(path, "w"), indent=4)

    def add_object(self, obj):
        for evaluated_obj in self.__eval_object(obj):
            self.data["scene"].append(evaluated_obj)

    def __eval_object(self, obj):
        if isinstance(obj, dict):
            res = obj.copy()
            iterators = []
            keys = []
            for key, value in obj.items():
                if _is_evaluable_in(value):
                    iterators.append(iter(self.__eval_object(value)))
                    keys.append(key)
            for item in product(*iterators):
                for key, value in zip(keys, item):
                    res[key] = value
                yield res.copy()
        elif isinstance(obj, list):
            yield obj
        elif isinstance(obj, Iterable):
            for item in obj:
                yield item
        else:
            yield obj


def __color(col):
    if isinstance(col, tuple) and isinstance(col[0], (int, float)):
        if len(col) == 3:
            return f"Color({col[R]}, {col[G]}, {col[B]})"
        elif len(col) == 4:
            return f"Color({col[R]}, {col[G]}, {col[B]}, {col[A]})"
        else:
            return "Color()"
    elif isinstance(col, Iterable):
        res = []
        for item in col:
            res.append(__color(item))
        return tuple(res)
    else:
        return "Color()"


def __vector(vec):
    if isinstance(vec, tuple) and isinstance(vec[0], (int, float)):
        if len(vec) == 2:
            return f"Vector2({vec[X]}, {vec[Y]})"
        else:
            return "Vector2()"
    elif isinstance(vec, Iterable):
        res = []
        for item in vec:
            res.append(__vector(item))
        return tuple(res)
    else:
        return "Vector()"


def PhysicsObject(
    name,
    track=False,
    *,
    mass=1.0,
    charge=0.0,
    position=(0, 0),
    velocity=(0, 0),
    track_color=(0, 0, 0),
    **kwargs,
):
    res = {
        "name": name,
        "type": "object",
        "properties": {
            "mass": mass,
            "charge": charge,
            "position": __vector(position),
            "velocity": __vector(velocity),
        },
    }
    res.update(kwargs)
    if track:
        res["properties"]["track"] = {"default_color": __color(track_color)}
    return res


def MatrixMagneticField(
    name, *, strength=1.0, dir=DIR_CROSS, position=(0, 0), size=(128, 128)
):
    return {
        "name": name,
        "type": "magnetic",
        "shape": "matrix",
        "properties": {
            "strength": strength,
            "direction": dir,
            "position": __vector(position),
            "size": __vector(size),
        },
    }


def CircleMagneticField(
    name, *, strength=1.0, dir=DIR_CROSS, position=(0, 0), radius=64.0
):
    return {
        "name": name,
        "type": "magnetic",
        "shape": "circle",
        "properties": {
            "strength": strength,
            "direction": dir,
            "position": __vector(position),
            "radius": radius,
        },
    }


def MatrixElectricField(name, *, strength=100.0, position=(0, 0), size=(128, 128)):
    return {
        "name": name,
        "type": "electric",
        "shape": "matrix",
        "properties": {
            "strength": strength,
            "position": __vector(position),
            "size": __vector(size),
        },
    }


def CircleElectricField(name, *, strength=100.0, position=(0, 0), radius=64.0):
    return {
        "name": name,
        "type": "electric",
        "shape": "circle",
        "properties": {
            "strength": strength,
            "position": __vector(position),
            "radius": radius,
        },
    }


def LineBaffle(name, *, position=(0, 0), length=64.0):
    return {
        "name": name,
        "type": "baffle",
        "shape": "matrix",
        "properties": {
            "position": __vector(position),
            "length": length,
        },
    }


def CircleBaffle(name, *, position=(0, 0), radius=64.0):
    return {
        "name": name,
        "type": "baffle",
        "shape": "circle",
        "properties": {
            "position": __vector(position),
            "radius": radius,
        },
    }


if __name__ == "__main__":
    scene = Scene()
    scene["B"] = "1.0"
    scene["q"] = "1.0"

    velocity = []
    n = 32
    for i in range(0, n):
        velocity.append(
            (cos(2 * pi / n * i) * 200.0, sin(2 * pi / n * i) * 200.0),
        )

    scene.add_object(
        PhysicsObject(
            "my_object",
            velocity=velocity,
            position=(640, 320),
            track=True,
            mass=2.0,
            charge="q",
        )
    )
    scene.add_object(
        MatrixMagneticField(
            "my_magnetic_field",
            strength="B",
            position=(640, 320),
            size=(1280, 640),
            dir=DIR_DOT,
        )
    )
    scene.save("scene.json")
