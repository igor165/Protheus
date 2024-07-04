#include 'protheus.ch'
#include 'parmtype.ch'

user function ValEstTes()
	local lret:=	.T.
	Local aArea := GetArea()

	IF SB1->B1_X_PRDES=='1'
		IF SF4->F4_ESTOQUE=='N'
			//lret:= .F.
			Alert('Verificar divergencia entre a TES e Cadastro de Produto. Este Produto está definido como ESTOCAVEL e a TES está definida para DESPESA.')
		EndIf
    EndIf

	DBSELECTAREA( "SBM" )
	SBM->(DBSETORDER( 1 )) //BM_FILIAL+BM_GRUPO
	SBM->(DBSEEK( FwxFilial("SBM")+SB1->B1_GRUPO))
		IF SBM->BM_ATVFIX == 'S'
			IF SF4->F4_ATUATF == 'N'
				lret:= .F.
				Alert('Produto do Grupo de Imobilizado Usando TES que não gera imobilizado, favor verificar.')
			EndIf
		EndIf
	SBM->(DBCLOSEAREA(  ))

	RestArea(aArea)
return lret
