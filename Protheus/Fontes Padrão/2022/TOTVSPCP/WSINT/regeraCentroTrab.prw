#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

wsrestful workCenter description "Busca centro de trabalho"

	wsdata codCelErp as int
	wsdata estab as char
	
	wsmethod get description "Fluxo de Produção" wssyntax "/workCenter"
end wsrestful

wsmethod get wsreceive codCelErp, estab wsservice workCenter 
	local listaCtProduc := {} 
	local empFilial := {}
	
	DEFAULT self:codCelErp := nil, self:estab := nil
	If self:estab == nil ;
		.or. ;
		self:codCelErp == nil 
	
		::SetContentType("application/json")	 
		::SetResponse(FWJsonSerialize(listaCtProduc,.F.,.F.))
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
	
	listaCtProduc := getCTByCel(self:codCelErp)
	::SetContentType("application/json")	 
	::SetResponse(FWJsonSerialize(listaCtProduc,.F.,.F.))	
Return .T.