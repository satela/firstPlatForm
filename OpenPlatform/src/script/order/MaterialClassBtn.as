package script.order
{
	import model.orderModel.MatetialClassVo;
	
	import ui.order.TabChooseBtnUI;
	
	public class MaterialClassBtn extends TabChooseBtnUI
	{
		public var matclassvo:MatetialClassVo;
		public function MaterialClassBtn()
		{
			super();
		}
		
		public function setData(matName:Object):void
		{
			matclassvo = matName as MatetialClassVo;
			this.selbtn.label = matclassvo.matclassname;
			this.selfIcon.visible = false;
		}
		
		public function set ShowSelected(value:Boolean):void
		{
			this.selbtn.selected = value;
			
		}
	}
}