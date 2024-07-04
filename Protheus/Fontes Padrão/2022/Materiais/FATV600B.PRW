#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FATA600.CH"
#INCLUDE "DBTREE.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} At600CntOk
Valida a consistencia dos itens da proposta para a geracao dos contratos 

@author luiz.jesus
@since 18/03/2014
@version 12
/*/
//-------------------------------------------------------------------
Function At600CntOk(cTpContrt)

Local aArea	:= GetArea()
Local lRet		:= .T.
Local nJ		:= 0
Local nLin		:= 0
Local cAba		:= ""
Local cTipo	:= ""
Local cTES		:= ""

Local oModel	:= FWModelActive()
Local cFolder	:= ""

DbSelectArea('SB1')
SB1->(DbSetOrder(1))
DbSelectArea('SF4')
SF4->(DbSetOrder(1))

For nJ := 1 to 2

	If nJ == 1
		cFolder := 'ADZPRODUTO'
		cAba	:= STR0002 //"Produto(s)"
	Else
		cFolder := 'ADZACESSOR'
		cAba	:= STR0003 //"Acessorio(s)"
	EndIf

	For nLin := 1 to oModel:GetModel(cFolder):Length()
		oModel:GetModel(cFolder):GoLine(nLin)	
		If (oModel:GetModel(cFolder):IsUpdated() .Or. oModel:GetModel(cFolder):IsInserted()) .And. !Empty(oModel:GetModel(cFolder):GetValue("ADZ_PRODUT"))
	
			cTipo	:= oModel:GetModel(cFolder):GetValue("ADZ_TPPROD")
			cTES	:= oModel:GetModel(cFolder):GetValue("ADZ_TES")
		
		//Valida quanto ao tipo de produto 
			If Empty(cTipo)
				Aviso(STR0019, I18N(STR0130 + ' #1 ' + STR0131 + ' #2 ',{cValToChar(nLin),cAba}), {STR0214} ,1 ) //"Por favor, selecione o tipo de produto para o item "###" na aba "				
				lRet := .F.
				Exit
			Else
				SF4->(Dbseek( xFilial("SF4") + cTES ))
			//Valida a TES de acordo com o tipo de cada produto
				Do Case
				//Validacao para produto Kit Basico
				Case cTipo == "1"
					If SF4->F4_DUPLIC <> "S" .OR. SF4->F4_ESTOQUE <> "S"
						Aviso(STR0019, I18N(STR0132 + ' #1 ' + STR0133 + ' #2 ' + STR0134 + STR0135,{cValToChar(nLin),cAba}), {STR0214} ,1 )//"O item "###"aba "###"foi informado como Kit Básico."#" O TES utilizado neste produto deve movimentar estoque e gerar duplicatas."
						lRet := .F.
						Exit
					EndIf
				//Validacao para produto de envio Mensal a cobrar
				Case cTipo == "2"
					//Contrato Pre-Determinado
					If cTpContrt == "2"
						If SF4->F4_DUPLIC <> "S" .OR. SF4->F4_ESTOQUE <> "N"
							Aviso(STR0019, I18N(STR0132 + ' #1 ' + STR0133 + ' #2 ' + STR0136 + STR0137,{cValToChar(nLin),cAba}), {STR0214} ,1 )//"foi informado como Mensal."#" O TES utilizado neste produto deve gerar duplicatas e não movimentar estoque."
							lRet := .F.
							Exit
						EndIf
					//Contrato Fixo
					Else
						If SF4->F4_DUPLIC <> "N" .OR. SF4->F4_ESTOQUE <> "N"
							Aviso(STR0019, I18N(STR0132 + ' #1 ' + STR0133 + ' #2 ' + STR0136 + STR0138,{cValToChar(nLin),cAba}), {STR0214} ,1 ) //" O TES utilizado neste produto não deve gerar duplicatas e nem movimentar estoque."
							lRet := .F.
							Exit
						EndIf
					EndIf
				//Validacao para produto de Demanda
				Case cTipo == "3"
					//Contrato Pre-Determinado
					If cTpContrt == "2"
						If SF4->F4_DUPLIC <> "S" .OR. SF4->F4_ESTOQUE <> "N"
							Aviso(STR0019, I18N(STR0132 + ' #1 ' + STR0133 + ' #2 ' + STR0139 + STR0137,{cValToChar(nLin),cAba}), {STR0214} ,1 )//"foi informado como Demanda."
							lRet := .F.
							Exit
						EndIf
					//Contrato Fixo
					Else
						If SF4->F4_DUPLIC <> "N" .OR. SF4->F4_ESTOQUE <> "N"
							Aviso(STR0019, I18N(STR0132 + ' #1 ' + STR0133 + ' #2 ' + STR0139 + STR0138,{cValToChar(nLin),cAba}), {STR0214} ,1 )
							lRet := .F.
							Exit
						EndIf
					EndIf
					If lRet .AND. SB1->(DbSeek(xFilial("SB1")+oModel:GetModel(cFolder):GetValue("ADZ_PRODUT"))) .AND. Empty(SB1->B1_GRUPO)
						Aviso(STR0019, I18N(STR0140 + ' #1 ' + STR0133 + ' #2 ' + STR0141,{cValToChar(nLin),cAba}), {STR0214} ,1 )
						lRet := .F.
					EndIf
				End Case
			EndIf
		EndIf
	Next nLin

Next nJ

RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At600VdAlo
Valida se o produto esta configurado para alocacao.

@sample		At600VdAlo()

@since		02/04/2014
@version	P12

@return 	cRet, Caracter, Descrição da entidade
/*/
//------------------------------------------------------------------------------
Function At600VdAlo(nPos)
			
