package script.workpanel.items
{
	import ui.order.MaterialNameItemUI;
	
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.MaterialItemVo;
	import model.orderModel.MatetialClassVo;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	import model.orderModel.ProcessCatVo;
	import model.orderModel.ProductVo;
	
	import script.ViewManager;
	
	
	public class MaterialCell extends MaterialNameItemUI
	{
		public var matvo:ProductVo;
		public var matCategoryVo:MatetialClassVo;
		
		public function MaterialCell()
		{
			super();
		}
		public function setData(product:Object):void
		{
			this.offAllCaller(this);
			
			if(product.prodName)
			{
				matvo = product as ProductVo;
				this.matbtn.label = matvo.prodName + (matvo.isClientProd?"(自有)":"");// + "\n(" + matvo.material_brand + "," + Math.round(matvo.unit_weight*1000) + ")" ;
				if(matvo.materialColor != "")
				{
					this.matbtn.label +="("+ matvo.materialColor + ")";
				}
				this.on(Event.CLICK,this,onClickMat,[matvo]);
				this.moreBtn.visible = false;
				
				this.grayimg.visible = PaintOrderModel.instance.checkExceedMaterialSize(matvo);
				this.selfIcon.visible = matvo.isClientProd;
				
				this.mouseEnabled =  !PaintOrderModel.instance.checkExceedMaterialSize(matvo);
				this.manuFacIcon.skin = "commers/"  + OrderConstant.OUTPUT_ICON[PaintOrderModel.instance.getManuFactureIndex(product.manufacturer_code)];
			}
			else
			{
				matCategoryVo = product as MatetialClassVo;
				this.matbtn.label = matCategoryVo.matclassname ;
				this.moreBtn.visible = false;
				this.grayimg.visible = false;
				this.selfIcon.visible = false;
				
				this.mouseEnabled = true;
				this.manuFacIcon.skin = "";
				this.on(Event.CLICK,this,onClickMatCategory);
				this.moreBtn.on(Event.CLICK,this,moreMaterial);
				
				this.on(Event.MOUSE_OVER,this,function(){
					
					this.moreBtn.visible = true;
				});
				this.on(Event.MOUSE_OUT,this,function(){
					
					this.moreBtn.visible = false;
				})	
			}
			
			//this.blackrect.visible = false;
			//this.redrect.visible = false;
		}
		
		private function onClickMat(materialVo:ProductVo):void
		{
			
			if(PaintOrderModel.instance.checkExceedMaterialSize(materialVo))
			{
				ViewManager.showAlert("有图片超出材料的最大尺寸");
				return;
			}
			
			if(PaintOrderModel.instance.checkUnFitFileType(materialVo))
			{
				//ViewManager.showAlert("图片格式不符合产品要求");
				return;
			}
			var tempmat:ProductVo = materialVo;
			
//			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProdAttribute + tempmat.prodCode + "&org_code=" + tempmat.manufacturerCode,this,function(data:String){
//				
//				
//				
//			},null,null);
			
			
			// TODO Auto Generated method stub
			if(materialVo.procTreeList != null && materialVo.procTreeList.length > 0)
			{
				materialVo.resetData();
				PaintOrderModel.instance.curSelectMat = materialVo;
				EventCenter.instance.event(EventCenter.SHOW_SELECT_TECH);
				ViewManager.instance.closeView(ViewManager.VIEW_MORE_PRODUCT_PANEL);
				
				//ViewManager.instance.closeView(ViewManager.VIEW_SELECT_MATERIAL);
				
				//ViewManager.instance.openView(ViewManager.VIEW_SELECT_TECHNORLOGY,false);
			}
			else
			{
				var tempmat:ProductVo = materialVo;
				//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProcessCatList + tempmat.prodCode,this,function(data:String){
				var selectoutputCenters:Array = PaintOrderModel.instance.getSelectedOutPutCenter();
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProcFlowNew + tempmat.prodCode + "&manufacturerCode=" + tempmat.manufacturerCode,this,function(data:String){
					
					var result:Object = JSON.parse(data as String);
					if(!result.hasOwnProperty("status"))
					{
						PaintOrderModel.instance.curSelectMat = tempmat;
						PaintOrderModel.instance.curSelectMat.procTreeList = [];
						
						for(var i:int=0;i < result.length;i++)
						{
							var procNode:MaterialItemVo = new MaterialItemVo(result[i].procFlowNode);
							PaintOrderModel.instance.curSelectMat.procTreeList.push(procNode);
						}
						ViewManager.instance.closeView(ViewManager.VIEW_MORE_PRODUCT_PANEL);
						
						EventCenter.instance.event(EventCenter.SHOW_SELECT_TECH);
						//ViewManager.instance.closeView(ViewManager.VIEW_SELECT_MATERIAL);
						
						//ViewManager.instance.openView(ViewManager.VIEW_SELECT_TECHNORLOGY,false);
					}}
					
					,null,null);
				
			}
			
			
		}
		
		private function moreMaterial(e:Event):void
		{
			if(matCategoryVo.childMatList != null)
			{
				ViewManager.instance.openView(ViewManager.VIEW_MORE_PRODUCT_PANEL,false,matCategoryVo);
			}
			else
			{
				getCatergoryProduct(openMoreProduct);
				
			}
			e.stopPropagation();
			
		}
		private function openMoreProduct():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_MORE_PRODUCT_PANEL,false,matCategoryVo);
		}
		private function onClickMatCategory():void
		{
			if(matCategoryVo.childMatList != null)
			{
				getDefaultMaterialId();
			}
			else
			{
				getCatergoryProduct(getDefaultMaterialId);
			}
		}
		
		private function getDefaultMaterialId():void
		{
			if(matCategoryVo.defaultProductId == null)
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProductCategoryDefault + "name=" + matCategoryVo.matclassname,this,function(data:String){
					
					
					var result:Object = JSON.parse(data as String);
					if(result.status == 0)
					{
						if(result.data.id != 0)
						{
							matCategoryVo.defaultProductId = result.data.productid;
						}
					}
					
					if(this.destroyed)
						return;
					chooseDefaultMat();
					
				},null,null)
			}
			else
				chooseDefaultMat();
			
			
		}
		private function chooseDefaultMat():void
		{
			
			for(var i:int=0;i < matCategoryVo.childMatList.length;i++)
			{
				if(matCategoryVo.childMatList[i].prod_code == matCategoryVo.defaultProductId)
				{
					onClickMat(matCategoryVo.childMatList[i]);
					return;
				}
			}
			
			if(matCategoryVo.childMatList.length > 0)
			{
				onClickMat(matCategoryVo.childMatList[0]);
				var params:String = "name=" + matCategoryVo.matclassname + "&categoryid=" + matCategoryVo.nodeId + "&productid=" + matCategoryVo.childMatList[0].prod_code;
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.updateProductCategoryDefault ,null,null,params,"post");
			}
		}
		private function getCatergoryProduct(callback:Function):void
		{
			var selectoutputCenters:Array = PaintOrderModel.instance.getSelectedOutPutCenter();
			
			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProdList + PaintOrderModel.instance.selectAddress.searchZoneid + "&prodCat_name=" + matvo.matclassname + "&manufacturerList=" + selectoutputCenters.toString() + "&customer_code=" + Userdata.instance.founderPhone,this,onGetProductListBack,null,null);
			
			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProdList + PaintOrderModel.instance.selectAddress.zoneid + "&prodCat_name=" + matCategoryVo.matclassname + "&manufacturerList=" + selectoutputCenters.toString() + "&customer_code=" + Userdata.instance.founderPhone,this,function(data:String){
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProdListNew + PaintOrderModel.instance.selectAddress.zoneid + "&prodCatName=" + matCategoryVo.matclassname + "&manufacturerCodeList=" + selectoutputCenters.toString() + "&customerCode=" + Userdata.instance.founderPhone+ "&clientCode=" + Userdata.instance.clientCode,this,function(data:String){
				
				if(this.destroyed)
					return;
				
				var result:Object = JSON.parse(data as String);
				if(!result.hasOwnProperty("status"))
				{
					//var matvo:MatetialClassVo = uiSkin.tablist.array[uiSkin.tablist.selectedIndex] as MatetialClassVo;
					matCategoryVo.childMatList = [];
					//var temp:Array = [];
					var allmaterial:Object = {};
					
					for(var i:int=0;i < result.length;i++)
					{
						if(!allmaterial.hasOwnProperty(result[i].prodCode))
						{
							var proVo:ProductVo = new ProductVo(result[i]);
							proVo.priority = PaintOrderModel.instance.getManuFacturePriority(proVo.manufacturerCode);
							allmaterial[result[i].prodCode] = proVo;
						}
						else
						{
							if(allmaterial[result[i].prodCode].priority > PaintOrderModel.instance.getManuFacturePriority(result[i].manufacturerCode))
							{
								proVo = new ProductVo(result[i]);
								proVo.priority = PaintOrderModel.instance.getManuFacturePriority(proVo.manufacturerCode);
								allmaterial[result[i].prodCode] = proVo;
							}
							else if(result[i].isClientProd)
							{
								proVo = new ProductVo(result[i]);
								allmaterial[result[i].uniqueCode] = proVo;
								
							}
						}						
						
					}
					for(var mate in allmaterial)
						matCategoryVo.childMatList.push(allmaterial[mate]);
					matCategoryVo.childMatList.sort(sortMaterial);
					if(callback)
						callback.call(this);
					
				}
				
				
			},null,null);
		}
		private function sortMaterial(a:ProductVo,b:ProductVo):int
		{
			//var anum:String = a.prod_code;
			//var bnum:String = b.prod_code;
			
			var anum:String = a.materialCode;
			var bnum:String = b.materialCode;
			
			var ano:String = "";
			for(var i:int=0;i < anum.length;i++)
			{
				if(anum.charCodeAt(i) <= 57 && anum.charCodeAt(i) >= 48)
					ano = ano + anum[i];
			}
			var bno:String = "";
			for(var i:int=0;i < bnum.length;i++)
			{
				if(bnum.charCodeAt(i) <= 57 && bnum.charCodeAt(i) >= 48)
					bno = bno + bnum[i];
			}
			
			if(parseInt(ano) <= parseInt(bno))
				return -1;
			else
				return 1;
		}
		
		private function onGetProcessListBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(!result.hasOwnProperty("status"))
			{
				PaintOrderModel.instance.curSelectMat = matvo;
				PaintOrderModel.instance.curSelectMat.procTreeList = new Vector.<ProcessCatVo>();
				for(var i:int=0;i < result.length;i++)
				{
					if(PaintOrderModel.instance.curSelectMat.prodName.indexOf("户内") >=0 && result[i].procCat_Name.indexOf("户外") >= 0)
					{
						ViewManager.showAlert("材料与工艺不匹配");
						//return;
					}
					if(PaintOrderModel.instance.curSelectMat.prodName.indexOf("户外") >=0 && result[i].procCat_Name.indexOf("户内") >= 0)
					{
						ViewManager.showAlert("材料与工艺不匹配");
						//return;
					}
					PaintOrderModel.instance.curSelectMat.procTreeList.push(new ProcessCatVo(result[i]));
				}
				
				EventCenter.instance.event(EventCenter.SHOW_SELECT_TECH);
				//ViewManager.instance.closeView(ViewManager.VIEW_SELECT_MATERIAL);
				
				//ViewManager.instance.openView(ViewManager.VIEW_SELECT_TECHNORLOGY,false);
			}
		}
		public function set ShowSelected(value:Boolean):void
		{
			//this.blackrect.visible = !value;
			//this.redrect.visible = value;
			
		}
		
	}
}