/**This class is automatically generated by LayaAirIDE, please do not make any modifications. */
package ui.order {
	import laya.ui.*;
	import laya.display.*;

	public class AIImageItemUI extends View {
		public var aiImg:Image;
		public var partWhiteBtn:Button;
		public var yixingBtn:Button;
		public var imgName:Label;

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"View","props":{"width":204},"compId":2,"child":[{"type":"Image","props":{"top":0,"skin":"uiCommonUpdate/grayFrame.png","sizeGrid":"3,3,3,3","right":0,"left":0,"height":260},"compId":6},{"type":"Image","props":{"y":102,"x":102,"width":200,"var":"aiImg","skin":"comp/image.png","height":200,"anchorY":0.5,"anchorX":0.5},"compId":3},{"type":"Button","props":{"y":228,"x":10,"width":80,"var":"partWhiteBtn","skin":"uiCommonUpdate/green2.png","labelSize":16,"labelFont":"SimHei","labelColors":"#003dC6,#FFFFFF,#FFFFFF","label":"白墨通道","height":30},"compId":4},{"type":"Button","props":{"y":228,"width":80,"var":"yixingBtn","skin":"uiCommonUpdate/green2.png","right":10,"labelSize":16,"labelFont":"SimHei","labelColors":"#003dC6,#FFFFFF,#FFFFFF","label":"异形切割","height":30},"compId":5},{"type":"Label","props":{"var":"imgName","top":207,"text":"遮罩图15mm","right":0,"left":0,"fontSize":14,"font":"SimHei","align":"center"},"compId":7}],"loadList":["uiCommonUpdate/grayFrame.png","comp/image.png","uiCommonUpdate/green2.png"],"loadList3D":[]};
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);

		}

	}
}