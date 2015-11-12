
# ---------------------------------------------------------------

cxx"""
  #include <QOpenGLWidget>
  class MyGLCanvas : public QOpenGLWidget
  {

  public:
    // {};

    MyGLCanvas(int idx) : _idx(idx) {}
    int getidx() { return _idx; }

  protected:
    void paintGL() {
      $:(draw( icxx"return this;" )::Void);
    }

  private:
    int _idx;
  };


  class MyCanvas : public QWidget
  {

  public:
    // {};

    MyCanvas(int idx) : _idx(idx) {}
    int getidx() { return _idx; }

  protected:
    // just call the julia method `draw` and pass the MyCanvas pointer
    void paintEvent(QPaintEvent *event)  
    {
      $:(draw( icxx"return this;" )::Void);
    }


  private:
    int _idx;
  };
"""

# ---------------------------------------------------------------

# cxx"""
#   // class MyWindow : public QRasterWindow
#   // {
#   // public:
#   //   MyWindow(int idx, const char* title, int w, int h) {
#   //     std::cout << title << w << h << std::endl;
#   //     m_idx = idx;
#   //     setTitle(title);
#   //     resize(w,h);
#   //   }

#   // protected:

#   //   void render(QPainter *p) {
#   //     std::cout << "here!" << std::endl;
#   //     $:(render( icxx"return p;" )::Void);
#   //   }

#   // private:
#   //   int m_idx;
#   // };
# """


# ---------------------------------------------------------------


