#include "DocumentStore.h"

#include <chrono>
#include <QDir>
#include <QStandardPaths>
#include <QDebug>

using namespace DocumentScanner;
using namespace cv;

QImage convertMat2QImage(const Mat &img)
{
	// TODO do we ensure the OpenCV image type?
	return QImage((uchar*) img.data, img.cols, img.rows, 
						img.step, QImage::Format_RGB888);
}

QString getTimeStampNow()
{
	return QString::number(std::chrono::duration_cast<std::chrono::milliseconds>(
		std::chrono::system_clock::now().time_since_epoch()).count());
}

QString joinPath(QString d1, QString d2)
{
	return QFileInfo(QDir(d1), d2).path();
}

QString getDocumentBaseDir()
{
	QDir doc(joinPath(QStandardPaths::writableLocation(QStandardPaths::CacheLocation), "docs"));
	if (!doc.exists() && !doc.mkpath("."))
	{
		qDebug() << "Failed to create document base directory " << doc.absolutePath();
	}
	return doc.absolutePath();
}

QString getDocumentDir(const QString &id)
{
	QDir doc(joinPath(getDocumentBaseDir(), id));
	if (!doc.exists() && !doc.mkpath("."))
	{
		qDebug() << "Failed to create document directory " << doc.absolutePath();
	}
	return doc.absolutePath();
}

QStringList getIDsFromCache()
{
	QDir base(getDocumentBaseDir());
	base.setFilter(QDir::Dirs | QDir::NoDotAndDotDot | QDir::NoDotDot);
	return base.entryList();
}

QString getRawImagePath(const QString &id)
{
	QFileInfo(getDocumentDir(id), "raw.jpg").absolutePath();
}

QString getDocImagePath(const QString &id)
{
	QFileInfo(getDocumentDir(id), "doc.jpg").absolutePath();
}

QString URL2Path(const QString &URL)
{
	if (URL.startsWith("file://"))
	{
		return URL.right(URL.size()-7);
	}
	return URL;
}

Document createDocument(const QString &imageURL)
{
  QString imagePath = URL2Path(imageURL);

  Mat img = imread(imagePath.toStdString());
  if (!img.data)
  {
	  qDebug() << "image does not exist or is invalid: " << imagePath;
  }
  return Document(img);
}

QImage DocumentStore::requestImage(const QString &id, QSize *size, 
								const QSize &requestedSize)
{
	QImage img;
	
    if (m_documents.count(id))
    {
		img = convertMat2QImage(m_documents.at(id).getDocImage());
		QSize sizeOrig = img.size();
	
		if (size)
		  *size = sizeOrig;
		
		QSize newSize(requestedSize.width() > 0 ? requestedSize.width() : sizeOrig.width(),
					  requestedSize.height() > 0 ? requestedSize.height() : sizeOrig.height());
		img = img.scaled(newSize, Qt::KeepAspectRatio); 
	}
	else
    {
		qDebug() << "Tried to access document with invalid id " << id;	
		if (size)
			*size = QSize(0, 0);
	}	
	return img;
}

QString DocumentStore::addDocument(const QString &url)
{
	Document d = createDocument(url);
	QString id = getTimeStampNow();
	
	if (!m_documents.count(id))
    {
		m_documents.insert(std::pair<QString,Document>(id,d));
		return id;
	}
	else
    {
		qDebug() << "Incredible! A document with the exact same timestamp already existed! We met a document from the future with id " << id;	
		return QString();
	}
}

void DocumentStore::cacheDocument(const QString &id)
{
	if (m_documents.count(id))
    {
		Document d = m_documents.at(id);
		imwrite(getRawImagePath(id).toStdString(), d.getRawImage());
		imwrite(getDocImagePath(id).toStdString(), d.getDocImage());
	}
	else
    {
		qDebug() << "Tried to access document with invalid id " << id;	
	}
}


void DocumentStore::removeDocument(const QString &id)
{
	if (m_documents.count(id))
    {
		//TODO remove document from cache
		m_documents.erase(id);
	}
	else
    {
		qDebug() << "Tried to access document with invalid id " << id;	
	}
}

Document& DocumentStore::accessDocument(const QString &id)
{
	if (m_documents.count(id))
    {
		return m_documents.at(id);
	}
	else
    {
		qDebug() << "Tried to access document with invalid id " << id;	
		return m_dummy;
	}	
}

QStringList DocumentStore::getIDs()
{
	QStringList ids;
	ids.reserve(m_documents.size());
	for (auto const& idmap : m_documents)
		ids.push_back(idmap.first);	
	return ids;
}

QStringList DocumentStore::restoreCache()
{
	QStringList ids = getIDsFromCache();
	for (QString id:ids)
		addDocument(getRawImagePath(id));
	return ids;
}