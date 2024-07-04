#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA600B.CH"

#DEFINE NTASKAPR 7 //Prox. Tarefa - Aprovacao
#DEFINE NTASKREP 8 //Prox. Tarefa - Reprovacao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A600ATECM  ºAutor  ³Vendas CRM          º Data ³  31/01/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o status da proposta no ECM.   				     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FATA600                                                    º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRetorno   ³ExpL: Verdadeiro		                                     º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParametros³ExpC1: Empresa                                             º±±
±±º			 ³ExpC2: Filial                                              º±±
±±º			 ³ExpC3: Codigo da Proposta                                  º±±
±±º			 ³ExpC4: Id do ECM                                 			 º±±
±±º			 ³ExpC5: Status da Proposta                                  º±±
±±º			 ³ExpL6: Abertura do Ambiente                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A600ATECM(cEmpAnt,cFilAnt,cProposta,cIdECM,cStatus,lSetEnv)

Local aRet 		:= {}								   					// Array com status do processo
Local cUsrId	:= ""								   					// Id do Usuario do Sistema
Local cMD5 		:= ""													// Senha em MD5 do usuario
Local nPos 		:= 0 								   					// Posicao do array
Local oXML 		:= Nil													// Objeto XML com dados da proposta
Local cXML 		:= ""													// XML da proposta no formato string
Local cError 	:= ""								   					// Caso a funcao XmlParser retornar um erro a varivel sera preenchida
Local cWarning 	:= "" 													// Caso a funcao XmlParserretornar uma advertencia a varivel sera preenchida
Local cComments := IIF(cStatus=="S",STR0001,STR0003)  			  		// Aprovacao Automatica
Local nNextTask := IIF(cStatus=="S",NTASKAPR,NTASKREP)					// Reprovacao Automatica
Local xStatus   := IIF(cStatus=="S",Upper(STR0004),Upper(STR0005))		// Aprovado/Reprovado

Default lSetEnv := .F.

If lSetEnv
	Sleep(4000)
	RpcSetEnv(cEmpAnt,cFilAnt)
EndIf

DbSelectArea("AGY")
DbSetOrder(1)

If DbSeek(xFilial("AGY")+cIdECM)
	While AGY->(!EOF()) .AND. AGY->AGY_FILIAL == xFilial("AGY") .AND. AllTrim(AGY->AGY_IDECM) == cIdECM
		
		If Empty(AGY->AGY_STATUS) .AND. Empty(AGY->AGY_TPAPV)
			
			cUsrId := AllTrim(AGY->AGY_CODUSR)
			cMD5   := PswMD5GetPass(cUsrId)
			cXML   := A600PXML(cProposta)
			oXml   := XmlParser(cXML,'_',@cError,@cWarning)
			oXml:_FATA600:_STATUS:_VALUE:TEXT := xStatus
			
			cXML := XMLSaveStr( oXml )
			
			aRet := BIUpdateTask(cIdECM,cComments,cXML,{},.T.,nNextTask,{},cUsrId,"MD5:"+cMD5)
			
			nPos := aScan( aRet, { |x| x[1] == "ERROR" } )
			If nPos > 0
				msgStop(STR0002+aRet[nPos][2] )
			Endif
			If nPos == 0
				RecLock("AGY",.F.)
				AGY->AGY_STATUS := cStatus
				AGY->AGY_TPAPV  := "A"
				AGY->AGY_DTFIM  := DDATABASE
				MsUnLock()
			EndIf
			
		EndIf
		
		AGY->(DbSkip())
	End
EndIf

If lSetEnv
	RpcClearEnv()
EndIf

Return(.T.)

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} Ft600Aprv

Aprovacao/Reprovacao de orcamentos

@sample  Ft600Aprv(lAprova,oDlg) 
@Param   lAprova - Aprova ou Reprova o Orçamento
@return  Nil

@author  Serviços/CRM
@since   26/05/2015
@version P12
/*/
//-----------------------------------------------------------------------------------------
Function Ft600Aprv(lAprova,oDlg)

Local aArea		:= GetArea()
Local cAlias	:= "SCJ"
Local nOpc		:= 2
Local nRec		:= 0

DbSelectArea("SCJ")
DbSetOrder(4) //CJ_FILIAL+CJ_PROPOST
DbSeek(xFilial("SCJ")+M->ADY_PROPOS)

nRec := SCJ->(Recno())

If lAprova
	A502Libera(cAlias,nRec,nOpc)
	Aviso(STR0006,STR0007,{STR0009},1)//Proposta Aprovada
Else 
	A502Desapr(cAlias,nRec,nOpc)
	Aviso(STR0006,STR0008,{STR0009},1)//Proposta Reprovada
EndIf

RestArea(aArea)

Return Nil

