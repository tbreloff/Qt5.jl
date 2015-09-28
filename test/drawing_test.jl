using Cxx

include("/home/tom/.julia/v0.5/Qt5/src/Qt5.jl")
q.QApplication()
scene = q.Scene()

# e1 = q.Ellipse(q.Pct(0.5), q.Pct(0.5),
#                q.Pct(1), q.Pct(0.5),
#                q.Pen("black"), q.Brush("red"))
# push!(scene, e1)
# display(scene)
# e1.h = 0.8
# display(scene)

vw = q.View(q.ViewBox(300,0,300,300), q.SceneItem[])
push!(scene, vw)

e2 = q.Ellipse(q.Pct(0.5), q.Pct(0.5),
               q.Pct(1), q.Pct(0.5),
               q.Pen("black"), q.Brush("blue"))
push!(vw, e2)
display(scene)

for i in 1:100
   push!(scene, q.Ellipse(rand(),rand(),0.1,0.1,q.Pen("black"),q.Brush("orange")))
end
display(scene)