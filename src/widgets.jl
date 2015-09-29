

cxx"""
  #include <QGLWidget>
  class MyCanvas : public QGLWidget
  {

  public:
    // enum Shape { Line, Points, Polyline, Polygon, Rect, RoundedRect, Ellipse, Arc,
    //              Chord, Pie, Path, Text, Pixmap };

    MyCanvas(int idx) : _idx(idx) {}
    int getidx() { return _idx; }

  protected:
    // just call the julia method `draw` and pass the MyCanvas pointer
    void paintEvent(QPaintEvent *event)  
    {
      std::cout << "PAINT! " << std::endl;
      $:(draw( icxx"return this;" )::Void);
    }

  private:
    int _idx;
  };
"""

# ----------------------------------------------------

"anything with coords in a scene"
abstract SceneItem

# "layers are containers in a scene... nothing to draw directly"
# abstract Layer <: SceneItem

"these are things that need to be drawn"
abstract Shape <: SceneItem

# ----------------------------------------------------


type Scene
  canvas
  items::Vector{SceneItem}
end

Scene(canvas::Cxx.CppPtr) = Scene(canvas, SceneItem[])

const _scenes = Dict{Int, Scene}()


# NOTE: this is the callback that gets called from within MyCanvas::paintEvent
#       ALL drawing should be done before returning
function draw(canvas::Cxx.CppPtr)
  # dump(canvas)

  # get the index of the canvas
  idx = @cxx canvas->getidx()
  # @show idx

  # get the starting coordinates
  # x = @cxx canvas->x()
  # y = @cxx canvas->y()
  width = @cxx canvas->width()
  height = @cxx canvas->height()
  # @show x y width height
  # box = SceneBox(Nullable{SceneBox}(), P2(x,y), P2(width,height))
  box = ViewBox(0, 0, width, height)
  # @show box

  # grab the scene object
  scene = _scenes[idx]
  # dump(scene)

  # set up the painter
  painter = Painter(@cxxnew QPainter(canvas))
  @cxx (painter.o)->setRenderHint(@cxx(QPainter::Antialiasing), true)

  # draw something
  for item in scene.items
    draw(item, painter, box)
  end

  nothing
end

function Scene()
  # get the next available index
  idx = isempty(_scenes) ? 1 : maximum(keys(_scenes)) + 1

  # create a new canvas, and set the window title
  canvas = @cxxnew MyCanvas(idx)
  @cxx canvas->setWindowTitle(pointer("idx: $idx"))

  # create, store, and return the Scene object
  scene = Scene(canvas)
  _scenes[idx] = scene
end

function Base.display(scene::Scene)
  @cxx scene.canvas->update()
  @cxx scene.canvas->show()
end


Base.push!(scene::Scene, item::SceneItem) = push!(scene.items, item)

# ----------------------------------------------------



# ----------------------------------------------------

@enum MetricType PercentMetric PixelMetric

immutable Metric{M}
  val::Float64
end

typealias Px Metric{PixelMetric}
typealias Pct Metric{PercentMetric}

Base.convert(::Type{Px}, x::Real) = Px(float(x))
Base.convert(::Type{Pct}, x::Real) = Pct(float(x))
Base.promote_rule{T<:Real}(::Type{Px}, ::Type{T}) = Px
Base.promote_rule{T<:Real}(::Type{Pct}, ::Type{T}) = Pct

Base.show(io::IO, p::Px) = print(io, "Pixel{", p.val, "}")
Base.show(io::IO, p::Pct) = print(io, "Percent{", p.val, "}")

for op in (:+, :-, :*, :/)
  @eval $op(p1::Px, p2::Px) = Px($op(p1.val, p2.val))
  @eval $op(p1::Pct, p2::Pct) = Px($op(p1.val, p2.val))
end

"This allows combination of percent and pixel metrics"
immutable Distance
  pct::Float64
  px::Float64
end

