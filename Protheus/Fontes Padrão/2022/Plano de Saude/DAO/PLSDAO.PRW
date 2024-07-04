#INCLUDE "PLSDAO.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MSOBJECT.CH"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Define
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
#DEFINE ___cPLSLog "BA1"
#DEFINE ___cPLSNLg "BX4|BA0|BIM|BIA|BIF|BIJ|BJA|BJS|BCN|BMP|BMB|BMC|BH0"

#DEFINE IDX_FIELD_ID 1 
#DEFINE IDX_FIELD_VALUE 2 
#DEFINE IDX_FIELD_STA 3

#DEFINE IDX_INDEX_IDX 1 
#DEFINE IDX_INDEX_CHAVE 3 

/*/{Protheus.doc} PLSDAO
Persiste obj na base de dados (DAO).

@author Alexander Santos
@since 14/01/2011
@version P11
/*/

Class PLSDAO From PLSCONTR

METHOD New(oObj,aErros) Constructor
METHOD Destroy()

EndClass
//-------------------------------------------------------------------
/*/{Protheus.doc} NEW
Contrutor da classe

@author Alexander Santos
@since 14/01/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD New(oObj,aErros) Class PLSDAO                                              
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Persiste OBJ															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DPCRUD(oObj,Self,aErros)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim do Metodo
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return Self
//-------------------------------------------------------------------
/*/ { Protheus.doc } Destroy
Libera da memoria o obj (Destroy)

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Destroy() Class PLSDAO
FreeObj(Self:self)
Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o	 ЁDPCRUD	ЁAutor  Ё Alexander Santos            Ё Data Ё 03.03.11 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁRotina de gravacao com base no obj modelo.						Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/                   
Static Function DPCRUD(oObj,oSelf,aErros)
LOCAL aArea     := GetArea()
LOCAL nHoraBase := Seconds()
LOCAL nI		:= 0
LOCAL cChave	:= ""
LOCAL lFound	:= .F.
LOCAL cAlias	:= oObj:GetAlias()
LOCAL nOpc 		:= oObj:GetOperation() 
LOCAL nRecno	:= oObj:GetRecno()
LOCAL nIdx		:= oObj:GetIdx()
LOCAL cKey		:= oObj:GetKey()
LOCAL lLog		:= oObj:GetLog()
LOCAL lAltera   := oObj:GetlAltera()
LOCAL aData		:= oObj:GetData()
LOCAL aIndex	:= oObj:GetIndex()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicia o processo de gravacao											 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(cAlias)

	BEGIN TRANSACTION

		Do Case
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Inclusao																 
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	 		Case nOpc==MODEL_OPERATION_INSERT
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Retorna chave de pesquisa												 
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				cChave := DPRetChv(cAlias,aIndex,aData,nIdx,oSelf)
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Seta o Idx																 
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				If (cAlias)->( IndexOrd() ) <> nIdx
					(cAlias)->( DbSetOrder(nIdx) )
				EndIf
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Verifica se ja existe o registro										 
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				lFound := (cAlias)->( MsSeek( xFilial(cAlias)+cChave ) )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Se nao existe inclui se existir altera pois o setAlterar foi acionado 																 
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				If !lFound .Or. (lFound .And. lAltera)

					(cAlias)->( RecLock(cAlias,Iif(lFound,.F.,.T.) ) )
					
						For nI := 1 To Len(aData)
						
							If aData[nI][IDX_FIELD_STA]
								If (cAlias)->(FieldPos(aData[nI][IDX_FIELD_ID])) > 0 
									(cAlias)->( FieldPut( FieldPos(aData[nI][IDX_FIELD_ID]) , aData[nI][IDX_FIELD_VALUE] ) ) 
								EndIf
							EndIf
							
						Next nI
					
					(cAlias)->( MsUnlock() )
				Else
					FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0001+AllToChar( cChave )+"] no alias ["+cAlias+"]" , 0, 0, {}) //"ImpossМvel incluir - Chave duplicada ["
					AaDd(aErros,STR0001+AllToChar( cChave )+STR0002+cAlias+"]") //"ImpossМvel incluir - Chave duplicada ["###"] no alias ["
				EndIf	
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Recno do registro														 
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				oObj:SetRecno( (cAlias)->( Recno() ) )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Log do sistema															 
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				If lLog
					DPLogReg(cAlias,nOpc,aData,oSelf)
				EndIf	
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Alteracao																 
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	 		Case nOpc==MODEL_OPERATION_UPDATE
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Posiciona no registro													 
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				If Empty(cKey)
					(cAlias)->( MsGoto( nRecno ) )
					lFound := !(cAlias)->( Eof() )
				Else
					lFound := DPFindKey(cAlias,nIdx,cKey)				
	        	EndIf
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Se encontrado
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				If lFound
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//Ё Log do sistema															 
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					If lLog
						DPLogReg(cAlias,nOpc,aData,oSelf)
					EndIf	
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//Ё Alteracao																 
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					(cAlias)->( RecLock(cAlias, .F.) )
					
						For nI := 1 To Len(aData)
						
							If aData[nI][IDX_FIELD_STA]
								If (cAlias)->(FieldPos(aData[nI][IDX_FIELD_ID])) > 0 
									(cAlias)->( FieldPut( FieldPos(aData[nI][IDX_FIELD_ID]) , aData[nI][IDX_FIELD_VALUE] ) ) 
								EndIf
							EndIf
							
						Next nI
					
					(cAlias)->( MsUnlock() )
				Else
					FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0003+cAlias+"]" , 0, 0, {}) //"ImpossМvel Alterar - Registro nЦo encontrado no alias ["
					AaDd(aErros,STR0003+cAlias+"]") //"ImpossМvel Alterar - Registro nЦo encontrado no alias ["
				EndIf	
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд 
			//Ё Exclucao																 
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			Case nOpc==MODEL_OPERATION_DELETE
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Posiciona no registro													 
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				If Empty(cKey)
					(cAlias)->( MsGoto( nRecno ) )
					lFound := !(cAlias)->( Eof() )
				Else
					lFound := DPFindKey(cAlias,nIdx,cKey)				
	        	EndIf
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Se encontrado
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				If lFound
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//Ё Deleta																	 
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					(cAlias)->( RecLock(cAlias, .F. ) )
						(cAlias)->( DbDelete() )
					(cAlias)->( MsUnlock() )
				Else
					FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0004+cAlias+"]" , 0, 0, {}) //"ImpossМvel Exclui - Registro nЦo encontrado no alias ["
					AaDd(aErros,STR0004+cAlias+"]") //"ImpossМvel Exclui - Registro nЦo encontrado no alias ["
				EndIf	
				
			EndCase
		
	END TRANSACTION

EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Restaura area															 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
RestArea( aArea )                   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё DuraГЦo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oSelf:SetLog(nHoraBase)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim do metodo															 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o	 ЁDPFindKey ЁAutor  Ё Alexander Santos            Ё Data Ё 03.03.11 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁPosiciona na chave informada										Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/                   
Static Function DPFindKey(cAlias,nIdx,cKey)
LOCAL lFound := .F.
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se o indice existe
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If !SIX->( DbSeek(cAlias+cValToChar(nIdx),.F.) )
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0008 + cValToChar(nIdx) + STR0009 + cAlias + "]" , 0, 0, {}) //"O indice ["##"] nЦo existe no alias ["
	Return(.F.)
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Posiciona no registro													 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If (cAlias)->( IndexOrd() ) <> nIdx
	(cAlias)->( DbSetOrder(nIdx) )
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se ja existe o registro										 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
lFound := (cAlias)->( MsSeek( xFilial(cAlias)+cKey ) )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(lFound)
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o	 ЁDPLogReg  ЁAutor  Ё Alexander Santos            Ё Data Ё 03.03.11 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁRotina de log de campo com base no obj							Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/                   
Static Function DPLogReg(cAlias,nOpc,aData,oSelf)
LOCAL aArea     	:= GetArea()
LOCAL nHoraBase 	:= Seconds()
LOCAL nI			:= 0          
LOCAL cType			:= ""
LOCAL cSeq			:= ""
LOCAL cNomCam		:= ""
LOCAL cCodOpe 		:= Iif( cAlias $ ___cPLSNLg,"    ",PLSINTPAD() )
LOCAL bVldOpeGrv	:= { || .F. }
LOCAL lLogGrv		:= .F.
DEFAULT aData 	:= {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё CodeBlock para validacao do log de campo								 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == MODEL_OPERATION_INSERT
	bVldOpeGrv := { || BIQ->BIQ_INCLUI == "1" }
ElseIf nOpc == MODEL_OPERATION_UPDATE
	bVldOpeGrv := { || BIQ->BIQ_ALTERA == "1" }
ElseIf nOpc == MODEL_OPERATION_DELETE
	bVldOpeGrv := { || BIQ->BIQ_EXCLUS == "1" }
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se o log de campo esta ligado									 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BIQ->( DbSetOrder(1) )
lLogGrv := ( cAlias $ ___cPLSLog ) .Or. ( BIQ->( MsSeek( xFilial("BIQ")+cCodOpe+cAlias ) ) .And. Eval(bVldOpeGrv) )

If lLogGrv
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Nova Sequencia															 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cSeq := PLBX1NEW()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Log de Inclusao ou Alteracao...                                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BX1->( RecLock("BX1",.T.) )
		BX1->BX1_FILIAL   := xFilial("BX1")
		BX1->BX1_SEQUEN   := cSeq
		BX1->BX1_ALIAS    := cAlias
		BX1->BX1_RECNO    := StrZero( &(cAlias+"->(Recno())") ,Len(BX1->BX1_RECNO))
		
		If nOpc == MODEL_OPERATION_INSERT
			BX1->BX1_TIPO := "I"
		ElseIf nOpc == MODEL_OPERATION_UPDATE
			BX1->BX1_TIPO := "A"
		ElseIf nOpc == MODEL_OPERATION_DELETE
			BX1->BX1_TIPO := "E"
		EndIf
		
		BX1->BX1_USUARI   := Upper(PLRETOPE())
		BX1->BX1_DATA     := Date()
		BX1->BX1_HORA     := Time()
		BX1->BX1_ESTTRB   := GetComputerName()
		
		If BX1->(FieldPos("BX1_ROTINA")) > 0
			BX1->BX1_ROTINA := FunName()
		EndIf
	BX1->( MsUnLock() )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Log de Alteracao campos													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nOpc == MODEL_OPERATION_UPDATE
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Campos 																	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For nI := 1 To Len(aData)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Somente campos alterados												 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If !aData[nI][IDX_FIELD_STA]
				Loop
			EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Nome do Campo															 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cNomCam := aData[nI,IDX_FIELD_ID]
	        cType   := ValType(cNomCam)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica tipo de dado													 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Do Case
				Case cType == "C"
					cContOld := (cAlias)->&cNomCam
					cContNew := aData[nI,IDX_FIELD_VALUE]
				Case cType == "N"
					cContOld := AllTrim( Str( (cAlias)->&cNomCam ,17,4 ) )
					cContNew := AllTrim( Str( aData[nI,IDX_FIELD_VALUE],17,4 ) )
				Case cType == "D"
					cContOld := DtoC( (cAlias)->&cNomCam )
					cContNew := DtoC(aData[nI,IDX_FIELD_VALUE])
			EndCase
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Gravacao																 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If cContOld <> cContNew
			
				BX2->( RecLock("BX2",.T.) )
					BX2->BX2_FILIAL   := xFilial("BX2")
					BX2->BX2_SEQUEN   := BX1->BX1_SEQUEN
					BX2->BX2_CAMPO    := AllTrim(cNomCam)
					BX2->BX2_TITULO   := Posicione("SX3",2,AllTrim(cNomCam),"X3_TITULO")
					BX2->BX2_ANTVAL   := cContOld
					BX2->BX2_NOVVAL   := cContNew
				BX2->( MsUnLock() )
				
			EndIf	
		Next
	EndIf
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Restaura area															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
RestArea( aArea )                   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё DuraГЦo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oSelf:SetLog(nHoraBase)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o	 ЁDPRetChv  ЁAutor  Ё Alexander Santos            Ё Data Ё 03.03.11 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁRetorna chave de pesquisa com base no idx unico ou da aindex		Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/                   
Static Function DPRetChv(cAlias,aIndex,aData,nIdx,oSelf)
LOCAL nHoraBase := Seconds()
LOCAL nI, nX 	:= 0
LOCAL nPos		:= 0                                       
LOCAL nTamCampo	:= 0
LOCAL cChave 	:= ""
LOCAL cConteudo	:= ""
LOCAL aRet		:= {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta a chave de pesquisa com base na matriz de index					 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nI:=1 To Len(aIndex)
	// devido a release 25 com dicionario no banco a funГЦo FWFormStruct(PLSSTRUC) nЦo utilizar mais
	// a primeira posiГЦo do array aIndex, trocamos para utilizar a segunda, necessario cValToChar pois
	// todas as chamadas passam o nIdx como numИrico
	// If aIndex[nI,IDX_INDEX_IDX] == nIdx	
	If aIndex[nI,2] == cValToChar(nIdx)
			
		aRet := oSelf:Split("+", StrTran( StrTran( StrTran( StrTran( Upper(AllTrim(aIndex[nI,3] ) ),'DTOS',''), ')','' ),'(',''),'DTOS','') )
		
		For nX:=1 To Len(aRet)
			If ( nPos := Ascan(aData,{ |x| x[IDX_FIELD_ID] == aRet[nX]}) ) > 0 .And. aData[nPos,IDX_FIELD_STA] .And. At("_FILIAL",aData[nPos,IDX_FIELD_ID]) == 0

				nTamCampo := TamSx3( aData[nPos,IDX_FIELD_ID])[1]
				
				If ValType(aData[nPos,IDX_FIELD_VALUE]) == 'D'
					cConteudo := AllTrim( DtoS( aData[nPos,IDX_FIELD_VALUE] ) )
					cChave    += cConteudo + Space( nTamCampo - Len(cConteudo) )
				Else          
					cConteudo := AllTrim( cValToChar( aData[nPos,IDX_FIELD_VALUE] ) )						
					cChave 	  += cConteudo + Space( nTamCampo - Len(cConteudo) )
				EndIf	
			EndIf
		Next
		
	EndIf
	
Next         
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Erro																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(cChave)
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0005+AllToChar( nIdx )+STR0006+cAlias+STR0007 , 0, 0, {}) //"ImpossМvel criar chave com o IDX ["###"] do alias ["###"] informado"
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё DuraГЦo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oSelf:SetLog(nHoraBase)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Funcao															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(cChave)
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPLSDAO    Ё Autor Ё Totvs				    Ё Data Ё 30/03/10 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Somente para compilar a class							  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSDAO
Return
