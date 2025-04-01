package script.workpanel.items
{
	import model.orderModel.MatetialClassVo;
	
	import ui.inuoView.items.MatCategoryItemUI;
	
	public class MaterialCategoryCell extends MatCategoryItemUI
	{
		public var matclassvo:MatetialClassVo;

		public function MaterialCategoryCell()
		{
			super();
		}
		
		public function setData(matName:Object):void
		{
			matclassvo = matName as MatetialClassVo;
			this.selbtn.label = matclassvo.matclassname;
			
			this.selbtn.width = this.selbtn.text.textWidth + 40;
			this.width = this.selbtn.width;
			
			this.selfIcon.visible = false;
		}
		
		public function set ShowSelected(value:Boolean):void
		{
			this.selbtn.selected = value;
			
		}
		
	}
}