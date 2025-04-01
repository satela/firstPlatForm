package script.workpanel.items
{
	import model.HttpRequestUtil;
	import model.picmanagerModel.PicInfoVo;
	import model.picmanagerModel.RelatedChooseModel;
	
	import ui.inuoView.items.SmallPictureItemUI;
	
	public class OriginFileCell extends SmallPictureItemUI
	{
		public function OriginFileCell()
		{
			super();
			this.width = 80;
			this.height = 80;
			//this.selFrame.width = 80;
			//this.selFrame.height = 80;
			this.selFrame.visible = false;

		}
		
		public function setData(data:PicInfoVo):void
		{
			this.selFrame.visible = RelatedChooseModel.instance.curOriginFile == data;
			this.pic.skin =  HttpRequestUtil.smallerrPicUrl + data.fid + ".jpg";
			this.pic.x = 40;
			this.pic.y = 40;

			if(data.picWidth > data.picHeight)
			{
				this.pic.width = 80;					
				this.pic.height = 80/data.picWidth * data.picHeight;
				
				
			}
			else
			{
				this.pic.height = 80;
				this.pic.width = 80/data.picHeight * data.picWidth;
			}
		}
		
		public function setChoose(choose:Boolean):void
		{
			this.selFrame.visible = choose;

		}
		
	}
}