

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
    const qtincdir = "/usr/include/qt5"
    const qtlibdir = "/usr/lib64"
    const QtCore = joinpath(qtincdir, "QtCore/")
    const QtWidgets = joinpath(qtincdir, "QtWidgets/")

    addHeaderDir(qtincdir, kind = C_System)
    addHeaderDir(QtCore, kind = C_System)
    addHeaderDir(QtWidgets, kind = C_System)

    Libdl.dlopen(joinpath(qtlibdir,"libQt5Core.so"), Libdl.RTLD_GLOBAL)
    Libdl.dlopen(joinpath(qtlibdir,"libQt5Gui.so"), Libdl.RTLD_GLOBAL)
    Libdl.dlopen(joinpath(qtlibdir,"libQt5Widgets.so"), Libdl.RTLD_GLOBAL)
end

cxx"""
    #include <QtCore>
    #include <QApplication>
    #include <QMessageBox>
    #include <QPushButton>
"""

# # init the QApplication object
# function initApp()
#     # notes: This is pretty stupid, but it seems QApplication is capturing the pointer
#     # to the reference, so we can't just # stack allocate it because that won't
#     # be valid for exec
#     ac = [Int32(1)]
#     global const a = "julia"
#     x = Ptr{UInt8}[pointer(a),C_NULL]
#     app = @cxxnew QApplication(*(pointer(ac)),pointer(x))
# end
# const app = initApp()


const ac = [Int32(1)]
const a = "julia"
x = Ptr{UInt8}[pointer(a),C_NULL]
const app = @cxxnew QApplication(*(pointer(ac)),pointer(x))


# this will be called from the julia main loop
function update_loop(_timer)
    icxx"""
        $app->processEvents();
    """
end

function startEventLoop()
    # kick off the gui loop callbacks
    Base.Timer( update_loop, 0.1, 0.005 )
end


# BUG: this version doesn't work - unresponsive gui
#update_loop(_timer) = @cxx app.processEvents() # default QEventFlags::AllEvents


# add silly test
say_hi() = println("Hi!")::Void
cxx"""
#include <iostream>
void handle_hi()
{
    $:(say_hi());
}
"""


function createMessageBox()
    # create messagebox
    mb = @cxxnew QMessageBox(@cxx(QMessageBox::Information),
                          pointer("Hello World"),
                          pointer("This is a QMessageBox"))

    # add buttons
    @cxx mb->addButton(@cxx(QMessageBox::Ok))

    hibtn = @cxxnew QPushButton(pointer("Say Hi!"))
    @cxx mb->addButton(hibtn, @cxx(QMessageBox::ActionRole))

    setup(hibtn)

    # display the window
    @cxx mb->setWindowModality(@cxx(Qt::NonModal))
    @cxx mb->show()

    mb
end

# BUGS?
# - type translation doesn't work right for $:(btn) if I call connect from a cxx""" block
# - I get isexprs assertion failure if I try to use a lambda. think it might be a
#   block parsing issue though.
function setup(btn)
    icxx"""
        QObject::connect($btn, &QPushButton::clicked, handle_hi );
    """
end
# setup(hibtn)




# exit if not interactive shell
!isinteractive() && stop_timer(timer)
