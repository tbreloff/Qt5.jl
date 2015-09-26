
# ---------------------------------------------------------------


cxx"""
  
  #include <QBrush>
  #include <QPen>
  #include <QPixmap>
  #include <QWidget>

  class RenderArea : public QWidget
  {
    Q_OBJECT

  public:
      enum Shape { Line, Points, Polyline, Polygon, Rect, RoundedRect, Ellipse, Arc,
                   Chord, Pie, Path, Text, Pixmap };

      RenderArea(QWidget *parent = 0);

      QSize minimumSizeHint() const Q_DECL_OVERRIDE;
      QSize sizeHint() const Q_DECL_OVERRIDE;

  public slots:
      void setShape(Shape shape);
      void setPen(const QPen &pen);
      void setBrush(const QBrush &brush);
      void setAntialiased(bool antialiased);
      void setTransformed(bool transformed);

  protected:
      void paintEvent(QPaintEvent *event) Q_DECL_OVERRIDE;

  private:
      Shape shape;
      QPen pen;
      QBrush brush;
      bool antialiased;
      bool transformed;
      QPixmap pixmap;
  };
"""

# ---------------------------------------------------------------

cxx"""
  class MyWindow : public QRasterWindow
  {
  public:
    MyWindow(int idx, const char* title, int w, int h) {
      std::cout << title << w << h << std::endl;
      m_idx = idx;
      setTitle(title);
      resize(w,h);
      //m_timerId = startTimer(1000);
    }

  protected:

    void render(QPainter *p) {
      std::cout << "here!" << std::endl;
      $:(render( icxx"return p;" )::Void);
    }

  private:
    int m_idx;
  };
"""


# ---------------------------------------------------------------