Local aArea		:= GetArea()
Local lRetorno	:= Pertence("12")
Local cFolder		:= ""
Local oModel		:= FwModelActive()

Default nPos	:= 0

If nPos == 1
	cFolder := "ADZPRODUTO"
ElseIf nPos ==2
	cFolder := "ADZACESSOR"
EndIf

If lRetorno .And. nPos > 0
	
	If oModel:GetModel(cFolder):GetValue("ADZ_PRDALO")  == "1"
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		
		If DbSeek(xFilial("SB1")+oModel:GetModel(cFolder):GetValue("ADZ_PRODUT"))
			If !(SB1->B1_TIPO == "MO" .AND. SB1->B1_UM == "HR")
				//Problema: Este produto não está configurado para alocação. 		
				//Solucao: Selecione um produto do tipo Mão de Obra (MO) e 
				//com sua unidade de medida configurada como horas (HR).
				lRetorno := .F.
				Help("",1,"AT600ALOC")
			EndIf
		EndIf
		If lRetorno
			If Empty(oModel:GetModel(cFolder):GetValue("ADZ_TPPROD"))
				//Problema: O tipo de produto não foi definido para este item.
				//Solucao: Informe os tipos de produtos: 1-Material Operacional, 2-Mensal, 3-Demanda.                                                                                   
				lRetorno := .F.
				Help("",1,"AT600TPPROD")
			EndIf
		EndIf
	EndIf
	
EndIf

RestArea(aArea)

Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} A600VldPOrc
	
Valida se o produto pode entrar na importação da vistoria tecnica 

@sample	A600VldPOrc()

@since		26/03/2014
@version	P12

/*/
//------------------------------------------------------------------------------
Function A600VldPOrc( cProduto, cVistoria )

Local lRet := .F.
Local aArea := GetArea()

Default cVistoria := ""

TFJ->( DbSetOrder( 2 ) ) //TFJ_FILIAL + TFJ_PROPOS + TFJ_REVIS

If TFJ->( DbSeek( xFilial('TFJ')+ M->ADY_PROPOS + M->ADY_PREVIS ) )

	lRet := TFJ->TFJ_GRPRH == cProduto .Or. ;	
			 TFJ->TFJ_GRPMI == cProduto .Or. ;	
			 TFJ->TFJ_GRPMC == cProduto .Or. ;	
			 TFJ->TFJ_GRPLE == cProduto
		
EndIf

If !lRet .And. !Empty(cVistoria)

	TFJ->( DbSetOrder( 6 ) ) //TFJ_FILIAL + TFJ_CODVIS
	
	If TFJ->( DbSeek( xFilial('TFJ')+cVistoria ) )
	
		lRet := TFJ->TFJ_GRPRH == cProduto .Or. ;	
			 	 TFJ->TFJ_GRPMI == cProduto .Or. ;	
			 	 TFJ->TFJ_GRPMC == cProduto .Or. ;	
			 	 TFJ->TFJ_GRPLE == cProduto
			 
	EndIf  

EndIf 	

RestArea(aArea)

Return(lRet)


