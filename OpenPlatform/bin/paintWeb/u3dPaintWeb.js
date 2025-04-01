var UnityPaintWeb = {};
var paintWebInstance;
var layaCaller;
UnityPaintWeb.createUnity = function()
{

	 //paintWebInstance = UnityLoader.instantiate("gameContainer", "webglout/Build/webglout.json", {onProgress: UnityProgress});
	 var container = document.querySelector("#unity-paint-container");
	 if(paintWebInstance != null)
	 {
		 container.style.display = "";
		 this.setSceneActive("1");
		 this.startRender();
		 if(layaCaller != null)
		{
			layaCaller.unityIsReady();
		}
		 return;
	 }
	 var container = document.querySelector("#unity-paint-container");
      var canvas = document.querySelector("#unity-paint-canvas");
      var loadingBar = document.querySelector("#unity-paint-loading-bar");
      var progressBarFull = document.querySelector("#unity-paint-progress-bar-full");
     // var warningBanner = document.querySelector("#unity-warning");

		document.body.appendChild( container);

      // Shows a temporary message banner/ribbon for a few seconds, or
      // a permanent error message on top of the canvas if type=='error'.
      // If type=='warning', a yellow highlight color is used.
      // Modify or remove this function to customize the visually presented
      // way that non-critical warnings and error messages are presented to the
      // user.
      function unityShowBanner(msg, type) {
        function updateBannerVisibility() {
          //warningBanner.style.display = warningBanner.children.length ? 'block' : 'none';
        }
        var div = document.createElement('div');
        div.innerHTML = msg;
        //warningBanner.appendChild(div);
        if (type == 'error') div.style = 'background: red; padding: 10px;';
        else {
          if (type == 'warning') div.style = 'background: yellow; padding: 10px;';
          setTimeout(function() {
           // warningBanner.removeChild(div);
            updateBannerVisibility();
          }, 5000);
        }
        updateBannerVisibility();
      }

      var buildUrl = "paintWeb/Build";
      var loaderUrl = buildUrl + "/paintWeb.loader.js";
      var config = {
        dataUrl: buildUrl + "/paintWeb.data.unityweb",
        frameworkUrl: buildUrl + "/paintWeb.framework.js.unityweb",
        codeUrl: buildUrl + "/paintWeb.wasm.unityweb",
        streamingAssetsUrl: "StreamingAssets",
        companyName: "DefaultCompany",
        productName: "CharacterPaint",
        productVersion: "0.1",
        showBanner: unityShowBanner,
		cacheControl: function (url) {
     // Caching enabled for .data and .bundle files.
     // Revalidate if file is up to date before loading from cache
		 if (url.match(/\.data/) || url.match(/\.bundle/)) {
			 return "must-revalidate";
		 }

		 // Caching enabled for .mp4 and .custom files
		 // Load file from cache without revalidation.
		 if (url.match(/\.mp4/) || url.match(/\.custom/)) {
			 return "immutable";
		 }
	 
		 // Disable explicit caching for all other files.
		 // Note: the default browser cache may cache them anyway.
		 return "no-store";
	   },
   
      };

      // By default Unity keeps WebGL canvas render target size matched with
      // the DOM size of the canvas element (scaled by window.devicePixelRatio)
      // Set this to false if you want to decouple this synchronization from
      // happening inside the engine, and you would instead like to size up
      // the canvas DOM size and WebGL render target sizes yourself.
      // config.matchWebGLToCanvasSize = false;

      if (/iPhone|iPad|iPod|Android/i.test(navigator.userAgent)) {
        // Mobile device style: fill the whole browser client area with the game canvas:

        var meta = document.createElement('meta');
        meta.name = 'viewport';
        meta.content = 'width=device-width, height=device-height, initial-scale=1.0, user-scalable=no, shrink-to-fit=yes';
        document.getElementsByTagName('head')[0].appendChild(meta);
        container.className = "unity-mobile";
        canvas.className = "unity-mobile";

        // To lower canvas resolution on mobile devices to gain some
        // performance, uncomment the following line:
        // config.devicePixelRatio = 1;


      } else {
        // Desktop style: Render the game canvas in a window that can be maximized to fullscreen:

        //canvas.style.width = "960px";
        //canvas.style.height = "600px";
      }

      loadingBar.style.display = "block";

      var script = document.createElement("script");
      script.src = loaderUrl;
      script.onload = () => {
         createUnityInstance(canvas, config, (progress) => {
          progressBarFull.style.width = 100 * progress + "%";
              }).then((unityInstance) => {
				  paintWebInstance = unityInstance;
                loadingBar.style.display = "none";
                
              }).catch((message) => {
                alert(message);
              });
            };

      document.body.appendChild(script);
	  

}

UnityPaintWeb.closeUnity = function()
{

	paintWebInstance.Module.abort();

}

UnityPaintWeb.UnityIsReady = function()
{
	console.log("unity load complete");	
	if(layaCaller != null)
	{
		layaCaller.unityIsReady();
	}
	else{
		UnityPaintWeb.stopRender();
				
		UnityPaintWeb.setSceneActive("0");
	}
}

UnityPaintWeb.sendProcInfo = function(info)
{
	
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "setEffectInfo",info);
	
}
UnityPaintWeb.selectCharacter = function(index)
{
	if(layaCaller != null)
	{
		layaCaller.selectCharacter(index);
	}
}

UnityPaintWeb.setCharacterEdgeIndex = function(index)
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "setCharacterEdgeIndex",index);
}

UnityPaintWeb.turnCharacterLight = function(url)
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "turnCharacterLight",url);
}
UnityPaintWeb.changeLigthColor = function(color)
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "changeLigthColor",color);
}

UnityPaintWeb.createMesh = function(picurl)
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "create3DText",picurl);

}
UnityPaintWeb.setFrontFaceActive = function(show)
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "setFrontFaceActive",show);
}
UnityPaintWeb.stopRender = function()
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "stopRender");

}

UnityPaintWeb.startRender = function()
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "startRender");

}
UnityPaintWeb.createLayer = function(params)
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "createFontlayer",params);

}

UnityPaintWeb.changefontSize = function(size)
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "setFontSize",size);
}

UnityPaintWeb.changebackground = function(texurl)
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "changeBackGround",texurl);
}

UnityPaintWeb.changelayerAlpha = function(texurl)
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "changeLayerAlpha",texurl);
}

UnityPaintWeb.changeligthIntensity = function(texurl)
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "changeLightIntensity",texurl);
}

UnityPaintWeb.changeCausticUVX = function(uvx)
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "changeCausticUVX",uvx);
}

UnityPaintWeb.changeCausticUVY = function(uvx)
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "changeCausticUVY",uvx);
}
UnityPaintWeb.changeCausticStrength = function(strength)
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "changeCausticItrate",strength);
}

UnityPaintWeb.changeCameraFov = function(fov)
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "changeReflectCameraFov",fov);
}

UnityPaintWeb.moveCamera = function(offset)
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "moveCamera",offset);
}

UnityPaintWeb.setSceneActive = function(active)
{
	if(paintWebInstance != null)
	paintWebInstance.SendMessage("Main Camera", "setSceneActive",active);
}

