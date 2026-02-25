#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "MetroWordleBackend.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    MetroWordleBackend backend;
    engine.rootContext()->setContextProperty(QStringLiteral("wordleBackend"), &backend);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("MetroWordleC", "Main");

    return app.exec();
}
