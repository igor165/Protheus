#INCLUDE "JURA106C.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA106C
Follow-ups
Verificação de rotinas relacionadas a inclusão/ alteração / exclusão
de follow-ups automáticos ou de intervenção de usuário

@author Juliana Iwayama Velho
@since 14/10/09
@version 1.0
/*/

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106GFLWP
Rotina para inclusão de follow-ups por intervenção do usuário ou automático

@param cAssJur   - Código do assunto jurídico
@param cCodFw    - Código do follow-up
@param dDtFw     - Data do follow-up
@param cTipoFw   - Tipo de follow-up
@param cFwPai    - Código do follow-up pai
@param lDtProxEv - Se a data vem do campo prox evento

@author Juliana Iwayama Velho
@since 10/10/09
@version 1.0

@obs NTAMASTER - Dados do Follow-ups
@obs NTEDETAIL - Responsáveis

/*/
//-------------------------------------------------------------------
Function JA106GFLWP(cAssJur, cCodFw, dDtFw , cTipoFw, cFwPai, lDtProxEv)
Local aArea      := GetArea()
Local aAreaNRT   := NRT->( GetArea() )
Local aAreaNVD   := NVD->( GetArea() )

Default lDtProxEv := .F.

NVD->( dbSetOrder( 1 ) )
NVD->( dbSeek( xFilial( 'NVD' ) + cTipoFw ) )

While !NVD->( EOF() ) .And. xFilial( 'NVD' ) + cTipoFw == NVD->NVD_FILIAL + NVD->NVD_CTIPOF 
	
	NRT->( dbSetOrder( 1 ) )
	
	If NRT->( dbSeek( xFilial( 'NRT' ) + NVD->NVD_CTFPAD ) )
			
		If NRT->NRT_TIPOGF == '1'

			J106GFWAUT(cAssJur, cCodFw, dDtFw, cTipoFw,,cFwPai,,, lDtProxEv )

		ElseIf NRT->NRT_TIPOGF == '2'

			JA106GFWIU( cAssJur, cCodFw, dDtFw, cTipoFw, cFwPai, lDtProxEv )

		EndIf
		
	EndIf
	
	NVD->( dbSkip() )
	
End

RestArea( aAreaNRT )
RestArea( aAreaNVD )
RestArea( aArea )

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA106ALTFP
Rotina para alteração de follow-ups filhos, quando o follow-up pai é
alterado

@param 	cCodFw      	Código do follow-up
@param 	nQtdeDias     	Diferença de dias entre a data original do follow-up e a nova data
@param 	lMaior       	.T./.F. A nova data é maior ou não que a original
@param 	lSemMsg  		.T./.F. Para a mensagem de confirmação só aparecer na primeira vez

