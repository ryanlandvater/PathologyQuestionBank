//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

#ifndef QBIMAGEPROVIDER_H
#define QBIMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QImage>
#include <boost/shared_ptr.hpp>

//#define IMAGE_ENTRY boost::shared_ptr<const QImage>
class QBClient;
class QBImageProvider : public QQuickImageProvider
{
    friend class QBClient;

    QBClient*                           _client;
    QHash <const QString,QImage>        _images;

public:

    explicit QBImageProvider(QBClient* client);

    // Virtual function that allows for image access
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;
    void clear();

protected:
    void addImage(const QString& IMGID, QImage&);
    void removeImage(const QString& IMGID);

};

#endif // QBIMAGEPROVIDER_H
