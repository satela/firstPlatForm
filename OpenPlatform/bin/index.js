/**
 * 设置LayaNative屏幕方向，可设置以下值
 * landscape           横屏
 * portrait            竖屏
 * sensor_landscape    横屏(双方向)
 * sensor_portrait     竖屏(双方向)
 */
window.screenOrientation = "sensor_landscape";

/*function load(name) {
    let xhr = new XMLHttpRequest(),
        okStatus = document.location.protocol === "file:" ? 0 : 200;
    xhr.open('GET', name, true);
    xhr.overrideMimeType("text/html;charset=utf-8");//默认为utf-8
    xhr.send(null);
    return xhr.status === okStatus ? xhr.responseText : null;
}*/
 
//let text = load("version.json");

let xhrreq = new XMLHttpRequest(),
        okStatus = document.location.protocol === "file:" ? 0 : 200;
    xhrreq.open('GET', "version.json?" + Math.random(), true);
    xhrreq.overrideMimeType("text/html;charset=utf-8");//默认为utf-8
	xhrreq.onreadystatechange= onStateChange;
    xhrreq.send(null);
function onStateChange()
{
	var ready = xhrreq.readyState;
	if(ready == 4)
	{
		var version = xhrreq.responseText;
		console.log("version:" + version); //输出到浏览器控制器中
		loadLib("js/bundle.js?"+ version);
		//loadLib("js/bundle.min.js?" + version);

	}
	
}
 



//-----libs-begin-----
//loadLib("libs/box2d.js");
//-----libs-end-------
//loadLib("js/bundle.js?"+ Math.random());
//loadLib("js/bundle.min.js?" + Math.random());
