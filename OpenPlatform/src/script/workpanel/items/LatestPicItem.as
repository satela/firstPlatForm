package script.workpanel.items
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	import laya.ui.Image;
	
	import model.HttpRequestUtil;
	import model.picmanagerModel.PicInfoVo;
	
	import ui.inuoView.PicManagerPanelUI;
	import ui.inuoView.items.SmallPictureItemUI;
	
	public class LatestPicItem extends SmallPictureItemUI
	{
		public function LatestPicItem()
		{
			super();
			this.selFrame.visible = false;
			this.on(Event.DOUBLE_CLICK,this,function(){
				
				EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[PicManagerPanelUI,1]);

				
			});
		}
		
		public function setData(data:PicInfoVo):void
		{
			this.pic.skin =  HttpRequestUtil.smallerrPicUrl + data.fid + ".jpg";
			
			if(data.picWidth > data.picHeight)
			{
				this.pic.width = 120;					
				this.pic.height = 120/data.picWidth * data.picHeight;
								
				
			}
			else
			{
				this.pic.height = 120;
				this.pic.width = 120/data.picHeight * data.picWidth;
			}
		}
	}
}