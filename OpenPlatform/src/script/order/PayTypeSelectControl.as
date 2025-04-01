package script.order
{
	import eventUtil.EventCenter;
		
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.Ease;
	import laya.utils.Tween;
	
	import model.Constast;
	import model.HttpRequestUtil;
	import model.Userdata;
	
	import script.ViewManager;
	
	import ui.inuoView.MyWorkPanelUI;
	import ui.order.ConfirmOrderPanelUI;
	
	import utils.UtilTool;
	
	public class PayTypeSelectControl extends Script
	{
		private var uiSkin:ConfirmOrderPanelUI;
		
		public var param:Object;
		
		public var paylefttime:int = 0;
		
		
		public function PayTypeSelectControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as ConfirmOrderPanelUI;
			
			uiSkin.mainview.scaleX = 0.2;
			uiSkin.mainview.scaleY = 0.2;
			
			Tween.to(uiSkin.mainview,{scaleX:1,scaleY:1},300,Ease.backOut);
			
			uiSkin.payall.selected = true;
			
			//if(Userdata.instance.accountType == 1)
			uiSkin.paytype.selectedIndex = 0 ;
			
			if(Userdata.instance.accountType == Constast.ACCOUNT_EMPLOYEE && Userdata.instance.privilege.indexOf(Constast.PAY_ORDER_ONLINE) < 0 && Userdata.instance.privilege.indexOf(Constast.PAY_ORDER_BY_MONEY) >= 0)
			{
				
				uiSkin.paytype.selectedIndex = 1;
				
				
			}
//			else
//			{
//				uiSkin.paytype.selectedIndex = 1 ;
//				uiSkin.paytype.mouseEnabled = false;
//			}
//			
			uiSkin.accountmoney.text = "0元";
			
			
			uiSkin.needpay.text = param.amount + "元";
			
			uiSkin.realpay.text =  param.amount + "元";
			
			if(param.lefttime != null)
			{
				paylefttime = param.lefttime;
				uiSkin.paytime.text = UtilTool.getCountDownString(paylefttime);
				//uiSkin.paytime.visible = false;
				Laya.timer.loop(1000,this,countdownpay);
			}
			else
			{
				uiSkin.countdownbox.visible = false;
			}
			//uiSkin.needpay.visible = !Userdata.instance.isHidePrice();
			//uiSkin.realpay.visible = !Userdata.instance.isHidePrice();
			if(Userdata.instance.isHidePrice())
			{
				uiSkin.needpay.text = "****";
				uiSkin.realpay.text = "****";
			}

			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,getCompanyInfoBack,null,null);

			uiSkin.paybtn.on(Event.CLICK,this,onPayOrder);
			uiSkin.cancelbtn.on(Event.CLICK,this,onCancel);
			
			uiSkin.mainpanel.vScrollBarSkin = "";
			uiSkin.mainpanel.hScrollBarSkin = "";

			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;
			//uiSkin.mainpanel.width = Browser.width;

			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);


		}
		
		
		private function countdownpay():void
		{
			if(paylefttime > 0)
			{
				paylefttime--;
				uiSkin.paytime.text = UtilTool.getCountDownString(paylefttime);
			}
			else
			{
				ViewManager.instance.closeView(ViewManager.VIEW_SELECT_PAYTYPE_PANEL);
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"支付超时，您可以去我的订单页面继续支付",caller:this,callback:closeOrderView});
			}
		}
		
		private function closeOrderView():void
		{
			
			//ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE,true);
			EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[MyWorkPanelUI,0]);

		}
		
		private function onResizeBrower():void
		{
			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;


		}
		private function getCompanyInfoBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				
				Userdata.instance.money = Number(result.data.balance);
				
				Userdata.instance.actMoney = 0;//Number(result.activity_balance);
				Userdata.instance.frezeMoney = 0;//Number(result.activity_locked_balance);
				Userdata.instance.factoryMoney = Number(result.data.factoryBalance);

				uiSkin.accountmoney.text = Userdata.instance.money.toString() + "元";
				
				uiSkin.actmoney.text = Userdata.instance.actMoney.toString() + "元";
				
				uiSkin.factoryMoney.text = Userdata.instance.factoryMoney.toString() + "元";
				
				
				if(Userdata.instance.actMoney >= param.amount)
					uiSkin.paytype.selectedIndex = 2;
				else if(Userdata.instance.money >= param.amount)
					uiSkin.paytype.selectedIndex = 1;
				else if(Userdata.instance.factoryMoney >= param.amount)
					uiSkin.paytype.selectedIndex = 2;
				
				if(Userdata.instance.isHidePrice())
				{
					uiSkin.accountmoney.text = "****";
					uiSkin.actmoney.text = "****";

				}
			}
		}	
		private function onPayOrder():void
		{
			if(param.orderid != null)
				var ordrid:String = (param.orderid as Array).join(",");

			if(uiSkin.paytype.selectedIndex == 0)
			{
				if(Userdata.instance.accountType == Constast.ACCOUNT_EMPLOYEE && Userdata.instance.privilege.indexOf(Constast.PAY_ORDER_ONLINE) < 0 || Userdata.instance.isHidePrice())
				{
					ViewManager.showAlert("您没有在线支付的权限,请联系管理者开放权限");
					return;
				}
				if(param.orderid != null)
				{
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.chargeRequest,this,getOnlinePayUrlBack,JSON.stringify(param.orderid) ,"post");

					//Browser.window.open(HttpRequestUtil.httpUrl + HttpRequestUtil.chargeRequest + "amount=0&orderid=" + param.orderid,null,null,true);

				}
					//Browser.window.open("about:self","_self").location.href = HttpRequestUtil.httpUrl + HttpRequestUtil.chargeRequest + "amount=0&orderid=" + param.orderid;
				else if(param.size != null)
				{
					//HttpRequestUtil.httpUrl + HttpRequestUtil.extendStorage + "size=" + param.size,null,null,true);
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.extendStorage,this,getOnlinePayUrlBack,JSON.stringify({"size":param.size.toString()}) ,"post");

				}
				
				//ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"是否支付成功？",caller:this,callback:confirmSucess,ok:"是",cancel:"否"});

					//Browser.window.open("about:self","_self").location.href  = HttpRequestUtil.httpUrl + HttpRequestUtil.extendStorage + "size=" + param.size;

				//ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"是否支付成功？",caller:this,callback:confirmSucess,ok:"是",cancel:"否"});
				//Browser.window.open(HttpRequestUtil.httpUrl + HttpRequestUtil.chargeRequest + "amount=0&orderid=" + param.orderid,"_blank"); 
			}
			else
			{
				if(Userdata.instance.accountType == Constast.ACCOUNT_EMPLOYEE && Userdata.instance.privilege.indexOf(Constast.PAY_ORDER_BY_MONEY) <0 )
				{
					ViewManager.showAlert("您没有余额支付的权限,请联系管理者开放权限");
					return;
				}
				
				if(uiSkin.paytype.selectedIndex == 1 && Userdata.instance.money < param.amount)
				{
					ViewManager.showAlert("账户余额不足");
					return;
				}
				
				if(uiSkin.paytype.selectedIndex == 2 && Userdata.instance.factoryMoney < param.amount)
				{
					ViewManager.showAlert("代充余额不足");
					return;
				}
				
				if(uiSkin.paytype.selectedIndex == 3 && Userdata.instance.factoryMoney < param.amount)
				{
					ViewManager.showAlert("代充余额不足");
					return;
				}
				
				var paykind:int = uiSkin.paytype.selectedIndex - 1;
				if(param.orderid != null)
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.payOrderByMoney,this,payMoneyBack,JSON.stringify({"orderSn":param.orderid ,"kind":paykind.toString()}) ,"post");
				else if(param.size != null)
				{
					
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.payextendStorage,this,payMoneyBack,JSON.stringify({"size":param.size,"&kind": paykind}) ,"post");
					
				}


			}
		}
		
		private function getOnlinePayUrlBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				//Browser.window.open(result.data,null,null,true);
				//showPayOnLine(result.data);
				Browser.window.open("about:self","_self").location.href = result.data;
				
			}
		}
		

		private function payMoneyBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				EventCenter.instance.event(EventCenter.PAY_ORDER_SUCESS);
				ViewManager.instance.closeView(ViewManager.VIEW_SELECT_PAYTYPE_PANEL);
				EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[MyWorkPanelUI,0]);
				Userdata.instance.firstOrder = "0";
				ViewManager.showAlert("支付成功");

			}
		}
		
		private function confirmSucess(result:Boolean):void
		{
			if(result)
			{
				EventCenter.instance.event(EventCenter.PAY_ORDER_SUCESS);
				ViewManager.instance.closeView(ViewManager.VIEW_SELECT_PAYTYPE_PANEL);
				//ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE);
				EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[MyWorkPanelUI,0]);


			}
		}
		private function onCancel():void
		{
			if(param.orderid != null)
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"确定取消支付吗？取消支付您可以到订单界面查询支付状态或继续支付。",caller:this,callback:confirmCancel});	
			else
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"确定取消支付吗？",caller:this,callback:confirmCancel});	

		}
		
		private function confirmCancel(b:Boolean):void
		{
			if(b)
			{
				ViewManager.instance.closeView(ViewManager.VIEW_SELECT_PAYTYPE_PANEL);
				EventCenter.instance.event(EventCenter.CANCEL_PAY_ORDER);
				EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[MyWorkPanelUI,0]);

			}

		}
		
		public override function  onDestroy():void
		{
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			Laya.timer.clearAll(this);
		}
	}
}