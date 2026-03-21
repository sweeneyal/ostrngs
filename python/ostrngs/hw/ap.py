from random import randrange
from dataclasses import dataclass

@dataclass
class Block:
    x  : int
    y  : int
    xs : int
    ys : int

    def area(self):
        return self.xs * self.ys
    
    def contains(self, other):
        # if the bottom left and top right points both exist within the self rectangle,
        # then the other rectangle is contained within the self rectangle.
        x_origin_overlap = (other.x > self.x) and (other.x < self.x + self.xs)
        y_origin_overlap = (other.y > self.y) and (other.y < self.y + self.ys)
        x_corner_overlap = (other.x + other.xs > self.x) and (other.x + other.xs < self.x + self.xs)
        y_corner_overlap = (other.y + other.ys > self.y) and (other.y + other.ys < self.y + self.ys)
        return x_corner_overlap and x_origin_overlap and y_corner_overlap and y_origin_overlap

    
class Area:
    def __init__(self, xmin, xmax, ymin, ymax):
        self.rectangles = list()
        self.subspaces  = list()
        self.base = Block(xmin, ymin, xmax-xmin, ymax-ymin)

    def add_subspace(self, space):
        self.subspaces.append(space)

"""
There are three categories of possibilities for random scatter of rectangles:
-> Corner allocation - top row of squares
-> Edge allocation - middle row of squares
-> Middle allocation - bottom row of squares

| | | |   | | | |   | | |X|   |X| | |
| | | |   | | | |   | | | |   | | | |
|X| | |   | | |X|   | | | |   | | | |

| | | |   | | | |   | |X| |   | | | |
| | | |   | | |X|   | | | |   |X| | |
| |X| |   | | | |   | | | |   | | | |

| | | |
| |X| |
| | | |

If allocated to a corner, there are then two free rectangles (A, B) generated 
with one rectangle allocated (X).

|A|A|A|
|A|A|A|
|X|B|B|

If allocated to an edge, there are then three free rectangles (A, B, C) generated 
with one rectangle allocated (X).

|A|B|C|
|A|B|C|
|A|X|C|

If allocated to somewhere in the middle, there are then four free rectangles (A, B, C, D) generated 
with one rectangle allocated (X).

|A|B|C|
|A|X|C|
|A|D|C|

The job of the scatter function is to recursively search the space and its subspaces for places to allocate
rectangles.
"""

def scatter(space, xs, ys):
    if space.base.xs < xs or space.base.ys < ys:
        return None

    if len(space.subspaces) == 0:
        xmin = space.base.x
        ymin = space.base.y
        xmax = space.base.x + space.base.xs
        ymax = space.base.y + space.base.ys

        if xmin == xmax - xs:
            x = xmin
        else:
            x = randrange(xmin, xmax - xs)

        if ymin == ymax - ys:
            y = ymin
        else:
            y = randrange(ymin, ymax - ys)

        is_bottom = y == ymin
        is_left   = x == xmin
        is_right  = x == xmax - xs
        is_top    = y == ymax - ys

        is_bottom_left  = is_bottom and is_left
        is_top_left     = is_top and is_left
        is_bottom_right = is_bottom and is_right
        is_top_right    = is_top and is_right

        is_corner = is_bottom_left or is_top_left or is_bottom_right or is_top_right
        is_edge   = is_bottom or is_left or is_right or is_top

        if is_corner:
            if is_bottom_left:
                s0 = Area(x + xs, xmax, ymin, ymax)
                s1 = Area(xmin, x + xs, y+ys, ymax)
                space.add_subspace(s0)
                space.add_subspace(s1)
            elif is_top_left:
                s0 = Area(xmin, xmax, ymin, y)
                s1 = Area(x + xs, xmax, y, ymax)
                space.add_subspace(s0)
                space.add_subspace(s1)
            elif is_bottom_right:
                s0 = Area(xmin, x, ymin, ymax)
                s1 = Area(x, xmax, y + ys, ymax)
                space.add_subspace(s0)
                space.add_subspace(s1)
            elif is_top_right:
                s0 = Area(xmin, x, ymin, ymax)
                s1 = Area(x, xmax, ymin, y)
                space.add_subspace(s0)
                space.add_subspace(s1)
        elif is_edge:
            if is_bottom:
                s0 = Area(xmin, x, ymin, ymax)
                s1 = Area(x + xs, xmax, ymin, ymax)
                s2 = Area(x, x+xs, y+ys, ymax)
                space.add_subspace(s0)
                space.add_subspace(s1)
                space.add_subspace(s2)
            elif is_top:
                s0 = Area(xmin, x, ymin, ymax)
                s1 = Area(x + xs, xmax, ymin, ymax)
                s2 = Area(x, x+xs, ymin, y+ys)
                space.add_subspace(s0)
                space.add_subspace(s1)
                space.add_subspace(s2)
            elif is_left:
                s0 = Area(xmin, xmax, ymin, y)
                s1 = Area(xmin, xmax, y + ys, ymax)
                s2 = Area(x+xs, xmax, y, y+ys)
                space.add_subspace(s0)
                space.add_subspace(s1)
                space.add_subspace(s2)
            elif is_right:
                s0 = Area(xmin, xmax, ymin, y)
                s1 = Area(xmin, xmax, y + ys, ymax)
                s2 = Area(xmin, x, y, y+ys)
                space.add_subspace(s0)
                space.add_subspace(s1)
                space.add_subspace(s2)
        else:
            s0 = Area(xmin, xmax, ymin, y)
            s1 = Area(xmin, xmax, y + ys, ymax)
            s2 = Area(xmin, x, y, y + ys)
            s3 = Area(x + xs, xmax, y, y + ys)
            space.add_subspace(s0)
            space.add_subspace(s1)
            space.add_subspace(s2)
            space.add_subspace(s3)
        return (x, y)
    else:
        for subspace in space.subspaces:
            coords = None
            if xs <= subspace.base.xs and ys <= subspace.base.ys:
                coords = scatter(subspace, xs, ys)
            if coords is not None:
                return coords
        return None

if __name__ == "__main__":
    X_MIN = 12
    Y_MIN = 5
    X_MAX = 76
    Y_MAX = 50

    source_sizes = [
        (3,3),
        (4,16),
        (2,6),
        (1,4),
        (1,2),
        (3,3),
        (3,3),
        (3,3)
    ]

    space = Area(X_MIN, X_MAX, Y_MIN, Y_MAX)
    
    coords = []

    for size in source_sizes:
        next_coord = scatter(space, size[0], size[1])
        if next_coord is not None:
            coords.append(next_coord)
            print(next_coord)
        else:
            raise Exception

    import matplotlib.pyplot as plt
    from matplotlib.patches import Rectangle

    #define Matplotlib figure and axis
    fig, ax = plt.subplots()
    ax.set_xlim(xmin=X_MIN, xmax=X_MAX)
    ax.set_ylim(ymin=Y_MIN, ymax=Y_MAX)
    colormap = plt.get_cmap('jet')
    cmap = [colormap(ii/len(coords)) for ii in range(len(coords))]

    #add rectangle to plot
    for ii in range(len(coords)):
        ax.add_patch(Rectangle(coords[ii], source_sizes[ii][0], source_sizes[ii][1], facecolor=cmap[ii]))

    #display plot
    plt.show()