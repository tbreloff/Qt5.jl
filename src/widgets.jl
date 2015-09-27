

cxx"""
  class MyCanvas : public QWidget
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
  xy::P2
  wh::P2
end

const _scenes = Dict{Int, Scene}()


# NOTE: this is the callback that gets called from within MyCanvas::paintEvent
#       ALL drawing should be done before returning
function draw(canvas::Cxx.CppPtr)
  dump(canvas)

  # get the index of the canvas
  idx = @cxx canvas->getidx()
  @show idx

  # get the starting coordinates
  x = @cxx canvas->x()
  y = @cxx canvas->y()
  width = @cxx canvas->width()
  height = @cxx canvas->height()
  @show x y width height
  box = SceneBox(Nullable{SceneBox}(), P2(x,y), P2(width,height))
  @show box

  # grab the scene object
  scene = _scenes[idx]
  dump(scene)

  # set up the painter
  painter = @cxxnew QPainter(canvas)
  @cxx painter->setRenderHint(@cxx(QPainter::Antialiasing), true)

  # draw something
  for item in scene.items
    draw(item, painter, box)
  end

  # p = Pen("blue")
  # @cxx painter->setPen(p)
  # @cxx painter->drawEllipse(50.0, 50.0, 50.0, 20.0)

  nothing
end

function Scene()
  # get the next available index
  idx = isempty(_scenes) ? 1 : maximum(keys(_scenes)) + 1

  # create a new canvas, and set the window title
  canvas = @cxxnew MyCanvas(idx)
  @cxx canvas->setWindowTitle(pointer("idx: $idx"))

  # create, store, and return the Scene object
  scene = Scene(canvas, Layer[])
  _scenes[idx] = scene
end

function Base.display(scene::Scene)
  @cxx scene.canvas->update()
  @cxx scene.canvas->show()
end

# ----------------------------------------------------



# ----------------------------------------------------

@enum MetricType PercentMetric PixelMetric

immutable Metric{M}
  val::Float64
end

typealias Px Metric{PixelMetric}
typealias Pct Metric{PercentMetric}

"This allows combination of percent and pixel metrics"
immutable Distance
  pct::Float64
  px::Float64
end

convert(::Type{Distance}, pct::Pct) = Distance(pct, 0.0)
convert(::Type{Distance}, px::Px) = Distance(0.0, px)

"defines a view inside the widget area"
immutable ViewBox
  x::Px
  y::Px
  w::Px
  h::Px
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
  for item in items
    draw(item, painter, view.box)
  end
end

# ---------------------------------------------------

type Ellipse <: Shape
  x::Distance
  y::Distance
  w::Distance
  h::Distance
  pen
  brush
end

function draw(item::Ellipse, painter, box::ViewBox)
  # xy, wh = convertPctToSceneCoords(box, center, radius)
  x = px_x(item.x, box)
  y = px_y(item.y, box)
  w = px_w(item.w, box)
  h = px_h(item.h, box)
  @cxx painter->setPen(item.pen)
  @cxx painter->setBrush(item.brush)
  @cxx painter->drawEllipse(x, y, w, h)
end

push!(scene::Union{Scene,Layer}, item::Ellipse) = push!(scene.items, item)

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

function Pen(cstr::ASCIIString)
  @cxx QPen(pointer(cstr))
end

function Brush(cstr::ASCIIString)
  @cxx QBrush(pointer(cstr))
end

# Base.display(c::Canvas) = @cxx (c.widget)->show()

# ----------------------------------------------------

function render(painter)
  dump(painter)
  nothing
end

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


