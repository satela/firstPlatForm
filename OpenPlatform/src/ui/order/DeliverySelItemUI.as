/**This class is automatically generated by LayaAirIDE, please do not make any modifications. */
package ui.order {
	import laya.ui.*;
	import laya.display.*;

	public class DeliverySelItemUI extends View {
		public var backsp:Sprite;
		public var commondelType:RadioGroup;
		public var urgentdeltype:RadioGroup;

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"View","props":{"width":1280,"height":48},"compId":2,"child":[{"type":"Box","props":{"y":0,"x":0},"compId":3,"child":[{"type":"Sprite","props":{"width":1280,"visible":false,"var":"backsp","height":48},"compId":4,"child":[{"type":"Rect","props":{"width":1280,"name":"rect","lineWidth":1,"height":48,"fillColor":"#FF8247"},"compId":5}]},{"type":"Box","props":{"y":10,"x":4},"compId":7,"child":[{"type":"Label","props":{"y":5,"x":0,"text":"普通配送:","fontSize":20,"font":"SimHei"},"compId":8},{"type":"RadioGroup","props":{"y":1,"x":93,"var":"commondelType","skin":"uiCommonUpdate/bigRdio.png","scaleY":1,"scaleX":1,"labels":"送货上门,工厂自提,转成配送(60元),普通快递(30元)","labelSize":18,"labelPadding":"5","labelFont":"SimHei","labelColors":"#000000,#000000,#036dc6","labelAlign":"center"},"compId":9}]},{"type":"Box","props":{"y":11,"x":762,"visible":false},"compId":10,"child":[{"type":"Label","props":{"y":3,"x":-9,"text":"加急配送:","fontSize":20,"font":"SimHei"},"compId":11},{"type":"RadioGroup","props":{"y":0,"x":80,"var":"urgentdeltype","skin":"uiCommonUpdate/bigRdio.png","scaleY":1,"scaleX":1,"labels":"送货上门,工厂自提,转成配送(60元)","labelSize":18,"labelPadding":"5","labelFont":"SimHei","labelAlign":"center"},"compId":12}]}]}],"loadList":["uiCommonUpdate/bigRdio.png"],"loadList3D":[]};
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);

		}

	}
}