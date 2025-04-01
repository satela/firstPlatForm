package script.prodCustomer.item
{
	import laya.utils.Handler;
	
	import model.prodCustomerModel.ProdParamVo;
	
	import ui.prodCustom.ProdParamItemUI;
	
	public class ProdParamCell extends ProdParamItemUI
	{
		private var paramVo:ProdParamVo;
		public function ProdParamCell()
		{
			super();
			
			this.btnList.itemRender = ConditionBtnCell;
			
			//this.btnList.vScrollBarSkin = "";
			this.btnList.spaceX = 10;
			this.btnList.renderHandler = new Handler(this, updateParamItem);
			
		}
		
		public function setData(data:ProdParamVo):void
		{
			paramVo = data;
			this.conLbl.text = paramVo.paramName;
			this.btnList.array = paramVo.paramList;
		}
		private function updateParamItem(cell:ConditionBtnCell):void
		{
			cell.setData(cell.dataSource);
		}
		
	}
}