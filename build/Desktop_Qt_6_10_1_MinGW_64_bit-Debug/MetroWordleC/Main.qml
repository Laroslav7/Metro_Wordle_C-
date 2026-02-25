import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.settings

Window {
    id: root
    width: 1400
    height: 860
    visible: true
    title: "Metro Wordle 1.2"
    color: "#111111"

    property color metroBlue: "#2d89ef"
    property color metroGreen: "#00a300"
    property color metroPurple: "#7459d1"
    property color metroRed: "#b91d47"
    property color metroTeal: "#117a90"
    property color metroRust: "#d6522e"
    property color metroYellow: "#e3a21a"
    property color metroOrange: "#da532c"
    property color metroIndigo: "#603cba"
    property color metroGray: "#555555"
    property color metroCyan: "#00879d"

    property bool editMode: false
    property string appTitle: "METRO WORDLE"
    property string currentView: ""
    property string messageText: ""
    property var boardRows: []
    property var keyStates: ({})

    readonly property int cellSize: 135
    readonly property int gapSize: 6

    function wordLength() { return wordleBackend.targetWord.length }

    function startRandom() {
        wordleBackend.startRandomMode()
        startGameUI()
    }

    function startGameUI() {
        appTitle = wordleBackend.gameType
        currentView = "gamePlay"
        messageText = ""
        keyStates = ({})
        buildBoard()
    }

    function buildBoard() {
        const rows = []
        for (let i = 0; i < 6; ++i) {
            let row = []
            for (let j = 0; j < wordLength(); ++j)
                row.push({letter: "", state: ""})
            rows.push(row)
        }
        boardRows = rows
    }

    function addLetter(letter) {
        if (!wordleBackend.targetWord || wordleBackend.gameOver) return
        const value = wordleBackend.addLetter(letter)
        if (!value) return
        const row = wordleBackend.currentAttempt
        for (let i = 0; i < wordLength(); ++i)
            boardRows[row][i].letter = i < value.length ? value[i] : ""
        boardRowsChanged()
    }

    function backspace() {
        const value = wordleBackend.deleteLetter()
        if (value === undefined) return
        const row = wordleBackend.currentAttempt
        for (let i = 0; i < wordLength(); ++i)
            boardRows[row][i].letter = i < value.length ? value[i] : ""
        boardRowsChanged()
    }

    function submitGuess() {
        const result = wordleBackend.submitGuess()
        if (result.message)
            messageText = result.message
        if (!result.results)
            return

        const guess = result.guess
        const row = result.attempt === wordleBackend.currentAttempt ? wordleBackend.currentAttempt - (wordleBackend.gameOver ? 0 : 1) : wordleBackend.currentAttempt
        for (let i = 0; i < result.results.length; ++i) {
            const r = result.results[i]
            boardRows[row][r.index].letter = r.letter
            boardRows[row][r.index].state = r.state
            if (!keyStates[r.letter] || r.state === "correct" || (r.state === "present" && keyStates[r.letter] === "absent"))
                keyStates[r.letter] = r.state
        }
        keyStatesChanged()
        boardRowsChanged()
    }

    function openApp(view, title) {
        appTitle = title
        currentView = view
    }

    function tileSpan(size) {
        if (size === "wide" || size === "large") return 2
        return 1
    }

    function tileRowSpan(size) {
        if (size === "large") return 2
        return 1
    }

    Settings {
        id: settings
        property var tileSizes: ({})
    }

    ListModel {
        id: tileModel
        ListElement { tileId: "game"; label: "Играть"; colorHex: "#2d89ef"; size: "large"; icon: "qrc:/bathroom_tiles/Game.png" }
        ListElement { tileId: "desktop"; label: "Рабочий стол"; colorHex: "#2b2b2b"; size: "wide"; icon: "qrc:/bathroom_tiles/Desktop.png" }
        ListElement { tileId: "me"; label: "M E"; colorHex: "#a200ff"; size: "wide"; icon: "" }
        ListElement { tileId: "return"; label: "Вернуться"; colorHex: "#117a90"; size: "wide"; icon: "qrc:/bathroom_tiles/Again.png" }
        ListElement { tileId: "weather"; label: "Погода"; colorHex: "#da532c"; size: "small"; icon: "qrc:/bathroom_tiles/weather.png" }
        ListElement { tileId: "about"; label: "О программе"; colorHex: "#d6522e"; size: "small"; icon: "qrc:/bathroom_tiles/info.png" }
        ListElement { tileId: "clock"; label: ""; colorHex: "#7459d1"; size: "wide"; icon: "" }
        ListElement { tileId: "music"; label: "Музыка"; colorHex: "#603cba"; size: "wide"; icon: "qrc:/bathroom_tiles/Music.png" }
        ListElement { tileId: "settings"; label: "Настройки"; colorHex: "#555555"; size: "wide"; icon: "qrc:/bathroom_tiles/Seting.png" }
        ListElement { tileId: "gallery"; label: "Галерея"; colorHex: "#00879d"; size: "wide"; icon: "qrc:/bathroom_tiles/Galery.png" }
        ListElement { tileId: "store"; label: "Microsoft Store"; colorHex: "#00a300"; size: "wide"; icon: "qrc:/bathroom_tiles/Store.png" }
        ListElement { tileId: "video"; label: "Видео"; colorHex: "#b21a41"; size: "small"; icon: "qrc:/bathroom_tiles/Video.png" }
        ListElement { tileId: "mail"; label: "Почта"; colorHex: "#008fa3"; size: "wide"; icon: "qrc:/bathroom_tiles/Mail.png" }
        ListElement { tileId: "explorer"; label: "Проводник"; colorHex: "#e3c800"; size: "large"; icon: "qrc:/bathroom_tiles/Explorer.png" }
    }

    Image { anchors.fill: parent; source: "qrc:/BackGround/LockScreen.png"; fillMode: Image.PreserveAspectCrop }
    Rectangle { anchors.fill: parent; color: "#33000000" }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 60
                anchors.rightMargin: 60
                Text { text: "Metro Wordle"; color: "white"; font.pixelSize: 46; font.weight: Font.Light }
                Item { Layout.fillWidth: true }
                Button {
                    text: "✎"
                    onClicked: editMode = !editMode
                    background: Rectangle { radius: 20; color: editMode ? metroRed : "transparent"; border.width: 2; border.color: "white" }
                    contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
                Row {
                    spacing: 12
                    Text { text: "User"; color: "white"; font.pixelSize: 22 }
                    Image { source: "qrc:/bathroom_tiles/user.png"; width: 40; height: 40 }
                }
            }
        }

        Flickable {
            Layout.fillHeight: true
            Layout.fillWidth: true
            contentWidth: grid.implicitWidth + 120
            contentHeight: height
            clip: true

            Grid {
                id: grid
                x: 60
                y: 10
                rows: 4
                flow: Grid.TopToBottom
                rowSpacing: gapSize
                columnSpacing: gapSize

                Repeater {
                    model: tileModel
                    delegate: Rectangle {
                        required property string tileId
                        required property string label
                        required property string colorHex
                        required property string size
                        required property string icon

                        width: cellSize * tileSpan(size) + gapSize * (tileSpan(size) - 1)
                        height: cellSize * tileRowSpan(size) + gapSize * (tileRowSpan(size) - 1)
                        color: colorHex

                        Text {
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            anchors.margins: 10
                            text: tileId === "clock" ? Qt.formatTime(new Date(), "hh:mm") + "\n" + Qt.formatDate(new Date(), "d MMMM") : label
                            color: "white"
                            font.pixelSize: tileId === "clock" ? 26 : (label === "M E" ? 54 : 18)
                            font.bold: label === "M E"
                        }

                        Image {
                            visible: icon.length > 0
                            source: icon
                            anchors.centerIn: parent
                            width: parent.width * 0.45
                            height: parent.height * 0.45
                            fillMode: Image.PreserveAspectFit
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (editMode) {
                                    const next = size === "small" ? "wide" : (size === "wide" ? "large" : "small")
                                    tileModel.setProperty(index, "size", next)
                                } else {
                                    if (tileId === "game") openApp("gameMenu", "METRO WORDLE")
                                    if (tileId === "about") openApp("about", "ИНФОРМАЦИЯ")
                                    if (tileId === "return" && !wordleBackend.gameOver && wordleBackend.targetWord) openApp("gamePlay", wordleBackend.gameType)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        visible: currentView !== ""
        anchors.fill: parent
        color: "#111"
        z: 10

        ColumnLayout {
            anchors.fill: parent
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                color: "#1f1f1f"
                Row {
                    spacing: 14
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 30
                    Button { text: "←"; onClicked: currentView = "" }
                    Text { text: appTitle; color: "white"; font.pixelSize: 30 }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Column {
                    anchors.centerIn: parent
                    spacing: 30
                    visible: currentView === "gameMenu"
                    Row {
                        spacing: 40
                        Rectangle {
                            width: 280; height: 280; color: metroBlue
                            Text { anchors.centerIn: parent; text: "Создать игру"; color: "white"; font.pixelSize: 32 }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    const link = wordleBackend.generateLink(createWord.text, "https://metro-wordle.local")
                                    linkOutput.text = link.length ? link : "Минимум 3 буквы"
                                }
                            }
                        }
                        Rectangle {
                            width: 280; height: 280; color: metroGreen
                            Text { anchors.centerIn: parent; text: "Случайно"; color: "white"; font.pixelSize: 32 }
                            MouseArea { anchors.fill: parent; onClicked: startRandom() }
                        }
                    }
                    TextField { id: createWord; placeholderText: "СЛОВО"; width: 360 }
                    Text { id: linkOutput; color: "#ccc" }
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 10
                    visible: currentView === "gamePlay"

                    Text { text: messageText; color: "white"; font.pixelSize: 24; horizontalAlignment: Text.AlignHCenter; width: parent.width }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6
                        Repeater {
                            model: boardRows.length
                            delegate: Row {
                                spacing: 6
                                property int rowIndex: index
                                Repeater {
                                    model: wordLength()
                                    delegate: Rectangle {
                                        width: 55
                                        height: 55
                                        border.color: "#444"
                                        border.width: 2
                                        color: {
                                            const st = boardRows[rowIndex][index].state
                                            if (st === "correct") return metroGreen
                                            if (st === "present") return metroYellow
                                            if (st === "absent") return "#3a3a3c"
                                            return "transparent"
                                        }
                                        Text { anchors.centerIn: parent; text: boardRows[rowIndex][index].letter; color: "white"; font.pixelSize: 30; font.bold: true }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 210
                        color: "#1a1a1a"
                        GridLayout {
                            anchors.centerIn: parent
                            columns: 12
                            columnSpacing: 5
                            rowSpacing: 5
                            Repeater {
                                model: ["Й","Ц","У","К","Е","Н","Г","Ш","Щ","З","Х","Ъ","Ф","Ы","В","А","П","Р","О","Л","Д","Ж","Э","Я","Ч","С","М","И","Т","Ь","Б","Ю"]
                                delegate: Rectangle {
                                    required property string modelData
                                    width: 48; height: 48
                                    color: keyStates[modelData] === "correct" ? metroGreen : keyStates[modelData] === "present" ? metroYellow : keyStates[modelData] === "absent" ? "#3a3a3c" : "#444"
                                    Text { anchors.centerIn: parent; text: modelData; color: "white"; font.bold: true }
                                    MouseArea { anchors.fill: parent; onClicked: addLetter(modelData) }
                                }
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 20
                        Button { text: "ENTER"; onClicked: submitGuess() }
                        Button { text: "⌫"; onClicked: backspace() }
                    }
                }

                Flickable {
                    visible: currentView === "about"
                    anchors.fill: parent
                    contentHeight: aboutText.height + 60
                    Text {
                        id: aboutText
                        width: parent.width - 120
                        x: 60
                        y: 40
                        color: "#eee"
                        wrapMode: Text.WordWrap
                        font.pixelSize: 24
                        text: "Metro Wordle\n\nУлучшенная версия Wordle\n\nИстория создания: Мы с друзьями играли в Wordle и заметили, что мало букв. Jonny_Silver решил создать свой Wordle — изначально назвав его Meme Wordle. Позже проект подхватил Laroslav7, который придумал концепцию Metro Wordle.\n\nВерсия: 1.2\nCEO: Jonny_Silver\nГлава разработок: Laroslav7\nПрограммисты: Google AI Studio, Gemini"
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        const args = Qt.application.arguments
        for (let i = 0; i < args.length; ++i) {
            if (args[i].indexOf("#") >= 0) {
                const hash = args[i].split("#")[1]
                if (wordleBackend.startFriendMode(hash)) {
                    startGameUI()
                    currentView = "gamePlay"
                }
                break
            }
        }
    }

    Shortcut {
        sequences: ["Return", "Enter"]
        onActivated: if (currentView === "gamePlay") submitGuess()
    }

    Shortcut {
        sequence: "Backspace"
        onActivated: if (currentView === "gamePlay") backspace()
    }

    Keys.onPressed: function(event) {
        if (currentView !== "gamePlay") return
        const t = event.text.toUpperCase()
        if (/^[А-ЯЁ]$/.test(t)) addLetter(t)
    }
}
