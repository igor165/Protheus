#Include "PROTHEUS.CH"
#Include "OFAGCA07.CH"
/*/{Protheus.doc} OFAGCA07
	VMI - Rotina de Menu que vai gerar/enviar DMS4 de um determinado Orçamento

	@author Andre Luis Almeida
	@since  14/05/2021
/*/
Function OFAGCA07()
Local cDMS := "DMS4"
Local aDMS := {"DMS4"}
Local aRet := {"",cDMS}
Local aParamBox := {}
aAdd(aParamBox,{1,STR0001,space(GetSx3Cache("VS1_NUMORC","X3_TAMANHO")),"@!",'FG_Seek("VS1","MV_PAR01",1,.f.)',"VS1ORC",".t.",070,.t.}) // Orçamento
aAdd(aParamBox,{2,STR0002,cDMS,aDMS,40,"",.t.,".t."}) // Interface
If ParamBox(aParamBox, STR0003 ,@aRet,,,,,,,,.F.,.F.) // Geração VMI
	OFAGCA0210_OrcamentoEspecifico( aRet[1] , aRet[2] ) // ( VS1_NUMORC , Interface do DMS )
EndIf
Return