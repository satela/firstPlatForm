/**This class is automatically generated by LayaAirIDE, please do not make any modifications. */
package ui.order {
	import laya.ui.*;
	import laya.display.*;

	public class HoleSpriteUI extends View {
		public var sp:Sprite;
		public var redhole:Sprite;
		public var greenhole:Sprite;

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"View","props":{"width":0,"height":0},"compId":2,"child":[{"type":"Sprite","props":{"y":0,"x":0,"width":20,"var":"sp","pivotY":0.5,"pivotX":0.5,"height":20},"compId":3,"child":[{"type":"Sprite","props":{"y":10,"x":10,"var":"redhole"},"compId":5,"child":[{"type":"Circle","props":{"y":0,"x":0,"radius":10,"name":"hole","lineWidth":2,"lineColor":"#f4ecec","fillColor":"#ff0000"},"compId":4}]},{"type":"Sprite","props":{"y":10,"x":10,"visible":false,"var":"greenhole"},"compId":6,"child":[{"type":"Circle","props":{"y":0,"x":0,"radius":10,"name":"hole","lineWidth":2,"lineColor":"#f4ecec","fillColor":"#0aea1c"},"compId":7}]}]}],"loadList":[],"loadList3D":[]};
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);

		}

	}
}