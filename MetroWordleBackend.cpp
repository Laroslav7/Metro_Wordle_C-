#include "MetroWordleBackend.h"

#include <QByteArray>
#include <QDateTime>
#include <QRandomGenerator>
#include <QRegularExpression>
#include <QUrl>

MetroWordleBackend::MetroWordleBackend(QObject *parent)
    : QObject(parent)
    , m_wordsDb({
          QStringLiteral("ДОМ"), QStringLiteral("УЛИЦА"), QStringLiteral("ГОРОД"), QStringLiteral("СТРАНА"),
          QStringLiteral("МИР"), QStringLiteral("ЧЕЛОВЕК"), QStringLiteral("ЛЮДИ"), QStringLiteral("ДРУГ"),
          QStringLiteral("СЕМЬЯ"), QStringLiteral("ВРЕМЯ"), QStringLiteral("ЖИЗНЬ"), QStringLiteral("СЛОВО"),
          QStringLiteral("ПРОБЛЕМА"), QStringLiteral("РЕШЕНИЕ"), QStringLiteral("МАГАЗИН"), QStringLiteral("ШКОЛА"),
          QStringLiteral("ТЕЛЕФОН"), QStringLiteral("КОМПЬЮТЕР"), QStringLiteral("ИНТЕРНЕТ"), QStringLiteral("ИГРА"),
          QStringLiteral("МУЗЫКА"), QStringLiteral("ФИЛЬМ"), QStringLiteral("ВИДЕО"), QStringLiteral("ПОГОДА"),
          QStringLiteral("СОЛНЦЕ"), QStringLiteral("ЛУНА"), QStringLiteral("ЗВЕЗДА"), QStringLiteral("СНЕГ"),
          QStringLiteral("РАДОСТЬ"), QStringLiteral("МЕЧТА"), QStringLiteral("ПОБЕДА"), QStringLiteral("ПУТЬ"),
          QStringLiteral("ОПЫТ"), QStringLiteral("ПАМЯТЬ"), QStringLiteral("НОВОСТЬ"), QStringLiteral("ИСТОРИЯ"),
          QStringLiteral("СИТУАЦИЯ"), QStringLiteral("ПРАВИЛО"), QStringLiteral("ЗАКОН"), QStringLiteral("КОМАНДА"),
          QStringLiteral("ЛИДЕР"), QStringLiteral("ПРОЕКТ"), QStringLiteral("РЕЗУЛЬТАТ"), QStringLiteral("СИСТЕМА"),
          QStringLiteral("КАЧЕСТВО"), QStringLiteral("ЗНАЧЕНИЕ"), QStringLiteral("ИНФОРМАЦИЯ"), QStringLiteral("ФАЙЛ"),
          QStringLiteral("ПАПКА"), QStringLiteral("ПРОГРАММА"), QStringLiteral("ПРИЛОЖЕНИЕ"), QStringLiteral("СЕРВИС"),
          QStringLiteral("СТРАНИЦА"), QStringLiteral("ССЫЛКА"), QStringLiteral("ПРОФИЛЬ"), QStringLiteral("АККАУНТ"),
          QStringLiteral("ПАРОЛЬ"), QStringLiteral("СЕТЬ"), QStringLiteral("СЕРВЕР"), QStringLiteral("КЛИЕНТ"),
          QStringLiteral("ЗАПРОС"), QStringLiteral("СТАТУС"), QStringLiteral("ПОКУПКА"), QStringLiteral("ОПЛАТА"),
          QStringLiteral("БЮДЖЕТ"), QStringLiteral("ФИНАНСЫ"), QStringLiteral("БИЗНЕС"), QStringLiteral("БРЕНД"),
          QStringLiteral("ТРЕНД"), QStringLiteral("БУДУЩЕЕ"), QStringLiteral("ИННОВАЦИЯ"), QStringLiteral("ПРОДУКТ"),
          QStringLiteral("МЕНЕДЖМЕНТ"), QStringLiteral("КУЛЬТУРА"), QStringLiteral("ДЕДЛАЙН"), QStringLiteral("ВАЖНОСТЬ"),
          QStringLiteral("КРИНЖ"), QStringLiteral("РОФЛ"), QStringLiteral("ЧИЛЛ"), QStringLiteral("ХАЙП"),
          QStringLiteral("СКИЛЛ"), QStringLiteral("БАГ"), QStringLiteral("ФИЧА"), QStringLiteral("СТРИМ"),
          QStringLiteral("ДОНАТ"), QStringLiteral("ТИКТОК"), QStringLiteral("ЮТУБ"), QStringLiteral("ЧАТ"),
          QStringLiteral("БОТ"), QStringLiteral("НЕЙРОСЕТЬ"), QStringLiteral("АНДРОИД"), QStringLiteral("ГАДЖЕТ"),
          QStringLiteral("ПЛАНШЕТ"), QStringLiteral("НОУТБУК"), QStringLiteral("ВАЙФАЙ"), QStringLiteral("БЛЮТУЗ")
      })
{
}

QString MetroWordleBackend::targetWord() const { return m_targetWord; }
int MetroWordleBackend::currentAttempt() const { return m_currentAttempt; }
int MetroWordleBackend::currentTile() const { return m_currentTile; }
bool MetroWordleBackend::gameOver() const { return m_gameOver; }
QString MetroWordleBackend::gameType() const { return m_gameType; }