@author Juliana Iwayama Velho
@since 07/10/09
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA106ALTFP(cCodFw, nQtdeDias, lMaior, lSemMsg)
Local aArea      := GetArea()
Local aAreaNTA   := NTA->( GetArea() )
Local oStruct    := FWFormStruct( 1, "NTA" )
Local cMVBlqFer  := SuperGetMV('MV_JBLQFER',, '2')
Local oModelFw   := NIL 
Local lRet       := .T.
Local aDetail

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModelFw:= MPFormModel():New( "JURA106C", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModelFw:AddFields( "NTAMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )

oModelFw:SetDescription( STR0001 ) // "Modelo de Dados de Follow-ups"
oModelFw:GetModel( "NTAMASTER" ):SetDescription( STR0002 ) // "Dados de Follow-ups"

//----------------------------------------
//Verifica se o follow-up alterada é pai de outro(s)
//----------------------------------------
NTA->( dbSetOrder( 3 ) ) 

If NTA->( dbSeek( xFilial( 'NTA' ) + cCodFw ) )
	
	If lSemMsg .Or. ApMsgYesNo(STR0003) //"Deseja alterar todos follow-ups vinculados?"
		
		While !NTA->( EOF() ) .And. xFilial( 'NTA' ) + cCodFw == NTA->NTA_FILIAL + NTA->NTA_CFLWPP
			
			lRet := .T.
			
			oModelFw:SetOperation( 4 )
			oModelFw:Activate()
			
			If lMaior
				
				dNvDtFw := NTA->NTA_DTFLWP + nQtdeDias
				
			Else
				
				dNvDtFw := NTA->NTA_DTFLWP - nQtdeDias
				
			EndIf
			
			If cMVBlqFer == '1'
				
				dNvDtFw := DataValida( dNvDtFw )
				
			EndIf
										
			If !oModelFw:SetValue("NTAMASTER","NTA_DTFLWP",dNvDtFw)
				lRet := .F.
				JurMsgErro( STR0004 ) //"Erro ao alterar data do follow-up"
				aAdd( aDetail, { "NTA_DTFLWP", dNvDtFw } )
				Exit
			Else
				oModelFw:SetValue("NTAMASTER",'NTA_DTALT' ,DATE())
				oModelFw:LoadValue("NTAMASTER",'NTA_USUALT',PadR( PswChave(__CUSERID), TamSX3('NTA_USUALT')[1] ) )
			EndIf
			
			
			If lRet
				If ( lRet := oModelFw:VldData() )
					
					oModelFw:CommitData()
					
					If __lSX8
						ConfirmSX8()
					EndIf
					
				EndIf
				
			EndIf
			
			oModelFw:DeActivate()
			
			
			If lRet
				
				JA106ALTFP(NTA->NTA_COD, nQtdeDias, lMaior, .T.)
				
			EndIf
			
			NTA->( dbSkip() )
			
		End
		
	EndIf
	
EndIf

RestArea( aAreaNTA )
RestArea( aArea )

Return nil              
//-------------------------------------------------------------------
/*/{Protheus.doc} JA106EXCL
Rotina para exclusão de follow-ups e andamentos 

@param  cCodFw: Código do follow-up
@param  lExclui .T./.F. - É exclusão?

@Return lRet:   .T./.F. - As informações são válidas ou não

@author Marcelo Dente
@since 15/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA106EXCL(cCodFw, lExclui)
Local aArea    := GetArea()
Local aAreaNTA := NTA->( GetArea() )
Local aAreaNTE := NTE->( GetArea() )
Local aAreaNT4 := NT4->( GetArea() )
Local aLstExc  := JA106SELX(cCodFw,, lExclui)
Local nTamanho := 0
Local nCount   := 0
Local lRet     := .T.
	
	If ValType(aLstExc) <> 'A' .Or. Len(aLstExc) == 0
		lRet:=.F.
	Else

		dbSelectArea("NTA")
		dbSelectArea("NTE")
		dbSelectArea("NT4")
		NTA->( dbSetOrder( 1 ) ) //NTA_FILIAL+NTA_COD
		NTE->( dbSetOrder( 2 ) ) //NTE_FILIAL+NTE_CFLWP
		NT4->( dbSetOrder( 1 ) ) //NT4_FILIAL+NT4_COD

		// Apaga Follow-up(NTA) e responsáveis (NTE)
		nTamanho := len(aLstExc)
		For nCount := 1 to nTamanho
			// Valida se é Fup
			If aLstExc[nCount][4] == 'F'
				// Apaga Follow-up(NTA) e responsáveis (NTE) do array
				If (NTA->( dbSeek( xFilial( 'NTA' ) + aLstExc[nCount][2] ) ))

					If (NTE->( dbSeek( xFilial( 'NTE' ) + NTA->NTA_COD ) ))
		
						While !NTE->( EOF() ) .AND. (NTE->(NTE_FILIAL + NTE_CFLWP)) == (NTA->NTA_FILIAL + NTA->NTA_COD) 

							NTE->(Reclock( 'NTE', .F. ))
								NTE->(dbDelete())
							NTE->(MsUnlock())

							lRet := NTE->(DELETED())

							If !lRet
								JurMsgErro(STR0005) //"Erro ao excluir"
								Exit
							EndIf
							
							NTE->( dbSkip() )
						End
					EndIf

					NTA->(Reclock( 'NTA', .F. ))
						NTA->(dbDelete())
					NTA->(MsUnlock())

					If lRet := NTA->(DELETED())
						JurExcAnex ('NTA',aLstExc[nCount][2])
					Else
						JurMsgErro(STR0005) //"Erro ao excluir"
						Exit
					EndIf

				Else
					lRet := .F.
				EndIf
			Else
				If (NT4->( dbSeek( xFilial( 'NT4' ) + aLstExc[nCount][2] ) ))
					NT4->(Reclock( 'NT4', .F. ))
						NT4->(dbDelete())
					NT4->(MsUnlock())

					If lRet := NT4->(DELETED())
						JurExcAnex ('NT4',aLstExc[nCount][2])
					Else
						JurMsgErro(STR0005) //"Erro ao excluir"
						Exit
					EndIf
				EndIf
			EndIf
		Next	
		NTA->( dbCloseArea() )
		NTE->( dbCloseArea() )
		NT4->( dbCloseArea() )
	EndIf

	RestArea( aAreaNTE )
	RestArea( aAreaNTA )
	RestArea( aAreaNT4 )
	RestArea( aArea )

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} Verifica registros a serem Excluidos
Função genérica para montagem de interface de seleção de exclusão
 de Andamentos e Follow-ups, montada pelo NTA e NT4

@param  cCodFw   - Código do Follow-up
@return aFwAnLst - Array com os registros a serem Excluidos
@Return lExclui .T./.F. - É exclusão?

@author Marcelo Dente
@since  15/09/2015
@version 1.0
/*/
//--------------------------------------------------------------------
Function JA106SELX(cCodFw, aFwAnLst, lExclui)
Local aSalvAmb := GetArea()
Local aSalvNTA := NTA->( GetArea() )
Local aSalvNT4 := NT4->( GetArea() ) 
Local aRet     := {}
Local aRetorno := {}
Local cVar     := ""
Local oDlg     := NIL
Local oLbx     := NIL
Local oButOk   := NIL
Local oButCanc := NIL
Local cFil     := xFilial("NTA")
Local nI       := 1

Default cCodFw := ''
Default aFwAnLst := {}
Default lExclui  := NIL
	
	If !Empty(cCodFw) 
		//RECEBE A LISTA DE CÓDIGOS PARA APAGAR
		aRetorno := DelAllFWP(cCodFw)

		//CARREGA FUPS
		NTA->( dbSetOrder( 1 ) )
		NTA->( dbGoTop() )
		
		For nI := 1 To Len(aRetorno) 
			IF(NTA->(dbseek(cFil+aRetorno[nI])))
				If aScan( aFwAnLst, {|x| x[2]+x[6] == (NTA->NTA_FILIAL)+(NTA->NTA_COD)+'F'} ) == 0
					aAdd(  aFwAnLst, { .T., NTA->NTA_COD, NTA->NTA_CFLWPP, NTA->NTA_DESC, NTA->NTA_FILIAL ,'F',NTA->NTA_DTFLWP, NTA->(Recno())} )
				EndIf
			EndIf
		Next
		
		// CARREGA ANDAMENTOS
		NT4->(dbSetOrder( 5 ))
		NT4->(dbGoTop())

		For nI := 1 To Len(aRetorno)
			IF(NT4->(dbseek(cFil+aRetorno[nI])))
				If aScan( aFwAnLst, {|x| x[2]+x[6] == (NT4->NT4_FILIAL)+(NT4->NT4_COD)+'A'} ) == 0
					aAdd(  aFwAnLst, { .T., NT4->NT4_COD, NT4->NT4_CFWLP, NT4->NT4_DESC, NT4->NT4_FILIAL ,'A',NT4->NT4_DTANDA,NT4->(Recno())} )
				EndIf
			EndIf
		Next
		
		ASORT(aFwAnLst, , , { | x,y | x[2]+x[6] < y[2]+y[6] } )
		
		
		If ((Len(aFwAnLst) == 1) .Or.(JurAuto()))
			aRet:=aFwAnLst
			If lExclui
				RetSelecao( @aRet, aFwAnLst )
			EndIf
		Else
			Define MSDialog  oDlg Title "" From 0, 0 To 250, 595 Pixel
			oDlg:cToolTip := STR0009  // "Follow-ups/Andamentos relacionados que serão excluídos"
			oDlg:cTitle   := STR0010  // "Follow-ups/Andamentos serão excluídos"
			@ 10, 10 Listbox  oLbx Var  cVar Fields Header STR0016,STR0017,STR0018,STR0019 STR0011 Size 278, 95 Of oDlg Pixel // "Follow-ups/andamentos"
			oLbx:SetArray(  aFwAnLst )
			oLbx:bLine := {|| { aFwAnLst[oLbx:nAt, 2], aFwAnLst[oLbx:nAt, 6],aFwAnLst[oLbx:nAt, 7], aFwAnLst[oLbx:nAt, 4]}}
			oLbx:cToolTip   :=  oDlg:cTitle
			oLbx:lHScroll   := .F. // NoScroll
			oLbxlUseDefaultColors := .T.
			oLbx:nScrollType := 0
			@ 112, 80  Button oButOk   Prompt STR0012  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aFwAnLst ), oDlg:End()  ) ; // "Excluír"
			Message STR0013  Of oDlg // "Confirma a seleção e efetua" "o processamento"
			oButOk:SetCss( CSSBOTAO )
			@ 112, 115  Button oButCanc Prompt STR0014  Size 32, 12 Pixel Action ( aRet:={},oDlg:End() ) ; // "Cancelar"
			Message STR0015 Of oDlg  // "Cancela a Exclusão"
			oButCanc:SetCss( CSSBOTAO )
			Activate MSDialog  oDlg Center
		EndIf
		
	EndIf
	
	RestArea(aSalvNT4)
	RestArea(aSalvNTA)
	RestArea(aSalvAmb)

