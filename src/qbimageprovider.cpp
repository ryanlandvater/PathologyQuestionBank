//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

#include "qbimageprovider.h"

QBImageProvider::QBImageProvider(QBClient* client) :
    QQuickImageProvider(QQuickImageProvider::Image,
                        QQuickImageProvider::ForceAsynchronousImageLoading),
    _client(client)
{

}

QImage QBImageProvider::requestImage(const QString &id, QSize *size, const QSize &)
{
    const QImage& image = _images.find(id).value();

    if (size)
        *size = QSize(image.width(), image.height());

    return image;
}

void QBImageProvider::clear()
{
    _images.clear();
}

void QBImageProvider::addImage(const QString &id, QImage& image)
{
    _images.insert(id, image);
}

void QBImageProvider::removeImage(const QString &IMGID)
{
    _images.remove(IMGID);
}


