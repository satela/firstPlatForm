package script.order.item
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.HttpRequestUtil;
	
	import ui.order.AIImageItemUI;
	
	public class AICutImageCell extends AIImageItemUI
	{
		private var picdata:Object;
		
		public function AICutImageCell()
		{
			super();
			this.partWhiteBtn.on(Event.CLICK,this,onRelatePartWhite);
			this.yixingBtn.on(Event.CLICK,this,onRelateYixing);

		}
		
		public function setData(data:*):void
		{
			picdata = data;
			
			
			var prop:Object= JSON.parse(data.properties);
			
			if(parseInt(prop.width) > parseInt(prop.height))
			{
				this.aiImg.width = 200;					
				this.aiImg.height = 200/parseInt(prop.width) *parseInt(prop.height);
			
				
			}
			else
			{
				this.aiImg.height = 200;
				this.aiImg.width = 200/parseInt(prop.height) * parseInt(prop.width);
			}
			this.imgName.text = picdata.route;
			
			this.partWhiteBtn.selected = picdata.picInfo.partWhiteFid == picdata.name;
			this.yixingBtn.selected = picdata.picInfo.yixingFid == picdata.name;

		}
		
		private function onRelatePartWhite():void
		{
			if(picdata.picInfo.partWhiteFid == picdata.name)
			{
				var params:Object = {"fileId":picdata.fid,"targetId": "0"};	
				
			}
			
			else
				 params = {"fileId":picdata.fid,"targetId": picdata.name};	
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.setPartWhiteRelated,this,onSetPartWhiteBack,JSON.stringify(params),"post");
		}
		
		private function onSetPartWhiteBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				trace("设置成功");
				//ViewManager.showAlert("设置成功");
				EventCenter.instance.event(EventCenter.UPDATE_FILE_LIST);
				if(picdata.picInfo.partWhiteFid != picdata.name)
					EventCenter.instance.event(EventCenter.UPDATE_RELATED_PIC,["partWhiteFid",picdata.name]);
				else
					EventCenter.instance.event(EventCenter.UPDATE_RELATED_PIC,["partWhiteFid","0"]);
				
			}
		}
		
		private function onRelateYixing():void
		{
			if(picdata.picInfo.yixingFid == picdata.name)
			{
				var params:Object = {"fileId":picdata.fid,"targetId": "0"};	

			}
			else
				 params = {"fileId":picdata.fid,"targetId": picdata.name};	
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.setYixingRelated,this,onSetRelatedBack,JSON.stringify(params),"post");
		}
		private function onSetRelatedBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				trace("设置成功");
				//ViewManager.showAlert("设置成功");
				EventCenter.instance.event(EventCenter.UPDATE_FILE_LIST);
				if(picdata.picInfo.yixingFid != picdata.name)
					EventCenter.instance.event(EventCenter.UPDATE_RELATED_PIC,["yixingFid",picdata.name]);
				else
					EventCenter.instance.event(EventCenter.UPDATE_RELATED_PIC,["yixingFid","0"]);


			}
		}
	}
}