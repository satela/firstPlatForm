package script.characterpaint
{
	import laya.ui.Image;
	
	import ui.characterpaint.BackImgItemUI;
	
	public class BackGroundItem extends BackImgItemUI
	{
		public var urlpath:String;
		public function BackGroundItem()
		{
			super();
		}
		
		public function setData(url:String):void
		{
			this.img.skin = "textureU3d/" +  url + ".jpg";
			urlpath = url;
			setSelected(false);
		}
		
		public function setSelected(isSel:Boolean):void
		{
			this.frame.visible = isSel;
		}
	}
}