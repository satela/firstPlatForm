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
	import model.orderModel.CutImageData;
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

		//private var cuttype:int;
		
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
			var maxcutlength:Number = curmat.materialLength-2;

			//品赋阳光没有腹板
			//if(hasFubai)
			//	maxcutwidth = 120;
			
			uiSkin.maxtips.text = "（单份最大裁切宽度：" + maxcutwidth + "cm）";

			if(PaintOrderModel.instance.curSelectOrderItem != null)
			{
//				var cutdata:Object = {};
//				cutdata.finalWidth = PaintOrderModel.instance.curSelectOrderItem.finalWidth;
//				cutdata.finalHeight = PaintOrderModel.instance.curSelectOrderItem.finalHeight;
//				cutdata.fid = PaintOrderModel.instance.curSelectOrderItem.ordervo.picinfo.fid;
//				cutdata.maxwidth = maxcutwidth;
//				cutdata.maxlength = maxcutlength;
//
//				cutdata.border = UtilTool.getBorderDistance(PaintOrderModel.instance.curSelectMat.getAllSelectedTech() as Vector.<MaterialItemVo>);
//				
//				cutdata.orderitemvo = PaintOrderModel.instance.curSelectOrderItem.ordervo;
//				if((PaintOrderModel.instance.curSelectOrderItem.finalWidth + cutdata.border) > curmat.materialLength && (PaintOrderModel.instance.curSelectOrderItem.finalHeight + cutdata.border) > curmat.materialLength)
//					cutdata.orderitemvo.cuttype = 2;
//				else
//					cutdata.orderitemvo.cuttype = 0;
//				
//				//品赋阳光没有腹板
//				//if(maxcutwidth < OrderConstant.MAX_CUT_THRESHOLD)		
//				//{
//					//cutdata.orderitemvo.cutnum = Math.ceil((PaintOrderModel.instance.curSelectOrderItem.finalWidth + cutdata.border)/OrderConstant.CUT_PRIOR_WIDTH);
//				
//			
//				if(cutdata.orderitemvo.cuttype == 0 || cutdata.orderitemvo.cuttype == 2)
//				{
//					cutdata.orderitemvo.vCutnum = Math.ceil((PaintOrderModel.instance.curSelectOrderItem.finalWidth + cutdata.border)/maxcutwidth);
//					if(cutdata.orderitemvo.vCutnum < 2)
//						cutdata.orderitemvo.vCutnum = 2;
//					
//					var cutlen:Number = (PaintOrderModel.instance.curSelectOrderItem.finalWidth + cutdata.border)/cutdata.orderitemvo.vCutnum;
//					cutlen = parseFloat(cutlen.toFixed(2));
//					cutdata.orderitemvo.vEachCutLength = [];
//					for(var j:int=0;j < cutdata.orderitemvo.vCutnum;j++)
//						cutdata.orderitemvo.vEachCutLength.push(cutlen);
//				}
//				if(cutdata.orderitemvo.cuttype == 2)
//				{
//					cutdata.orderitemvo.hCutnum = Math.ceil((PaintOrderModel.instance.curSelectOrderItem.finalHeight + cutdata.border)/maxcutwidth);
//					if(cutdata.orderitemvo.hCutnum < 2)
//						cutdata.orderitemvo.hCutnum = 2;
//					
//					var cutlen:Number = (PaintOrderModel.instance.curSelectOrderItem.finalHeight + cutdata.border)/cutdata.orderitemvo.hCutnum;
//					cutlen = parseFloat(cutlen.toFixed(2));
//					cutdata.orderitemvo.hEachCutLength = [];
//					for(var j:int=0;j < cutdata.orderitemvo.hCutnum;j++)
//						cutdata.orderitemvo.hEachCutLength.push(cutlen);
//				}
				var cutdata:CutImageData = getCutData(PaintOrderModel.instance.curSelectOrderItem,curmat);
				
				arr.push(cutdata);
			}
			else
			{
				var batchlist:Vector.<PicOrderItem> = PaintOrderModel.instance.batchChangeMatItems;
				
				var border:Number = UtilTool.getBorderDistance(PaintOrderModel.instance.curSelectMat.getAllSelectedTech() as Vector.<MaterialItemVo>);
				
				for(var i:int=0;i < batchlist.length;i++)
				{
					//if(batchlist[i].finalWidth + border > curmat.materialWidth && batchlist[i].finalHeight + border > curmat.materialWidth)
					//{
//						var cutdata:Object = {};
//						cutdata.finalWidth = batchlist[i].finalWidth;
//						cutdata.finalHeight = batchlist[i].finalHeight;
//						cutdata.fid = batchlist[i].ordervo.picinfo.fid;
//						cutdata.maxwidth = maxcutwidth;
//						
//						cutdata.border = UtilTool.getBorderDistance(PaintOrderModel.instance.curSelectMat.getAllSelectedTech() as Vector.<MaterialItemVo>);
//
//						cutdata.orderitemvo = batchlist[i].ordervo;
//						
//						if((batchlist[i].finalWidth + cutdata.border) > curmat.materialLength && (batchlist[i].finalHeight + cutdata.border) > curmat.materialLength)
//							cutdata.orderitemvo.cuttype = 2;
//						else
//							cutdata.orderitemvo.cuttype = 0;
//						
//						if(cutdata.orderitemvo.cuttype == 0 || cutdata.orderitemvo.cuttype == 2)
//						{
//						
//							cutdata.orderitemvo.vCutnum = Math.ceil((batchlist[i].finalWidth + cutdata.border)/maxcutwidth);
//							if(cutdata.orderitemvo.vCutnum < 2)
//								cutdata.orderitemvo.vCutnum = 2;
//														
//							
//							var cutlen:Number = (batchlist[i].finalWidth + cutdata.border)/cutdata.orderitemvo.vCutnum;
//							cutlen = parseFloat(cutlen.toFixed(2));
//							cutdata.orderitemvo.vEachCutLength = [];
//							for(var j:int=0;j < cutdata.orderitemvo.vCutnum;j++)
//								cutdata.orderitemvo.vEachCutLength.push(cutlen);
//						}
//						if(cutdata.orderitemvo.cuttype == 2)
//						{
//							cutdata.orderitemvo.hCutnum = Math.ceil((batchlist[i].finalHeight + cutdata.border)/maxcutwidth);
//							if(cutdata.orderitemvo.hCutnum < 2)
//								cutdata.orderitemvo.hCutnum = 2;
//							
//							var cutlen:Number = (batchlist[i].finalHeight + cutdata.border)/cutdata.orderitemvo.hCutnum;
//							cutlen = parseFloat(cutlen.toFixed(2));
//							cutdata.orderitemvo.hEachCutLength = [];
//							for(var j:int=0;j < cutdata.orderitemvo.hCutnum;j++)
//								cutdata.orderitemvo.hEachCutLength.push(cutlen);
//						}
						cutdata = getCutData(batchlist[i],curmat);
						if(cutdata != null)
							arr.push(cutdata);

					//}
				}
			}
			
			uiSkin.productlist.array = arr;
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

			uiSkin.productlist.on(Event.MOUSE_OVER,this,pauseParentScroll);
			uiSkin.productlist.on(Event.MOUSE_OUT,this,resumeParentScroll);
			
			//initView();
			//uiSkin.inputnum.on(Event.INPUT,this,onCutNumChange);

		}
		
		private function getCutData(picorderItem:PicOrderItem,productVo:ProductVo):CutImageData
		{
			var cutdata:CutImageData = new CutImageData();
			cutdata.finalWidth = picorderItem.finalWidth;
			cutdata.finalHeight = picorderItem.finalHeight;
			cutdata.fid = picorderItem.ordervo.picinfo.fid;
			cutdata.maxwidth = productVo.materialWidth - 2;
			cutdata.maxlength = productVo.materialLength - 2;
			
			cutdata.border = UtilTool.getBorderDistance(productVo.getAllSelectedTech() as Vector.<MaterialItemVo>);
			
			cutdata.orderitemvo = picorderItem.ordervo;
//			if((picorderItem.finalWidth + cutdata.border) > productVo.materialLength && (picorderItem.finalHeight + cutdata.border) > productVo.materialLength)
//				cutdata.orderitemvo.cuttype = 2;
//			else
//				cutdata.orderitemvo.cuttype = 0;
			
			var shortSide:Number = Math.min(picorderItem.finalWidth,picorderItem.finalHeight) + cutdata.border;
			var longSide:Number = Math.max(picorderItem.finalWidth,picorderItem.finalHeight) + cutdata.border;
			if(shortSide > productVo.materialWidth && longSide > productVo.materialWidth && shortSide <= productVo.materialLength && longSide <=  productVo.materialLength)
			{
				cutdata.orderitemvo.cutDirect = OrderConstant.CUT_TWO_SIDE;
				cutdata.cutLength = [cutdata.maxwidth];
				cutdata.orderitemvo.cuttype = 0;

			}
			else if(shortSide > productVo.materialWidth && longSide > productVo.materialWidth && shortSide <= productVo.materialLength && longSide > productVo.materialLength)
			{
				if(picorderItem.finalWidth >= picorderItem.finalHeight)
				{
					cutdata.orderitemvo.cutDirect = OrderConstant.CUT_WIDTH_ONLY;
					cutdata.orderitemvo.cuttype = 0;

				}
				else
				{
					cutdata.orderitemvo.cutDirect = OrderConstant.CUT_HEIGHT_ONLY;
					cutdata.orderitemvo.cuttype = 1;

				}
				
				cutdata.cutLength = [cutdata.maxwidth];

			}
			else if(shortSide <= productVo.materialWidth &&  longSide > productVo.materialLength)
			{
				if(picorderItem.finalWidth >= picorderItem.finalHeight)
				{
					cutdata.orderitemvo.cutDirect = OrderConstant.CUT_WIDTH_ONLY;
					cutdata.orderitemvo.cuttype = 0;

				}
				else
				{
					cutdata.orderitemvo.cutDirect = OrderConstant.CUT_HEIGHT_ONLY;
					cutdata.orderitemvo.cuttype = 1;

				}
				
				cutdata.cutLength = [cutdata.maxwidth,cutdata.maxlength];

				
			}
			else if(shortSide > productVo.materialLength &&  longSide > productVo.materialLength)
			{
				cutdata.orderitemvo.cutDirect = OrderConstant.CUT_TWO_SIDE;
				cutdata.cutLength = [cutdata.maxwidth,cutdata.maxlength];
				cutdata.orderitemvo.cuttype = 2;

			}
			else return null;
			
			//品赋阳光没有腹板
			//if(maxcutwidth < OrderConstant.MAX_CUT_THRESHOLD)		
			//{
			//cutdata.orderitemvo.cutnum = Math.ceil((PaintOrderModel.instance.curSelectOrderItem.finalWidth + cutdata.border)/OrderConstant.CUT_PRIOR_WIDTH);
			
			
			//if(cutdata.orderitemvo.cuttype == 0 || cutdata.orderitemvo.cuttype == 2)
			//{
			if(cutdata.orderitemvo.cutDirect == OrderConstant.CUT_WIDTH_ONLY || cutdata.orderitemvo.cutDirect == OrderConstant.CUT_TWO_SIDE)
			{
				cutdata.orderitemvo.vCutnum = Math.ceil((picorderItem.finalWidth + cutdata.border)/cutdata.maxwidth);
				if(cutdata.orderitemvo.vCutnum < 2)
					cutdata.orderitemvo.vCutnum = 2;
				cutdata.orderitemvo.vEachCutLength = [];

				if(cutdata.orderitemvo.cuttype == 2)
				{
					var cutlen:Number = cutdata.maxwidth;//(picorderItem.finalWidth + cutdata.border)/cutdata.orderitemvo.vCutnum;
					//cutlen = parseFloat(cutlen.toFixed(2));
					for(var j:int=0;j < cutdata.orderitemvo.vCutnum;j++)
					{
						if(j < cutdata.orderitemvo.vCutnum - 1)
							cutdata.orderitemvo.vEachCutLength.push(cutlen);
						else
							cutdata.orderitemvo.vEachCutLength.push(picorderItem.finalWidth + cutdata.border - cutlen * (cutdata.orderitemvo.vCutnum - 1));
							
						
					}
				}
				else
				{
					cutlen = (picorderItem.finalWidth + cutdata.border)/cutdata.orderitemvo.vCutnum;
					cutlen = parseFloat(cutlen.toFixed(2));
					for(var j:int=0;j < cutdata.orderitemvo.vCutnum;j++)
					{						
						cutdata.orderitemvo.vEachCutLength.push(cutlen);						
					}
				}
			}
			else if(cutdata.orderitemvo.cutDirect == OrderConstant.CUT_HEIGHT_ONLY || cutdata.orderitemvo.cutDirect == OrderConstant.CUT_TWO_SIDE)
			{
				cutdata.orderitemvo.hCutnum = Math.ceil((picorderItem.finalHeight + cutdata.border)/cutdata.maxwidth);
				if(cutdata.orderitemvo.hCutnum < 2)
					cutdata.orderitemvo.hCutnum = 2;
				cutdata.orderitemvo.hEachCutLength = [];

				if(cutdata.orderitemvo.cuttype == 2)
				{
					var cutlen:Number = cutdata.maxwidth;//(picorderItem.finalHeight + cutdata.border)/cutdata.orderitemvo.hCutnum;
					//cutlen = parseFloat(cutlen.toFixed(2));
					for(var j:int=0;j < cutdata.orderitemvo.hCutnum;j++)
					{
						if(j < cutdata.orderitemvo.hCutnum - 1)
							cutdata.orderitemvo.hEachCutLength.push(cutlen);
						else
							cutdata.orderitemvo.hEachCutLength.push(picorderItem.finalHeight + cutdata.border - cutlen * (cutdata.orderitemvo.hCutnum - 1));
						
					}
				}
				else
				{
					var cutlen:Number = (picorderItem.finalHeight + cutdata.border)/cutdata.orderitemvo.hCutnum;
					cutlen = parseFloat(cutlen.toFixed(2));
					for(var j:int=0;j < cutdata.orderitemvo.hCutnum;j++)
					{
						if(j < cutdata.orderitemvo.hCutnum - 1)
							cutdata.orderitemvo.hEachCutLength.push(cutlen);
						
					}
				}
			}
				
			//}
			if(cutdata.orderitemvo.cuttype == 2)
			{
				cutdata.orderitemvo.hCutnum = Math.ceil((picorderItem.finalHeight + cutdata.border)/cutdata.maxlength);
				if(cutdata.orderitemvo.hCutnum < 2)
					cutdata.orderitemvo.hCutnum = 2;
				
				var cutlen:Number = cutdata.maxlength;//(picorderItem.finalHeight + cutdata.border)/cutdata.orderitemvo.hCutnum;
				//cutlen = parseFloat(cutlen.toFixed(2));
				cutdata.orderitemvo.hEachCutLength = [];
				for(var j:int=0;j < cutdata.orderitemvo.hCutnum;j++)
				{
					if(j < cutdata.orderitemvo.hCutnum - 1)
						cutdata.orderitemvo.hEachCutLength.push(cutlen);
					else
						cutdata.orderitemvo.hEachCutLength.push(picorderItem.finalHeight + cutdata.border - cutlen * (cutdata.orderitemvo.hCutnum - 1));
					
				}
			}
			return cutdata;
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
					var horcutArr:Array;// = arr[i].orderitemvo.vEachCutLength;
					var vertCutArr:Array;
					if(arr[i].orderitemvo.cuttype == 0 || arr[i].orderitemvo.cuttype == 2)
					{
						horcutArr = arr[i].orderitemvo.vEachCutLength;
					}
					else
					{
						horcutArr = [(arr[i] as CutImageData).finalWidth];
					}
					
					if(arr[i].orderitemvo.cuttype == 1 || arr[i].orderitemvo.cuttype == 2)
					{
						vertCutArr = arr[i].orderitemvo.hEachCutLength;
					}
					else
					{
						vertCutArr = [(arr[i] as CutImageData).finalHeight];
					}
					if(!checkValidCutNum(horcutArr,vertCutArr))
					{
						return;
					}
					 
				}
			}
//			if(hasUnSameLength)
//			{
//				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"您选择了非等分裁切下单，由此产生的少量色差或长度拼接问题，生产方不负责承担损失，请谨慎选择。",caller:this,callback:onFirmCut});
//				return;
//			}
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

			ViewManager.instance.closeView(ViewManager.INPUT_CUT_NUM);
			
		}
		
		private function checkValidCutNum(horiCut:Array,vertCut:Array):Boolean
		{
			var hasUnSameLength:Boolean = false;

			var curmat:ProductVo = PaintOrderModel.instance.curSelectMat;
			for(var j:int=0;j < horiCut.length;j++)
			{
				for(var i:int=0;i < vertCut.length;i++)
				{
					if(Math.min(horiCut[j],vertCut[i]) > (curmat.materialWidth-2) || Math.max(horiCut[j],vertCut[i]) > (curmat.materialLength-2))
					{
						ViewManager.showAlert("请检查切割后每块板子的大小，短边不能大于" + (curmat.materialWidth - 2) + "cm，" + "长边不能大于" + (curmat.materialLength - 2) + "cm");
						return false;
					}
				}
			}
			
			return true;
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
			closeView();
			//ViewManager.instance.closeView(ViewManager.INPUT_CUT_NUM);

		}
	}
}