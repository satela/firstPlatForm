package script.order.item
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.HttpRequestUtil;
	
	import script.order.MaterialItem;
	
	public class MoreMaterialItem extends MaterialItem
	{
		public function MoreMaterialItem()
		{
			super();
		}
		
		public override function setData(product:Object):void
		{
			super.setData(product);
			
			moreBtn.visible = false;
			moreBtn.label = "设为默认";
			
			moreBtn.on(Event.CLICK,this,setDefaultMaterial);
			
			this.on(Event.MOUSE_OVER,this,function(){
				
				this.moreBtn.visible = true;
			});
			this.on(Event.MOUSE_OUT,this,function(){
				
				this.moreBtn.visible = false;
			});	
		}
		private function setDefaultMaterial(e:Event):void
		{
			e.stopPropagation();
			
			EventCenter.instance.event(EventCenter.SET_DEFAULT_PRODUCT,matvo);				
			
		}
		
	}
}