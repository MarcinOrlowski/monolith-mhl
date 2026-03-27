import QtQuick

QtObject {
    property string themeId: "rwm-rainbow-waves"
    property string name: "Rainbow Waves"
    property bool enabled: true

    property var background: [
        "#F5F0E8",
        "#EDE6D6",
        "#E8E0D0",
        "#F0EAE0",
        "#FAF6F0"
    ]

    property string effect: "#8A8278"

    property var ghosts: [
        "#D4CCC0",
        "#C8C0B4",
        "#BEB6AA",
        "#D0C8BC"
    ]

    property var waveMain: [
        "#A09888",
        "#968E7E",
        "#8C8474",
        "#827A6C",
        "#6E2028",
        "#6E665C",
        "#645C54",
        "#5A524A",
        "#504842",
        "#46403A"
    ]

    property var waveHighlight: [
        "#C8C0B0",
        "#BEB6A6",
        "#B4AC9C",
        "#AAA292",
        "#8C3038",
        "#968E80",
        "#8C8478",
        "#827A70",
        "#787068",
        "#6E6660"
    ]

    property string glowCore: "#FFFFFF"
    property string spotColor: "#FFFFFF"
    property string starColor: "#FFFFFF"
}
