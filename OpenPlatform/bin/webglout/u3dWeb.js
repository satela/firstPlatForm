var Unity3dWeb = {};
var gameInstance;
var layaCaller;
Unity3dWeb.createUnity = function()
{

	 //gameInstance = UnityLoader.instantiate("gameContainer", "webglout/Build/webglout.json", {onProgress: UnityProgress});
	 var container = document.querySelector("#unity-container");
	 if(gameInstance != null)
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
	 var container = document.querySelector("#unity-container");
      var canvas = document.querySelector("#unity-canvas");
      var loadingBar = document.querySelector("#unity-loading-bar");
      var progressBarFull = document.querySelector("#unity-progress-bar-full");
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

      var buildUrl = "webglout/Build";
	  var version = "2";
      var loaderUrl = buildUrl + "/webout.loader.js?version=" + version;
      var config = {
        dataUrl: buildUrl + "/webout.data.unityweb?version=" + version,
        frameworkUrl: buildUrl + "/webout.framework.js.unityweb?version" + version,
        codeUrl: buildUrl + "/webout.wasm.unityweb?version=" + + version,
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
				  gameInstance = unityInstance;
                loadingBar.style.display = "none";
                
              }).catch((message) => {
                alert(message);
              });
            };

      document.body.appendChild(script);
	  

}

Unity3dWeb.closeUnity = function()
{

	gameInstance.Module.abort();

}

Unity3dWeb.UnityIsReady = function()
{
	console.log("unity load complete");	
	if(layaCaller != null)
	{
		layaCaller.unityIsReady();
	}
	else{
		Unity3dWeb.stopRender();
				
		Unity3dWeb.setSceneActive("0");
	}
}

Unity3dWeb.sendProcInfo = function(info)
{
	
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "setEffectInfo",info);
	
}
Unity3dWeb.selectCharacter = function(index)
{
	if(layaCaller != null)
	{
		layaCaller.selectCharacter(index);
	}
}

Unity3dWeb.setCharacterEdgeIndex = function(index)
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "setCharacterEdgeIndex",index);
}

Unity3dWeb.turnCharacterLight = function(url)
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "turnCharacterLight",url);
}
Unity3dWeb.changeLigthColor = function(color)
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "changeLigthColor",color);
}

Unity3dWeb.createMesh = function(picurl)
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "create3DText",picurl);

}
Unity3dWeb.setFrontFaceActive = function(show)
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "setFrontFaceActive",show);
}
Unity3dWeb.stopRender = function()
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "stopRender");

}

Unity3dWeb.startRender = function()
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "startRender");

}
Unity3dWeb.createLayer = function(params)
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "createFontlayer",params);

}

Unity3dWeb.changefontSize = function(size)
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "setFontSize",size);
}

Unity3dWeb.changebackground = function(texurl)
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "changeBackGround",texurl);
}

Unity3dWeb.changelayerAlpha = function(texurl)
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "changeLayerAlpha",texurl);
}

Unity3dWeb.changeligthIntensity = function(texurl)
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "changeLightIntensity",texurl);
}

Unity3dWeb.changeCausticUVX = function(uvx)
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "changeCausticUVX",uvx);
}

Unity3dWeb.changeCausticUVY = function(uvx)
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "changeCausticUVY",uvx);
}
Unity3dWeb.changeCausticStrength = function(strength)
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "changeCausticItrate",strength);
}

Unity3dWeb.changeCameraFov = function(fov)
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "changeReflectCameraFov",fov);
}

Unity3dWeb.moveCamera = function(offset)
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "moveCamera",offset);
}

Unity3dWeb.setSceneActive = function(active)
{
	if(gameInstance != null)
	gameInstance.SendMessage("Main Camera", "setSceneActive",active);
}

