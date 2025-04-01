package script.workpanel.items
{
	import model.HttpRequestUtil;
	import model.picmanagerModel.PicInfoVo;
	
	import ui.inuoView.items.PicSimpleItemUI;
	
	public class SimpleFilePicCell extends PicSimpleItemUI
	{
		private var picInfo:PicInfoVo;
		public function SimpleFilePicCell()
		{
			super();
			this.selframe.visible = false;

		}
		
		public function setData(data:*):void
		{
			picInfo = data;
			this.fileName.text = data.directName;
			
			this.pic.skin =  HttpRequestUtil.smallerrPicUrl + data.fid + ".jpg";

			if(picInfo.picWidth > picInfo.picHeight)
			{
				this.pic.width = 240;					
				this.pic.height = 240/picInfo.picWidth * picInfo.picHeight;
				
							
			}
			else
			{
				this.pic.height = 240;
				this.pic.width = 240/picInfo.picHeight * picInfo.picWidth;
								
				
			}
		}
		
		public function setChoose(choose:Boolean):void
		{
			this.selframe.visible = choose;
		}
	}
}