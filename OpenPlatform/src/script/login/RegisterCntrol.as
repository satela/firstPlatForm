package script.login
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.display.Input;
	import laya.events.Event;
	import laya.events.Keyboard;
	import laya.maths.Point;
	import laya.net.Loader;
	import laya.ui.List;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.users.CityAreaVo;
	
	import script.ViewManager;
	import script.login.CityAreaItem;
	import script.prefabScript.CmykInputControl;
	
	import ui.login.RegisterPanelUI;
	import ui.login.RegisterPhonePanelUI;
	
	import utils.UtilTool;
	import utils.WaitingRespond;
	
	public class RegisterCntrol extends Script
	{
		//private var uiSkin:RegisterPanelUI;
		private var uiSkin:RegisterPhonePanelUI;

		private var province:Object;
		
		//private var verifycode:Object;
		public var param:Object;

		private var phonecode:String = "";
		
		private var coutdown:int = 60;
		
		private var curStep:int = 0;
		private var proid:String = "";
		private var cityid:String = "";
		private var areaid:String = "";
		private var townid:String = "";
		private var hasInit:Boolean = false;
		private var companyareaId:String;
		
		private var thirdid:String;

		
		private var uuId:String = "";
		
		private var inputListUser:Array;
		private var inputListCompany:Array;
		
		private var curInputIndex:int = 0;

		private var serviceTxt:String = "尊敬的用户：\n" +
     									"   shortName是专业的为广告及相关产品委托生产、买卖、交付等提供服务的网站（下称“本网站”），为广告相关产品及其他产品的委托生产、买卖、交付等的双方用户提供居间服务及其他相关服务，在此特别提醒用户认真阅读本《服务协议》(下称“本协议”)中各个条款，并确认是否同意本协议条款。用户的使用行为将视为对本协议的接受，并同意接受本协议各项条款的约束。\n\n" + 

										"一、本协议条款的确认\n" + 
										"   1、本网站的各项服务的所有权归companyName。本协议内容包括协议正文及所有本网站已经发布或将来可能发布的各类规则。所有规则为协议不可分割的一部分，与本协议正文具有同等法律效力。以任何方式进入本网站即表示用户已充分阅读、理解并同意接受本协议的条款。\n" + 
    									"   2、本网站有权根据业务需要酌情修订本协议，并以网站公告或直接更新的形式进行更新，不再单独通知。经修订的协议条款一经公布，即产生效力。如用户不同意相关修订，可以选择停止使用。如用户继续使用本网站，则将视为用户已接受经修订的协议条款。\n\n" + 
										"二、服务要求及保密\n" + 
										"1、用户必须符合下列要求：\n" + 
		" （1）应当是具备完全民事权利能力和与所从事的民事行为相适应的行为能力的自然人、法人或其他组织；\n" + 
		" （2）自行配备上网的所需设备，并自行负担上网及其他与此服务有关的电话、网络等费用；\n" + 
		" （3）按本网站要求完成注册，保证向本网站提供的任何资料、注册信息的真实性、正确性及完整性，保证本网站可以通过上述联系方式与用户进行联系；当上述资料发生变更时，及时更新用户资料；\n" + 
		" （4）账号使用权仅属于初始注册人，禁止赠与、借用、租用、转让或售卖，否则，本网站有权收回账号；\n" + 
		" （5）用户保证各项行为符合各项法律、法规、政策规定，以及本网站各项协议等的要求；\n" + 
		" （6）用户为委托方或买方的，保证遵守印刷、出版等行业的法律、法规、政策规定，且保证要求制作的产品不会侵犯他人的知识产权；\n" + 
		" （7）用户为广告经营者的，应当在注册时验证广告经营资格；若后续资格有变动的，应及时变更登记信息。\n" + 
		"2、本网站对用户的隐私资料进行保护，承诺不会在未获得用户许可的情况下擅自将用户的个人资料信息出租或出售给任何第三方，但以下情况除外：\n" + 
		" （1）为完成用户与第三方交易； \n" + 
		" （2）用户同意让第三方共享资料；\n" + 
		" （3）用户同意公开其个人资料，享受为其提供的商品和服务；\n" + 
		" （4）根据法律的有关规定，或者行政或司法机构的要求，向第三方或者行政、司法机构披露；\n" + 
		" （5）本网站发现用户违反了本网站服务条款或其它规定。\n" + 
		"   若本网站有合理理由怀疑用户资料信息为错误、不实、失效或不完整，本网站有权暂停或终止用户的帐号，并拒绝现在或将来使用本站网络服务的全部或部分，同时保留追索用户不当得利返还的权利。\n\n" + 
		"三、平台服务和地位 \n" + 
		"   本网站仅作为用户物色交易对象，就货物和服务的交易进行协商，以及获取各类与交易相关的居间服务的场所，不涉及用户间因交易而产生的法律关系及法律纠纷。本网站不能控制或保证交易信息的真实性、合法性、准确性，亦不能控制或保证交易所涉及的物品及服务的质量、安全或合法性，以及相关交易各方履行在贸易协议项下的各项义务的能力。但本网站会尽力协助各方履行各自义务。用户注册并选择本网站提供的服务，即视为认可由本网站为其提供居间服务及有关服务的内容，同时认可通过本网站指定的账号或支付平台由本网站监管、代付有关款项。\n\n" + 
		"四、结束服务\n" + 
		"   用户或本网站可随时根据实际情况中断一项或多项网络服务。本网站不需对任何个人或第三方负责而随时中断服务。结束用户服务后，用户使用网络服务的权利马上中止。从那时起，用户没有权利要求本网站，本网站也没有义务传送任何未处理的信息或提供未完成的服务给用户或第三方。用户在使用服务期间因使用服务与其他用户之间发生的关系，不因本协议的终止而终止。\n\n" + 
		
		"五、服务费用。 \n" + 
		"   本网站保留在征得用户同意后，收取服务费用的权利。用户因进行交易、获取有偿服务等发生的所有应纳税赋，由用户自行承担。\n\n" + 
		
		"六、广告展示\n" + 
		"   用户在本网站发表宣传资料或参与广告策划，展示商品或服务，都只是在相应的用户之间发生，本网站不承担任何责任。\n\n" + 
		
		"七、服务内容的所有权\n" + 
		"   本网站有关文字、软件、声音、图片、录象、图表、广告及其他文件的全部内容受版权、商标、和其它财产所有权属于本网站所有，受法律的保护。\n\n" + 
		
		"八、责任限制\n" + 
		"   如因不可抗力或其他本网站无法控制的原因使本网站无法正常运营的，本网站不承担责任。\n\n" + 
		
		"九、争议解决和管辖\n" + 
		"   本协议的订立、执行和解释及争议的解决均应适用中国法律。\n" + 
		"如用户与本网站发生任何争议，双方应尽力友好协商解决；协商不成时，任何一方均应向本网站所属公司住所地人民法院提起诉讼。\n";


		


		public function RegisterCntrol()
		{
			super();
		}
		
		override public function onStart():void
		{
			
			uiSkin = this.owner as RegisterPanelUI; 
						
			uiSkin.mainpanel.vScrollBarSkin = "";
			uiSkin.mainpanel.hScrollBarSkin = "";
			uiSkin.contractpanel.hScrollBarSkin = "";
			uiSkin.contractpanel.vScrollBarSkin = "";

//			uiSkin.input_adress.maxChars = 200;
//			uiSkin.input_company.maxChars = 50;
			uiSkin.input_conpwd.maxChars = 20;
			uiSkin.input_conpwd.type = Input.TYPE_PASSWORD;
			uiSkin.input_phone.maxChars = 11;
			uiSkin.input_phone.restrict = "0-9";
			uiSkin.input_phonecode.maxChars = 46;
			
			uiSkin.input_pwd.maxChars = 20;
			//uiSkin.input_pwd.type = Input.TYPE_PASSWORD;
			
			uiSkin.nameInput.maxChars = 20;
			
			uiSkin.applyJoinPanel.visible = false;
			uiSkin.step1Panel.visible = true;
			uiSkin.step2Panel.visible = false;
			inputListUser = [uiSkin.input_phone,uiSkin.input_pwd,uiSkin.inputCode,uiSkin.input_phonecode];
			inputListCompany = [uiSkin.input_companyname,uiSkin.contactName,uiSkin.contactPhone,uiSkin.detail_addr];
			
			for(var i:int=0;i < inputListUser.length;i++)
			{
				inputListUser[i].on(Event.INPUT,this,checkNextBtnState);
				inputListUser[i].on(Event.KEY_DOWN,this,onInputKeyDown,[inputListUser]);
				inputListUser[i].on(Event.FOCUS,this,onInputFocus,[i]);
				inputListCompany[i].on(Event.KEY_DOWN,this,onInputKeyDown,[inputListCompany]);
				inputListCompany[i].on(Event.FOCUS,this,onInputFocus,[i]);
			}
			
			uiSkin.createAccountInput.maxChars = 11;
			uiSkin.createAccountInput.restrict = "0-9";
			
			uiSkin.codeValid.visible = false;
			
			uiSkin.commentInput.maxChars = 8;
			
			uiSkin.applyEnter.on(Event.CLICK,this,function(){
				
				uiSkin.applyJoinPanel.visible = true;
			});
			
			uiSkin.closeJoin.on(Event.CLICK,this,function(){
				
				uiSkin.applyJoinPanel.visible = false;
			});
			uiSkin.confirmJoin.on(Event.CLICK,this,onJoinCompany);
			
			checkNextBtnState();
//			uiSkin.input_receiver.maxChars = 10;
//			uiSkin.input_receiverphone.maxChars = 11;
//			uiSkin.input_receiverphone.restrict = "0-9";
			uiSkin.inputCode.maxChars = 8;
			
			uiSkin.sevicepro.leading = 5;
			
			var json = Laya.loader.getRes("config.json?" + Userdata.instance.configVersion);
			var companyName:String = json["companyName"];
			var shortName:String = json["shortName"];
			
			uiSkin.sevicepro.text = serviceTxt.replace("companyName",companyName).replace("shortName",shortName);
			
			//uiSkin.sevicepro.text = serviceTxt;
			
			uiSkin.txtpanel.vScrollBarSkin = "";
			uiSkin.txtpanel.hScrollBarSkin = "";

//			if(Browser.height > Laya.stage.height)
//				uiSkin.contractpanel.height = Laya.stage.height;
//			else
//				uiSkin.contractpanel.height = Browser.height;

			
			//uiSkin.contractpanel.width = Browser.width;

//			uiSkin.radio_default.selectedIndex = 0;
//			
			uiSkin.provList.itemRender = CityAreaItem;
			uiSkin.provList.vScrollBarSkin = "";
			uiSkin.provList.repeatX = 1;
			uiSkin.provList.spaceY = 2;
//			
			uiSkin.provList.renderHandler = new Handler(this, updateCityList);
			uiSkin.provList.selectEnable = true;
			uiSkin.provList.selectHandler = new Handler(this, selectProvince);
			
			uiSkin.cityList.itemRender = CityAreaItem;
			uiSkin.cityList.vScrollBarSkin = "";
			uiSkin.cityList.repeatX = 1;
			uiSkin.cityList.spaceY = 2;
			
			uiSkin.cityList.selectEnable = true;
			
			uiSkin.cityList.renderHandler = new Handler(this, updateCityList);
			uiSkin.cityList.selectHandler = new Handler(this, selectCity);
			
			
			uiSkin.areaList.itemRender = CityAreaItem;
			uiSkin.areaList.vScrollBarSkin = "";
			uiSkin.areaList.selectEnable = true;
			uiSkin.areaList.repeatX = 1;
			uiSkin.areaList.spaceY = 2;
			
			uiSkin.areaList.renderHandler = new Handler(this, updateCityList);
			uiSkin.areaList.selectHandler = new Handler(this, selectArea);
			
			uiSkin.townList.itemRender = CityAreaItem;
			uiSkin.townList.vScrollBarSkin = "";
			uiSkin.townList.selectEnable = true;
			uiSkin.townList.repeatX = 1;
			uiSkin.townList.spaceY = 2;
			
			uiSkin.townList.renderHandler = new Handler(this, updateCityList);
			uiSkin.townList.selectHandler = new Handler(this, selectTown);
			
			
			uiSkin.btnSelProv.on(Event.CLICK,this,onShowProvince);
			uiSkin.btnSelCity.on(Event.CLICK,this,onShowCity);
			uiSkin.btnSelArea.on(Event.CLICK,this,onShowArea);
			uiSkin.btnSelTown.on(Event.CLICK,this,onShowTown);

			uiSkin.btnGetCode.on(Event.CLICK,this,onGetPhoneCode);

			//uiSkin.btnClose.on(Event.CLICK,this,onCloseScene);
			//uiSkin.bgimg.alpha = 0.9;
			uiSkin.areabox.visible = false;
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = false;
			uiSkin.townbox.visible = false;
			
			//uiSkin.txtRefresh.underline = true;
			//uiSkin.txtRefresh.underlineColor = "#121212";
			uiSkin.txtRefresh.on(Event.CLICK,this,onRefreshVerify);

			uiSkin.gotoNext.on(Event.CLICK,this,onRegister);
			uiSkin.gotoFirst.on(Event.CLICK,this,onCloseScene);
			uiSkin.on(Event.CLICK,this,hideAddressPanel);

			//uiSkin.mainpanel.height = Browser.height;
			//iSkin.mainpanel.width = Browser.width;

			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;

			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			updateStep();
			if(param != null && param.step == 2)
			{
				uiSkin.contractpanel.visible = false;
				gotoRegisterCompany();
				
			}
			
			//Laya.timer.frameLoop(1,this,updateVerifyPos);
			//Laya.timer.frameLoop(1,this,updateVeryfiCodePos);

			Browser.window.uploadApp = this;

			uiSkin.okbtn.disabled = true;
			uiSkin.agreebox.on(Event.CLICK,this,onAgreeService);
			uiSkin.okbtn.on(Event.CLICK,this,onReadService);
			uiSkin.applyBtn.on(Event.CLICK,this,onApplayCompanyRegister);

		}
		
//		private function initView():void
//		{
//			uiSkin.provList.array = ChinaAreaModel.instance.getAllProvince();
//			selectProvince(0);
//			uiSkin.provList.refresh();
//		}
		
		private function onInputKeyDown(inputList:Array,e:Event):void
		{
			if(e.keyCode == Keyboard.TAB)
			{
				curInputIndex++;
				curInputIndex = (curInputIndex%inputList.length);
				
				
				inputList[curInputIndex].focus = true;
			}
			
		}
		
		private function onInputFocus(index:int):void
		{
			curInputIndex = index;
			hideAddressPanel(null);
		}
		private function updateStep():void
		{
			if(curStep == 0)
			{
				uiSkin.sencondStep.filters = [UtilTool.grayscaleFilter];
				//uiSkin.lastStep.filters = [UtilTool.grayscaleFilter];
				//uiSkin.secondLine.filters = [UtilTool.grayscaleFilter];
			}
			else
			{
				uiSkin.sencondStep.filters = null;
				//uiSkin.secondLine.filters = null;
			}
		}
		private function onReadService():void
		{
			uiSkin.contractpanel.visible = false;
			var codes:Array = UtilTool.getVerifyCodes(4);
			
			for(var i:int=0;i<codes.length;i++)
			{
				uiSkin["code"+i].text = codes[i];
			}
			inputListUser[0].focus = true;

//			verifycode = Browser.document.createElement("div");
//			verifycode.id = "v_container";
//			verifycode.style="width: 200px;height: 78px;left:950px;top:548";
//			verifycode.style.width = 200/Browser.pixelRatio + "px";
//			verifycode.style.height = 50/Browser.pixelRatio + "px";
//			
//			
//			verifycode.style.position ="absolute";
//			verifycode.style.zIndex = 999;
//			Browser.document.body.appendChild(verifycode);//添加到舞台
//			
//			//uiSkin.on(Event.CLICK,this,hideAddressPanel);
//			Browser.window.loadVerifyCode();
			
		}
		private function onAgreeService():void
		{
			uiSkin.okbtn.disabled = !uiSkin.agreebox.selected;
		}
		private function onResizeBrower():void
		{
			
			
			//uiSkin.contractpanel.height = Browser.height;
//			if(Browser.height > Laya.stage.height)
//				uiSkin.contractpanel.height = Laya.stage.height;
//			else
//				uiSkin.contractpanel.height = Browser.height;
//			uiSkin.contractpanel.width = Browser.width;
//
//			uiSkin.mainpanel.height = Browser.height;
//			uiSkin.mainpanel.width = Browser.width;
			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;

		}
		
//		private function updateVeryfiCodePos():void
//		{
//			if(verifycode != null)
//			{
//				var pt:Point = uiSkin.imgCodeInput.localToGlobal(new Point(uiSkin.imgCodeInput.x,uiSkin.imgCodeInput.y),true);
//				
//				var scaleNum:Number = Browser.clientWidth/Laya.stage.width;
//				
//				
//				verifycode.style.top = (pt.y - 340)*scaleNum + "px";
//				verifycode.style.left = (pt.x-150)*scaleNum +  "px";				
//				
//				verifycode.style.width =  "200px";
//				verifycode.style.height = "78px";
//				
//			}
//		}
		
		private function onGetPhoneCode():void
		{
			// TODO Auto Generated method stub
//			var res:Boolean = Browser.window.checkCode(uiSkin.inputCode.text);
//			if(!res)
//			{
//				ViewManager.showAlert("图片验证码错误");
//				return;
//			}
			if(uiSkin.input_phone.text.length < 11)
			{
				Browser.window.alert("请填写正确的手机号");
				return;
			}
			uiSkin.btnGetCode.disabled = true;
			var params:Object = {"mobileNumber":uiSkin.input_phone.text,"smsToken":UtilTool.uuid()};
			uuId = params.smsToken;
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getVerifyCode ,this,onGetPhoneCodeBack,JSON.stringify(params),"post");
		}
		
		
		private function onGetPhoneCodeBack(data:String):void
		{
			if(this.destroyed)
				return;
			var result:Object = JSON.parse(data);
			coutdown = 60;
			if(result.code == "0")
			{
				phonecode = result.code;
				uiSkin.btnGetCode.label = "60秒后重试";
				Laya.timer.loop(1000,this,countdownCode);
			}
			else
				uiSkin.btnGetCode.disabled = false;

		}
		
		private function countdownCode():void
		{
			coutdown--;
			if(coutdown > 0)
			{
				uiSkin.btnGetCode.label = coutdown + "秒后重试";
			}
			else
			{
				uiSkin.btnGetCode.disabled = false;
				uiSkin.btnGetCode.label = "获取验证码";
				Laya.timer.clear(this,countdownCode);
				uiSkin.codeValid.visible = true;

			}
		}
		private function onRefreshVerify(e:Event):void
		{
			//Browser.window.loadVerifyCode();
			
			var codes:Array = UtilTool.getVerifyCodes(4);
			
			for(var i:int=0;i<codes.length;i++)
			{
				uiSkin["code"+i].text = codes[i];
			}

		}
		private function onCloseScene():void
		{
			//if(verifycode != null)
			//Browser.document.body.removeChild(verifycode);//添加到舞台
			Laya.timer.clear(this,countdownCode);

			ViewManager.instance.closeView(ViewManager.VIEW_REGPANEL);
			ViewManager.instance.openView(ViewManager.VIEW_lOGPANEL,true);
			if(typeof(Browser.window.orientation) != "undefined" && Userdata.instance.isLogin)
				ViewManager.showAlert("注册成功！\n欢迎通过电脑访问www.ps.vip下单。");
			

			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

			//this.owner.removeSelf();
		}		
		
		private function checkNextBtnState():void
		{
			var enabled:Boolean = true;
			if(uiSkin.input_phone.text.length < 11)
			{
				enabled = false;
			}
//			if(uiSkin.nameInput.text == "")
//			{
//				enabled = false;
//			}
			if(uiSkin.input_phone.text.length < 11)
			{
				enabled = false;
			}
			if(uiSkin.input_pwd.text.length < 6)
			{
				enabled = false;
			}
//			if(uiSkin.input_conpwd.text.length < 6)
//			{
//				enabled = false;
//			}
			if(uiSkin.input_phonecode.text == "")
			{
				enabled = false;
			}
			
			if(uiSkin.inputCode.text.length < 4)
			{
				enabled = false;
			}
			
			uiSkin.gotoNext.disabled = !enabled;
		}
		private function onRegister():void
		{
			
			var res:Boolean = uiSkin.inputCode.text.toLocaleLowerCase() == (uiSkin.code0.text + uiSkin.code1.text + uiSkin.code2.text + uiSkin.code3.text).toLocaleLowerCase();
			
			if(res)
			{
				if(uiSkin.input_phone.text.length < 11)
				{
					Browser.window.alert("请填写正确的手机号");
					return;
				}
//				if(uiSkin.nameInput.text.length == 0)
//				{
//					Browser.window.alert("请输入用户名");
//					return;
//				}
				
				if(uiSkin.input_pwd.text.length < 6)
				{
					Browser.window.alert("密码长度至少6位");
					return;
				}
//				if(uiSkin.input_pwd.text != uiSkin.input_conpwd.text)
//				{
//					Browser.window.alert("密码确认不对");
//					uiSkin.conpwdError.visible = true;
//					return;
//				}
				
//				if(uiSkin.input_company.text.length < 6)
//				{
//					Browser.window.alert("请填写正确的公司名称");
//					return;
//				}
//				if(uiSkin.input_receiver.text == "")
//				{
//					Browser.window.alert("请填写收货人");
//					return;
//				}
//				if(uiSkin.input_receiverphone.text == "")
//				{
//					Browser.window.alert("请填写收货人电话");
//					return;
//				}
//				if(uiSkin.input_receiverphone.text == "")
//				{
//					Browser.window.alert("请填写收货人电话");
//					return;
//				}
//				
//				if(uiSkin.province.text == "")
//				{
//					Browser.window.alert("请选择省份");
//					return;
//				}
//				
//				if(uiSkin.citytxt.text == "")
//				{
//					Browser.window.alert("请选择城市");
//					return;
//				}
//				if(uiSkin.citytxt.text == "")
//				{
//					Browser.window.alert("请选择城市");
//					return;
//				}
//				
//				if(uiSkin.input_adress.text.length < 10)
//				{
//					Browser.window.alert("请填写详细收货地址");
//					return;
//				}
//				
//				if(uiSkin.input_phonecode.text == "")
//				{
//					Browser.window.alert("请填写手机验证码");
//					return;
//				}
				
				var param:Object = {};
				param.mobileNumber = uiSkin.input_phone.text;
				param.password = uiSkin.input_pwd.text;
				param.smsCode = uuId + "@" + uiSkin.input_phonecode.text;	//"13a9f1c2-9a81-11ee-b9d1-0242ac120002";//
				//param.smsCode = "13a9f1c2-9a81-11ee-b9d1-0242ac120002";//
				param.nickName = uiSkin.input_phone.text;		

				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.registerUrl,this,onRegisterBack,JSON.stringify(param),"post");

			}
			else
			{
				Browser.window.alert("图片验证码错误");
				//Browser.window.loadVerifyCode();

			}

		}
		
		private function onRegisterBack(data:String):void
		{
			if(this.destroyed)
				return;
			// TODO Auto Generated method stub
			var result:Object = JSON.parse(data);
			if(result.code == 0)
			{
				//Browser.window.alert("注册成功！");
				//Browser.document.body.removeChild(verifycode);//添加到舞台
				//verifycode = null;
				uiSkin.step1Panel.visible = false;
				uiSkin.step2Panel.visible = true;
				uiSkin.input_companyname.focus = true;
				
				curStep = 1;
				updateStep();
				
				
				//var param:String = "phone=" + uiSkin.input_phone.text + "&pwd=" + uiSkin.input_pwd.text + "&mode=0";
				//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.loginInUrl,this,onLoginBack,param,"post");
				
				var param:Object = {};
				param.mobileNumber = uiSkin.input_phone.text;
				
				param.auth = uiSkin.input_pwd.text;
				param.method = 0;				
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.loginInUrl,this,onLoginBack,JSON.stringify(param),"post");
				

			}
		}		
		
		private function onLoginBack(data:Object):void
		{
			if(this.destroyed)
				return;
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				Userdata.instance.resetData();
				
				Userdata.instance.isLogin = true;
				Userdata.instance.userAccount = result.data.mobileNumber;
				Userdata.instance.accountType = result.data.userType;
				Userdata.instance.privilege = result.data.userPermisson;
				Userdata.instance.token = result.data.token;
				Userdata.instance.userName = result.data.nickName;
				Userdata.instance.orgAudit = result.data.needAuditOrg;
				Userdata.instance.orgAuditState = result.data.orgAuditState;

				
				Userdata.instance.step = result.data.step;
				Userdata.instance.firstOrder = result.data.firstOrder;

				
				if(result.data.token != null && result.data.token != "")
				{
					Userdata.instance.token = result.data.token;
					UtilTool.setLocalVar("userToken",Userdata.instance.token);
					
					
				}
				
				
				updateAuditState();
				//ViewManager.showAlert("登陆成功");
				EventCenter.instance.event(EventCenter.LOGIN_SUCESS, uiSkin.input_phone.text);
				UtilTool.setLocalVar("useraccount",uiSkin.input_phone.text);
				UtilTool.setLocalVar("userpwd",uiSkin.input_pwd.text);
				
				Userdata.instance.loginTime = (new Date()).getTime();
				UtilTool.setLocalVar("loginTime",Userdata.instance.loginTime);
				uiSkin.contactPhone.text = Userdata.instance.userAccount;

				//ViewManager.instance.closeView(ViewManager.VIEW_lOGPANEL);
				//ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE);
				
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer + "parentId=0",this,initView,null,null);

				
				//console.log(Browser.document.cookie.split("; "));
			}
			else
			{
				
				
			}
			
		}
		
		private function gotoRegisterCompany():void
		{
			uiSkin.step1Panel.visible = false;
			uiSkin.step2Panel.visible = true;
			uiSkin.input_companyname.focus = true;
			curStep = 1;
			updateStep();
			updateAuditState();

		}
		private function updateAuditState():void
		{
			if(Userdata.instance.orgAudit)
				uiSkin.applyBtn.label = "提交审核";
			
			if(Userdata.instance.orgAuditState == 0)
			{
				uiSkin.applyBtn.disabled = true;
				uiSkin.applyBtn.label = "审核中...";
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAuditInfo,this,getAuditInfoBack,null,null);
				uiSkin.applyEnter.visible = false;

			}
			else
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer + "parentId=0",this,initView,null,null);

			if(Userdata.instance.orgAuditState == 2)
			{
				uiSkin.auditTips.visible = true;
			}
			else
				uiSkin.auditTips.visible = false;
			
		}
		private function getAuditInfoBack(data:*):void
		{
			if(this.destroyed)
				return;
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				uiSkin.input_companyname.text = result.data.name;
				uiSkin.contactName.text = result.data.cnee;
				uiSkin.contactPhone.text = result.data.mobileNumber;
				uiSkin.detail_addr.text = result.data.addr;
				
				proid = (result.data.regionId as String).slice(0,2) + "0000";
				cityid = (result.data.regionId as String).slice(0,4) + "00";
				areaid = (result.data.regionId as String).slice(0,6);
				townid = result.data.regionId;
				
			}
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer + "parentId=0",this,initView,null,null);

		}
		public override function onDestroy():void
		{
			
			Laya.timer.clearAll(this);

		}
		private function hideAddressPanel(e:Event):void
		{
			if(e != null && e.target is List)
				return;
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = false;
			uiSkin.areabox.visible = false;
			uiSkin.townbox.visible = false;
			
			uiSkin.mainpanel.vScrollBar.target = uiSkin.mainpanel;


		}
		private function onShowProvince(e:Event):void
		{
			uiSkin.provbox.visible = true;
			uiSkin.citybox.visible = false;
			uiSkin.areabox.visible = false;
			uiSkin.townbox.visible = false;
			
			uiSkin.mainpanel.vScrollBar.target = null;
						
			e.stopPropagation();
		}
		private function onShowCity(e:Event):void
		{
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = true;
			uiSkin.areabox.visible = false;
			uiSkin.townbox.visible = false;
			uiSkin.mainpanel.vScrollBar.target = null;

			e.stopPropagation();
		}
		private function onShowArea(e:Event):void
		{
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = false;
			uiSkin.areabox.visible = true;
			uiSkin.townbox.visible = false;
			uiSkin.mainpanel.vScrollBar.target = null;

			e.stopPropagation();
		}
		
		private function onShowTown(e:Event):void
		{
			uiSkin.provbox.visible = false;
			uiSkin.citybox.visible = false;
			uiSkin.areabox.visible = false;
			uiSkin.townbox.visible = true;
			uiSkin.mainpanel.vScrollBar.target = null;

			e.stopPropagation();
		}
		
		private function updateCityList(cell:CityAreaItem,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function initView(data:Object):void
		{
			if(this.destroyed)
				return;
			
			//WaitingRespond.instance.hideWaitingView();
			var result:Object = JSON.parse(data as String);
			
			uiSkin.provList.array = result.data as Array;//ChinaAreaModel.instance.getAllProvince();
			
			var selpro:int = 0;
			if(hasInit == false)
			{
				//var auditproid:String = UtilTool.getLocalVar("proid","0");
				
				if(proid  != "")
				{
					for(var i:int=0;i < uiSkin.provList.array.length;i++)
					{
						if(uiSkin.provList.array[i].id == proid)
						{
							selpro = i;
							break;
						}
					}
				}
			}
			
			selectProvince(selpro);
		}
		
		private function selectProvince(index:int):void
		{
			if(uiSkin.provList.array[index] == null)
				return;
			if(uiSkin == null || uiSkin.destroyed)
				return;
			
			province = uiSkin.provList.array[index];
			uiSkin.provbox.visible = false;
			uiSkin.province.text = province.areaName;
			
			proid = province.id;
			
			
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer+"parentId="+proid ,this,function(data:String)
			{
				if(uiSkin == null || uiSkin.citytxt == null || uiSkin.destroyed)
					return;
				
				var result:Object = JSON.parse(data as String);
				
				uiSkin.cityList.array = result.data as Array;//ChinaAreaModel.instance.getAllCity(province.id);
				uiSkin.cityList.refresh();
				
				var selpro:int = 0;
				if(hasInit == false)
				{
					
					if(cityid  != "")
					{
						for(var i:int=0;i < uiSkin.cityList.array.length;i++)
						{
							if(uiSkin.cityList.array[i].id == cityid)
							{
								selpro = i;
								break;
							}
						}
					}
				}
				
				uiSkin.citytxt.text = uiSkin.cityList.array[selpro].areaName;
				//uiSkin.cityList.selectedIndex = selpro;
				selectCity(selpro);
				
			},null,null);
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);
			
		}
		
		private function selectCity(index:int):void
		{
			if(uiSkin == null || uiSkin.destroyed)
				return;
			
			uiSkin.citybox.visible = false;
			
			cityid = uiSkin.cityList.array[index].id;
			
			var tempid = cityid;

			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer+"parentId="+tempid ,this,function(data:String)
			{
				if(uiSkin == null || uiSkin.areatxt == null || uiSkin.destroyed)
					return;
				
				var result:Object = JSON.parse(data as String);
				
				uiSkin.areaList.array = result.data as Array;//ChinaAreaModel.instance.getAllCity(province.id);
				uiSkin.areaList.refresh();
				
				var selpro:int = 0;
				if(hasInit == false)
				{
					
					if(areaid != "")
					{
						for(var i:int=0;i < uiSkin.areaList.array.length;i++)
						{
							if(uiSkin.areaList.array[i].id == areaid)
							{
								selpro = i;
								break;
							}
						}
					}
				}
				
				uiSkin.areatxt.text = uiSkin.areaList.array[selpro].areaName;
				//uiSkin.areaList.selectedIndex = selpro;
				selectArea(selpro);
				
				
			},null,null);
			uiSkin.citytxt.text = uiSkin.cityList.array[index].areaName;
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);
			
		}
		
		private function selectArea(index:int):void
		{
			if(uiSkin == null || uiSkin.destroyed)
				return;
			
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);
			
			if( index == -1 )
				return;
			areaid = uiSkin.areaList.array[index].id;
			
			var tempid = areaid;
			

			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAddressFromServer+"parentId="+tempid ,this,function(data:String)
			{
				if(uiSkin == null || uiSkin.towntxt == null || uiSkin.destroyed)
					return;
				
				
				var result:Object = JSON.parse(data as String);
				
				uiSkin.btnSelTown.visible = result.data.length > 0;
				if(result.data.length == 0)
				{
					companyareaId = areaid;
					return;
				}
				
				uiSkin.townList.array = result.data as Array;//ChinaAreaModel.instance.getAllCity(province.id);
				uiSkin.townList.refresh();
				
				var selpro:int = 0;
				if(hasInit == false)
				{
					
					if(townid != "")
					{
						for(var i:int=0;i < uiSkin.townList.array.length;i++)
						{
							if(uiSkin.townList.array[i].id == townid)
							{
								selpro = i;
								break;
							}
						}
					}
				}
				
				uiSkin.towntxt.text = uiSkin.townList.array[selpro].areaName;
				//uiSkin.townList.selectedIndex =selpro;
				companyareaId = uiSkin.townList.array[selpro].id;
				
				
			},null,null);
			
			uiSkin.areatxt.text = uiSkin.areaList.array[index].areaName;
			
			uiSkin.areabox.visible = false;
			
		
		}
		
		private function selectTown(index:int):void
		{
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);
			hasInit = true;
			
			if( index == -1 )
				return;
			uiSkin.townbox.visible = false;
			uiSkin.towntxt.text = uiSkin.townList.array[index].areaName;
			companyareaId = uiSkin.townList.array[index].id;
			townid = companyareaId;
			
		}
		
		private function onApplayCompanyRegister():void
		{
			
			if(uiSkin.input_companyname.text.length < 6)
			{
				ViewManager.showAlert("企业名称长度至少6位");
				
			}
			if(UtilTool.hasForbidenChars(uiSkin.input_companyname.text))
			{
				
				ViewManager.showAlert("请不要填写\\、*、/、#、\"等特殊字符");
				return;
				
			}
			
			if(uiSkin.contactName.text == "")
			{
				ViewManager.showAlert("请填写联系人");
				return;
			}
			
			if(UtilTool.hasForbidenChars(uiSkin.contactName.text))
			{
				
				ViewManager.showAlert("请不要填写\\、*、/、#、\"等特殊字符");
				return;
				
			}
			
			if(uiSkin.contactPhone.text.length < 11)
			{
				Browser.window.alert("请填写正确的联系人手机号");
				return;
			}
			
			if(UtilTool.hasForbidenChars(uiSkin.detail_addr.text))
			{
				
				ViewManager.showAlert("请不要填写\\、*、/、#、\"等特殊字符");
				return;
				
			}
			
			
			var params:Object = {};
			params.name = uiSkin.input_companyname.text;
			params.shortName = uiSkin.input_companyname.text.substr(0,6);
			
			params.regionId = companyareaId;
			params.addr = uiSkin.detail_addr.text;
			params.idCode =  Userdata.instance.userAccount;// "91310116MAC1L4DK1F";
			
			var fullcityname:String = uiSkin.province.text + " " + uiSkin.citytxt.text + " " + uiSkin.areatxt.text + " " + (uiSkin.btnSelTown.visible?uiSkin.towntxt.text:"");

			params.cnee = uiSkin.contactName.text;
			params.mobileNumber =  uiSkin.contactPhone.text;
			params.region = companyareaId + "|" + areaid;
			params.regionName = fullcityname;
			
			
			//Browser.window.createGroup({urlpath:HttpRequestUtil.httpUrl + HttpRequestUtil.createGroup, cname:uiSkin.input_companyname.text,cshortname:uiSkin.shortname.text,czoneid:companyareaId,caddr:uiSkin.detail_addr.text,reditcode:uiSkin.reditcode.text,file:curYyzzFile});
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.createGroup,this,onSaveCompnayBack,JSON.stringify(params),"post");
			
			//Browser.window.createGroup({urlpath:HttpRequestUtil.httpUrl + HttpRequestUtil.createGroup, cname:uiSkin.input_companyname.text,cshortname:uiSkin.shortname.text,czoneid:companyareaId,caddr:uiSkin.detail_addr.text,reditcode:uiSkin.reditcode.text,file:null});

		}
		
		private function onSaveCompnayBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				Userdata.instance.firstOrder = "1";
				Userdata.instance.isLogin = false;
				
				if(Userdata.instance.orgAudit)
				{
					ViewManager.showAlert("公司信息提交成功，请等待审核");
					uiSkin.applyBtn.label = "审核中...";
					uiSkin.applyBtn.disabled = true;
					uiSkin.applyEnter.visible = false;

				}
				else
					onCloseScene();

			}
			else
			{
				ViewManager.showAlert("公司注册失败，请检查信息是否填写正确");
				//onCloseScene();

			}
		}
		
		private function onJoinCompany():void
		{
			if(uiSkin.createAccountInput.text.length < 11)
			{
				ViewManager.showAlert("请输入正确的企业创建者账号");
				return;
			}
			
			if(uiSkin.commentInput.text == "")
			{
				ViewManager.showAlert("填写备注信息更容易通过申请");
				return;
			}
			var param:Object = {"mobileNumber" :uiSkin.createAccountInput.text , "msg":uiSkin.commentInput.text};
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.joinOrganize,this,onJoinOrganizeBack,JSON.stringify(param),"post");
			uiSkin.applyJoinPanel.visible = false;
		}
		
		private function onJoinOrganizeBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				onCloseScene();
				ViewManager.showAlert("申请成功，请等待管理者审核");

			}
		}
		
		
	}
}