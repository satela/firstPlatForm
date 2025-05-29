package {
	import eventUtil.EventCenter;
	
	import laya.display.Scene;
	import laya.display.Sprite;
	import laya.display.Stage;
	import laya.events.Event;
	import laya.net.AtlasInfoManager;
	import laya.net.Loader;
	import laya.net.ResourceVersion;
	import laya.net.URL;
	import laya.utils.Browser;
	import laya.utils.Handler;
	import laya.utils.Stat;
	import laya.utils.Utils;
	
	import model.Constast;
	import model.HttpRequestUtil;
	import model.Userdata;
	
	import script.ViewManager;
	
	import ui.LoginViewUI;
	import ui.login.LoadingPanelUI;
	
	public class Main {
		
		private var tt:Number;

		public function Main() {
			//根据IDE设置初始化引擎		
			
//			Browser.window.mainLaya = this;
//			console.log("Start laya");
//			return;
			//trace("brower width:" + Browser.width);
			if (window["Laya3D"]) window["Laya3D"].init(1280, 832);
			else 
			{
				if(typeof(Browser.window.orientation) != "undefined")
					Laya.init(1080, 1920, Laya["WebGL"]);
				else
					Laya.init(1920, 1080, Laya["WebGL"]);

			}
			//Laya["Physics"] && Laya["Physics"].enable();
			//Laya["DebugPanel"] && Laya["DebugPanel"].enable();
			Laya.stage.scaleMode = "fixedwidth";Stage.SCALE_NOSCALE; // "noscale";//GameConfig.scaleMode;
			Laya.stage.screenMode = GameConfig.screenMode;
			Laya.stage.alignV = "top";//GameConfig.alignV;
			Laya.stage.alignH = "left";//
			
			if(Browser.width > Laya.stage.width)
				Laya.stage.alignH = "center";
			else
				Laya.stage.alignH = "left";
			
			//Laya.stage.alignH = GameConfig.alignH;

			//兼容微信不支持加载scene后缀场景
			URL.exportSceneToJson = GameConfig.exportSceneToJson;
			
			//tt = (new Date()).getTime();
			//console.log("now time:" + tt);

			//打开调试面板（IDE设置调试模式，或者url地址增加debug=true参数，均可打开调试面板）
			if (GameConfig.debug || Utils.getQueryString("debug") == "true") Laya.enableDebugPanel();
			if (GameConfig.physicsDebug && Laya["PhysicsDebugDraw"]) Laya["PhysicsDebugDraw"].enable();
			if (GameConfig.stat) Stat.show();
			Laya.alertGlobalError = true;
			
			//激活资源版本控制，版本文件由发布功能生成
			Userdata.instance.curRandomStr = "version.json?" + (new Date()).getTime().toString();
			
			ResourceVersion.enable(Userdata.instance.curRandomStr, Handler.create(this, this.onVersionLoaded), ResourceVersion.FILENAME_VERSION);
			Laya.stage.on(Event.RESIZE,this,onResizeBrower);
//			var screenHeight:int = window.screen.height;
//			var screenWidth:int = window.screen.width;
//			
//			if(screenHeight < 1080)
//				Laya.stage.scaleY = screenHeight/1080;
//			
//			if(screenWidth < 1920)
//				Laya.stage.scaleX = screenWidth/1920;
		}
		
		private function changeAligh():void
		{
			if(Browser.width > Laya.stage.width && Laya.stage.alignH != "center")
				Laya.stage.alignH = "center";
			else if(Browser.width <= Laya.stage.width && Laya.stage.alignH != "left")
				Laya.stage.alignH = "left";

		}
		public function startInit():void
		{
			if (window["Laya3D"]) window["Laya3D"].init(Browser.width, Browser.height);
			else Laya.init(288, 1620, Laya["WebGL"]);
			//Laya["Physics"] && Laya["Physics"].enable();
			//Laya["DebugPanel"] && Laya["DebugPanel"].enable();
			Laya.stage.scaleMode = Stage.SCALE_NOSCALE;//// Stage.SCALE_NOSCALE; // "noscale";//GameConfig.scaleMode;
			Laya.stage.screenMode = GameConfig.screenMode;
			Laya.stage.alignV = GameConfig.alignV;
			Laya.stage.alignH = "center";//GameConfig.alignH;
			
			
			
			//兼容微信不支持加载scene后缀场景
			URL.exportSceneToJson = GameConfig.exportSceneToJson;
			
			//tt = (new Date()).getTime();
			//console.log("now time:" + tt);
			
			//打开调试面板（IDE设置调试模式，或者url地址增加debug=true参数，均可打开调试面板）
			if (GameConfig.debug || Utils.getQueryString("debug") == "true") Laya.enableDebugPanel();
			if (GameConfig.physicsDebug && Laya["PhysicsDebugDraw"]) Laya["PhysicsDebugDraw"].enable();
			if (GameConfig.stat) Stat.show();
			Laya.alertGlobalError = true;
			
			//激活资源版本控制，版本文件由发布功能生成
			ResourceVersion.enable("version.json?" + (new Date()).getTime().toString(), Handler.create(this, this.onVersionLoaded), ResourceVersion.FILENAME_VERSION);
			Laya.stage.on(Event.RESIZE,this,onResizeBrower);
			
			
		}
		private function onVersionLoaded(e:Event):void {
			//激活大小图映射，加载小图的时候，如果发现小图在大图合集里面，则优先加载大图合集，而不是小图
			
			Userdata.instance.version =  Laya.loader.getRes(Userdata.instance.curRandomStr);
			console.log("版本号:" + Userdata.instance.version);
			Laya.loader.load([{url:"res/atlas/comp.atlas",type:Loader.ATLAS},{url:"res/atlas/commers.atlas?" + Userdata.instance.version,type:Loader.ATLAS},
				
				{url:"res/atlas/order1.atlas?" + Userdata.instance.version,type:Loader.ATLAS},
				{url:"res/atlas/upload1.atlas?" + Userdata.instance.version,type:Loader.ATLAS},
				{url:"res/atlas/usercenter1.atlas?" + Userdata.instance.version,type:Loader.ATLAS},
				{url:"res/atlas/mainpage.atlas?" + Userdata.instance.version,type:Loader.ATLAS},
				{url:"res/atlas/chargeact.atlas?" + Userdata.instance.version,type:Loader.ATLAS},
				{url:"res/atlas/uiCommonUpdate.atlas?" +  Userdata.instance.version,type:Loader.ATLAS},
				{url:"res/atlas/iconsNew.atlas?" + Userdata.instance.version,type:Loader.ATLAS},


			], Handler.create(this, onLoadedComp), null, Loader.ATLAS,1);


			//Laya.loader.load([{url:"res/atlas/comp.atlas",type:Loader.ATLAS},{url:"res/atlas/commers1.atlas",type:Loader.ATLAS},{url:"res/atlas/order1.atlas",type:Loader.ATLAS},{url:"res/atlas/upload1.atlas",type:Loader.ATLAS},{url:"res/atlas/usercenter1.atlas",type:Loader.ATLAS},{url:"res/atlas/mainpage1.atlas",type:Loader.ATLAS}], Handler.create(this, onLoadedComp), null, Loader.ATLAS);

		}
		
		private function onLoadedComp():void
		{
			//AtlasInfoManager.enable("fileconfig.json", Handler.create(null, onConfigLoaded));
			onConfigLoaded();
		}
		private function onConfigLoaded():void {
			//加载场景
			
			
			
			
			//trace("id:" + tt);
			
			
			//Laya.stage.addChild(new LoginViewUI());
			//var pageurl:String = Browser.window.location.href;
			//if(pageurl.indexOf("ps") >= 0)
				HttpRequestUtil.httpUrl = "../v2/";
			//else
			//	HttpRequestUtil.httpUrl =  "http://101.37.88.170/";
			
			//HttpRequestUtil.httpUrl = "http://47.111.13.238:7778/";

			
			Userdata.instance.configVersion =  (new Date()).getTime().toString();
			
			Laya.loader.load([{url:"config.json?"+ Userdata.instance.configVersion,type:Loader.JSON}], Handler.create(this, onLoadedJsonConfigComp), null, Loader.JSON);
			
			
		}
		private function onLoadedJsonConfigComp():void
		{
			//AtlasInfoManager.enable("fileconfig.json", Handler.create(null, onConfigLoaded));
			var json = Laya.loader.getRes("config.json?" + Userdata.instance.configVersion);
			Browser.window.document.title = json["title"];
			HttpRequestUtil.biggerPicUrl = json["biggerPicUrl"];
			HttpRequestUtil.smallerrPicUrl = json["smallPicUrl"];
			HttpRequestUtil.originPicPicUrl = json["originPicPicUrl"];

			HttpRequestUtil.httpUrl = json["httpUrl"];
			Userdata.instance.clientCode = json["clientCode"];

			var u = new Browser.window.URL(Browser.window.location.href);
			var orderId:String = u.searchParams.get('orderID');
			var qrcode:String = u.searchParams.get('qrCode');
			if(orderId != null)
			{
				ViewManager.instance.openView(ViewManager.VIEW_SELL_PRICE_SHARE_PANEL,false,{"id":orderId,"qrCode":qrcode});
				return;
				
			}
			else
				ViewManager.instance.openView(ViewManager.VIEW_lOGPANEL);

		}
			
		
		
		private function onResizeBrower():void
		{
			// TODO Auto Generated method stub
			EventCenter.instance.event(EventCenter.BROWER_WINDOW_RESIZE);
			
			Laya.timer.once(50,this,changeAligh);

		}		
	
	}
}