QString MetroWordleBackend::sanitizeRussianWord(const QString &value) const
{
    QString v = value.trimmed().toUpper();
    v.remove(QRegularExpression(QStringLiteral("[^А-ЯЁ]")));
    return v;
}

void MetroWordleBackend::resetGame()
{
    m_currentAttempt = 0;
    m_currentTile = 0;
    m_gameOver = false;
    m_guessRows.clear();
    emit gameChanged();
}

void MetroWordleBackend::startRandomMode()
{
    resetGame();
    m_targetWord = m_wordsDb.at(QRandomGenerator::global()->bounded(m_wordsDb.size()));
    m_gameType = QStringLiteral("Случайное Metro Wordle");
    emit gameChanged();
}

bool MetroWordleBackend::startFriendMode(const QString &encodedHash)
{
    const QByteArray decoded = QByteArray::fromBase64(encodedHash.toUtf8());
    const QString word = sanitizeRussianWord(QString::fromUtf8(decoded));
    if (word.length() < 3)
        return false;

    resetGame();
    m_targetWord = word;
    m_gameType = QStringLiteral("Metro Wordle от друга");
    emit gameChanged();
    return true;
}

QString MetroWordleBackend::generateLink(const QString &word, const QString &baseUrl)
{
    const QString clean = sanitizeRussianWord(word);
    if (clean.length() < 3)
        return QString();

    const QString encoded = QString::fromUtf8(clean.toUtf8().toBase64());
    return baseUrl + QStringLiteral("#") + encoded;
}

QString MetroWordleBackend::addLetter(const QString &letter)
{
    if (m_gameOver || m_targetWord.isEmpty())
        return QString();

    const QString cleaned = sanitizeRussianWord(letter);
    if (cleaned.isEmpty())
        return QString();

    if (m_guessRows.size() <= m_currentAttempt)
        m_guessRows.resize(m_currentAttempt + 1);

    if (m_guessRows[m_currentAttempt].size() >= m_targetWord.size())
        return QString();

    m_guessRows[m_currentAttempt].append(cleaned.front());
    m_currentTile = m_guessRows[m_currentAttempt].size();
    emit gameChanged();
    return m_guessRows[m_currentAttempt];
}

QString MetroWordleBackend::deleteLetter()
{
    if (m_gameOver || m_targetWord.isEmpty())
        return QString();

    if (m_guessRows.size() <= m_currentAttempt || m_guessRows[m_currentAttempt].isEmpty())
        return QString();

    m_guessRows[m_currentAttempt].chop(1);
    m_currentTile = m_guessRows[m_currentAttempt].size();
    emit gameChanged();
    return m_guessRows[m_currentAttempt];
}

QVariantList MetroWordleBackend::revealResults(const QString &guess) const
{
    QVariantList results;
    QStringList targetLetters;
    for (const QChar ch : m_targetWord)
        targetLetters << QString(ch);

    QStringList states;
    states.fill(QStringLiteral("absent"), m_targetWord.size());

    for (int i = 0; i < m_targetWord.size(); ++i) {
        if (guess[i] == m_targetWord[i]) {
            states[i] = QStringLiteral("correct");
            targetLetters[i] = QString();
        }
    }

    for (int i = 0; i < m_targetWord.size(); ++i) {
        if (states[i] == QStringLiteral("absent")) {
            const int idx = targetLetters.indexOf(QString(guess[i]));
            if (idx >= 0) {
                states[i] = QStringLiteral("present");
                targetLetters[idx] = QString();
            }
        }
    }

    for (int i = 0; i < m_targetWord.size(); ++i) {
        QVariantMap entry;
        entry[QStringLiteral("index")] = i;
        entry[QStringLiteral("state")] = states[i];
        entry[QStringLiteral("letter")] = QString(guess[i]);
        results << entry;
    }
    return results;
}

QVariantMap MetroWordleBackend::submitGuess()
{
    QVariantMap out;
    if (m_targetWord.isEmpty()) {
        out[QStringLiteral("message")] = QStringLiteral("Начните новую игру");
        return out;
    }

    if (m_guessRows.size() <= m_currentAttempt)
        m_guessRows.resize(m_currentAttempt + 1);

    const QString guess = m_guessRows[m_currentAttempt];
    if (guess.size() < m_targetWord.size()) {
        out[QStringLiteral("message")] = QStringLiteral("Мало букв!");
        return out;
    }

    out[QStringLiteral("guess")] = guess;
    out[QStringLiteral("results")] = revealResults(guess);

    if (guess == m_targetWord) {
        m_gameOver = true;
        out[QStringLiteral("message")] = QStringLiteral("ПОБЕДА! 🎉");
    } else if (m_currentAttempt == MaxAttempts - 1) {
        m_gameOver = true;
        out[QStringLiteral("message")] = QStringLiteral("Слово было: ") + m_targetWord;
    } else {
        ++m_currentAttempt;
        m_currentTile = 0;
        out[QStringLiteral("message")] = QString();
    }

    out[QStringLiteral("gameOver")] = m_gameOver;
    out[QStringLiteral("attempt")] = m_currentAttempt;
    emit gameChanged();
    return out;
}
