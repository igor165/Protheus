#Include "PROTHEUS.CH"
#Include "OFAGCA06.CH"
/*/{Protheus.doc} OFAGCA06
	VMI - Rotina de Menu que vai gerar/enviar DMS4 de uma determinada Ordem de Serviço

	@author Andre Luis Almeida
	@since  14/05/2021
/*/
Function OFAGCA06()
Local cDMS := "DMS4"
Local aDMS := {"DMS4"}
Local aRet := {"",cDMS}
Local aParamBox := {}
aAdd(aParamBox,{1,STR0001,space(GetSx3Cache("VO1_NUMOSV","X3_TAMANHO")),"@!",'FG_Seek("VO1","MV_PAR01",1,.f.)',"VO1",".t.",070,.t.}) // Ordem de Serviço
aAdd(aParamBox,{2,STR0002,cDMS,aDMS,40,"",.t.,".t."}) // Interface
If ParamBox(aParamBox, STR0003 ,@aRet,,,,,,,,.F.,.F.) // Geração VMI
	OFAGCA0209_OSEspecifica( aRet[1] , aRet[2] ) // ( VO1_NUMOSV , Interface do DMS )
EndIf
Return