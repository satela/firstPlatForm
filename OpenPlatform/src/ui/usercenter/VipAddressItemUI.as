/**This class is automatically generated by LayaAirIDE, please do not make any modifications. */
package ui.usercenter {
	import laya.ui.*;
	import laya.display.*;
	import laya.display.Text;
	import script.prefabScript.LinkTextControl;

	public class VipAddressItemUI extends View {
		public var conName:Label;
		public var phonetxt:Label;
		public var detailaddr:Label;
		public var checksel:CheckBox;
		public var operateBox:Box;
		public var btnDel:Text;
		public var btnedit:Text;

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"View","props":{"width":940,"height":60},"compId":2,"child":[{"type":"Image","props":{"top":0,"skin":"commers/inputbg.png","sizeGrid":"3,3,3,3","right":0,"left":0,"bottom":0},"compId":17},{"type":"Label","props":{"y":18,"x":33,"width":93,"var":"conName","valign":"middle","text":"徐建华","height":24,"fontSize":18,"font":"SimHei","color":"#354052","align":"center"},"compId":3},{"type":"Label","props":{"y":18,"x":151,"width":156,"var":"phonetxt","valign":"middle","text":"13564113173","height":24,"fontSize":18,"font":"SimHei","color":"#354052","align":"center"},"compId":5},{"type":"Label","props":{"y":0,"x":314,"wordWrap":true,"width":431,"var":"detailaddr","valign":"middle","text":"上海市浦东新区周浦镇瑞浦路612弄23号1001室","height":60,"fontSize":18,"font":"SimHei","color":"#354052","align":"center"},"compId":6},{"type":"CheckBox","props":{"y":22,"x":10,"var":"checksel","skin":"commers/multicheck.png","labelSize":20},"compId":19},{"type":"Box","props":{"y":22,"x":814,"var":"operateBox"},"compId":20,"child":[{"type":"Text","props":{"var":"btnDel","text":"删除","presetID":1,"fontSize":16,"font":"SimHei","color":"#354052","y":0,"x":0,"isPresetRoot":true,"runtime":"laya.display.Text"},"compId":8,"child":[{"type":"Script","props":{"presetID":2,"runtime":"script.prefabScript.LinkTextControl"},"compId":9}]},{"type":"Text","props":{"x":42,"text":"|","presetID":1,"fontSize":16,"font":"SimHei","color":"#354052","y":0,"isPresetRoot":true,"runtime":"laya.display.Text"},"compId":16},{"type":"Text","props":{"x":61,"width":47,"var":"btnedit","text":"编辑","presetID":1,"fontSize":16,"font":"SimHei","color":"#354052","y":0,"isPresetRoot":true,"runtime":"laya.display.Text"},"compId":11,"child":[{"type":"Script","props":{"presetID":2,"runtime":"script.prefabScript.LinkTextControl"},"compId":12}]}]}],"loadList":["commers/inputbg.png","commers/multicheck.png","prefabs/LinksText.prefab"],"loadList3D":[]};
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);

		}

	}
}