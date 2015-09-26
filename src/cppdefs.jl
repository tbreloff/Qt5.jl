
# ---------------------------------------------------------------

cxx"""
  

  class MyCanvas : public QWidget
  {
    // Q_OBJECT

  public:
      // enum Shape { Line, Points, Polyline, Polygon, Rect, RoundedRect, Ellipse, Arc,
      //              Chord, Pie, Path, Text, Pixmap };

    MyCanvas(int idx) : _idx(idx)
    {
        // shape = Polygon;
        // antialiased = false;
        // transformed = false;
        // // pixmap.load(":/images/qt-logo.png");

        // setBackgroundRole(QPalette::Base);
        // setAutoFillBackground(true);
    }

    int getidx() { return _idx; }

      // QSize minimumSizeHint() const Q_DECL_OVERRIDE;
      // QSize sizeHint() const Q_DECL_OVERRIDE;

  // public slots:
      // void setShape(Shape shape);
      // void setPen(const QPen &pen);
      // void setBrush(const QBrush &brush);
      // void setAntialiased(bool antialiased);
      // void setTransformed(bool transformed);

  protected:
      void paintEvent(QPaintEvent *event)  
      {
        std::cout << "PAINT! " << std::endl;
        $:(paint( icxx"return this;" )::Void);
      }

  private:
    int _idx;
      // Shape shape;
      // QPen pen;
      // QBrush brush;
      // bool antialiased;
      // bool transformed;
      // QPixmap pixmap;
  };


// QCanvas::QCanvas(QWidget *parent)

// QSize QCanvas::minimumSizeHint() const
// {
//     return QSize(100, 100);
// }

// QSize QCanvas::sizeHint() const
// {
//     return QSize(400, 200);
// }

// void QCanvas::setShape(Shape shape)
// {
//     this->shape = shape;
//     update();
// }

// void QCanvas::setPen(const QPen &pen)
// {
//     this->pen = pen;
//     update();
// }

// void QCanvas::setBrush(const QBrush &brush)
// {
//     this->brush = brush;
//     update();
// }

// void QCanvas::setAntialiased(bool antialiased)
// {
//     this->antialiased = antialiased;
//     update();
// }

// void QCanvas::setTransformed(bool transformed)
// {
//     this->transformed = transformed;
//     update();
// }

// void QCanvas::paintEvent(QPaintEvent * /* event */)
// {
//   std::cout << "PAINT! " << std::endl;

//     // static const QPoint points[4] = {
//     //     QPoint(10, 80),
//     //     QPoint(20, 10),
//     //     QPoint(80, 30),
//     //     QPoint(90, 70)
//     // };

//     // QRect rect(10, 20, 80, 60);

//     // QPainterPath path;
//     // path.moveTo(20, 80);
//     // path.lineTo(20, 30);
//     // path.cubicTo(80, 0, 50, 50, 80, 80);

//     // int startAngle = 20 * 16;
//     // int arcLength = 120 * 16;

//     // QPainter painter(this);
//     // painter.setPen(pen);
//     // painter.setBrush(brush);
//     // if (antialiased)
//     //     painter.setRenderHint(QPainter::Antialiasing, true);

//     // for (int x = 0; x < width(); x += 100) {
//     //     for (int y = 0; y < height(); y += 100) {
//     //         painter.save();
//     //         painter.translate(x, y);
//     //         if (transformed) {
//     //             painter.translate(50, 50);
//     //             painter.rotate(60.0);
//     //             painter.scale(0.6, 0.9);
//     //             painter.translate(-50, -50);
//     //         }

//     //         switch (shape) {
//     //         case Line:
//     //             painter.drawLine(rect.bottomLeft(), rect.topRight());
//     //             break;
//     //         case Points:
//     //             painter.drawPoints(points, 4);
//     //             break;
//     //         case Polyline:
//     //             painter.drawPolyline(points, 4);
//     //             break;
//     //         case Polygon:
//     //             painter.drawPolygon(points, 4);
//     //             break;
//     //         case Rect:
//     //             painter.drawRect(rect);
//     //             break;
//     //         case RoundedRect:
//     //             painter.drawRoundedRect(rect, 25, 25, Qt::RelativeSize);
//     //             break;
//     //         case Ellipse:
//     //             painter.drawEllipse(rect);
//     //             break;
//     //         case Arc:
//     //             painter.drawArc(rect, startAngle, arcLength);
//     //             break;
//     //         case Chord:
//     //             painter.drawChord(rect, startAngle, arcLength);
//     //             break;
//     //         case Pie:
//     //             painter.drawPie(rect, startAngle, arcLength);
//     //             break;
//     //         case Path:
//     //             painter.drawPath(path);
//     //             break;
//     //         case Text:
//     //             painter.drawText(rect,
//     //                              Qt::AlignCenter,
//     //                              tr("Qt by\nThe Qt Company"));
//     //             break;
//     //         case Pixmap:
//     //             painter.drawPixmap(10, 10, pixmap);
//     //         }
//     //         painter.restore();
//     //     }
//     // }

//     // painter.setRenderHint(QPainter::Antialiasing, false);
//     // painter.setPen(palette().dark().color());
//     // painter.setBrush(Qt::NoBrush);
//     // painter.drawRect(QRect(0, 0, width() - 1, height() - 1));
// }



"""

# ---------------------------------------------------------------

cxx"""
  // class MyWindow : public QRasterWindow
  // {
  // public:
  //   MyWindow(int idx, const char* title, int w, int h) {
  //     std::cout << title << w << h << std::endl;
  //     m_idx = idx;
  //     setTitle(title);
  //     resize(w,h);
  //   }

  // protected:

  //   void render(QPainter *p) {
  //     std::cout << "here!" << std::endl;
  //     $:(render( icxx"return p;" )::Void);
  //   }

  // private:
  //   int m_idx;
  // };
"""


# ---------------------------------------------------------------


