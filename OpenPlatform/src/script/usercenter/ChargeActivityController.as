package script.usercenter
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	
	import script.ViewManager;
	
	import ui.usercenter.ChargeActivityPanelUI;
	
	public class ChargeActivityController extends Script
	{
		private var uiSkin:ChargeActivityPanelUI;
		
		private var curactinfo;
		public function ChargeActivityController()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as ChargeActivityPanelUI;
			
			
			
			uiSkin.accout.text = Userdata.instance.userAccount;
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,getCompanyInfoBack,null,"post");
			
			uiSkin.moneytxt.text = "--";
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getChargeActivity,this,getActivityInfoBack,null,"post");

			
			
			uiSkin.actpanel.visible = true;
			uiSkin.noactbox.visible = false;
			uiSkin.actbox.visible = false;
			uiSkin.totalreturn.editable = false;
			uiSkin.chargeamount.editable = false;
			//uiSkin.chargeamount.on(Event.CHANGE,this,onchangeAmout);
			for(var i:int=0;i < 8;i++)
			{
				uiSkin["moneybtn" + i].on(Event.CLICK,this,onChangeMoney,[i]);
			}
			//uiSkin.chargeamount.restrict = "0-9";
			uiSkin.chargeamount.maxChars = 8;
			//uiSkin.chargeamount.restrict = "0-9";
			
			uiSkin.joinact.on(Event.CLICK,this,onjoinActivity);
			uiSkin.recordbtn.on(Event.CLICK,this,showRecordView);
			
			uiSkin.groupCharge.visible = false;
			uiSkin.grpchargeBtn.on(Event.CLICK,this,onGrpChargeConfirm);
			uiSkin.closeGroup.on(Event.CLICK,null,function(){
				uiSkin.groupCharge.visible = false;
			});
			uiSkin.copyname.on(Event.CLICK,this,copytext,[uiSkin.companyname.text]);
			uiSkin.copybank.on(Event.CLICK,this,copytext,[uiSkin.bank.text]);
			uiSkin.copyaccount.on(Event.CLICK,this,copytext,[uiSkin.account.text]);
			uiSkin.finishcharge.on(Event.CLICK,this,onSendFinishCharge);
			
			EventCenter.instance.on(EventCenter.CANCEL_CHARGE_RECORD,this,updateAccountData);

		}
		
		private function updateAccountData():void
		{
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,getCompanyInfoBack,null,"post");

		}
		
		private function showRecordView():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_CHARGE_RECORD_PANEL,false);
		}
		
		private function onChangeMoney(index:int):void
		{
			var numarr:Array = [1000,2000,3000,5000,10000,20000,30000,50000];
			uiSkin.chargeamount.text = numarr[index].toString();
			uiSkin.totalreturn.text = (numarr[index] * 1.15 as Number).toFixed(0);
			
		}
		private function getActivityInfoBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				if(result.data != null && result.data.length > 0)
				{
					curactinfo = result.data[0];
					
					uiSkin.actbox.visible = true;
					uiSkin.noactbox.visible = false;
					
					uiSkin.zhiufbaobtn.selected = true ;
					var actinfo:Object = result.data[0];
					uiSkin.acttitle.text = actinfo.ra_name;
					uiSkin.actrule.text = "活动规则：" + actinfo.ra_text;
					uiSkin.chargeamount.text = "10000"; 
					uiSkin.totalreturn.text = "11500";
				}
				else
				{
					uiSkin.noactbox.visible = true;
					uiSkin.actbox.visible = false;
					
				}
			}
		}
		
		private function onjoinActivity():void
		{
			if(uiSkin.chargeamount.text == "" || uiSkin.chargeamount.text == "0")
			{
				ViewManager.showAlert("请输入充值金额");
				return;
			}
			var num:Number = parseFloat(uiSkin.chargeamount.text);// * 1000;
			
			if(num%1000 != 0)
			{
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg: "充值金额必须是1000的倍数。"});
				return;
			}
			
			var params:String = "rid=" + curactinfo.ra_id + "&amount=" + num;
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.joinChargeActivity,this,joinActBack,params,"post");
			
		}
		private function joinActBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				//Browser.window.open(HttpRequestUtil.httpUrl + HttpRequestUtil.payChargeActivity + "rarid=" +result.data.rar_id,null,null,true);
				
				Browser.window.open("about:self","_self").location.href = HttpRequestUtil.httpUrl + HttpRequestUtil.payChargeActivity + "rarid=" +result.data.rar_id;

				//ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"是否支付成功？",caller:this,callback:confirmSucess,ok:"是",cancel:"否"});
				
			}
			
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
		
		private function onSendFinishCharge():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"请确认您已完成对公转账，并且转账金额与您选择的活动金额相等。",caller:this,callback:onConfirmSend});
		}
		private function onConfirmSend(b:Boolean):void
		{
			if(b)
			{
				var num:Number = parseFloat(uiSkin.chargeamount.text);// * 1000;
				
				if(num%1000 != 0)
				{
					ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg: "充值金额必须是1000的倍数。"});
					return;
				}
				var params:String = "rid=" + curactinfo.ra_id + "&amount=" + num;

				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.joinChargeActivity,this,joinGroupChargeActBack,params,"post");

				
			}
		}
		
		private function joinGroupChargeActBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				var num:Number = parseFloat(uiSkin.chargeamount.text);// * 1000;

				var params="amount="+num + "&id=" + result.data.rar_id;
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.groupChargeActivity,this,joinGrpChhargeBack,params,"post");

			}
		}
		
		
		private function joinGrpChhargeBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				ViewManager.showAlert("申请成功，请等待工作人员审核");
				uiSkin.groupCharge.visible = false;
			}
			
		}
		private function onGrpChargeConfirm():void
		{
			this.uiSkin.groupCharge.visible = true;
		}
		private function confirmSucess(result:Boolean):void
		{
			if(result)
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,getCompanyInfoBack,null,"post");
			}
			
		}
		
		private function getCompanyInfoBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				Userdata.instance.money = Number(result.balance);
				Userdata.instance.actMoney = Number(result.activity_balance);
				Userdata.instance.frezeMoney = Number(result.activity_locked_balance);
				
				uiSkin.moneytxt.text = Userdata.instance.money.toString() + "元";
				uiSkin.actMoney.text = Userdata.instance.actMoney.toString() + "元";
				uiSkin.frezeMoney.text = Userdata.instance.frezeMoney.toString() + "元";
				if(Userdata.instance.isHidePrice())
				{
					uiSkin.moneytxt.text = "****";
					uiSkin.actMoney.text = "****";
					uiSkin.frezeMoney.text = "****";
				}
				
			}
		}
		
		public override  function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.CANCEL_CHARGE_RECORD,this,updateAccountData);

		}
	}
}