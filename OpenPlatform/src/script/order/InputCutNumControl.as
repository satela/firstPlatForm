package script.order
{
	import eventUtil.EventCenter;
	
	import flashx.textLayout.formats.BackgroundColor;
	
	import laya.components.Script;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.orderModel.MaterialItemVo;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	import model.orderModel.ProductVo;
	
	import script.ViewManager;
	
	import ui.order.InputCutNumPanelUI;
	import ui.order.OrderAddressItemUI;
	
	import utils.UtilTool;
	
	public class InputCutNumControl extends Script
	{
		private var uiSkin:InputCutNumPanelUI;
		//private var matvo:MaterialItemVo;
		
		private var hasFubai:Boolean;
		private var param:Object;
		private var leastCutNum:int;

		private var cuttype:int;
		
		private var linelist:Vector.<Sprite>;

		public function InputCutNumControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			
			uiSkin = this.owner as InputCutNumPanelUI; 
			
			uiSkin.mainpanel.vScrollBarSkin = "";
			uiSkin.mainpanel.hScrollBarSkin = "";
			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			
			hasFubai = param;
			linelist = new Vector.<Sprite>();
			uiSkin.okbtn.on(Event.CLICK,this,closeView);
			
			uiSkin.productlist.itemRender = ImageCutItem;
			
			//uiSkin.productlist.vScrollBarSkin = "";
			uiSkin.productlist.repeatX = 3;
			uiSkin.productlist.spaceY = 20;
			uiSkin.productlist.spaceX = 60;
			
			
			uiSkin.productlist.renderHandler = new Handler(this, updateProductList);
			uiSkin.productlist.selectEnable = false;
			
			var arr:Array = [];
			var curmat:ProductVo = PaintOrderModel.instance.curSelectMat;

			uiSkin.closeBtn.on(Event.CLICK,this,closeScene);
			
			uiSkin.cancelBtn.on(Event.CLICK,this,closeScene);

			var maxcutwidth:Number = curmat.materialWidth-2;
			//品赋阳光没有腹板
			//if(hasFubai)
			//	maxcutwidth = 120;
			
			uiSkin.maxtips.text = "（单份最大裁切宽度：" + maxcutwidth + "cm）";

			if(PaintOrderModel.instance.curSelectOrderItem != null)
			{
				var cutdata:Object = {};
				cutdata.finalWidth = PaintOrderModel.instance.curSelectOrderItem.finalWidth;
				cutdata.finalHeight = PaintOrderModel.instance.curSelectOrderItem.finalHeight;
				cutdata.fid = PaintOrderModel.instance.curSelectOrderItem.ordervo.picinfo.fid;
				cutdata.maxwidth = maxcutwidth;

				cutdata.border = UtilTool.getBorderDistance(PaintOrderModel.instance.curSelectMat.getAllSelectedTech() as Vector.<MaterialItemVo>);
				
				cutdata.orderitemvo = PaintOrderModel.instance.curSelectOrderItem.ordervo;
				cutdata.orderitemvo.cuttype = 0;
				
				//品赋阳光没有腹板
				//if(maxcutwidth < OrderConstant.MAX_CUT_THRESHOLD)		
				//{
					//cutdata.orderitemvo.cutnum = Math.ceil((PaintOrderModel.instance.curSelectOrderItem.finalWidth + cutdata.border)/OrderConstant.CUT_PRIOR_WIDTH);
				cutdata.orderitemvo.cutnum = Math.ceil((PaintOrderModel.instance.curSelectOrderItem.finalWidth + cutdata.border)/maxcutwidth);
					if(cutdata.orderitemvo.cutnum < 2)
						cutdata.orderitemvo.cutnum = 2;
				//}
				//else
				//	cutdata.orderitemvo.cutnum = Math.ceil((PaintOrderModel.instance.curSelectOrderItem.finalWidth + cutdata.border)/maxcutwidth);

				
				var cutlen:Number = (PaintOrderModel.instance.curSelectOrderItem.finalWidth + cutdata.border)/cutdata.orderitemvo.cutnum;
				cutlen = parseFloat(cutlen.toFixed(2));
				cutdata.orderitemvo.eachCutLength = [];
				for(var j:int=0;j < cutdata.orderitemvo.cutnum;j++)
					cutdata.orderitemvo.eachCutLength.push(cutlen);
				arr.push(cutdata);
			}
			else
			{
				var batchlist:Vector.<PicOrderItem> = PaintOrderModel.instance.batchChangeMatItems;
				
				var border:Number = UtilTool.getBorderDistance(PaintOrderModel.instance.curSelectMat.getAllSelectedTech() as Vector.<MaterialItemVo>);
				
				for(var i:int=0;i < batchlist.length;i++)
				{
					if(batchlist[i].finalWidth + border > curmat.materialWidth && batchlist[i].finalHeight + border > curmat.materialWidth)
					{
						var cutdata:Object = {};
						cutdata.finalWidth = batchlist[i].finalWidth;
						cutdata.finalHeight = batchlist[i].finalHeight;
						cutdata.fid = batchlist[i].ordervo.picinfo.fid;
						cutdata.maxwidth = maxcutwidth;
						
						cutdata.border = UtilTool.getBorderDistance(PaintOrderModel.instance.curSelectMat.getAllSelectedTech() as Vector.<MaterialItemVo>);

						cutdata.orderitemvo = batchlist[i].ordervo;
						cutdata.orderitemvo.cuttype = 0;
						//cutdata.orderitemvo.cutnum = Math.ceil((batchlist[i].finalWidth + cutdata.border)/maxcutwidth);
						
						//if(maxcutwidth < OrderConstant.MAX_CUT_THRESHOLD)					
						//{
							//cutdata.orderitemvo.cutnum = Math.ceil((batchlist[i].finalWidth + cutdata.border)/OrderConstant.CUT_PRIOR_WIDTH);
							cutdata.orderitemvo.cutnum = Math.ceil((batchlist[i].finalWidth + cutdata.border)/maxcutwidth);
							if(cutdata.orderitemvo.cutnum < 2)
								cutdata.orderitemvo.cutnum = 2;
						//}
						//else
						//	cutdata.orderitemvo.cutnum = Math.ceil((batchlist[i].finalWidth + cutdata.border)/maxcutwidth);
						
						
						var cutlen:Number = (batchlist[i].finalWidth + cutdata.border)/cutdata.orderitemvo.cutnum;
						cutlen = parseFloat(cutlen.toFixed(2));
						cutdata.orderitemvo.eachCutLength = [];
						for(var j:int=0;j < cutdata.orderitemvo.cutnum;j++)
							cutdata.orderitemvo.eachCutLength.push(cutlen);
						arr.push(cutdata);
					}
				}
			}
			
			uiSkin.productlist.array = arr;
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

			uiSkin.productlist.on(Event.MOUSE_OVER,this,pauseParentScroll);
			uiSkin.productlist.on(Event.MOUSE_OUT,this,resumeParentScroll);
			
			//initView();
			//uiSkin.inputnum.on(Event.INPUT,this,onCutNumChange);

		}
		
		private function onResizeBrower():void
		{
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

		}
		
		private function pauseParentScroll():void
		{

			uiSkin.mainpanel.vScrollBar.target = null;
		}
		private function resumeParentScroll():void
		{
			
			uiSkin.mainpanel.vScrollBar.target = uiSkin.mainpanel;
			
		}
		private function updateProductList(cell:ImageCutItem,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		
		
		private function closeView():void
		{
			var arr:Array = uiSkin.productlist.array;
			var hasUnSameLength:Boolean = false;
			for(var i:int=0;i < arr.length;i++)
			{
				if(arr[i] != null)
				{
					var allcut:Array = arr[i].orderitemvo.eachCutLength;
					for(var j:int=0;j < allcut.length;j++)
					{
						if(allcut[j] <= 0 || allcut[j] > arr[i].maxwidth)
						{
							ViewManager.showAlert("请检查每份切割长度是否有效（切割不能为空或0，也不能大于最大长度" + arr[i].maxwidth + "cm)。" );
							return;
						}
						if(hasUnSameLength == false)
						{
							for(var m:int=j+1;m < allcut.length;m++)
							{
								if(Math.abs(allcut[m] - allcut[j]) > 0.02)
									hasUnSameLength = true;
							}
						}
					}
				}
			}
			if(hasUnSameLength)
			{
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"您选择了非等分裁切下单，由此产生的少量色差或长度拼接问题，生产方不负责承担损失，请谨慎选择。",caller:this,callback:onFirmCut});
				return;
			}
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

			ViewManager.instance.closeView(ViewManager.INPUT_CUT_NUM);
			
		}
		
		private function onFirmCut(b:Boolean):void
		{
			if(b)
			{
				EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
				
				ViewManager.instance.closeView(ViewManager.INPUT_CUT_NUM);
			}
		}
		
		private function closeScene():void
		{
			ViewManager.instance.closeView(ViewManager.INPUT_CUT_NUM);

		}
	}
}