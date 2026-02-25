import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root
    width: 1400
    height: 860
    visible: true
    title: "Metro Wordle 1.2"
    color: "#0f0f0f"

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
    property color metroBrightPurple: "#a200ff"

    property bool editMode: false
    property string appTitle: "METRO WORDLE"
    property string currentView: ""
    property string currentGameStage: "menu"
    property string messageText: ""
    property string generatedCode: ""
    property string generatedLink: ""
    property var boardRows: []
    property var keyStates: ({})
    property date nowTime: new Date()

    readonly property int cellSize: 135
    readonly property int gapSize: 6

    function wordLength() { return wordleBackend.targetWord.length }

    function buildBoard() {
        const rows = []
        for (let i = 0; i < 6; ++i) {
            const row = []
            for (let j = 0; j < wordLength(); ++j)
                row.push({letter: "", state: ""})
            rows.push(row)
        }
        boardRows = rows
    }

    function startGameUI() {
        appTitle = wordleBackend.gameType
        currentView = "game"
        currentGameStage = "play"
        messageText = ""
        keyStates = ({})
        buildBoard()
    }

    function goGameMenu() {
        appTitle = "METRO WORDLE"
        currentView = "game"
        currentGameStage = "menu"
    }

    function startRandom() {
        wordleBackend.startRandomMode()
        startGameUI()
    }

    function startByCode(code) {
        if (wordleBackend.startCodeMode(code)) {
            startGameUI()
        } else {
            messageText = "Неверный код"
        }
    }

    function createGameWord() {
        generatedCode = wordleBackend.createGameCode(createWord.text)
        if (!generatedCode.length) {
            generatedLink = ""
            messageText = "Минимум 3 буквы"
            return
        }
        generatedLink = wordleBackend.generateLink(createWord.text, "https://metro-wordle.local")
        messageText = "Код готов"
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
        const row = wordleBackend.currentAttempt
        if (row < 0 || row >= boardRows.length) return
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

        const row = Math.max(0, wordleBackend.currentAttempt - (wordleBackend.gameOver ? 0 : 1))
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

    function tileSpan(size) {
        if (size === "wide" || size === "large") return 2
        return 1
    }

    function tileRowSpan(size) {
        if (size === "large") return 2
        return 1
    }

    function actionTileClicked(tileId) {
        if (editMode)
            return

        if (tileId === "game")
            goGameMenu()
        else if (tileId === "about") {
            appTitle = "ИНФОРМАЦИЯ"
            currentView = "about"
        } else if (tileId === "return" && wordleBackend.targetWord.length && !wordleBackend.gameOver) {
            appTitle = wordleBackend.gameType
            currentView = "game"
            currentGameStage = "play"
        }
    }

    ListModel {
        id: tileModel
        ListElement { tileId: "game"; label: "Играть"; colorHex: "#2d89ef"; size: "large"; icon: "qrc:/bathroom_tiles/Game.png"; glyph: "" }
        ListElement { tileId: "desktop"; label: "Рабочий стол"; colorHex: "#2b2b2b"; size: "wide"; icon: "qrc:/bathroom_tiles/Desktop.png"; glyph: "" }
        ListElement { tileId: "me"; label: ""; colorHex: "#a200ff"; size: "wide"; icon: ""; glyph: "M E" }
        ListElement { tileId: "return"; label: "Вернуться"; colorHex: "#117a90"; size: "wide"; icon: "qrc:/bathroom_tiles/Again.png"; glyph: "" }
        ListElement { tileId: "weather"; label: "Погода"; colorHex: "#da532c"; size: "small"; icon: "qrc:/bathroom_tiles/weather.png"; glyph: "" }
        ListElement { tileId: "let-t"; label: ""; colorHex: "#2d89ef"; size: "small"; icon: ""; glyph: "T" }
        ListElement { tileId: "let-r"; label: ""; colorHex: "#e3a21a"; size: "small"; icon: ""; glyph: "R" }
        ListElement { tileId: "about"; label: "О программе"; colorHex: "#d6522e"; size: "small"; icon: "qrc:/bathroom_tiles/info.png"; glyph: "" }
        ListElement { tileId: "clock"; label: ""; colorHex: "#7459d1"; size: "wide"; icon: ""; glyph: "" }
        ListElement { tileId: "music"; label: "Музыка"; colorHex: "#603cba"; size: "wide"; icon: "qrc:/bathroom_tiles/Music.png"; glyph: "" }
        ListElement { tileId: "let-l"; label: ""; colorHex: "#e3a21a"; size: "wide"; icon: ""; glyph: "L" }
        ListElement { tileId: "settings"; label: "Настройки"; colorHex: "#555555"; size: "wide"; icon: "qrc:/bathroom_tiles/Seting.png"; glyph: "" }
        ListElement { tileId: "gallery"; label: "Галерея"; colorHex: "#00879d"; size: "wide"; icon: "qrc:/bathroom_tiles/Galery.png"; glyph: "" }
        ListElement { tileId: "store"; label: "Microsoft Store"; colorHex: "#00a300"; size: "wide"; icon: "qrc:/bathroom_tiles/Store.png"; glyph: "" }
        ListElement { tileId: "let-s"; label: ""; colorHex: "#b91d47"; size: "small"; icon: ""; glyph: "S" }
        ListElement { tileId: "video"; label: "Видео"; colorHex: "#b21a41"; size: "small"; icon: "qrc:/bathroom_tiles/Video.png"; glyph: "" }
        ListElement { tileId: "mail"; label: "Почта"; colorHex: "#008fa3"; size: "wide"; icon: "qrc:/bathroom_tiles/Mail.png"; glyph: "" }
        ListElement { tileId: "explorer"; label: "Проводник"; colorHex: "#e3c800"; size: "large"; icon: "qrc:/bathroom_tiles/Explorer.png"; glyph: "" }
    }

    Image { anchors.fill: parent; source: "qrc:/BackGround/LockScreen.png"; fillMode: Image.PreserveAspectCrop }
    Rectangle { anchors.fill: parent; color: "#1a000000" }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 82
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
                        background: Rectangle { radius: 20; color: editMode ? metroRed : "transparent"; border.width: 2; border.color: "#d0ffffff" }
                        contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                    Row {
                        spacing: 12
                        Text { text: "User"; color: "white"; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter }
                        Image { source: "qrc:/bathroom_tiles/user.png"; width: 40; height: 40 }
                    }
                }
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: startGrid.width + 120
                clip: true

                Grid {
                    id: startGrid
                    x: 60
                    y: 12
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
                            required property string glyph

                            width: cellSize * tileSpan(size) + gapSize * (tileSpan(size) - 1)
                            height: cellSize * tileRowSpan(size) + gapSize * (tileRowSpan(size) - 1)
                            color: colorHex
                            opacity: 0
                            scale: 0.95

                            Behavior on scale { NumberAnimation { duration: 120 } }
                            Behavior on opacity { NumberAnimation { duration: 120 } }

                            SequentialAnimation on opacity {
                                running: true
                                loops: 1
                                PauseAnimation { duration: index * 25 }
                                NumberAnimation { from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
                            }

                            SequentialAnimation on scale {
                                running: true
                                loops: 1
                                PauseAnimation { duration: index * 25 }
                                NumberAnimation { from: 0.93; to: 1.0; duration: 230; easing.type: Easing.OutBack }
                            }

                            Text {
                                visible: tileId === "clock"
                                anchors.centerIn: parent
                                color: "white"
                                text: Qt.formatTime(nowTime, "hh:mm") + "\n" + Qt.formatDate(nowTime, "d MMMM")
                                font.pixelSize: 34
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Text {
                                visible: glyph.length > 0
                                anchors.centerIn: parent
                                color: "white"
                                text: glyph
                                font.pixelSize: glyph === "M E" ? 56 : 64
                                font.bold: true
                                letterSpacing: glyph === "M E" ? 8 : 0
                            }

                            Image {
                                visible: icon.length > 0
                                source: icon
                                anchors.centerIn: parent
                                width: parent.width * 0.52
                                height: parent.height * 0.52
                                fillMode: Image.PreserveAspectFit
                            }

                            Text {
                                visible: label.length > 0
                                anchors.left: parent.left
                                anchors.bottom: parent.bottom
                                anchors.margins: 10
                                color: "white"
                                text: label
                                font.pixelSize: 17
                                font.bold: true
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.width: 2
                                border.color: editMode ? "#99ffffff" : "transparent"
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.scale = 1.025
                                onExited: parent.scale = 1.0
                                onClicked: {
                                    if (editMode) {
                                        const next = size === "small" ? "wide" : (size === "wide" ? "large" : "small")
                                        tileModel.setProperty(index, "size", next)
                                    } else {
                                        actionTileClicked(tileId)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: appOverlay
        anchors.fill: parent
        visible: currentView !== ""
        opacity: visible ? 1 : 0
        color: "#f0101010"
        z: 20

        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        ColumnLayout {
            anchors.fill: parent
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 74
                color: "#1d1d1d"
                border.width: 1
                border.color: "#244a4a4a"
                Row {
                    spacing: 16
                    anchors.left: parent.left
                    anchors.leftMargin: 28
                    anchors.verticalCenter: parent.verticalCenter
                    Button {
                        text: "←"
                        onClicked: {
                            if (currentView === "game" && currentGameStage !== "menu") {
                                currentGameStage = "menu"
                                appTitle = "METRO WORDLE"
                            } else {
                                currentView = ""
                            }
                        }
                        background: Rectangle { radius: 18; color: "transparent"; border.width: 2; border.color: "white" }
                        contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                    Text { text: appTitle; color: "white"; font.pixelSize: 30; font.weight: Font.DemiBold }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Column {
                    visible: currentView === "game" && currentGameStage === "menu"
                    anchors.centerIn: parent
                    spacing: 26

                    Row {
                        spacing: 28
                        Repeater {
                            model: [
                                { key: "create", title: "Создать игру", desc: "Загадай слово", color: metroBlue },
                                { key: "random", title: "Случайно", desc: "Слово из базы", color: metroGreen },
                                { key: "code", title: "Ввести код", desc: "Начать по коду", color: metroPurple }
                            ]
                            delegate: Rectangle {
                                required property var modelData
                                width: 270
                                height: 250
                                color: modelData.color
                                radius: 2

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 14
                                    Text { text: modelData.title; color: "white"; font.pixelSize: 34; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignHCenter }
                                    Text { text: modelData.desc; color: "#d8ffffff"; font.pixelSize: 20; horizontalAlignment: Text.AlignHCenter }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (modelData.key === "create") currentGameStage = "create"
                                        if (modelData.key === "random") startRandom()
                                        if (modelData.key === "code") currentGameStage = "enterCode"
                                    }
                                }
                            }
                        }
                    }
                }

                Column {
                    visible: currentView === "game" && currentGameStage === "create"
                    anchors.centerIn: parent
                    spacing: 16
                    width: 680

                    Text { text: "Введите слово для друга"; color: "white"; font.pixelSize: 34; font.weight: Font.Light }
                    TextField {
                        id: createWord
                        placeholderText: "СЛОВО"
                        color: "white"
                        selectedTextColor: "white"
                        selectionColor: metroBlue
                        placeholderTextColor: "#70ffffff"
                        background: Rectangle { color: "#22000000"; border.color: "#66ffffff"; border.width: 2 }
                        font.pixelSize: 30
                    }
                    Button {
                        text: "Создать код"
                        onClicked: createGameWord()
                        background: Rectangle { color: metroBlue }
                        contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 22 }
                    }
                    Rectangle {
                        width: parent.width
                        height: 130
                        color: "#1f1f1f"
                        border.color: "#4e4e4e"
                        visible: generatedCode.length > 0
                        Column {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8
                            Text { text: "Код игры:"; color: "#cccccc"; font.pixelSize: 18 }
                            Text { text: generatedCode; color: "white"; font.pixelSize: 26; font.bold: true }
                            Text { text: generatedLink; color: "#8cc8ff"; font.pixelSize: 14; elide: Text.ElideRight; width: parent.width }
                        }
                    }
                }

                Column {
                    visible: currentView === "game" && currentGameStage === "enterCode"
                    anchors.centerIn: parent
                    spacing: 16
                    width: 620
                    Text { text: "Ввод кода игры"; color: "white"; font.pixelSize: 34; font.weight: Font.Light }
                    TextField {
                        id: codeInput
                        placeholderText: "ВСТАВЬ КОД"
                        color: "white"
                        selectedTextColor: "white"
                        selectionColor: metroPurple
                        placeholderTextColor: "#70ffffff"
                        background: Rectangle { color: "#22000000"; border.color: "#66ffffff"; border.width: 2 }
                        font.pixelSize: 28
                        onAccepted: startByCode(text)
                    }
                    Button {
                        text: "Начать игру"
                        onClicked: startByCode(codeInput.text)
                        background: Rectangle { color: metroPurple }
                        contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 22 }
                    }
                }

                Column {
                    visible: currentView === "game" && currentGameStage === "play"
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 10

                    Text {
                        text: messageText
                        color: "white"
                        font.pixelSize: 22
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                    }

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
                                        Text {
                                            anchors.centerIn: parent
                                            text: boardRows[rowIndex][index].letter
                                            color: "white"
                                            font.pixelSize: 30
                                            font.bold: true
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 220
                        color: "#181818"
                        border.color: "#303030"
                        Column {
                            anchors.centerIn: parent
                            spacing: 6
                            Repeater {
                                model: ["ЙЦУКЕНГШЩЗХЪ", "ФЫВАПРОЛДЖЭ", "ЯЧСМИТЬБЮ"]
                                delegate: Row {
                                    spacing: 5
                                    property string letters: modelData

                                    Item {
                                        visible: index === 2
                                        width: 75
                                        height: 48
                                        Rectangle { anchors.fill: parent; color: metroGreen }
                                        Text { anchors.centerIn: parent; text: "ENTER"; color: "white"; font.bold: true }
                                        MouseArea { anchors.fill: parent; onClicked: submitGuess() }
                                    }

                                    Repeater {
                                        model: letters.length
                                        delegate: Rectangle {
                                            width: 48
                                            height: 48
                                            radius: 3
                                            property string ch: letters[index]
                                            color: keyStates[ch] === "correct" ? metroGreen : keyStates[ch] === "present" ? metroYellow : keyStates[ch] === "absent" ? "#3a3a3c" : "#454545"
                                            Text { anchors.centerIn: parent; text: ch; color: "white"; font.bold: true }
                                            MouseArea { anchors.fill: parent; onClicked: addLetter(ch) }
                                        }
                                    }

                                    Item {
                                        visible: index === 2
                                        width: 75
                                        height: 48
                                        Rectangle { anchors.fill: parent; color: metroRed }
                                        Text { anchors.centerIn: parent; text: "⌫"; color: "white"; font.bold: true }
                                        MouseArea { anchors.fill: parent; onClicked: backspace() }
                                    }
                                }
                            }
                        }
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
                        color: "#efefef"
                        wrapMode: Text.WordWrap
                        font.pixelSize: 23
                        text: "Metro Wordle\n\nУлучшенная версия Wordle\n\nИстория создания: Мы с друзьями играли в Wordle и заметили, что мало букв. Jonny_Silver решил создать свой Wordle — изначально назвав его Meme Wordle. Позже проект подхватил Laroslav7, который придумал концепцию Metro Wordle.\n\nВерсия: 1.2\nCEO: Jonny_Silver\nГлава разработок: Laroslav7\nПрограммисты: Google AI Studio, Gemini"
                    }
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: nowTime = new Date()
    }

    Component.onCompleted: {
        root.requestActivate()
        const args = Qt.application.arguments
        for (let i = 0; i < args.length; ++i) {
            if (args[i].indexOf("#") >= 0) {
                const hash = args[i].split("#")[1]
                if (wordleBackend.startFriendMode(hash)) {
                    startGameUI()
                    currentView = "game"
                    currentGameStage = "play"
                }
                break
            }
        }
    }

    Shortcut {
        sequences: ["Return", "Enter"]
        onActivated: {
            if (currentView === "game" && currentGameStage === "play") submitGuess()
            if (currentView === "game" && currentGameStage === "enterCode") startByCode(codeInput.text)
        }
    }

    Shortcut {
        sequence: "Backspace"
        onActivated: if (currentView === "game" && currentGameStage === "play") backspace()
    }

    Keys.onPressed: function(event) {
        if (currentView !== "game" || currentGameStage !== "play")
            return

        const t = event.text.toUpperCase()
        if (/^[А-ЯЁ]$/.test(t)) {
            addLetter(t)
            event.accepted = true
        }
    }
}
