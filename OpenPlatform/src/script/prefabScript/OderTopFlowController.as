package script.prefabScript
{
	import laya.components.Script;
	import laya.ui.Box;
	import laya.ui.HBox;
	import laya.ui.Image;
	import laya.ui.Label;
	
	import model.Constast;
	
	public class OderTopFlowController extends Script
	{
		private var uiSkin:HBox;
		
		/** @prop {name:step,tips:"步骤",type:int}*/
		public var step:int = 1;//

		public function OderTopFlowController()
		{
			super();
		}
		
		override public function onEnable():void {
			
			uiSkin = this.owner as HBox;
			for(var i:int=1;i < 5;i++)
			{
				var box:Box = uiSkin.getChildByName("step" + i) as Box;
				if(box != null)
				{
					var lbl:Label = box.getChildByName("lbl") as Label;
					var underline:Image = box.getChildByName("underline") as Image;
					lbl.color = step == i?"#003dc6":"#485157";
					underline.visible = step==i;
				}
			}
			
		}
	}
}