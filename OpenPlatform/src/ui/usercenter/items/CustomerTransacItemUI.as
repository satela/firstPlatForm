/**This class is automatically generated by LayaAirIDE, please do not make any modifications. */
package ui.usercenter.items {
	import laya.ui.*;
	import laya.display.*;
	import laya.display.Text;
	import script.prefabScript.LinkTextControl;

	public class CustomerTransacItemUI extends View {
		public var customerNamelbl:Label;
		public var transacNum:Label;
		public var transactDate:Label;
		public var transactName:Label;
		public var money:Label;
		public var transacType:Label;
		public var userNamelbl:Label;
		public var deleteBtn:Text;
		public var commentlbl:Label;

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"View","props":{"width":1600,"height":36},"compId":2,"child":[{"type":"Label","props":{"y":0,"x":2,"width":260,"var":"customerNamelbl","valign":"middle","text":"客户名称可以八个大字","height":29,"fontSize":24,"font":"SimHei","bold":true,"align":"left"},"compId":3},{"type":"Label","props":{"y":1,"x":284,"width":221,"var":"transacNum","valign":"middle","text":"18014398509481987","height":29,"fontSize":24,"font":"SimHei","bold":true,"align":"center"},"compId":4},{"type":"Label","props":{"y":1,"x":610,"width":237,"var":"transactDate","valign":"middle","text":"2019-05-22 15:30:00","height":29,"fontSize":24,"font":"SimHei","bold":true,"align":"left"},"compId":5},{"type":"Label","props":{"y":1,"x":976,"width":88,"var":"transactName","valign":"middle","text":"支付宝","height":26,"fontSize":20,"font":"SimHei","bold":true,"align":"center"},"compId":8},{"type":"Label","props":{"y":1,"x":876,"width":85,"var":"money","valign":"middle","text":"3495","height":29,"fontSize":24,"font":"SimHei","bold":true,"align":"left"},"compId":15},{"type":"Label","props":{"y":3,"x":523,"width":64,"var":"transacType","valign":"middle","text":"订单","height":29,"fontSize":24,"font":"SimHei","bold":true,"align":"center"},"compId":21},{"type":"Label","props":{"y":1,"x":1080,"width":109,"var":"userNamelbl","valign":"middle","text":"老李","height":26,"fontSize":20,"font":"SimHei","bold":true,"align":"center"},"compId":22},{"type":"Text","props":{"y":6.5,"x":1544,"var":"deleteBtn","text":"删除","presetID":1,"fontSize":18,"font":"SimHei","color":"#d92e16","bold":true,"isPresetRoot":true,"runtime":"laya.display.Text"},"compId":23,"child":[{"type":"Script","props":{"presetID":2,"runtime":"script.prefabScript.LinkTextControl"},"compId":24}]},{"type":"Image","props":{"y":0,"x":0,"skin":"commers/cutline.png","right":0,"left":0,"height":1,"bottom":0},"compId":13},{"type":"Label","props":{"y":1,"x":1207,"width":282,"var":"commentlbl","valign":"middle","text":"老李这里是备注需要二十个字以内","height":26,"fontSize":16,"font":"SimHei","bold":true,"align":"left"},"compId":25}],"loadList":["prefabs/LinksText.prefab","commers/cutline.png"],"loadList3D":[]};
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);

		}

	}
}