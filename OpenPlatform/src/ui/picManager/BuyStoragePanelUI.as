/**This class is automatically generated by LayaAirIDE, please do not make any modifications. */
package ui.picManager {
	import laya.ui.*;
	import laya.display.*;
	import script.picUpload.BuyStorageController;

	public class BuyStoragePanelUI extends View {
		public var mainpanel:Panel;
		public var mainview:Image;
		public var storagetype:RadioGroup;
		public var paymoney:Label;
		public var cancelbtn:Button;
		public var paybtn:Button;
		public var curStorageTxt:Label;
		public var outtimebox:Box;
		public var outtime:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadScene("picManager/BuyStoragePanel");

		}

	}
}