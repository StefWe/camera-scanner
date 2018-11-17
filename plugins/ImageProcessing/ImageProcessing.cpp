#include <QDebug>
#include <QtGui/QImage>
#include <QString>

#include <iostream>
#include <vector>
#include <cmath>

#include <QFileInfo>
#include <QDir>

#include "ImageProcessing.h"
#include "Document.h"

using namespace DocumentScanner;

ImageProcessing::ImageProcessing() {
  /* empty */
  //TODO define default params
  //TODO load params from config
}
void ImageProcessing::restoreCache()
{
	for (QString id : m_store.restoreCache())
		emit imageAdded(id);
}

void ImageProcessing::addImage(const QString &imageURL)
{
	QString id = m_store.addDocument(imageURL);
	m_store.cacheDocument(id);
	emit imageAdded(id);
	processImage(id);
}

void ImageProcessing::processImage(const QString &id)
{
	Document &d = m_store.accessDocument(id);
	d.detectDocument();
	emit imageProcessed(id, d.docDetected()); 
}

void ImageProcessing::removeImage(const QString &id)
{
	m_store.removeDocument(id);
	emit imageRemoved(id);
}

void ImageProcessing::removeAll()
{
	for (QString id : m_store.getIDs())
		removeImage(id);
}

bool ImageProcessing::isDocument(const QString &id)
{
	return m_store.accessDocument(id).docDetected();
}

void ImageProcessing::setParam(const QString &key, const QString &value)
{
	qDebug() << "ImageProcessing::setParam() not yet implemented";
//TODO
}

QString ImageProcessing::getParam(const QString &key)
{
	qDebug() << "ImageProcessing::getParam() not yet implemented";
//TODO
}
