#Include "PROTHEUS.CH"
#Include "OFAGCA05.CH"
/*/{Protheus.doc} OFAGCA05
	VMI - Rotina de Menu que vai gerar/enviar DMS3 de um determinado Pedido ( NF Entrada )

	@author Andre Luis Almeida
	@since  14/05/2021
/*/
Function OFAGCA05()
Local cDMS := "DMS3"
Local aDMS := {"DMS3"}
Local aRet := {"",cDMS}
Local aParamBox := {}
aAdd(aParamBox,{1,RetTitle("F1_DOC"),space(GetSx3Cache("F1_DOC","X3_TAMANHO")),"@!",'FG_Seek("SF1","MV_PAR01",1,.f.)',"SF1",".t.",070,.t.}) // Numero
aAdd(aParamBox,{1,RetTitle("F1_SERIE"),space(GetSx3Cache("F1_SERIE","X3_TAMANHO")),"@!",'FG_Seek("SF1","MV_PAR01+MV_PAR02",1,.f.)',"",".t.",030,.t.}) // Serie
aAdd(aParamBox,{1,RetTitle("F1_FORNECE"),space(GetSx3Cache("F1_FORNECE","X3_TAMANHO")),"@!",'FG_Seek("SF1","MV_PAR01+MV_PAR02+MV_PAR03",1,.f.)',"SA2",".t.",070,.t.}) // Fornecedor
aAdd(aParamBox,{1,RetTitle("F1_LOJA"),space(GetSx3Cache("F1_LOJA","X3_TAMANHO")),"@!",'FG_Seek("SF1","MV_PAR01+MV_PAR02+MV_PAR03+MV_PAR04",1,.f.)',"",".t.",030,.t.}) // Loja
aAdd(aParamBox,{2,STR0002,cDMS,aDMS,40,"",.t.,".t."}) // Interface
If ParamBox(aParamBox, STR0003 ,@aRet,,,,,,,,.F.,.F.) // Geração VMI
	OFAGCA0208_PedidoEspecifico( aRet[1]+aRet[2]+aRet[3]+aRet[4] , aRet[5] ) // ( Numero + Serie + Fornecedor + Loja , Interface do DMS )
EndIf
Return