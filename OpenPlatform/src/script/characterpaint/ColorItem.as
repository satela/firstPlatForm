package script.characterpaint
{
	import ui.characterpaint.ColorLblItemUI;
	
	public class ColorItem extends ColorLblItemUI
	{
		public function ColorItem()
		{
			super();
		}
		
		public function setData(color:String):void
		{
			this.lblcolor.bgColor = "#" +color;
		}
	}
}