Return  aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aFwAnLst  Vetor do ListBox

@author Marcelo Dente
@since  15/09/2015
@version 1.0
/*/
//--------------------------------------------------------------------

Static Function RetSelecao( aRet, aFwAnLst )
	Local  nI    := 0
	
	aRet := {}
	For nI := 1 To Len( aFwAnLst )
		If aFwAnLst[nI][1]
		   aAdd( aRet,{ aFwAnLst[nI][5],aFwAnLst[nI][2],aFwAnLst[nI][7],aFwAnLst[nI][6]} ) 
		EndIf
	Next nI

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} DelAllFWP
Executa rotinas de mapeamento da arvore dos Follow-ups vinculados

@param  cCodFw   - Código do Follow-up Posicionado             
@return aRetorno - Retorna a lista com os códigos de FUPs e Andamentos
					que estão relacionados em uma mesma cadeia

@author Marcelo Dente
@since  15/09/2015
@version 1.0
/*/
//--------------------------------------------------------------------

Static Function DelAllFWP(cCodFw)
Local aRetorno := {}

	aRetorno := RecFil(RecPai(cCodFw))

Return aRetorno

//--------------------------------------------------------------------
/*/{Protheus.doc} RecPai
Encontra o Pai ( raiz ) de toda a Arvore Gerada

@param  cCodFw - Código do Follow-up Posicionado
@return cRet   - Código do Follow-up que originou a cadeia (Pai / Raiz)

@author Marcelo Dente
@since  15/09/2015
@version 1.0
/*/
//--------------------------------------------------------------------

