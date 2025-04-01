package script {
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.display.Scene;
	import laya.display.Stage;
	import laya.events.Event;
	import laya.events.MouseManager;
	import laya.net.HttpRequest;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Label;
	import laya.ui.Panel;
	import laya.utils.Browser;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Log;
	import laya.utils.Tween;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	import model.picmanagerModel.DirectoryFileModel;
	
	import script.login.LogPanelControl;
	import script.usercenter.UserMainControl;
	
	import ui.LoginViewUI;
	import ui.login.LogPanelUI;
	import ui.login.RegisterPanelUI;
	
	import utils.UtilTool;
	
	/**
	 * 本示例采用非脚本的方式实现，而使用继承页面基类，实现页面逻辑。在IDE里面设置场景的Runtime属性即可和场景进行关联
	 * 相比脚本方式，继承式页面类，可以直接使用页面定义的属性（通过IDE内var属性定义），比如this.tipLbll，this.scoreLbl，具有代码提示效果
	 * 建议：如果是页面级的逻辑，需要频繁访问页面内多个元素，使用继承式写法，如果是独立小模块，功能单一，建议用脚本方
	 */
	

	public class MainPageControl extends Script {
		
		private var txtLogin:Label;
		private var txtReg:Label;
		
		private var versioninfo:Box;
		
		private var actbtn:Button;
				
		public function MainPageControl():void {
			//关闭多点触控，否则就无敌了
			MouseManager.multiTouchEnabled = false;
		}
		
		override public function onStart():void
		{
			 txtLogin = this.owner["txt_login"];
			txtLogin.on(Event.CLICK,this,onShowLogin);
			
			 txtReg = this.owner["txt_reg"];
			txtReg.on(Event.CLICK,this,onShowReg);
			
			var uploadbtn:Button = this.owner["btnUpload"];
			uploadbtn.on(Event.CLICK,this,onShowUpload);

			var paintOrderBtn:Button = this.owner["paintOrderBtn"];
			paintOrderBtn.on(Event.CLICK,this,onShowPaintOrder);

			var diaokeOrderBtn:Button = this.owner["characBtn"];
			//diaokeOrderBtn.on(Event.CLICK,this,onShowChracterTypePanel);

			
			var btnUserCenter:Button = this.owner["btnUserCenter"];
			btnUserCenter.on(Event.CLICK,this,onShowUserCenter);
			
			var btnproduct:Button = this.owner["btnproduct"];
			btnproduct.on(Event.CLICK,this,onProductView);
			
			var customerproduct:Button = this.owner["productCustomization"];
			customerproduct.on(Event.CLICK,this,onCustomerProductView);
			
			versioninfo = this.owner["enterinfo"];
			if(Browser.clientHeight < Laya.stage.height)
				versioninfo.y = Browser.clientHeight *1920/Browser.clientWidth - versioninfo.height;
			else
				versioninfo.y = Laya.stage.height - versioninfo.height;
			(this.owner as LoginViewUI).height = Browser.clientHeight *1280/Browser.clientWidth;

			var btnlinkto:Button = this.owner["linktobus"];
			btnlinkto.on(Event.CLICK,this,onOpenGongshang);
			
			actbtn = this.owner["btnact"];
			actbtn.visible = false;
			actbtn.on(Event.CLICK,this,onGotoCharge);

			(this.owner as LoginViewUI).linkicp.on(Event.CLICK,this,onOpenOficial);
			EventCenter.instance.on(EventCenter.LOGIN_SUCESS, this,onSucessLogin);
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

			
			(this.owner["panel_main"] as Panel).height = Browser.height;
			(this.owner["panel_main"] as Panel).hScrollBarSkin = "";
			(this.owner["panel_main"] as Panel).width = Browser.width;
			
			if(!Userdata.instance.isLogin)
				loginAccount();
			else
			{
				txtLogin.text = Userdata.instance.userAccount;
				txtReg.text = "[退出]";
				//getActivityInfo();
			}
			DirectoryFileModel.instance.haselectPic = {};

//			Tween.to(this.owner["toAiPhoto"],{scaleX:-1},1000,Ease.backIn,new Handler(this,onCompleteFlip),1000);
//			this.owner["toAiPhoto"].on(Event.CLICK,this,function(){
//				
//				Browser.window.open("http://www.photoai.vip",null,null,true);
//
//			})
			//HttpRequestUtil.instance.Request("https://large-thumbnail-image.oss-cn-hangzhou.aliyuncs.com/18014398514578468.plt",this,ongetdata,"","");


		}
//		private function onCompleteFlip():void
//		{
//			Tween.to(this.owner["toAiPhoto"],{scaleX:1},1000,Ease.backIn,new Handler(this,onCompleteFlipBack),500);
//
//		}
//		
//		private function onCompleteFlipBack():void
//		{
//			Tween.to(this.owner["toAiPhoto"],{scaleX:-1},1000,Ease.backIn,new Handler(this,onCompleteFlip),500);
//			
//		}
		
		private function ongetdata(data:*):void
		{
			trace(data);
		}
		private function onOpenGongshang()
		{
			Browser.window.open("http://www.gsxt.gov.cn/%7BF71C582A907AA9A77C0EF218C30915AFDDBCA77C96F73D4D09E3592B4A85097B87E62C5C18F2E9E75EE4EA5348B4AF45DB63374BC6AAC586EABEEBA8C48C8DD0A853A853A8F58D760E76817A817A8176817A024DB6A75CAB50ABF60D751CACB07FDF33E8223E00FC469D79017924DF021917AEB5D4C813F78F748F748F74-1561088596102%7D",null,null,true);

		}
		
		private function ongetMaintianBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(this.destroyed)
				return;
			
			if(result.status == 0)
			{
				if(result.state == null)
				{
					result.state = 0;
				}
				if(result.state > 0)
				{
					(this.owner["maintaintxt"] as Label).visible = true;
					(this.owner["maintaintxt"] as Label).text = result.msg
				}
			}
			
		}
		private function onOpenOficial():void
		{
			Browser.window.open("http://beian.miit.gov.cn",null,null,true);
		}
		private function loginAccount():void
		{
			var token:String = UtilTool.getLocalVar("userToken","0");
			Userdata.instance.token = token;
			//var pwd:String = UtilTool.getLocalVar("userpwd","0");
			if(token != "0" && token != "" )
			{								
				var param:Object = {};
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.enterUrl,this,onLoginBack,JSON.stringify(param),"post");
				
			}

		}
		
		private function onGotoCharge():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_USERCENTER,true,11);

		}
		private function getActivityInfo():void
		{
			//if(!Userdata.instance.hashowact)
			//	HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getChargeActivity,this,getActivityInfoBack,null,"post");
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getMaintainMsg,this,ongetMaintianBack,"","");

		}
		
		private function getActivityInfoBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				if(result.data != null && result.data.length > 0)
				{
					actbtn.visible = true;
					var date:Date = new Date();
					//trace("day time:" + date.getDate());
					if(!Userdata.instance.hashowact && (date.getDate() == 10 || date.getDate() == 20))
					{
						ViewManager.instance.openView(ViewManager.VIEW_ACTIVITY_ADVETISE_PANEL,false,result.data[0]);
						Userdata.instance.hashowact = true;

					}
				}
			}
		}
		private function onLoginBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				Userdata.instance.resetData();

				//var account:String = UtilTool.getLocalVar("useraccount","");
				Userdata.instance.userAccount = result.data.mobileNumber;
				Userdata.instance.isLogin = true;
				Userdata.instance.accountType = result.data.userType;
				Userdata.instance.privilege = result.data.userPermisson;
				//Userdata.instance.token = result.data.token;
					
				txtLogin.text =  Userdata.instance.userAccount;
				txtReg.text = "[退出]";
				
				console.log(Browser.document.cookie.split("; "));

				
				Userdata.instance.loginTime = (new Date()).getTime();
				UtilTool.setLocalVar("loginTime",Userdata.instance.loginTime);
				
				//getActivityInfo();
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.addressManageUrl,this,getMyAddressBack,"opt=list&page=1","post");
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getMaintainMsg,this,ongetMaintianBack,"","");
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,getCompanyInfoBack,null,"post");


			}
			
		}
		
		private function getCompanyInfoBack(data:Object):void
		{
			
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				var result:Object = JSON.parse(data as String);
				if(result.status == 0)
				{
					Userdata.instance.isVipCompany = result.vip == "1";
					Userdata.instance.checkJumpUrl();
					
				}
				
			}
		}
		
		private function getMyAddressBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				Userdata.instance.initMyAddress(result.data as Array);
				Userdata.instance.defaultAddId = result["default"];
			}
			else if(result.status == 205 || result.status　== 404)
			{
				ViewManager.instance.openView(ViewManager.VIEW_USERCENTER,true);
			}
		}
		private function onResizeBrower():void
		{
			// TODO Auto Generated method stub
			//console.log("height:" + Browser.height + "," + window.screen.availHeight + "," + window.screen.availWidth);
			//EventCenter.instance.event(EventCenter.BROWER_WINDOW_RESIZE);
			//versioninfo.y = Browser.height - versioninfo.height;
			
			//if(Browser.height < Laya.stage.height)
			//	versioninfo.y = Browser.height - versioninfo.height;
			//else
			//	versioninfo.y = Laya.stage.height - versioninfo.height;
			(this.owner as LoginViewUI).height = Browser.clientHeight *1280/Browser.clientWidth;
			
			if(Browser.clientHeight < Laya.stage.height)
				versioninfo.y = Browser.clientHeight *1280/Browser.clientWidth - versioninfo.height;
			else
				versioninfo.y = Laya.stage.height - versioninfo.height;
			

			//(this.owner["panel_main"] as Panel).height = Browser.height;
			//(this.owner["panel_main"] as Panel).width = Browser.width;

		}
		
		private function onShowUpload():void
		{
			if(Userdata.instance.isLogin)
				ViewManager.instance.openView(ViewManager.VIEW_PICMANAGER,true);
			else
			{
				ViewManager.showAlert("请先登录");
				ViewManager.instance.openView(ViewManager.VIEW_lOGPANEL);
				
			}
			//ViewManager.instance.openView(ViewManager.VIEW_USERCENTER,true);			
		}
		
		
		private function onShowPaintOrder():void
		{
//			ViewManager.showAlert("服务器升级中，预计14:00恢复，请谅解！");
//			return;
			
			if(Userdata.instance.isLogin)
			{
				PaintOrderModel.instance.orderType = OrderConstant.PAINTING;
				ViewManager.instance.openView(ViewManager.VIEW_PAINT_ORDER,true);
			}
			else
			{
				ViewManager.showAlert("请先登录");
				ViewManager.instance.openView(ViewManager.VIEW_lOGPANEL);
			}
		}
		
		private function onShowChracterTypePanel():void
		{
			if(Userdata.instance.isLogin)
				ViewManager.instance.openView(ViewManager.VIEW_CHARACTER_DEMONSTRATE_PANEL,false);
			else
			{
				ViewManager.showAlert("请先登录");
				ViewManager.instance.openView(ViewManager.VIEW_lOGPANEL);
			}
		}
		private function onShowUserCenter():void
		{
			if(!Userdata.instance.isLogin)
			{
				ViewManager.showAlert("请先登录");
				ViewManager.instance.openView(ViewManager.VIEW_lOGPANEL);
				return;
			}
			ViewManager.instance.openView(ViewManager.VIEW_USERCENTER,true);

		}
		private function onShowLogin(e:Event):void
		{
			if(!Userdata.instance.isLogin)
				ViewManager.instance.openView(ViewManager.VIEW_lOGPANEL);
			//this.owner.addChild(new LogPanelUI());
		}
		
		private function onShowReg(e:Event):void
		{
			if(!Userdata.instance.isLogin)
				ViewManager.instance.openView(ViewManager.VIEW_REGPANEL,true);
			else
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.loginOutUrl,this,onLoginOutBack,"","post");

			}


			//this.owner.addChild(new RegisterPanelUI());
		}
		
		private function onLoginOutBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				Userdata.instance.isLogin = false;
				txtLogin.text = "[登录]";
				txtReg.text = "[注册]";
				
				UtilTool.setLocalVar("useraccount","");
				UtilTool.setLocalVar("userpwd","");

			}
		}
		private function onSucessLogin(e:Object):void
		{
			txtLogin.text = e as String;
			txtReg.text = "[退出]";
			//getActivityInfo();
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.addressManageUrl,this,getMyAddressBack,"opt=list&page=1","post");

		}
		override public function onEnable():void {
			
			MouseManager.multiTouchEnabled = false;

			var panel:Panel = this.owner["panel_main"];
			panel.vScrollBarSkin = "";

		}
		private function onHttpRequestError(e:*=null):void
		{
			trace(e);
		}
		
		private function onHttpRequestProgress(e:*=null):void
		{
			trace(e)
		}
		
		private function onHttpRequestComplete(data:Object):void
		{
			trace(data);
			//logger.text += "收到数据：" + hr.data;
		}
		
		private function onBrowerResize(e:Event):void
		{
			//trace("wid:" + Browser.width);
			var scene:Scene = this.owner as Scene;
		}
		private function onProductView():void
		{
			if(!Userdata.instance.isLogin)
			{
				ViewManager.showAlert("请先登录");
				ViewManager.instance.openView(ViewManager.VIEW_lOGPANEL);
				return;
			}
			ViewManager.instance.openView(ViewManager.VIEW_PRODUCT_VIEW,true);
		}
		
		private function onCustomerProductView():void
		{
			if(!Userdata.instance.isLogin)
			{
				ViewManager.showAlert("请先登录");
				ViewManager.instance.openView(ViewManager.VIEW_lOGPANEL);
				return;
			}
			ViewManager.instance.openView(ViewManager.VIEW_PRODUCT_CATEGORY_PANEL,true);
		}
		public function onTipClick(e:Event):void {
			
		}
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.LOGIN_SUCESS, this,onSucessLogin);
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

			
		}
		
	}
}