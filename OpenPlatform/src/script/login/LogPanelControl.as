package script.login
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.display.Input;
	import laya.display.Scene;
	import laya.display.Stage;
	import laya.events.Event;
	import laya.events.Keyboard;
	import laya.maths.Point;
	import laya.ui.Button;
	import laya.utils.Browser;
	
	import model.Constast;
	import model.HttpRequestUtil;
	import model.Userdata;
	
	import script.ViewManager;
	
	import ui.login.LogPanelUI;
	import ui.login.LogPhonePanelUI;
	
	import utils.UtilTool;
	
	public class LogPanelControl extends Script
	{
		//private var uiSKin:LogPanelUI;
		private var uiSKin:LogPhonePanelUI;

		public var param:Object;
		private var logType:int = 0;
		private var uuId:String = "";
		private var coutdown:int = 60;

		private var pwdInput:Object;
		
		public function LogPanelControl()
		{
			//super();
		}
		
		override public function onStart():void
		{
			uiSKin = this.owner as LogPanelUI;
			//uiSKin.bgimg.alpha = 0.95;
			
			uiSKin.mainpanel.hScrollBarSkin = "";
			//uiSKin.mainpanel.width = Browser.width;
			//uiSKin.mainpanel.height = Browser.height;
			uiSKin.mainpanel.vScrollBarSkin = "";
			
			uiSKin.companyPic.skin = "bigImg/companyPic.png?" + Userdata.instance.version;
			
			//this.uiSKin.height = Browser.clientHeight *1280/Browser.clientWidth;

			//uiSKin.pwdBtn.on(Event.CLICK,this,onPwdLogin);
			//uiSKin.msgBtn.on(Event.CLICK,this,onMsgLogin);
			var json = Laya.loader.getRes("config.json?" + Userdata.instance.configVersion);
			var shortName:String = json["shortName"];
			uiSKin.titleBar.text = shortName + "自助下单系统";
			
			uiSKin.copyRight.text = json["copyRight"];
			
			
			//var json = Laya.loader.getRes("config.json?" + Userdata.instance.configVersion);
			var icpInfo:String = json["icp"];
			if(icpInfo != "")
				uiSKin.icp.text = icpInfo;
			
			var comInfo:String = json["comInfo"];
			if(icpInfo != "")
				uiSKin.comInfo.text = comInfo;
			
			onPwdLogin();
			
			//uiSKin.sendCodeBtn.on(Event.CLICK,this,onGetCode);
			uiSKin.input_account.maxChars = 11;
			uiSKin.input_account.restrict = "0-9";
			
			uiSKin.input_pwd.maxChars = 20;
			uiSKin.input_pwd.visible = false;
			
			//uiSKin.input_pwd.type = Input.TYPE_PASSWORD;
			
			
			uiSKin.input_pwd.alpha = 1;
			
			uiSKin.input_pwd.prompt = "";
			uiSKin.input_pwd.editable = false;
			uiSKin.input_pwd.disabled = true;
			
			
			
			uiSKin.input_account.on(Event.FOCUS,this,function(){
				
				uiSKin.accoutImg.skin = "commers/inputfocus.png";
				uiSKin.pwdImg.skin = "commers/inputbg.png";
				uiSKin.input_account.focus = true;
			});
			
		
			
			
			uiSKin.accountError.visible = false;
			uiSKin.pwdError.visible = false;

			uiSKin.txt_reg.underline = true;
			uiSKin.txt_reg.underlineColor =  Constast.CMYK_GREEN;
			
			uiSKin.txt_forget.underline = true;
			uiSKin.txt_forget.underlineColor =  Constast.CMYK_GREEN;
			
			uiSKin.txt_reg.on(Event.CLICK,this,onRegister);
			uiSKin.txt_forget.on(Event.CLICK,this,onResetpwd);
			
			uiSKin.btn_login.on(Event.CLICK,this,onLogin);
			
			//uiSKin.input_account.on(Event.KEY_DOWN,this,onAccountKeyUp);
			
			//uiSKin.input_pwd.on(Event.KEY_DOWN,this,onAccountKeyUp);
			
			
			Laya.stage.on(Event.KEY_DOWN,this,onStageKeyUp);
			
			uiSKin.input_account.focus = !Userdata.instance.isLogin;
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.on(EventCenter.OPEN_PANEL_VIEW,this,onOpenView);
			EventCenter.instance.on(EventCenter.COMMON_CLOSE_PANEL_VIEW,this,onshowInputPwd);
			Laya.timer.frameLoop(1,this,updatePwdInputPos);

			uiSKin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;
			uiSKin.logBox.visible = !Userdata.instance.isLogin;
			uiSKin.loginedBox.visible = Userdata.instance.isLogin;
			uiSKin.icp.on(Event.CLICK,this,onOpenGongshang);
			if(uiSKin.logBox.visible)
				initPwdinput();
			
			var autoLoginn:String = UtilTool.getLocalVar("autoLogin","0");
			uiSKin.checkAuto.selected = autoLoginn == "1";
			
			uiSKin.checkAuto.on(Event.CHANGE,this,onAutoLoginChange);
			var del:Button = uiSKin.pwdImg.getChildByName("delBtn") as Button;

			del.on(Event.CLICK,this,function(e){
				if(pwdInput != null)
				{
					pwdInput.value = "";
					e.stopPropagation();
					pwdInput.focus();
				}
				del.visible = false;
			})
			uiSKin.gotoFirst.on(Event.CLICK,this,function(){
				
				ViewManager.instance.closeView(ViewManager.VIEW_lOGPANEL);
				ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE);
				
				
			});
			//if(!Userdata.instance.isLogin && autoLoginn == "1")
			if(!Userdata.instance.isLogin)
				loginAccount();
			
			

		}
		
		private function onResizeBrower():void
		{

			uiSKin.height = Browser.clientHeight * Laya.stage.width/Browser.clientWidth;

		}
		
		private function onOpenGongshang()
		{
			Browser.window.open("https://beian.miit.gov.cn/#/Integrated/index",null,null,true);
			
		}
		
		private function onOpenView():void
		{
			if(pwdInput != null)
			{
				pwdInput.hidden = true;
				
			}
		}
		
		private function onshowInputPwd():void
		{
			if(pwdInput != null)
			{
				pwdInput.hidden = false;
				
			}
		}
		
		private function initPwdinput():void
		{
			
			pwdInput = Browser.document.createElement("input");
			
			pwdInput.style="filter:alpha(opacity=100);opacity:100;left:1100px;top:494px;font-size:28;color:#262827;border:none;font-family: SimHei;background-color: #f4f5f9";
			
			pwdInput.style.width = 502/Browser.pixelRatio;
			pwdInput.style.height = 53/Browser.pixelRatio;
			pwdInput.placeholder = "请输入密码";
			
			
			//			if(param && param.type == "License")
			//				file.multiple="";
			//			else			
			
			pwdInput.type ="password";
			pwdInput.style.position ="absolute";
			pwdInput.style.zIndex = 999;
			Browser.document.body.appendChild(pwdInput);//添加到舞台
			
			pwdInput.addEventListener("focus",function (event) {
				
				uiSKin.accoutImg.skin = "commers/inputbg.png";
				uiSKin.pwdImg.skin = "commers/inputfocus.png";
				
			})
//			
			pwdInput.addEventListener("blur",function (event) {
				
//				if(uiSKin != null && uiSKin.input_account != null && uiSKin.input_account.focus)
//				{
//					(uiSKin.input_account.textField as Input).nativeInput.focus();
//
//				}
				
			})
//				
			pwdInput.addEventListener("input",function (event) {
				
				var del:Button = uiSKin.pwdImg.getChildByName("delBtn") as Button;

				del.visible = pwdInput.value.length > 0;
				
			})
				

		}
		
		private function updatePwdInputPos():void
		{
			if(pwdInput != null)
			{
				//verifycode.style.top = 548 - uiSkin.mainpanel.vScrollBar.value + "px";
				var pt:Point = uiSKin.input_pwd.localToGlobal(new Point(uiSKin.input_pwd.x,uiSKin.input_pwd.y),true);
				
				var scaleNum:Number = Browser.clientWidth/Laya.stage.width;
								
				
				pwdInput.style.width = scaleNum * 502;//Browser.pixelRatio;
				pwdInput.style.height = scaleNum * 33;//Browser.pixelRatio;
				
				pwdInput.style.fontSize = 28*scaleNum;
				pwdInput.style.fontSize = 28*scaleNum;
				
								
				pwdInput.style.top = pt.y*scaleNum + "px";
				pwdInput.style.left = (pt.x - 32)*scaleNum +  "px";
			}
			
		}
				
		private function onAutoLoginChange():void
		{
			if(uiSKin.checkAuto.selected)
			{
				UtilTool.setLocalVar("autoLogin","1");
			}
			else
			{
				UtilTool.setLocalVar("autoLogin","0");

			}
		}
		private function loginAccount():void
		{
			var account:String = UtilTool.getLocalVar("useraccount","0");
			var pwd:String = UtilTool.getLocalVar("userpwd","0");
			var token:String = UtilTool.getLocalVar("userToken","0");
			
			//if(account != "0" && pwd != "0" && account != "" && pwd != "")
			if(token != "0" && token != "")
			{
				Userdata.instance.token = token;

//				uiSKin.input_account.text = account;
//				uiSKin.input_pwd.text = pwd;
//				var param:String = "phone=" + account + "&pwd=" + pwd + "&mode=0";
//				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.loginInUrl,this,onLoginBack,param,"post");
				
//				var param:Object = {};
//				param.mobileNumber = account;
//				if(logType == 0)
//				{
//					param.auth = pwd;
//					param.method = 0;
//				}
//				else
//				{
//					//param.auth =  uuId + "@" + uiSKin.input_code.text;
//					//param.method = 1;
//				}
//				
//				
//				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.loginInUrl,this,onLoginBack,JSON.stringify(param),"post");
				
//				var param:Object = {};
//				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.enterUrl,this,onLoginBack,JSON.stringify(param),"post");
			}
			

		}
		
		private function onPwdLogin():void
		{
//			uiSKin.pwdBtn.selected = true;
//			uiSKin.msgBtn.selected = false;
//			uiSKin.pwdLogin.visible = true;
//			uiSKin.mesgLogin.visible = false;
			logType = 0;
		}
		
		private function onMsgLogin():void
		{
//			uiSKin.pwdBtn.selected = false;
//			uiSKin.msgBtn.selected = true;
//			uiSKin.pwdLogin.visible = false;
//			uiSKin.mesgLogin.visible = true;
			logType = 1;
		}
		
		private function onGetCode():void
		{
			if(uiSKin.input_account.text.length < 11)
			{
				Browser.window.alert("请填写正确的手机号");
				return;
			}
			//uiSKin.sendCodeBtn.disabled = true;
			
			var params:Object = {"mobileNumber":uiSKin.input_account.text,"smsToken":UtilTool.uuid()};
			uuId = params.smsToken;
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getVerifyCode ,this,onGetPhoneCodeBack,JSON.stringify(params),"post");
		}
		private function onGetPhoneCodeBack(data:String):void
		{
//			var result:Object = JSON.parse(data);
//			if(result.code == 0)
//			{
//				uiSKin.sendCodeBtn.label = "60秒后重试";
//				Laya.timer.loop(1000,this,countdownCode);
//			}
//			else
//				uiSKin.sendCodeBtn.disabled = false;
			
		}
		private function countdownCode():void
		{
//			coutdown--;
//			if(coutdown > 0)
//			{
//				uiSKin.sendCodeBtn.label = coutdown + "秒后重试";
//			}
//			else
//			{
//				uiSKin.sendCodeBtn.disabled = false;
//				uiSKin.sendCodeBtn.label = "获取验证码";
//				Laya.timer.clear(this,countdownCode);
//			}
		}
		
		private function onAccountKeyUp(e:Event):void
		{
			if(e.keyCode == Keyboard.TAB)
			{
				if(uiSKin.input_account.focus)
				{
					//uiSKin.input_pwd.focus = true;
					pwdInput.focus();
					
				}
				//else if(uiSKin.input_account.focus)
				//	uiSKin.input_pwd.focus = true;
			}
			if(e.keyCode == Keyboard.ENTER)
			{
				onLogin();
			}
			e.stopPropagation();
		}
		
		private function onStageKeyUp(e:Event):void
		{
			if(e.keyCode == Keyboard.TAB)
			{
				if(Browser.window.document.activeElement == pwdInput)
				{
					pwdInput.blur();
					(uiSKin.input_account.textField as Input).nativeInput.focus();
					uiSKin.input_account.focus = true;
					uiSKin.accoutImg.skin = "commers/inputfocus.png";
					uiSKin.pwdImg.skin = "commers/inputbg.png";

				}
				else if(uiSKin.input_account.focus)
				{
					uiSKin.accoutImg.skin = "commers/inputbg.png";
					uiSKin.pwdImg.skin = "commers/inputfocus.png";

					pwdInput.focus();
				}
				
			}
			if(e.keyCode == Keyboard.ENTER)
			{
				onLogin();
			}
		}
		
		private function onLogin():void
		{
			// TODO Auto Generated method stub
			
			//(uiSKin.input_account.textField as Input).nativeInput.blur();
			//uiSKin.input_account.focus = false;
			
			
			if(uiSKin.input_account.text.length != 11)
			{
				ViewManager.showAlert("请填写正确的账号");
				return;
			}
			if(logType ==0 && pwdInput.value < 6)
			{
				ViewManager.showAlert("密码位数至少是6位");
				return;
			}
//			else if(logType == 1 && uiSKin.input_code.text.length < 1)
//			{
//				ViewManager.showAlert("请填写验证码");
//				return;
//			}
			
			var param:Object = {};
			param.mobileNumber = uiSKin.input_account.text;
			if(logType == 0)
			{
				param.auth = pwdInput.value;
				param.method = 0;
			}
			else
			{
				//param.auth =  uuId + "@" + uiSKin.input_code.text;
				//param.method = 1;
			}

			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.loginInUrl,this,onLoginBack, "phone=" + uiSKin.input_account.text + "&pwd=" + uiSKin.input_pwd.text + "&mode=0","post");

			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.loginInUrl,this,onLoginBackByPwd,JSON.stringify(param),"post");
		}
		
		private function onLoginBackByPwd(data:Object):void
		{
			onLoginBack(data);

		}
		private function onLoginBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			//if(result.status == 0)

			if(result.code == "0")
			{
				//Userdata.instance.resetData();
				
				Userdata.instance.isLogin = true;
				Userdata.instance.userAccount = result.data.mobileNumber;
				Userdata.instance.founderPhone = result.data.mobileNumber;
				Userdata.instance.userName = result.data.nickName;
				Userdata.instance.step = result.data.step;
				Userdata.instance.firstOrder = result.data.firstOrder;

				Userdata.instance.orgAudit = result.data.needAuditOrg;
				Userdata.instance.orgAuditState = result.data.orgAuditState;
				
				Userdata.instance.accountType = result.data.userType;
				Userdata.instance.privilege = result.data.userPermisson;
				if(result.data.token != null && result.data.token != "")
				{
					Userdata.instance.token = result.data.token;
					UtilTool.setLocalVar("userToken",Userdata.instance.token);

					
				}

				//ViewManager.showAlert("登陆成功");
				//Userdata.instance.userAccount = uiSKin.input_account.text;
				
				EventCenter.instance.event(EventCenter.LOGIN_SUCESS, Userdata.instance.userAccount);
				//UtilTool.setLocalVar("useraccount",uiSKin.input_account.text);
				//UtilTool.setLocalVar("userpwd",uiSKin.input_pwd.text);

				Userdata.instance.loginTime = (new Date()).getTime();
				UtilTool.setLocalVar("loginTime",Userdata.instance.loginTime);
				
				ViewManager.instance.closeView(ViewManager.VIEW_lOGPANEL);

				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,getCompanyInfoBack,null,null);
				
				
				//console.log(Browser.document.cookie.split("; "));
			}
			else
			{
				uiSKin.accountError.visible = result.status == 202;
				uiSKin.pwdError.visible = result.status == 204;

			}
			
		}
		
		private function getCompanyInfoBack(data:Object):void
		{
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "1058")
			{
				ViewManager.instance.openView(ViewManager.VIEW_REGPANEL,true,{"step":2});	
				//ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"您尚未加入公司",tips:"请申请注册公司,若已申请，请等待审核"});
				
			}
			else
				ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE);

		}
		private function onRegister():void
		{
			// TODO Auto Generated method stub
			ViewManager.instance.openView(ViewManager.VIEW_REGPANEL,true);
			
		}
		
		private function onResetpwd():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_CHANGEPWD,true);
			
		}
		override public function onEnable():void
		{
		}
		
		
		public override function onDestroy():void{
			// TODO Auto Generated method stub
			//Scene.close("login/LogPanel.scene");
			Laya.timer.clear(this,updatePwdInputPos);

			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			Laya.stage.off(Event.KEY_DOWN,this,onStageKeyUp);
			EventCenter.instance.off(EventCenter.OPEN_PANEL_VIEW,this,onOpenView);
			EventCenter.instance.off(EventCenter.COMMON_CLOSE_PANEL_VIEW,this,onshowInputPwd);
			//ViewManager.instance.closeView(ViewManager.VIEW_lOGPANEL);
			//ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE);
			if(pwdInput != null)
			{
				Browser.document.body.removeChild(pwdInput);//添加到舞台
				pwdInput = null;
			}
		}		
		
	}
}