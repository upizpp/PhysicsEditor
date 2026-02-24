import math


class vector:
    x = 0.0
    y = 0.0


    @staticmethod
    def from_angle(angle, length=1.0):
        return vector(math.cos(angle) * length, math.sin(angle) * length)
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __add__(self, other):
        return vector(self.x + other.x, self.y + other.y)

    def __sub__(self, other):
        return vector(self.x - other.x, self.y - other.y)

    def __mul__(self, other):
        return vector(self.x * other.x, self.y * other.y)

    def __truediv__(self, other):
        return vector(self.x / other.x, self.y / other.y)

    def __neg__(self):
        return vector(-self.x, -self.y)

    def __pos__(self):
        return vector(+self.x, +self.y)

    def __abs__(self):
        return vector(abs(self.x), abs(self.y))

    def __eq__(self, other):
        return self.x == other.x and self.y == other.y

    def __ne__(self, other):
        return self.x != other.x or self.y != other.y

    def __str__(self):
        return f"Vector2({self.x}, {self.y})"

    def __iter__(self):
        yield self.x
        yield self.y

    def length(self):
        return math.sqrt(self.length_squared())

    def length_squared(self):
        return self.x**2 + self.y**2

    def normalize(self):
        length = self.length()
        if length == 0:
            return vector(0, 0)
        return vector(self.x / length, self.y / length)

    def dot(self, other):
        return self.x * other.x + self.y * other.y

    def cross(self, other):
        return self.x * other.y - self.y * other.x

    def project(self, other):
        return other * (self.dot(other) / other.length_squared())

    def reject(self, other):
        return self - self.project(other)

    def rotate(self, angle):
        cos_angle = math.cos(angle)
        sin_angle = math.sin(angle)
        return vector(
            self.x * cos_angle - self.y * sin_angle,
            self.x * sin_angle + self.y * cos_angle,
        )

    def angle(self):
        return math.atan2(self.y, self.x)

    def angle_to(self, other):
        return other.angle() - self.angle()

    def tangent(self):
        return vector(-self.y, self.x)
