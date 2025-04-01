package script.login
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.display.Input;
	import laya.events.Event;
	import laya.events.Keyboard;
	import laya.utils.Browser;
	
	import model.HttpRequestUtil;
	
	import script.ViewManager;
	
	import ui.login.ResetPwdPanelUI;
	
	import utils.UtilTool;
	
	public class ResetPwdControl extends Script
	{
		private var uiSkin:ResetPwdPanelUI;
		public var param:Object;

		private var inputarr:Array;
		private var focusindex:int = 0;
		
		private var coutdown:int = 60;
		private var uuId:String = "";

		public function ResetPwdControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			
			uiSkin = this.owner as ResetPwdPanelUI; 
			uiSkin.btnClose.on(Event.CLICK,this,onCloseScen);
			uiSkin.btngetcode.on(Event.CLICK,this,onGetCode);
			uiSkin.btnok.on(Event.CLICK,this,onChangepwd);

			uiSkin.inputpwd.maxChars = 20;
			//uiSkin.inputpwd.type = Input.TYPE_PASSWORD;
			uiSkin.inputphone.maxChars = 11;
			uiSkin.inputphone.restrict = "0-9";
			uiSkin.inputcode.maxChars = 6;
			
			uiSkin.inputcfmpwd.maxChars = 20;
			//uiSkin.inputcfmpwd.type = Input.TYPE_PASSWORD;
			
			uiSkin.mainpanel.vScrollBarSkin = "";
			uiSkin.mainpanel.hScrollBarSkin = "";

			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			this.uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

			
			inputarr = [uiSkin.inputphone,uiSkin.inputpwd,uiSkin.inputcfmpwd,uiSkin.inputcode];
			for(var i:int=0;i < inputarr.length;i++)
			{
				inputarr[i].on(Event.KEY_DOWN,this,onAccountKeyUp);
			}
			
			Laya.stage.on(Event.FOCUS_CHANGE,this,onFocusChange);
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

			uiSkin.inputphone.focus = true;
			focusindex = 0;
		}
		private function onResizeBrower():void
		{
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			this.uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

		}
		private function onGetCode():void
		{
			// TODO Auto Generated method stub
			if(uiSkin.inputphone.text.length < 11)
			{
				Browser.window.alert("请填写正确的手机号");
				return;
			}
			uiSkin.btngetcode.disabled = true;
			
			var params:Object = {"mobileNumber":uiSkin.inputphone.text,"smsToken":UtilTool.uuid()};
			uuId = params.smsToken;
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getVerifyCode ,this,onGetPhoneCodeBack,JSON.stringify(params),"post");
			
		}
		private function onGetPhoneCodeBack(data:String):void
		{
			var result:Object = JSON.parse(data);
			if(result.code == "0")
			{
				var phonecode = result.code;
				uiSkin.btngetcode.label = "60秒后重试";
				Laya.timer.loop(1000,this,countdownCode);
			}
			else
				uiSkin.btngetcode.disabled = false;
			
			//trace("pho code:" + data);
		}
		
		private function countdownCode():void
		{
			coutdown--;
			if(coutdown > 0)
			{
				uiSkin.btngetcode.label = coutdown + "秒后重试";
			}
			else
			{
				uiSkin.btngetcode.disabled = false;
				uiSkin.btngetcode.label = "获取验证码";
				Laya.timer.clear(this,countdownCode);
			}
		}
		
		private function onChangepwd():void
		{
			if(uiSkin.inputcode.text == "")
			{
				ViewManager.showAlert("请填写验证码");
				return;
			}
			if(uiSkin.inputpwd.text == "")
			{
				ViewManager.showAlert("请填写新的密码");
				return;
			}
			if(uiSkin.inputpwd.text.length < 6)
			{
				Browser.window.alert("密码长度至少6位");
				return;
			}
			if(uiSkin.inputpwd.text != uiSkin.inputcfmpwd.text)
			{
				ViewManager.showAlert("两次填写的密码不一致");
				return;
			}
			
			var params:Object = {};
			params.mobileNumber = uiSkin.inputphone.text;
			params.smsCode =  uuId + "@" + uiSkin.inputcode.text;;
			params.password = uiSkin.inputpwd.text;

			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.changePwdReqUrl ,this,onChangePwdBack,JSON.stringify(params),"post");

		}
		
		private function onChangePwdBack(data:String):void
		{
			if(data != "")
			{
				var result:Object = JSON.parse(data);
				if(result.code == "0")
				{
					ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{caller:this,callback:showloginView,msg:"修改成功"});

				}
			}
		}
		
		private function showloginView(b:Boolean):void
		{
			//ViewManager.instance.openView(ViewManager.VIEW_lOGPANEL);
			onCloseScen();

		}
		private function onFocusChange(e:Event):void
		{
			
			if(Laya.stage.focus != null && inputarr.indexOf(Laya.stage.focus.parent) >= 0)
				focusindex = inputarr.indexOf(Laya.stage.focus.parent);

		}
		private function onAccountKeyUp(e:Event):void
		{
			if(e.keyCode == Keyboard.TAB)
			{
				focusindex = (++focusindex)%inputarr.length;
				inputarr[focusindex].focus = true;
			}
			if(e.keyCode == Keyboard.ENTER)
			{
				//onLogin();
			}
		}
		
		private function onCloseScen():void
		{
			// TODO Auto Generated method stub
			ViewManager.instance.openView(ViewManager.VIEW_lOGPANEL,true);
			ViewManager.instance.closeView(ViewManager.VIEW_CHANGEPWD);
			Laya.stage.off(Event.FOCUS_CHANGE,this,onFocusChange);
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

		}
	}
}