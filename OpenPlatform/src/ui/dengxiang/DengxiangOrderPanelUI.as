/**This class is automatically generated by LayaAirIDE, please do not make any modifications. */
package ui.dengxiang {
	import laya.ui.*;
	import laya.display.*;
	import script.prefabScript.OderTopFlowController;
	import script.uiTool.ButtonEffect;
	import laya.display.Text;
	import script.prefabScript.LinkTextControl;
	import script.dengxiang.DengxiangOrderController;

	public class DengxiangOrderPanelUI extends View {
		public var mainPanel:Panel;
		public var title:Label;
		public var step1:Box;
		public var step2:Box;
		public var step3:Box;
		public var step4:Box;
		public var unitpricelbl:Label;
		public var pricelbl:Label;
		public var selectAll:CheckBox;
		public var btnaddpic:Button;
		public var batchChange:Button;
		public var addpic:Button;
		public var opeBox:Box;
		public var batchDelete:Button;
		public var orderlistpanel:Panel;
		public var ordervbox:VBox;
		public var productNum:Label;
		public var textPayPrice:Label;
		public var textDiscount:Label;
		public var textTotalPrice:Label;
		public var goToNext:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadScene("dengxiang/DengxiangOrderPanel");

		}

	}
}