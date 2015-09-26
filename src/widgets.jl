
# ----------------------------------------------------

abstract Layer

type Scene
  canvas
  layers::Vector{Layer}
end

const _scenes = Dict{Int, Scene}()

function paint(canvas)
  dump(canvas)

  # get the index of the canvas
  idx = @cxx canvas->getidx()

  # grab the scene object
  scene = _scenes[idx]
  dump(scene)

  # set up the painter
  painter = @cxxnew QPainter(canvas)
  @cxx painter->setRenderHint(@cxx(QPainter::Antialiasing), true)

  # draw something
  p = Pen("blue")
  @cxx painter->setPen(p)
  @cxx painter->drawEllipse(50.0, 50.0, 50.0, 20.0)

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

"This is the window (in pixels relative to the canvas) for drawing"
immutable ParentCoords
  x::Float64
  y::Float64
  w::Float64
  h::Float64
end

"holds a list of child scene items and the coordinates"
type ViewLayer <: Layer
  coords::ParentCoords
  items::Vector{SceneItem}
end

# ----------------------------------------------------

abstract SceneItem

type Circle <: SceneItem
  centerx::Float64
  centery::Float64
  radius::Float64
end

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


