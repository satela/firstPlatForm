package script.usercenter
{
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	
	import model.Constast;
	import model.HttpRequestUtil;
	import model.Userdata;
	
	import script.ViewManager;
	
	import ui.usercenter.ChargePanelUI;
	
	public class ChargeControl extends Script
	{
		private var uiSkin:ChargePanelUI;

		private var curactinfo;
		public function ChargeControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as ChargePanelUI;
			
			
			
			uiSkin.accout.text = Userdata.instance.userAccount;
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,getCompanyInfoBack,null,null);

			uiSkin.moneytxt.text = "--";
			//uiSkin.moneytxt.text = Userdata.instance.money.toString();
			
			uiSkin.chargeinput.restrict = "0-9" + ".";
			uiSkin.chargeinput.maxChars = 8;
			uiSkin.confirmmoney.restrict = "0-9";
			uiSkin.confirmmoney.maxChars = 8;
			
			var json = Laya.loader.getRes("config.json?" + Userdata.instance.configVersion);
			
			uiSkin.companyname.text = json["chargeCompanyName"];
			uiSkin.bank.text = json["bank"];
			uiSkin.account.text = json["account"];
			uiSkin.otherInfo.text = json["otherInfo"];

			
			//uiSkin.paytypezfb.selected = true;
			uiSkin.inputmoneypanel.visible = false;
			uiSkin.copyname.on(Event.CLICK,this,copytext,[uiSkin.companyname.text]);
			uiSkin.copybank.on(Event.CLICK,this,copytext,[uiSkin.bank.text]);
			uiSkin.copyaccount.on(Event.CLICK,this,copytext,[uiSkin.account.text]);
			
			
			uiSkin.finishcharge.on(Event.CLICK,this,onShowInputMoney);
			uiSkin.closeinput.on(Event.CLICK,this,onHideInputMoney);
			
			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getChargeActivity,this,getActivityInfoBack,null,"post");

			uiSkin.confirmcharge.on(Event.CLICK,this,onChargeNow);
			uiSkin.sendcharge.on(Event.CLICK,this,onSendToPublicCharge);
			
			uiSkin.chargerecord.on(Event.CLICK,this,function(){
				ViewManager.instance.openView(ViewManager.VIEW_PUBLIC_CHARGE_RECORD_PANEL);
			});
			
		}
		
		private function copytext(copytxt:String):void
		{
			
			var dateInput = Browser.document.createElement("input");				
			
			dateInput.type ="text";
			dateInput.value = copytxt;
			Browser.document.body.appendChild(dateInput);//添加到舞台
			dateInput.select();
			
			window.document.execCommand('copy');
			Browser.document.body.removeChild(dateInput);//添加到舞台				
			
			
		}
		
		private function onShowInputMoney():void
		{
			uiSkin.inputmoneypanel.visible = true;
			uiSkin.confirmmoney.text = "0";
		}
		
		private function onHideInputMoney():void
		{
			uiSkin.inputmoneypanel.visible = false;
			
		}
		
		private function onSendToPublicCharge():void
		{
			if(uiSkin.confirmmoney.text == "")
			{
				ViewManager.showAlert("请输入转账金额");
				return;
				
			}
			
			if( parseFloat(uiSkin.confirmmoney.text) <= 0)
			{
				ViewManager.showAlert("转账金额不能为0");
				return;
				
			}
			uiSkin.inputmoneypanel.visible = false;
			
			var param:Object = {"amount" : uiSkin.confirmmoney.text};
			
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.publicChargeRequest,this,onsendChargeBack,JSON.stringify(param),"post");
		}
		
		private function onsendChargeBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				ViewManager.showAlert("请求成功，请等待工作人员确认，确认成功后将短信提示您");
			}
			else
			{
				ViewManager.showAlert("请求失败，请点击【转账记录】检查您是否有未处理的对公充值记录！");
			}
		}
		private function onChargeNow():void
		{
			if(uiSkin.chargeinput.text == "")
			{
				ViewManager.showAlert("请输入充值金额");
				return;
			}
			
			if(uiSkin.chargeinput.text == "0")
			{
				ViewManager.showAlert("充值金额不能为0");
				return;
				
			}
			
			if(Userdata.instance.accountType == Constast.ACCOUNT_EMPLOYEE && Userdata.instance.privilege[Constast.PRIVILEGE_PAYORDER_BY_SCAN] == "0")
			{
				ViewManager.showAlert("您没有充值的权限,请联系管理者开放权限");
				return;
			}
			
			var num:Number = Number(uiSkin.chargeinput.text);
			
			//Browser.window.open(HttpRequestUtil.httpUrl + HttpRequestUtil.recharge,null,null,true);
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.recharge,this,getRechargeRequestBack,JSON.stringify({"amount":num.toString()}),"post");

			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"是否支付成功？",caller:this,callback:confirmSucess,ok:"是",cancel:"否"});
			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.chargeRequest ,this,onChargeBack,"amount=" + num,"post");

		}
		
		private function getRechargeRequestBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				Browser.window.open(result.data,null,null,true);
			}
		}
		private function confirmSucess(result:Boolean):void
		{
			if(result)
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,getCompanyInfoBack,null,null);
			}

		}
		
		
		private function getCompanyInfoBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				Userdata.instance.isVipCompany = result.vip == "1";
				Userdata.instance.factoryMoney = 0;
				
				Userdata.instance.money = Number(result.data.balance);
				
				
				Userdata.instance.factoryMoney = Number(result.data.factoryBalance);;

				uiSkin.moneytxt.text = Userdata.instance.money.toString() + "元";
				
				uiSkin.factoryMoney.text = Userdata.instance.factoryMoney.toString() + "元";

				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getFactoryFreezeBalance + Userdata.instance.userAccount,this,getFactoryFreezeBalanceBack,null,null);

				if(Userdata.instance.isHidePrice())
				{
					uiSkin.moneytxt.text = "****";
				
				}

			}
		}
		private function getFactoryFreezeBalanceBack(data:*):void
		{
			if(this.destroyed)
				return;
			var result:Object = JSON.parse(data);
			if(result != null)
			{
				uiSkin.factoryFreezMoney.text = result.tobe_topup_amount + "元";
			}
		}
	}
}