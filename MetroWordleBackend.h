#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariant>
#include <QVariantMap>
#include <QVariantList>

class MetroWordleBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString targetWord READ targetWord NOTIFY gameChanged)
    Q_PROPERTY(int currentAttempt READ currentAttempt NOTIFY gameChanged)
    Q_PROPERTY(int currentTile READ currentTile NOTIFY gameChanged)
    Q_PROPERTY(bool gameOver READ gameOver NOTIFY gameChanged)
    Q_PROPERTY(QString gameType READ gameType NOTIFY gameChanged)

public:
    explicit MetroWordleBackend(QObject *parent = nullptr);

    QString targetWord() const;
    int currentAttempt() const;
    int currentTile() const;
    bool gameOver() const;
    QString gameType() const;

    Q_INVOKABLE void startRandomMode();
    Q_INVOKABLE bool startFriendMode(const QString &encodedHash);
    Q_INVOKABLE QString generateLink(const QString &word, const QString &baseUrl);
    Q_INVOKABLE void resetGame();
    Q_INVOKABLE QString addLetter(const QString &letter);
    Q_INVOKABLE QString deleteLetter();
    Q_INVOKABLE QVariantMap submitGuess();
    Q_INVOKABLE QVariantList revealResults(const QString &guess) const;

signals:
    void gameChanged();

private:
    QString sanitizeRussianWord(const QString &value) const;
    QStringList m_wordsDb;

    QString m_targetWord;
    int m_currentAttempt = 0;
    int m_currentTile = 0;
    bool m_gameOver = false;
    QString m_gameType = QStringLiteral("METRO WORDLE");
    QStringList m_guessRows;

    static constexpr int MaxAttempts = 6;
};
