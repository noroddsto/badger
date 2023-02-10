import '../images/badger.png'
import { Elm } from "../elm/src/App.elm";

const app = Elm.App.init();

app.ports.openDialog.subscribe((domId) => {
    requestAnimationFrame(() => {
        document.getElementById(domId).showModal();
    })
});

app.ports.closeDialog.subscribe((domId) => {
    requestAnimationFrame(() => {
        document.getElementById(domId).close();
    })
});

app.ports.downloadSvg.subscribe(({ domId, fileName }) => {
    let svgData = document.getElementById(domId);
    if (svgData) {
        const svgBlob = new Blob([svgData.outerHTML], { type: "image/svg+xml;charset=utf-8" })
        const svgUrl = URL.createObjectURL(svgBlob);
        const downloadLink = document.createElement("a");
        downloadLink.href = svgUrl;
        downloadLink.download = `${fileName}.svg`;
        //document.body.appendChild(downloadLink);
        downloadLink.click();
        //document.body.removeChild(downloadLink);
        URL.revokeObjectURL(svgUrl);
    }
});

