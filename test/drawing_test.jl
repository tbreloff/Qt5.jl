using Cxx

include("/home/tom/.julia/v0.5/Qt5/src/Qt5.jl")
q.QApplication()
# const scene = q.Scene()

# # e1 = q.Ellipse(q.Pct(0.5), q.Pct(0.5),
# #                q.Pct(1), q.Pct(0.5),
# #                q.Pen("black"), q.Brush("red"))
# # push!(scene, e1)
# # display(scene)
# # e1.h = 0.8
# # display(scene)

# const vw = q.View(q.ViewBox(300,0,300,300), q.SceneItem[])
# push!(scene, vw)
# display(scene)

# # e2 = q.Ellipse(q.Pct(0.5), q.Pct(0.5),
# #                q.Pct(1), q.Pct(0.5),
# #                q.Pen("black"), q.Brush("blue"))
# # push!(vw, e2)
# # display(scene)

function addcircles(scene)
  pen = q.Pen("black")
  brush = q.Brush("orange")
  vw = scene.items[1]
  for i in 1:1000000
     push!(vw, q.Ellipse(rand(),rand(),0.03,0.03,pen,brush))
  end
end

function dotest()
  scene = q.Scene()

  vw = q.View(q.ViewBox(300,0,300,300), q.SceneItem[])
  push!(scene, vw)
  display(scene)

  @time addcircles(scene)
  @time display(scene)
end

