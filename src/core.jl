
# @osx_only begin
#     const qtlibdir = "/Users/kfischer/Projects/qt-everywhere-opensource-src-5.3.1/qtbase/~/usr/lib/"
#     const QtCore = joinpath(qtlibdir,"QtCore.framework/")
#     const QtWidgets = joinpath(qtlibdir,"QtWidgets.framework/")

#     addHeaderDir(qtlibdir; isFramework = true, kind = C_System)

#     dlopen(joinpath(QtCore,"QtCore_debug"))
#     addHeaderDir(joinpath(QtCore,"Headers"), kind = C_System)
#     addHeaderDir("/Users/kfischer/Projects/qt-everywhere-opensource-src-5.3.1/qtbase/lib/QtCore.framework/Headers/5.3.1/QtCore")

#     cxxinclude("/Users/kfischer/Projects/qt-everywhere-opensource-src-5.3.1/qtbase/lib/QtCore.framework/Headers/5.3.1/QtCore/private/qcoreapplication_p.h")

#     dlopen(joinpath(QtWidgets,"QtWidgets"))
#     addHeaderDir(joinpath(QtWidgets,"Headers"), kind = C_System)
# end

using Cxx

@linux_only begin
  # TODO: probably allow for overrides from ENV

  const qtincdir = "/usr/include/qt5"
  addHeaderDir(qtincdir, kind = C_System)
  for dir in ("QtCore", "QtWidgets", "QtGui")
    addHeaderDir(joinpath(qtincdir, "$dir/"), kind = C_System)
  end

  const qtlibdir = "/usr/lib64"
  for lib in ("libQt5Core.so", "libQt5Gui.so", "libQt5Widgets.so")
    Libdl.dlopen(joinpath(qtlibdir, lib), Libdl.RTLD_GLOBAL)
  end
end

# basic includes
cxx"""
  #include <iostream>
  #include <QtCore>
  #include <QApplication>
  #include <QMessageBox>
  #include <QPushButton>
  // #include <QMainWindow>
  // #include <QWindow>
  // #include <QRasterWindow>
  #include <QBrush>
  #include <QPen>
  #include <QPixmap>
  #include <QWidget>
  #include <QPainter>
"""

type QApplication
  qapp
end

function QApplication()

  # create the args/nargs
  global const ac = [Int32(1)]
  global const a = "julia"
  x = Ptr{UInt8}[pointer(a),C_NULL]

  # create the QApplication
  global const app = QApplication(@cxxnew QApplication(*(pointer(ac)),pointer(x)))

  # quit on finalize  # TODO: make this work... not getting called
  # finalizer(app, quitapp)

  startEventLoop()
  app
end

function quitapp(app)
  @cxx (app.qapp)->quit()
end

# this will be called from the julia main loop
function update_loop(_timer)
    icxx"""
        $(app.qapp)->processEvents();
    """
end

# starts a timer which will call the QApplication's processEvents()
function startEventLoop()
  Base.Timer( update_loop, 0.1, 0.005 )
end
