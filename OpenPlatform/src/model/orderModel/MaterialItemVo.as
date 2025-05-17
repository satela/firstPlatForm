package model.orderModel
{
	import model.HttpRequestUtil;
	import model.picmanagerModel.PicInfoVo;
	
	import script.order.PicOrderItem;
	
	import utils.UtilTool;

	public class MaterialItemVo
	{
		public var procCode:String = "";// 前置工艺编码
		public var procName:String= "";// 前置工艺名称
		public var attachmentList:Array = [];//  前置工艺附件类型
		public var preProc_Price: Number = 0;//  前置工艺价格

		public var baseprice: Number = 0;//  底价

		public var nextProcRequired:int = 0;// 后置工艺是否必选
		public var measure_unit:String = "";//计价单位
		public var procLvl:int = 0;//工艺层级
		
		public var accessoryConditionList:Array;
		public var constraintList:Array;
		public var fileTupleList:Array;
		public var procConditionList:Array;
		
		//public var is_startProc:int = 0;//是否起始工艺
		//public var is_endProc:int = 0;//是否结束工艺

		private var _nextMatList:Vector.<MaterialItemVo>;
		
		private var _selected:Boolean = false;
		
		public var attchMentFileId:String = "";
		
		//附件的文件id
		public var attchFileId:String = "";
		
		public var has_discount:Boolean = true;//是否参与阶梯价格折扣
		
		public var unit_capacity:Number = 0;//正常产能
		public var unit_urgentCapacity:Number = 0;
		public var cap_uit:String = "";

		public var attachList:Array;
		public var selectAttachVoList:Vector.<AttchCatVo>;//选择的配件
		
		public var picInfoVo:PicInfoVo;//异形切割工艺计价需要图片信息
		public var hasFinishChoose:Boolean = false;//是否已经选好工艺流
		
		public var belognproductVo:ProductVo;
		public var picorderItem:PicOrderItem;

		public var finalNextMaterialList:Vector.<MaterialItemVo>;
		
		public var parentMaterialVo:MaterialItemVo;
		
		public var procImage:String;
		
		public var showType:String = ConstraintTool.RESULT_VALUE_NORMAL;//显示状态  1：隐藏 2 ：冻结 3：必须 4：正常显示
		
		public function MaterialItemVo(data:Object)
		{
			if(data != null)
			{
				for(var key in data)
				{
					if(this.hasOwnProperty(key))
						this[key] = data[key];
				}
				var nextpro:Array = data.children;
				_nextMatList = new Vector.<MaterialItemVo>();

				//trace(preProc_Name + "," + preProc_attachmentTypeList);
				
//				var priceInfo:Array = PaintOrderModel.instance.getProcePriceUnit(PaintOrderModel.instance.curSelectMat.manufacturer_code,this.preProc_Code);
//				if(priceInfo != null && priceInfo.length == 2)
//				{
//					this.measure_unit = priceInfo[0];
//					this.preProc_Price = priceInfo[1];
//				}

				if(nextpro && nextpro.length > 0)
				{
					for(var i:int=0;i < nextpro.length;i++)
					{
					
						var child:MaterialItemVo = new MaterialItemVo(nextpro[i]);
						child.parentMaterialVo = this;
						_nextMatList.push(child);
//						if(PaintOrderModel.instance.getProcDataByProcName(nextpro[i].postProc_name) != null)
//						{
//							_nextMatList.push(new MaterialItemVo(PaintOrderModel.instance.getProcDataByProcName(nextpro[i].postProc_name)));
//						}
//						else
//						{
//							var matvo:MaterialItemVo = new MaterialItemVo({});
//							matvo.nextProcRequired = 0;
//							matvo.attachmentList = nextpro[i].preProc_attachmentTypeList;
//							matvo.procCode =  nextpro[i].postProc_code;
//							matvo.procName = nextpro[i].postProc_name;
//							matvo.procLvl = 2;
//							matvo.preProc_Price = nextpro[i].postProc_price;
//							matvo.measure_unit = nextpro[i].measure_unit;
//							_nextMatList.push(matvo);
//												
//
//						}
					}
				}
			}
		}
		
		
		public function cloneData(product:ProductVo,picorder:PicOrderItem):MaterialItemVo
		{
//			hasFinishChoose = true;
//			belognproductVo = product;
//			picorderItem = picorder;
			
			var materialvo:MaterialItemVo = new MaterialItemVo(null);
						
			for(var key in this)
			{
				materialvo[key] = this[key];
			}
			
			materialvo.hasFinishChoose = true;
			materialvo.belognproductVo = product;
			materialvo.picorderItem = picorder;
			
			var nextmat:Vector.<MaterialItemVo> = new Vector.<MaterialItemVo>();
			for(var i:int=0;i < _nextMatList.length;i++)
			{
				nextmat.push(_nextMatList[i].cloneData(product,picorder));
			}
			materialvo._nextMatList = nextmat;

			if(this.selectAttachVoList != null)
			{
				var selctAttach:Vector.<AttchCatVo> = new Vector.<AttchCatVo>();
				for(var i:int=0;i < selectAttachVoList.length;i++)
				{
					selctAttach.push(selectAttachVoList[i].cloneData());
				}
				materialvo.selectAttachVoList = selctAttach;
			}

			return materialvo;
		}
		
		
		public function get nextMatList():Vector.<MaterialItemVo>
		{
			
			
			//var curselectProduct:ProductVo = PaintOrderModel.instance.curSelectMat;
						
			var curSelectPic:PicOrderItem = PaintOrderModel.instance.curSelectOrderItem;
			
			if(hasFinishChoose)
			{
				//curselectProduct = belognproductVo;
				curSelectPic = picorderItem;
				
			}
			var allpics:Vector.<PicOrderItem> = new Vector.<PicOrderItem>();
			if(curSelectPic != null)
				allpics.push(curSelectPic);
			else
				allpics = PaintOrderModel.instance.batchChangeMatItems;
			var hasGaoqingPenhui:Boolean = false;//高清喷绘3.2米不计算留白尺寸
			
			var allselectProc:Array = [];
			var materialItemVo:MaterialItemVo = this;
			allselectProc.push(materialItemVo);
			while(materialItemVo.parentMaterialVo != null)
			{
				if(materialItemVo.parentMaterialVo.selected)
					allselectProc.push(materialItemVo.parentMaterialVo);
				materialItemVo = materialItemVo.parentMaterialVo;
			}
			for(var i:int=0;i < allselectProc.length;i++)
			{
				if(allselectProc[i].procCode == "SPTE11160")
				{
					hasGaoqingPenhui = true;
					break;
				}
			}
			//if(curselectProduct != null && allpics.length > 0)			
			if(allpics != null && allpics.length > 0)
			{				
				
				if(this._nextMatList.length > 0)
				{
					var vec:Vector.<MaterialItemVo> = new Vector.<MaterialItemVo>();
					vec.push(this);
					var border:Number = UtilTool.getBorderDistance(vec);
					
					for(var j:int=0;j < this._nextMatList.length;j++)
					{
							var showtype:String = ConstraintTool.RESULT_VALUE_HIDE;
							for(var i:int=0;i < allpics.length;i++)
							{
								
								
								if(hasGaoqingPenhui)
								{
									
									border = 0;
								}
	//							if(allpics[i].finalWidth + border > curselectProduct.materialWidth && allpics[i].finalHeight + border > curselectProduct.materialWidth)
	//							{
	//								hasBeyongd = true;
	//								break;
	//							}
								var tempType:String = ConstraintTool.procShowType(this._nextMatList[j].accessoryConditionList,this._nextMatList[j].constraintList,this._nextMatList[j].procConditionList,allpics[i],allselectProc,border);
								if(showtype != ConstraintTool.RESULT_VALUE_NORMAL)
									showtype = tempType;
							}
							
							this._nextMatList[j].showType = showtype;
							if(showtype == ConstraintTool.RESULT_VALUE_HIDE)
							{
								//hasBeyongd = true;
								return this._nextMatList[j].nextMatList
								//break;
							}
								
						}
						//if(showType == ConstraintTool.RESULT_VALUE_HIDE)
						//	return this._nextMatList;
						
						return this._nextMatList;
										
				}
			}
			
			return this._nextMatList;
			
			
		}
		private function onAccCatlistBack(data:String):void
		{
			var result:Object = JSON.parse(data as String);
			if(!result.hasOwnProperty("status"))
			{
				if(result[0] != null)
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.GetAccessorylist + "manufacturer_code=" + PaintOrderModel.instance.curSelectMat.manufacturerCode + "&accessoryCat_name=" + result[0].accessoryCat_Name,this,onGetAccessorylistBack,null,null);

			}
		}
		
		private function onGetAccessorylistBack(data:String):void
		{
			var result:Array = JSON.parse(data as String) as Array;
			if(result)
			{
				attachList = [];
				for(var i:int=0;i < result.length;i++)
				{
					var attachVo:AttchCatVo = new AttchCatVo(result[i]);
					attachVo.materialItemVo = this;
					attachList.push(attachVo);
				}
			}
			
		}
		
		public function set selected(sel:Boolean):void
		{
			if(parentMaterialVo != null && sel)
			{
				for(var i:int=0;i < parentMaterialVo.nextMatList.length;i++)
				{
					parentMaterialVo.nextMatList[i].selected = false;
				}
			}
			_selected = sel;

		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		public function resetData():void
		{
			selected = false;
			attchMentFileId = "";
			attchFileId = "";
			if(nextMatList != null)
			{
				for(var i:int=0;i < nextMatList.length;i++)
				{
					nextMatList[i].resetData();
				}
			}
		}
	}
}