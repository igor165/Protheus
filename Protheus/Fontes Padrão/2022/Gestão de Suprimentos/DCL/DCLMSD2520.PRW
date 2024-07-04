#include "rwmake.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} DCLMSD2520
Ponto Entrada Exclusao Nota Venda  
Estorna Mov. Interna para produtos com opcao de requisita igual a "S"

@author Totvs
@since 07/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function DCLMSD2520()
Local _nModulo
Local _aArea		:= GetArea()
Local aAreaDH5	:= DH5->(GetArea())
Local cNumOp		:= ""

Private lMsErroAuto := .F.

DH5->(DbSetOrder(1))

If AllTrim(SuperGetMV("MV_REQAUTO")) == "S" .AND. SF4->F4_ESTOQUE == 'S'
	If DH5->(DbSeek(xFilial("DH5") + SB1->B1_COD)) .And. DH5->DH5_PREQUI == "S"

		SaveInter() // Salva variaveis publicas
	
		cNumOp := Left(If(Empty(SD2->D2_OP),SD2->D2_DOC,SD2->D2_OP),6)
	
	    _nModulo := nModulo 
	    nModulo  := 4 
		//estorna producao
		aVetor:={{"D3_OP",cNumOp+SD2->D2_ITEM+"001  ",NIL},;
				{"D3_COD",SD2->D2_COD,NIL},;
				{"D3_LOCAL",SD2->D2_LOCAL,NIL}}
		MSExecAuto({|x,y| mata250(x,y)},aVetor,5)
		If lMsErroAuto
			MOSTRAERRO()
			Aviso(OemToAnsi("Aviso - DCL"),OemToAnsi("A Exclusão do Documento de Saída não será concluida devido aos erros apresentados."),{"Ok"})
			lContDCL := .F.
			Return()
		Endif
		
		//exclusao da ordem de produçao
		aVetor1:={{"C2_ITEM",SD2->D2_ITEM,NIL},;
				{"C2_NUM",cNumOp,NIL},;
				{"C2_PRODUTO",SD2->D2_COD,NIL},;
				{"C2_LOCAL",SD2->D2_LOCAL,NIL}}
		MSExecAuto({|x,y| mata650(x,y)},aVetor1,5)
		If lMsErroAuto
			MOSTRAERRO()
			Aviso(OemToAnsi("Aviso - DCL"),OemToAnsi("A Exclusão do Documento de Saída não será concluida devido aos erros apresentados."),{"Ok"})
			lContDCL := .F.
			Return()
		Endif
		
		nModulo := _nModulo 
	
		RestInter()//Recupera as variáveis públicas
	EndIf
EndIf

// Produtos sem estoque , estorna movimentos provisórios de entrada no caso da exclusão da nota fiscal de saida.
IF DH5->(DBSEEK(XFILIAL('DH5')+SD2->D2_COD))
	IF DH5->DH5_PREQUI == "S"
		SG1->(DbSetOrder(5))//G1_FILIAL+G1_COD+DTOS(G1_FIM)+G1_TRT
		SG1->(DbSeek(xFilial() + SD2->D2_COD + DTOS(SD2->D2_EMISSAO),.T.))
		dFim := SG1->G1_FIM
		WHILE SD2->D2_COD == SG1->G1_COD .AND. ! SG1->(EOF()) .AND. dFim == SG1->G1_FIM
			IF ALLTRIM(SG1->G1_COMP) $ SUPERGETMV('MV_ESTZERO',.F.,'  ') .AND. SF4->F4_ESTOQUE == 'S'
				lContDCL := EstornaDCL(SF2->(F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE)+SD2->D2_ITEM , 2)
			ENDIF
			SG1->(DBSKIP())
		ENDDO
	ELSE
		IF ALLTRIM(SD2->D2_COD) $ SUPERGETMV('MV_ESTZERO',.F.,'  ') .AND. SF4->F4_ESTOQUE == 'S'
			lContDCL := EstornaDCL(SF2->(F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE)+SD2->D2_ITEM , 2)
		ENDIF
	ENDIF
ENDIF

//Deleta o Complemento dos Itens da Nota de Saída DCL
Dcl2520Delete()

RestArea(_aArea)
RestArea(aAreaDH5)

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} Dcl2520Delete
//Deleta o Complemento dos Itens da Nota de Saída DCL
@return   Nil

@author   José Eulálio
@since    13.04.2017
@version  P12
/*/
//-------------------------------------------------------------------
Static Function Dcl2520Delete()

DH3->(DbSetOrder(1)) //DH3_FILIAL+DH3_DOCD2+DH3_SERIE+DH3_CLIENT+DH3_LOJA+DH3_ITEM
If DH3->(DbSeek(xFilial("DH3") + SD2->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_ITEM)))
	RecLock("DH3",.F.)
	DH3->(DbDelete())	
	MsUnLock()
EndIf

Return
