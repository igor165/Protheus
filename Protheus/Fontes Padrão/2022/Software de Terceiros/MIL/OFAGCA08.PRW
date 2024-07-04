#Include "PROTHEUS.CH"
#Include "OFAGCA08.CH"
/*/{Protheus.doc} OFAGCA08
	VMI - Rotina de Menu que vai gerar/enviar DMS6 de um determinado Cliente

	@author Andre Luis Almeida
	@since  14/05/2021
/*/
Function OFAGCA08()
Local cDMS := "DMS6"
Local aDMS := {"DMS6"}
Local aRet := {"","",cDMS}
Local aParamBox := {}
aAdd(aParamBox,{1,STR0001,space(GetSx3Cache("A1_COD","X3_TAMANHO")),"@!",'FG_Seek("SA1","MV_PAR01",1,.f.)',"SA1",".t.",070,.t.}) // Código do Cliente
aAdd(aParamBox,{1,STR0002,space(GetSx3Cache("A1_LOJA","X3_TAMANHO")),"@!",'FG_Seek("SA1","MV_PAR01+MV_PAR02",1,.f.)',"",".t.",040,.t.}) // Loja do Cliente
aAdd(aParamBox,{2,STR0003,cDMS,aDMS,40,"",.t.,".t."}) // Interface
If ParamBox(aParamBox, STR0004 ,@aRet,,,,,,,,.F.,.F.) // Geração VMI
	OFAGCA0211_ClienteEspecifico( aRet[1]+aRet[2] , aRet[3] ) // ( A1_COD+A1_LOJA , Interface do DMS )
EndIf
Return