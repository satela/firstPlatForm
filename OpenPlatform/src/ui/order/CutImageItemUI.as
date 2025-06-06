/**This class is automatically generated by LayaAirIDE, please do not make any modifications. */
package ui.order {
	import laya.ui.*;
	import laya.display.*;

	public class CutImageItemUI extends View {
		public var borderimg:Image;
		public var paintimg:Image;
		public var hbox:HBox;
		public var hinput0:TextInput;
		public var hinput1:TextInput;
		public var hinput2:TextInput;
		public var hinput3:TextInput;
		public var hinput4:TextInput;
		public var hinput5:TextInput;
		public var hinput6:TextInput;
		public var horiOperateBox:Box;
		public var cutNumInput:TextInput;
		public var hori0:Button;
		public var hori1:Button;
		public var hori2:Button;
		public var hori3:Button;
		public var hori4:Button;
		public var vertOperateBox:Box;
		public var vert0:Button;
		public var vert1:Button;
		public var vert2:Button;
		public var vert3:Button;
		public var vert4:Button;
		public var vertCutNumInput:TextInput;
		public var horiRdoBox:Box;
		public var horiCutWidthRdo:RadioGroup;
		public var vertRdoBox:Box;
		public var vertCutWidthRdo:RadioGroup;
		public var vbox:Box;
		public var vinput0:TextInput;
		public var vinput1:TextInput;
		public var vinput2:TextInput;
		public var vinput3:TextInput;
		public var vinput4:TextInput;
		public var vinput5:TextInput;
		public var vinput6:TextInput;

		public static var uiView:Object =/*[STATIC SAFE]*/{"type":"View","props":{},"compId":2,"child":[{"type":"Image","props":{"y":87,"x":60,"width":377,"skin":"upload1/inoutbg.png","sizeGrid":"3,3,3,3","height":377},"compId":3,"child":[{"type":"Image","props":{"y":188,"x":188,"width":375,"var":"borderimg","skin":"commers/blackbg.png","sizeGrid":"2,2,2,2","height":100,"anchorY":0.5,"anchorX":0.5,"alpha":0.5},"compId":35},{"type":"Image","props":{"y":188,"x":188,"width":375,"var":"paintimg","skin":"comp/image.png","height":375,"anchorY":0.5,"anchorX":0.5},"compId":4}]},{"type":"HBox","props":{"y":479,"x":48,"width":400,"var":"hbox","height":30},"compId":20,"child":[{"type":"TextInput","props":{"y":0,"x":0,"width":50,"var":"hinput0","text":"100","skin":"comp/textinput.png","fontSize":16,"font":"SimSun","color":"#B1B1B1","sizeGrid":"6,15,7,14"},"compId":13},{"type":"TextInput","props":{"y":0,"x":0,"width":50,"var":"hinput1","text":"100","skin":"comp/textinput.png","fontSize":16,"font":"SimSun","color":"#B1B1B1","sizeGrid":"6,15,7,14"},"compId":15},{"type":"TextInput","props":{"y":0,"x":0,"width":50,"var":"hinput2","text":"100","skin":"comp/textinput.png","fontSize":16,"font":"SimSun","color":"#B1B1B1","sizeGrid":"6,15,7,14"},"compId":17},{"type":"TextInput","props":{"y":0,"x":0,"width":50,"var":"hinput3","text":"100","skin":"comp/textinput.png","fontSize":16,"font":"SimSun","color":"#B1B1B1","sizeGrid":"6,15,7,14"},"compId":22},{"type":"TextInput","props":{"y":0,"x":0,"width":50,"var":"hinput4","text":"100","skin":"comp/textinput.png","fontSize":16,"font":"SimSun","color":"#B1B1B1","sizeGrid":"6,15,7,14"},"compId":24},{"type":"TextInput","props":{"y":0,"x":0,"width":50,"var":"hinput5","text":"100","skin":"comp/textinput.png","fontSize":16,"font":"SimSun","color":"#B1B1B1","sizeGrid":"6,15,7,14"},"compId":25},{"type":"TextInput","props":{"y":0,"x":0,"width":50,"var":"hinput6","text":"100","skin":"comp/textinput.png","fontSize":16,"font":"SimSun","color":"#B1B1B1","sizeGrid":"6,15,7,14"},"compId":33}]},{"type":"Box","props":{"y":35,"x":48,"var":"horiOperateBox"},"compId":63,"child":[{"type":"TextInput","props":{"y":5,"x":342,"width":38,"var":"cutNumInput","type":"number","text":"25","skin":"commers/inputbg.png","sizeGrid":"8","height":22,"fontSize":18},"compId":36},{"type":"Label","props":{"y":9,"x":299,"width":41,"text":"更多：","height":16,"fontSize":16,"font":"SimHei","color":"#010101"},"compId":37},{"type":"HBox","props":{"space":16},"compId":45,"child":[{"type":"Button","props":{"width":42,"var":"hori0","skin":"uiCommonUpdate/nusel.png","labelSize":18,"labelColors":"#0,#FFFFFF,#FFFFFF","label":"2","height":34},"compId":39},{"type":"Button","props":{"x":58,"width":42,"var":"hori1","skin":"uiCommonUpdate/nusel.png","labelSize":18,"labelColors":"#0,#FFFFFF,#FFFFFF","label":"2","height":34},"compId":40},{"type":"Button","props":{"x":116,"width":42,"var":"hori2","skin":"uiCommonUpdate/nusel.png","labelSize":18,"labelColors":"#0,#FFFFFF,#FFFFFF","label":"2","height":34},"compId":42},{"type":"Button","props":{"x":174,"width":42,"var":"hori3","skin":"uiCommonUpdate/nusel.png","labelSize":18,"labelColors":"#0,#FFFFFF,#FFFFFF","label":"2","height":34},"compId":43},{"type":"Button","props":{"x":232,"width":42,"var":"hori4","skin":"uiCommonUpdate/nusel.png","labelSize":18,"labelColors":"#0,#FFFFFF,#FFFFFF","label":"2","height":34},"compId":44}]},{"type":"Label","props":{"y":9,"x":396,"text":"纵向","fontSize":18,"font":"SimHei"},"compId":46}]},{"type":"Box","props":{"y":99,"x":0,"var":"vertOperateBox"},"compId":64,"child":[{"type":"VBox","props":{"y":29,"space":16},"compId":53,"child":[{"type":"Button","props":{"width":42,"var":"vert0","skin":"uiCommonUpdate/nusel.png","labelSize":18,"labelColors":"#0,#FFFFFF,#FFFFFF","label":"2","height":34},"compId":48},{"type":"Button","props":{"y":57,"width":42,"var":"vert1","skin":"uiCommonUpdate/nusel.png","labelSize":18,"labelColors":"#0,#FFFFFF,#FFFFFF","label":"2","height":34},"compId":49},{"type":"Button","props":{"y":114,"width":42,"var":"vert2","skin":"uiCommonUpdate/nusel.png","labelSize":18,"labelColors":"#0,#FFFFFF,#FFFFFF","label":"2","height":34},"compId":50},{"type":"Button","props":{"y":170,"width":42,"var":"vert3","skin":"uiCommonUpdate/nusel.png","labelSize":18,"labelColors":"#0,#FFFFFF,#FFFFFF","label":"2","height":34},"compId":51},{"type":"Button","props":{"y":227,"width":42,"var":"vert4","skin":"uiCommonUpdate/nusel.png","labelSize":18,"labelColors":"#0,#FFFFFF,#FFFFFF","label":"2","height":34},"compId":52}]},{"type":"Label","props":{"x":3,"text":"横向","fontSize":18,"font":"SimHei"},"compId":54},{"type":"TextInput","props":{"y":343,"x":10,"width":38,"var":"vertCutNumInput","type":"number","text":"25","skin":"commers/inputbg.png","sizeGrid":"8","height":22,"fontSize":18},"compId":55},{"type":"Label","props":{"y":308,"x":6,"width":41,"text":"更多：","height":16,"fontSize":16,"font":"SimHei","color":"#010101"},"compId":56}]},{"type":"Box","props":{"y":12,"x":39,"var":"horiRdoBox"},"compId":65,"child":[{"type":"RadioGroup","props":{"x":120,"width":100,"var":"horiCutWidthRdo","skin":"comp/radiogroup.png","rotation":0,"labels":"120,240","labelSize":16,"height":14},"compId":58},{"type":"Label","props":{"width":96,"text":"纵向默认裁切长度：","height":16,"fontSize":14,"font":"SimHei"},"compId":59}]},{"type":"Box","props":{"y":12,"x":268,"var":"vertRdoBox"},"compId":66,"child":[{"type":"RadioGroup","props":{"x":118,"width":100,"var":"vertCutWidthRdo","skin":"comp/radiogroup.png","rotation":0,"labels":"120,240","labelSize":16,"height":14},"compId":61},{"type":"Label","props":{"width":96,"text":"横向默认裁切长度：","height":16,"fontSize":14,"font":"SimHei"},"compId":62}]},{"type":"Box","props":{"y":85,"x":461,"var":"vbox"},"compId":67,"child":[{"type":"TextInput","props":{"width":50,"var":"vinput0","text":"100","skin":"comp/textinput.png","fontSize":18,"font":"SimSun","color":"#B1B1B1","sizeGrid":"6,15,7,14"},"compId":27},{"type":"TextInput","props":{"width":50,"var":"vinput1","text":"100","skin":"comp/textinput.png","fontSize":18,"font":"SimSun","color":"#B1B1B1","sizeGrid":"6,15,7,14"},"compId":28},{"type":"TextInput","props":{"width":50,"var":"vinput2","text":"100","skin":"comp/textinput.png","fontSize":18,"font":"SimSun","color":"#B1B1B1","sizeGrid":"6,15,7,14"},"compId":29},{"type":"TextInput","props":{"width":50,"var":"vinput3","text":"100","skin":"comp/textinput.png","fontSize":18,"font":"SimSun","color":"#B1B1B1","sizeGrid":"6,15,7,14"},"compId":30},{"type":"TextInput","props":{"width":50,"var":"vinput4","text":"100","skin":"comp/textinput.png","fontSize":18,"font":"SimSun","color":"#B1B1B1","sizeGrid":"6,15,7,14"},"compId":31},{"type":"TextInput","props":{"width":50,"var":"vinput5","text":"100","skin":"comp/textinput.png","fontSize":18,"font":"SimSun","color":"#B1B1B1","sizeGrid":"6,15,7,14"},"compId":32},{"type":"TextInput","props":{"width":50,"var":"vinput6","text":"100","skin":"comp/textinput.png","fontSize":18,"font":"SimSun","color":"#B1B1B1","sizeGrid":"6,15,7,14"},"compId":34}]}],"loadList":["upload1/inoutbg.png","commers/blackbg.png","comp/image.png","comp/textinput.png","commers/inputbg.png","uiCommonUpdate/nusel.png","comp/radiogroup.png"],"loadList3D":[]};
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);

		}

	}
}