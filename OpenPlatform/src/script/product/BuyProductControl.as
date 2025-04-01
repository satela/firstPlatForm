package script.product
{
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.Button;
	
	import script.ViewManager;
	
	import ui.product.BuyProductPanelUI;
	
	public class BuyProductControl extends Script
	{
		private var uiSkin:BuyProductPanelUI;
		public var param:Object;
		
		public function BuyProductControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as BuyProductPanelUI;
			
			uiSkin.btnclose.on(Event.CLICK,this,closePanel);
			
			uiSkin.proname.text = param.pname;
			uiSkin.productimg.skin =  "product/p" + (1 + param.pid) + ".jpg";
			
			uiSkin.pricetxt.text = param.price + "元";
			
			var sizearr:Array = param.allsize;
			uiSkin.size0.label = sizearr[0];
			uiSkin.size1.label = sizearr[1];
			
			uiSkin.btnbuy.on(Event.CLICK,this,onClickBuy);
			uiSkin.size0.selected = true;
			
			uiSkin.size0.on(Event.CLICK,this,onClickSize,[uiSkin.size0]);
			uiSkin.size1.on(Event.CLICK,this,onClickSize,[uiSkin.size1]);

			
			uiSkin.numinput.restrict = "0-9";
			uiSkin.numinput.maxChars = 3;
			uiSkin.numinput.on(Event.INPUT,this,onNumChange);

			
		}
		
		private function onClickSize(btn:Button):void
		{
			uiSkin.size0.selected = btn == uiSkin.size0;
			uiSkin.size1.selected = btn == uiSkin.size1;
			
		}
		private function onNumChange():void
		{
			if(uiSkin.numinput.text == "")
				uiSkin.numinput.text = "1";
			
			var num:int = parseInt(uiSkin.numinput.text);
			if(num <= 0)
			{
				uiSkin.numinput.text = "1";
				num = 1;
			}
			
			uiSkin.pricetxt.text = (num * param.price).toString() + "元";
		}
		private function onClickBuy():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"购买成功"});
			closePanel();
		}
		
		private function closePanel():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_BUY_PRODUCT_VIEW);
		}
	}
}