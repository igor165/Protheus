#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

class itemFabric
	data cod_chave_erp
	data des_item_erp
	data cod_refer
	data cod_un_med_erp
	Method New()
endclass

Method New() class itemFabric
	self:cod_chave_erp  := AllTrim(SB1->B1_COD)
	self:des_item_erp   := AllTrim(SB1->B1_DESC)
	self:cod_refer      := ""
	self:cod_un_med_erp := AllTrim(SB1->B1_UM)	
return	

WSRESTFUL producedItem DESCRIPTION "Zoom de itens pro Ekanban"
	 
	WSDATA estab AS char
	WSDATA datCorte AS char	
	WSDATA zoomItem AS char
	 
	WSMETHOD GET DESCRIPTION "Itens fabricados" WSSYNTAX "/producedItem"
 
END WSRESTFUL
 
WSMETHOD GET WSRECEIVE estab, zoomItem WSSERVICE producedItem

	Local itemList := {}
	Local empFilial := {}

	DEFAULT self:estab := nil, self:zoomItem := nil
	If self:estab == nil ;
		.or. ;
		self:zoomItem == nil 

		::SetContentType("application/json")	 
		::SetResponse(FWJsonSerialize(itemList,.F.,.F.))
		return .T.
	endif

	OpenSM0()
	SM0->(dbGotop())
	
	//Grupo de Empresa
	aAdd(empFilial,SubStr(self:estab,1,Len(SM0->M0_CODIGO)))
	//Empresa + Unidade de negocio + Filial
	aAdd(empFilial,SubStr(self:estab,2 + Len(SM0->M0_CODIGO) ))

	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv(empFilial[1], empFilial[2])
	
	dbSelectArea("SB1")
	SB1->(dbGoTop())
	while SB1->(! EoF())
		if SB1->B1_COD != "MOD" ;
			.and. ;
			(Upper(self:zoomItem) $ Upper(SB1->B1_COD) .Or. Upper(self:zoomItem) $ Upper(SB1->B1_DESC) ) ;
		 	.and. ;		
			itemIsManufactured(SB1->B1_COD)
			
			aadd(itemList, itemFabric():New())
		endif
		SB1->(dbSkip())
	end
	 
	::SetContentType("application/json")	 
	::SetResponse(FWJsonSerialize(itemList,.F.,.F.))
Return .T.

static function itemIsManufactured(cod_item)
	dbSelectArea("SG1")
	dbSetOrder(1)
	dbseek(xFilial("SG1") + cod_item)
	
	while SG1->(! Eof()) ; 
				.and. ;
				 SG1->G1_filial == xFilial("SG1") ;
				 .and. ;
				 sg1->g1_cod == cod_item
				 
		return .T.

		SG1->(dbskip())				 
	end
	
return .F.