Function RecPai(cCodFw)
Local axArea    := GetArea()
Local cAliasQry := GetNextAlias()
Local cRet      := cCodFw
Local cCflwpp   := ''

	cQuery:= "SELECT NTA.NTA_CFLWPP "
	cQuery+=  " FROM "+ RetSqlName("NTA")+ " NTA"
	cQuery+= " WHERE NTA.NTA_COD ='"+cCodFw+"'"
	cQuery+=   " AND NTA.NTA_FILIAL = '"+xFilial("NTA")+"'"
	cQuery+=   " AND NTA.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	cCflwpp := (cAliasQry)->NTA_CFLWPP
	(cAliasQry)->( dbCloseArea())

	If !Empty(cCflwpp)
		cRet := RecPai(cCflwpp)  
	Endif

	RestArea( axArea )

Return cRet

//--------------------------------------------------------------------
/*/{Protheus.doc} RecFil
Encontra os Filhos/Pais ( filhas ) de toda a Arvore Gerada

@param  cRecPai - Código do registro pai
@param  aRetorno - Array com a lista de filhos
@return aRetorno - Array com a lista de filhos

@author Marcelo Dente
@since  15/09/2015
@version 1.0
/*/
//--------------------------------------------------------------------

Static Function RecFil(cRecPai, aRetorno)
Local axArea    :=GetArea()
Local cAliasQry :=GetNextAlias()
Local cQuery    :=''
Default aRetorno  := {}

	cQuery:= "SELECT NTA.NTA_FILIAL, NTA.NTA_COD,NTA.NTA_CFLWPP "
	cQuery+= " FROM "+ RetSqlName("NTA")+ " NTA"
	cQuery+= " WHERE NTA.NTA_CFLWPP ='"+cRecPai+"'"
	cQuery+= " AND NTA.NTA_FILIAL = '"+xFilial("NTA")+"'"
	cQuery+= " AND NTA.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	If Len(aRetorno) == 0
		aAdd(aRetorno, cRecPai)
	Endif

	While !(cAliasQry)->( EOF() )  		
		If !Empty((cAliasQry)->NTA_COD) .And. ((cAliasQry)->NTA_COD <> cRecPai)
			aAdd(aRetorno, (cAliasQry)->NTA_COD)
			RecFil((cAliasQry)->NTA_COD, @aRetorno)
		Endif

		(cAliasQry)->(dbSkip())  
	End

	(cAliasQry)->( dbCloseArea())

	RestArea(axArea)
	
Return aRetorno
