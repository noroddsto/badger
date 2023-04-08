import '../images/badger.png'
import { Elm } from "../elm/src/App.elm";


const localStorage = window.localStorage;
const presetList = localStorage ? Object.keys(localStorage) : [];
const flags = {
    supportLocalStorage: localStorage != null,
    presetList
};

const app = Elm.App.init({ flags });

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



app.ports.savePreset.subscribe(({ key, payload }) => {
    if (localStorage) {
        localStorage.setItem(key, JSON.stringify(payload));
        app.ports.savePresetResponse.send({ data: key });
    } else {
        app.ports.savePresetResponse.send({ error: 'Localstorage not available' });
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
});

app.ports.deletePreset.subscribe((key) => {
    if (localStorage) {
        const result = localStorage.removeItem(key)
        app.ports.deletePresetResponse.send({ data: key });
    } else {
        app.ports.deletePresetResponse.send({ error: 'Localstorage not available' });
    }
})