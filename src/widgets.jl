



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


