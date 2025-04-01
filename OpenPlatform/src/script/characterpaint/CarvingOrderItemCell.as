package script.characterpaint
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	import laya.utils.Browser;
	
	import model.HttpRequestUtil;
	import model.orderModel.PicOrderItemVo;
	import model.orderModel.ProductVo;
	
	import script.ViewManager;
	
	import ui.characterpaint.CavingOderItemUI;
		
	public class CarvingOrderItemCell extends CavingOderItemUI
	{
		public var ordervo:PicOrderItemVo;
		public var locked:Boolean = true;
		
		public var finalWidth:Number;
		public var finalHeight:Number;
		
		private var curproductvo:ProductVo;
		
		public function CarvingOrderItemCell()
		{
			super();
			this.framesel.visible = false;
			
			this.uploadBtn.on(Event.CLICK,this,showSelectPicView);

			
			this.picimg.on(Event.CLICK,this,showSelectPicView);
			this.deletebtn.on(Event.CLICK,this,reset);
			this.hideobj.on(Event.CHANGE,this,onChangeState);
			this.filename.visible = false;
			
			this.inputnum.text = "1";
			this.inputnum.restrict = "0-9";
			this.inputnum.on(Event.INPUT,this,onNumChange);
			
			this.subtn.on(Event.CLICK,this,onSubItemNum);
			this.addbtn.on(Event.CLICK,this,onAddItemNum);
			
			this.editBtn.on(Event.CLICK,this,onClickEdit);
			
		}
		
		private function onClickEdit():void
		{
			if(this.ordervo != null)
			{
				EventCenter.instance.event(EventCenter.SELECT_CARVING_ITEM,ordervo.indexNum);
				Browser.window.UnityPaintWeb.setCharacterEdgeIndex(ordervo.indexNum.toString());
			}
			
		}
		public function onNumChange():void
		{
			if(this.inputnum.text == "")
				this.inputnum.text = "1";
			
			if(this.ordervo && this.ordervo.orderData)
				this.ordervo.orderData.item_number = parseInt(this.inputnum.text);
			EventCenter.instance.event(EventCenter.UPDATE_ORDER_ITEM_TECH);
			
		}
		
		private function onSubItemNum():void
		{
			var num:int = parseInt(this.inputnum.text);
			if(num > 1)
				num--;
			this.inputnum.text = num.toString();
			onNumChange();
		}
		private function onAddItemNum():void
		{
			var num:int = parseInt(this.inputnum.text);
			num++;
			this.inputnum.text = num.toString();
			onNumChange();
		}
		
		
		private function showSelectPicView():void
		{
			if(this.ordervo == null)
			{
				EventCenter.instance.event(EventCenter.HIDE_U3D_DIV,false);
				
				ViewManager.instance.openView(ViewManager.VIEW_SELECT_PIC_TO_ORDER);
			}
			else
			{
				EventCenter.instance.event(EventCenter.SELECT_CARVING_ITEM,ordervo.indexNum);
				Browser.window.UnityPaintWeb.setCharacterEdgeIndex(ordervo.indexNum.toString());
				
			}
		}
		
		private function onChangeState():void
		{
			if(this.ordervo != null)
			{
				Browser.window.UnityPaintWeb.setFrontFaceActive(this.hideobj.selected ? 0:1);
				
			}
		}
		public function selectItem(selected:Boolean):void{
			this.framesel.visible = selected;
		}
		public function setData(data:PicOrderItemVo):void
		{
			ordervo = data;
			if(ordervo != null)
			{
				this.picimg.skin = HttpRequestUtil.smallerrPicUrl + ordervo.picinfo.fid + ".jpg";
				
				if(ordervo.picinfo.picWidth > ordervo.picinfo.picHeight)
				{
					this.picimg.width = 124;					
					this.picimg.height = 124/ordervo.picinfo.picWidth * ordervo.picinfo.picHeight;
					
				}
				else
				{
					this.picimg.height = 124;
					this.picimg.width = 124/ordervo.picinfo.picHeight * ordervo.picinfo.picWidth;
					
				}
				this.filename.visible = true;
				this.uploadBtn.visible = false;
				this.filename.text = ordervo.picinfo.directName;
				Browser.window.UnityPaintWeb.setCharacterEdgeIndex(ordervo.indexNum.toString());
				
				Browser.window.UnityPaintWeb.changefontSize(ordervo.picinfo.picPhysicWidth/100 + "&" + ordervo.picinfo.picPhysicHeight/100);
				
				var picurl:String = HttpRequestUtil.biggerPicUrl + ordervo.picinfo.fid + ".plt";
				Browser.window.UnityPaintWeb.createMesh(picurl);
			}
			else
				reset();
		}
		public function reset():void
		{
			
			if(this.ordervo != null)
			{
				Browser.window.UnityPaintWeb.setCharacterEdgeIndex(ordervo.indexNum.toString());
				
				Browser.window.UnityPaintWeb.setFrontFaceActive(0);
				this.ordervo.orderData = null;
				this.ordervo = null;
				this.picimg.skin = "";
				this.filename.text = "";
				this.filename.visible = false;
				
				this.framesel.visible = false;
				this.uploadBtn.visible = true;

			}
			
			this.curproductvo = null;
			
			
		}
		
		public function resetOrderData():void
		{
			if(this.ordervo != null)
			{
				this.ordervo.orderData = null;
			}
			this.curproductvo = null;
			
		}
		
		public function getPrice():Number
		{			
			return 0;//parseInt(this.inputnum.text) * this.ordervo.orderPrice;
		}
	}
}