Base.convert(::Type{Distance}, pct::Pct) = Distance(pct.val, 0.0)
Base.convert(::Type{Distance}, px::Px) = Distance(0.0, px.val)
Base.convert(::Type{Distance}, x::Real) = Distance(float(x), 0.0)
Base.promote_rule{T<:Union{Pct,Px,Real}}(::Type{Distance}, ::Type{T}) = Distance

for op in (:+, :-, :*, :/)
  @eval $op(d1::Distance, d2::Distance) = Distance($op(d1.pct, d2.pct), $op(d1.px, d2.px))
end

typealias DistOrDists Union{Distance, Vector{Distance}}

# ---------------------------------------------------

"defines a view inside the widget area... all values in pixels"
immutable ViewBox
  x::Float64
  y::Float64
  w::Float64
  h::Float64
end

px_x(dist::Distance, box::ViewBox) = box.x + (dist.pct * box.w + dist.px)
px_y(dist::Distance, box::ViewBox) = box.y + (dist.pct * box.h + dist.px)
px_w(dist::Distance, box::ViewBox) = dist.pct * box.w + dist.px
px_h(dist::Distance, box::ViewBox) = dist.pct * box.h + dist.px


# ---------------------------------------------------

"holds a list of child scene items and the coordinates"
type View <: SceneItem
  box::ViewBox
  items::Vector{SceneItem}
end

function draw(view::View, painter, box::ViewBox)
  for item in view.items
    draw(item, painter, view.box)
  end
end

Base.push!(v::View, item::Shape) = push!(v.items, item)

# ---------------------------------------------------

immutable Pen{T<:Cxx.CppValue}
  o::T
end

function Pen(cstr::AbstractString)
  Pen(@cxx QPen(pointer(cstr)))
end

immutable Brush{T<:Cxx.CppValue}
  o::T
end

function Brush(cstr::AbstractString)
  Brush(@cxx QBrush(pointer(cstr)))
end

# ---------------------------------------------------

type Painter{T<:Cxx.CppPtr}
  o::T
  pen::Nullable{Pen}
  brush::Nullable{Brush}
end

Painter(o) = Painter(o, Nullable{Pen}(), Nullable{Brush}())

function pen!(painter::Painter, pen::Pen)
  !isnull(painter.pen) && get(painter.pen) === pen && return
  painter.pen = Nullable(pen)
  @cxx (painter.o)->setPen(pen.o)
end
function brush!(painter::Painter, brush::Brush)
  !isnull(painter.brush) && get(painter.brush) === brush && return
  painter.brush = Nullable(brush)
  @cxx (painter.o)->setBrush(brush.o)
end



# ---------------------------------------------------

type Ellipse <: Shape
  x::Distance
  y::Distance
  w::Distance
  h::Distance
  pen::Pen
  brush::Brush
end

function draw(item::Ellipse, painter, box::ViewBox)
  # xy, wh = convertPctToSceneCoords(box, center, radius)
  x = px_x(item.x, box)
  y = px_y(item.y, box)
  w = px_w(item.w, box)
  h = px_h(item.h, box)
  pen!(painter, item.pen)
  brush!(painter, item.brush)
  @cxx (painter.o)->drawEllipse(x-0.5*w, y-0.5*h, w, h)
end

type Ellipses <: Shape
  n::Int
  x::Vector{Distance}
  y::Vector{Distance}
  w::Vector{Distance}
  h::Vector{Distance}
  pen::Vector{Pen}
  brush::Vector{Brush}
end


