/**This class is automatically generated by LayaAirIDE, please do not make any modifications. */
package ui.orderList {
	import laya.ui.*;
	import laya.display.*;
	import script.usercenter.WriteOffController;

	public class WriteOffOrderPanelUI extends View {
		public var ordertime:Label;
		public var transactionBtn:Button;
		public var selectall:CheckBox;
		public var orderList:List;
		public var btnsearch:Button;
		public var selectMoney:Label;
		public var totalWriteMoney:Label;
		public var pagenum:Label;
		public var lastpage:Button;
		public var nextpage:Button;
		public var confirmBtn:Button;
		public var closeBtn:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadScene("orderList/WriteOffOrderPanel");

		}

	}
}