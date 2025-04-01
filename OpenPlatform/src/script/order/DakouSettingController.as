package script.order
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.orderModel.DakouVo;
	import model.orderModel.PaintOrderModel;
	
	import script.ViewManager;
	
	import ui.order.DakouPanelUI;
	
	public class DakouSettingController extends Script
	{
		private var uiSkin:DakouPanelUI;
		
		private var curCell:DakouCell;
		
		public function DakouSettingController()
		{
			super();
		}
		override public function onStart():void
		{
			
			uiSkin = this.owner as DakouPanelUI; 
			
			uiSkin.mainpanel.vScrollBarSkin = "";
			uiSkin.mainpanel.hScrollBarSkin = "";
			
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			this.uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

			
			uiSkin.btnok.on(Event.CLICK,this,closeView);
			
			uiSkin.productlist.itemRender = DakouCell;
			
			//uiSkin.productlist.vScrollBarSkin = "";
			uiSkin.productlist.repeatX = 3;
			uiSkin.productlist.spaceY = 30;
			uiSkin.productlist.spaceX = 40;
			
			
			uiSkin.productlist.renderHandler = new Handler(this, updateProductList);
			uiSkin.productlist.selectEnable = false;
			
			uiSkin.batchEdit.selected = true;
			
			//uiSkin.dakouradio.on(Event.CHANGE,this,onChangeDakNum);
			
			var arr:Array = [];
			//var curmat:ProductVo = PaintOrderModel.instance.curSelectMat;
			
			if(PaintOrderModel.instance.curSelectOrderItem != null)
			{
				var cutdata:DakouVo = new DakouVo();
				cutdata.finalWidth = PaintOrderModel.instance.curSelectOrderItem.finalWidth;
				cutdata.finalHeight = PaintOrderModel.instance.curSelectOrderItem.finalHeight;
				cutdata.fid = PaintOrderModel.instance.curSelectOrderItem.ordervo.picinfo.fid;
				
				cutdata.orderitemvo = PaintOrderModel.instance.curSelectOrderItem.ordervo;
				cutdata.holeMargin = 1;
				cutdata.leftHoles= [];				
				cutdata.rightHoles= [];
				
				cutdata.upHoles= [];		
				
				cutdata.upHoles.push(new Point(cutdata.finalWidth/2,cutdata.holeMargin));
				cutdata.bottomHoles= [];
				
				arr.push(cutdata);
			}
			else
			{
				var batchlist:Vector.<PicOrderItem> = PaintOrderModel.instance.batchChangeMatItems;
				for(var i:int=0;i < batchlist.length;i++)
				{
					
					var cutdata:DakouVo = new DakouVo();
					cutdata.finalWidth = batchlist[i].finalWidth;
					cutdata.finalHeight = batchlist[i].finalHeight;
					cutdata.fid = batchlist[i].ordervo.picinfo.fid;
					
					cutdata.orderitemvo = batchlist[i].ordervo;
					cutdata.holeMargin = 1;
					cutdata.leftHoles= [];				
					cutdata.rightHoles= [];					
					cutdata.upHoles= [];				
					cutdata.bottomHoles= [];
					cutdata.upHoles.push(new Point(cutdata.finalWidth/2,cutdata.holeMargin));

					arr.push(cutdata);
					
				}
			}
			
			uiSkin.productlist.array = arr;
			uiSkin.batchEdit.on(Event.CHANGE,this,onBatchEditChange);
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			
			uiSkin.closeBtn.on(Event.CLICK,this,closeView);
			uiSkin.cancelBtn.on(Event.CLICK,this,closeView);

			uiSkin.productlist.on(Event.MOUSE_OVER,this,pauseParentScroll);
			uiSkin.productlist.on(Event.MOUSE_OUT,this,resumeParentScroll);
			EventCenter.instance.on(EventCenter.SELECT_DAKOU_CELL,this,onSelectCell);
			EventCenter.instance.on(EventCenter.BATCH_EDIT_DAKOU_CELL,this,onBatchUpdate);
			allPicSizeSame(arr);
			//initView();
			//uiSkin.inputnum.on(Event.INPUT,this,onCutNumChange);
			Laya.stage.on(Event.KEY_UP,this,moveHole);

		}
		private function allPicSizeSame(datalist:Array):void
		{
			var same:Boolean = true;
			var picwidth:Number = datalist[0].finalWidth;
			var picheight:Number = datalist[0].finalHeight;

			for(var i:int=0;i < datalist.length;i++)
			{
				if(Math.abs(datalist[i].finalWidth - picwidth) > 1 || Math.abs(datalist[i].finalHeight-picheight) > 0)
				{
					same = false;
					break;
				}
			}
			
			uiSkin.batchEdit.disabled = !(datalist.length > 1 && same);
			
			uiSkin.batchEdit.selected = !uiSkin.batchEdit.disabled;
			onBatchEditChange();
		}
		
		private function onBatchEditChange():void
		{
			for(var i:int=1;i < uiSkin.productlist.cells.length;i++)
			{
				uiSkin.productlist.cells[i].mouseEnabled = !uiSkin.batchEdit.selected;
			}
		}
		private function onSelectCell(cell:DakouCell):void
		{
			curCell = cell;
		}
		
		private function onBatchUpdate():void
		{
			if(uiSkin.batchEdit.selected)
			{
				var firstdata:DakouVo = uiSkin.productlist.array[0];
				for(var i:int=1;i < uiSkin.productlist.array.length;i++)
				{					
					uiSkin.productlist.array[i].leftHoles = firstdata.leftHoles;
					uiSkin.productlist.array[i].rightHoles = firstdata.rightHoles;
					uiSkin.productlist.array[i].upHoles = firstdata.upHoles;
					uiSkin.productlist.array[i].bottomHoles = firstdata.bottomHoles;
					uiSkin.productlist.array[i].holeMargin = firstdata.holeMargin;
				}
				for(i=1;i < uiSkin.productlist.cells.length;i++)
				{
					var cell:DakouCell = uiSkin.productlist.cells[i] as DakouCell;
					if(cell != null && uiSkin.productlist.array[i] != null)
					{
						cell.setData(uiSkin.productlist.array[i]);
					}
				}
			}
		}
		private function moveHole(e:Event):void
		{
			if(curCell != null)
				curCell.moveHole(e);
		}
		private function onResizeBrower():void
		{
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			this.uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

		}
		
		private function pauseParentScroll():void
		{
			
			uiSkin.mainpanel.vScrollBar.target = null;
		}
		private function resumeParentScroll():void
		{
			
			uiSkin.mainpanel.vScrollBar.target = uiSkin.mainpanel;
			
		}
		private function updateProductList(cell:DakouCell,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function onChangeDakNum():void
		{
			var arr:Array = uiSkin.productlist.array;
			for(var i:int=0;i < arr.length;i++)
			{
				//arr[i].orderitemvo.dakouNum = uiSkin.dakouradio.selectedIndex + 1;
				if(arr[i].orderitemvo.dakouNum == 1)
					arr[i].orderitemvo.dkleftpos= arr[i].finalWidth/2;
				else
					arr[i].orderitemvo.dkleftpos= 5;

				arr[i].orderitemvo.dkrightpos= arr[i].finalWidth - 5;
			}
			
			uiSkin.productlist.array = arr;
			uiSkin.productlist.refresh();
			
		}
		private function closeView():void
		{
			var arr:Array = uiSkin.productlist.array;
			for(var i:int=0;i < arr.length;i++)
			{
				if(arr[i].leftHoles.length + arr[i].rightHoles.length + arr[i].upHoles.length + arr[i].bottomHoles.length < 1)
				{
					ViewManager.showAlert("至少需要打一个孔");
					return;
				}
			}
			
			for(var i:int=0;i < arr.length;i++)
			{
				arr[i].orderitemvo.holeList = arr[i].leftHoles.concat(arr[i].rightHoles).concat(arr[i].upHoles).concat(arr[i].bottomHoles);
			}
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.off(EventCenter.SELECT_DAKOU_CELL,this,onSelectCell);
			EventCenter.instance.off(EventCenter.BATCH_EDIT_DAKOU_CELL,this,onBatchUpdate);

			//initView();
			//uiSkin.inputnum.on(Event.INPUT,this,onCutNumChange);
			Laya.stage.off(Event.KEY_UP,this,moveHole);

			ViewManager.instance.closeView(ViewManager.VIEW_DAKOU_PANEL);
			
		}
	}
}