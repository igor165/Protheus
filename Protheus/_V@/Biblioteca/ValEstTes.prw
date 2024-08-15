#include 'protheus.ch'
#include 'parmtype.ch'

//Valida��o do Campo D1_TES na rotina MATA103
user function ValEstTes()
	local lret:=	.T.
	Local aArea := GetArea()

	DBSELECTAREA( "SBM" )
	SBM->(DBSETORDER( 1 )) //BM_FILIAL+BM_GRUPO
	SBM->(DBSEEK( FwxFilial("SBM")+SB1->B1_GRUPO))

	IF SD1->D1_VUNIT > 1200 .and. SF4->F4_ATUATF = 'S' .and. SBM->BM_XTIPOP <> 'I'
		lRet := .F.
		Alert('Verificar Classifica��o adequada. Produto com valor acima de 1.200, utilizando tes para gerar Ativo Fixo com C�digo de Produto de�uso�e�consumo.')
	ENDIF

	IF lRet .and. SB1->B1_X_PRDES=='1' .and. SF4->F4_ESTOQUE=='N'
		//lret:= .F.
		Alert('Verificar divergencia entre a TES e Cadastro de Produto. Este Produto est� definido como ESTOCAVEL e a TES est� definida para DESPESA.')
    EndIf

	//IF lRet .and. SBM->BM_ATVFIX == 'S' .AND. SF4->F4_ATUATF == 'N'
	//	lret:= .F.
	//	Alert('Produto do Grupo de Imobilizado Usando TES que n�o gera imobilizado,�favor�verificar.')
	//EndIf
	
	SBM->(DBCLOSEAREA(  ))

	RestArea(aArea)
return lret
//Valida��o do Campo D1_CC na rotina MATA103
user function VldCCD1()
	local lret:=	.T.
	Local aArea := GetArea()

	DBSELECTAREA( "SBM" )
	SBM->(DBSETORDER( 1 )) //BM_FILIAL+BM_GRUPO
	SBM->(DBSEEK( FwxFilial("SBM")+SB1->B1_GRUPO))
	
	IF Empty(SD1->D1_TES)
		lRet := .F.
		Alert('INFORME O CAMPO TES ANTES DE INFORMAR O CENTRO DE CUSTO!')
	ENDIF
	
	IF lRet .and. SF4->F4_ATUATF = 'S' .AND. SBM->BM_XTIPOP  == 'I' .AND. CTT->CTT_XDPTO == '6' // (OBRA EM ANDAMENTO)
		lRet := .F.
		Alert('TES E PRODUTO DEFINIDAS PARA GERAR UM ATIVO A CLASSIFICAR UTILIZANDO CENTRO DE CUSTOS DE OBRAS EM ANDAMENTO, INFORMAR O CENTRO DE CUSTOS DO BEM')
	ENDIF

	IF lRet .and. SF4->F4_ATUATF = 'S' .AND. SBM->BM_XTIPOP <> 'I' .AND. SF4->F4_ESTOQUE = 'N'
		lret:= .F.
		Alert('INCONSISTENCIA NO LAN�AMENTO. A TES UTILIZADA GERA UM IMOBILIZADO A CLASSIFICAR E O PRODUTO N�O PERTENCE AO GURPO DE PRODUTOS DE IMOBILIZADO.')
    EndIf

	IF lRet .and. SF4->F4_ATUATF = 'N' .AND. SBM->BM_XTIPOP == 'I' .AND. SF4->F4_ESTOQUE = 'N'
		lret:= .F.
		Alert('INCONSISTENCIA NO LAN�AMENTO - PRODUTO IMOBILIZADO UTILIZANDO TES DE DESPESA, REVISAR CLASSIFICA��O.')
	EndIf

	IF lRet .and. SD1->D1_VUNIT > 1200 .AND. SF4->F4_ATUATF == "N" .AND. SBM->BM_XTIPOP == "C" .AND. SF4->F4_ESTOQUE = "N"
		IF !MsgYesNo("Produto Possui Valor adequado para classifica��o como ATIVO IMOBILIZADO, Confirma a classifica��o�para�Despesa�?")
			lret:= .F.
		EndIf
	EndIf
	
	SBM->(DBCLOSEAREA(  ))

	RestArea(aArea)
return lret
