package script.order
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.orderModel.MatetialClassVo;
	import model.orderModel.ProductVo;
	
	import script.ViewManager;
	import script.order.item.MoreMaterialItem;
	
	import ui.order.MoreProductPanelUI;
	
	public class MoreProductController extends Script
	{
		private var uiSkin:MoreProductPanelUI;
		public var param:MatetialClassVo;
		
		public function MoreProductController()
		{
			super();
		}
		
		override public function onStart():void
		{
			
			uiSkin = this.owner as MoreProductPanelUI; 
			
			uiSkin.mainpanel.vScrollBarSkin = "";
			uiSkin.mainpanel.hScrollBarSkin = "";
			
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			
			uiSkin.productList.itemRender = MoreMaterialItem;
			uiSkin.productList.vScrollBarSkin = "";
			uiSkin.productList.selectEnable = true;
			uiSkin.productList.spaceY = 10;
			uiSkin.productList.renderHandler = new Handler(this, updateMatNameItem);
			//uiSkin.productList.selectHandler = new Handler(this,onSlecteMat);

			uiSkin.closeBtn.on(Event.CLICK,this,onSlecteMat);
			uiSkin.productList.array = param.childMatList;
			uiSkin.categoryName.text = param.matclassname;
			EventCenter.instance.on(EventCenter.SET_DEFAULT_PRODUCT,this,setDefaultProduct);

			
		}
		
		private function setDefaultProduct(mat:ProductVo):void
		{
			var params:String = "name=" + param.matclassname + "&categoryid=" + param.nodeId + "&productid=" + mat.prodCode;
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.updateProductCategoryDefault ,this,function(data:*){
				
				var result:Object = JSON.parse(data as String);
				if(result.status == 0)
				{
					param.defaultProductId = mat.prodCode;
				
				}
				
			},params,"post");
			
			
		}
		private function updateMatNameItem(cell:MaterialItem):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function onSlecteMat(index:int):void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_MORE_PRODUCT_PANEL);
		}
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.SET_DEFAULT_PRODUCT,this,setDefaultProduct);

		}
	}
}