function draw(item::Ellipses, painter, box::ViewBox)
  nx = length(item.x)
  ny = length(item.y)
  nw = length(item.w)
  nh = length(item.h)
  np = length(item.pen)
  nb = length(item.brush)
  x = 0.0
  y = 0.0
  w = 0.0
  h = 0.0
  x = nx == 1 ? px_x(item.x[1], box) : 0.0
  y = ny == 1 ? px_y(item.y[1], box) : 0.0
  w = nw == 1 ? px_w(item.w[1], box) : 0.0
  h = nh == 1 ? px_h(item.h[1], box) : 0.0
  np == 1 && @cxx painter->setPen(item.pen[1].o)
  nb == 1 && @cxx painter->setBrush(item.brush[1].o)
  
  for i in 1:n
    if nx > 1
      x = px_x(item.x[mod1(i,nx)], box)
    end
    if ny > 1
      y = px_y(item.y[mod1(i,ny)], box)
    end
    if nw > 1
      w = px_w(item.w[mod1(i,nw)], box)
    end
    if nh > 1
      h = px_h(item.h[mod1(i,nh)], box)
    end
    if np > 1
      @cxx painter->setPen(item.pen[mod1(i,np)].o)
    end
    if nb > 1
      @cxx painter->setBrush(item.brush[mod1(i,nb)].o)
    end
    @cxx painter->drawEllipse(x-0.5*w, y-0.5*h, w, h)
  end
end

# ---------------------------------------------------

# note: null parent means it's top level

# "This is the box which contains shapes... all child shapes are relative to this box"
# immutable SceneBox
#   parent::Nullable{SceneBox}
#   xy::P2
#   wh::P2
# end

# TODO: a better composition... maybe pass scene w/h through directly?
# TODO: can we structure so that we don't need a parent reference, and the top level converts pct to scene?
#     note: we can probably pull this off if we stay as percentages... if item is 50% of box, and box is 30% of it's
#           parent, then we can just return 15% of the box pct

# "given values where x/y/w/h are on the scale 0->1, convert to box coords"
# function convertPctToBoxScale(box::SceneBox, xy::P2, wh::P2)
#   xy .* box.wh, wh .* box.wh
# end

# "given values where x/y/w/h are on the scale 0->1, convert to scene coords"
# function convertPctToSceneCoords(box::SceneBox, xy::P2, wh::P2)
#   xy, wh = convertPctToBoxScale(box, xy, wh)
#   if isnull(box.parent)
#     return xy, wh
#   else
#     return convertPctToBoxCoords(get(box.parent), xy, wh)
#   end
# end

# ----------------------------------------------------

# "holds a list of child scene items and the coordinates"
# type ViewLayer <: Layer
#   box::SceneBox
#   items::Vector{SceneItem}
# end

# function draw(layer::ViewLayer, painter, box::SceneBox)
#   for item in items
#     draw(item, painter, layer.box)
#   end
# end

# ----------------------------------------------------


# type Ellipse <: Shape
#   center::P2
#   radius::P2
#   pen
#   brush
# end

# function draw(item::Ellipse, painter, box::SceneBox)
#   xy, wh = convertPctToSceneCoords(box, center, radius)
#   @cxx painter->setPen(item.pen)
#   @cxx painter->setBrush(item.brush)
#   @cxx painter->drawEllipse(xy.x, xy.y, wh.w, wh.h)
# end

# push!(scene::Union{Scene,Layer}, item::Ellipse) = push!(scene.items, item)

# ----------------------------------------------------

# type Canvas
#   widget
# end

# function Canvas(idx::Int, title = "HELLO")
#   w = @cxxnew MyCanvas(idx)
#   @cxx w->setWindowTitle(pointer(title))
#   Canvas(w)
# end

# function Pen(cstr::ASCIIString)
#   @cxx QPen(pointer(cstr))
# end

# function Brush(cstr::ASCIIString)
#   @cxx QBrush(pointer(cstr))
# end

# Base.display(c::Canvas) = @cxx (c.widget)->show()

# ----------------------------------------------------

# function render(painter)
#   dump(painter)
#   nothing
# end

# ----------------------------------------------------

type Window
  o
end

function display(win::Window)
  @cxx (win.o)->show()
end

function window(idx::Int = 0; title = "HI", w = 1000, h = 500)
  Window(@cxxnew MyWindow(idx, pointer(title), w, h))
end


