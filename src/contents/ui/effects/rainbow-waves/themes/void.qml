import QtQuick

QtObject {
    property string themeId: "rwm-void"
    property string name: "Void"
    property bool enabled: true

    property var background: [
        "#06030C",
        "#08040E",
        "#0A0512",
        "#070410",
        "#04020A"
    ]

    property string effect: "#4A1A6E"

    property var ghosts: [
        "#1E0A38",
        "#180830",
        "#220C3A",
        "#140828"
    ]

    property var waveMain: [
        "#3A1268",
        "#32105C",
        "#2C0E52",
        "#260C48",
        "#220A40",
        "#1E0A38",
        "#1C0834",
        "#180830",
        "#140628",
        "#100622"
    ]

    property var waveHighlight: [
        "#5A2898",
        "#502488",
        "#46207A",
        "#3E1C6E",
        "#381A64",
        "#30185A",
        "#2C1452",
        "#261248",
        "#221040",
        "#1E0E38"
    ]

    property string glowCore: "#FFFFFF"
    property string spotColor: "#FFFFFF"
    property string starColor: "#FFFFFF"
}
