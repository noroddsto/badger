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



app.ports.log.subscribe((json) => {
    console.log(json);
});

const localStorage = window.localStorage;

app.ports.savePreset.subscribe(({ key, payload }) => {
    if (localStorage) {
        localStorage.setItem(key, JSON.stringify(payload));
        app.ports.savePresetResponse.send({ data: key });
    } else {
        app.ports.savePresetResponse.send({ error: 'Localstorage not available' });
    }
});

app.ports.listPresets.subscribe(() => {
    if (localStorage) {
        const keys = Object.keys(localStorage);
        app.ports.listPresetsResponse.send({ data: keys });
    } else {
        app.ports.listPresetsResponse.send({ error: 'Localstorage not available' });
    }
});

app.ports.loadPreset.subscribe((key) => {
    if (localStorage) {
        const result = localStorage.getItem(key)
        if (result) {
            const payload = JSON.parse(result);
            app.ports.loadPresetResponse.send({ data: { key, payload } });
        } else {
            app.ports.loadPresetResponse.send({ error: 'Key was not found' });
        }

    } else {
        app.ports.loadPresetResponse.send({ error: 'Localstorage not available' });
    }
})