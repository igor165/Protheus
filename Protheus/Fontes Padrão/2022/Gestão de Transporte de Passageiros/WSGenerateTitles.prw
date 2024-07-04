#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSGtpForms
Métodos WS do GTP para integração de Geração de Titulos

@author SIGAGTP
@since 07/08/2021
@version 1.0

/*/
//-------------------------------------------------------------------

WSRESTFUL GTPGENERATETITLES DESCRIPTION "WS de Geração de Titulos" 

	WSDATA cAgencia 			AS STRING
	WSDATA cNumFch 				AS STRING
	WSDATA cStatus 				AS STRING
	WSDATA nValor 				AS STRING
	WSDATA filialSelecionada 	AS STRING

	// Métodos GET
	WSMETHOD GET generateTitles DESCRIPTION 'Gera titulo da ficha'  PATH "generateTitles" PRODUCES APPLICATION_JSON 
	
END WSRESTFUL

/*
Metodo para geração do titulo para a ficha de remessa
*/
WSMETHOD GET generateTitles WSRECEIVE cAgencia,cNumFch,cStatus,nValor, filialSelecionada WSREST GTPGENERATETITLES
Local lRet  		:= .T.
Local cMsgRet   	:= ""
Local oResponse 	:= JsonObject():New()
Local cFilSelect	:= Self:filialSelecionada
Local cFilOldS      := cfilant

cfilant := cFilSelect

cMsgRet := A421PoGerTitRec(Self:cAgencia,Self:cNumFch,Self:cStatus,val(Self:nValor))

If EMPTY(cMsgRet)
	oResponse['status'] := "1"
	oResponse['nOk'] := "Geracao de titulo - Titulo gerado no financeiro com sucesso"
Else
	oResponse['status'] := "2"
	oResponse['nOk'] := cMsgRet
EndIf
Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

cfilant := cFilOldS

Return lRet

Static Function A421PoGerTitRec(cAgencia,cNumFch,cStatus,nValor)
Local aTitSE1    := {}
Local cPrefixo   := "PRV" 
Local cNumero    := ""
Local cParcela   := StrZero(1,TamSx3('E1_PARCELA')[1])
Local cTipo      := "TF "
Local cNatureza  := GPA281PAR("NATUREZA")
Local cCliente   := ""
Local cLoja      := ""
Local nX         := 0
Local aLog       := {}
Local cMsgErro   := ""
Local dDtEmissao := dDataBase
Local dDtVenc    := dDataBase
Local dDtVencRe  := dDataBase
Local lRet       := .T.
Local cFilAtu	 := cFilAnt
Local cTitChave	 := " "
Local aNewFlds   := {'G6X_FILORI', 'G6X_PREFIX', 'G6X_E12TIT', 'G6X_PARCEL', 'G6X_TIPO', 'G6X_ORITIT'}
Local lNewFlds   := GTPxVldDic('G6X', aNewFlds, .F., .T.)
Local cMsg       := ""

Private lMsErroAuto        := .F.
Private lAutoErrNoFile     := .T.

	If nValor <= 0
		
		G6X->(DbSetOrder(3))
		If G6X->(dbSeek(xFilial('G6X')+cAgencia+cNumFch))
			RECLOCK("G6X",.F.)
			G6X->G6X_STATUS := "2"
			G6X->(MsUnlock())	
		EndIf		
		
	Else
		Begin Transaction
		
			DbSelectArea("GI6")
			
			If GI6->(DbSeek(xFilial("GI6")+cAgencia))
				cCliente := GI6->GI6_CLIENT
				cLoja    := GI6->GI6_LJCLI
				If !Empty(GI6->GI6_FILRES)
					cFilAnt  := GI6->GI6_FILRES
				Endif
				If GI6->(FieldPos('GI6_TITPRO')) > 0
					If !Empty(GI6->GI6_TITPRO == "2") //Titulo Provisório | 1=Sim;2=Não
						cPrefixo  := GTPGetRules("PREFTITTES")
					Endif
				EndIf
			EndIf
			If Empty(cCliente)
				lRet := .F.
				cMsg := "GTPA421 - Nao sera possivel gerar o titulo, pois nao ha Cliente informado no cadastro de Agencia"
			ElseIf Empty(cNatureza)
				cMsg := "GTPA421 - Nao sera possivel gerar o titulo, pois nao ha Natureza informada no parametros de Modulo"
				lRet := .F.
			Endif 
			
			If lRet
			
				cNumero := GtpTitNum('SE1', cPrefixo, cParcela, cTipo)

				cTitChave   := xFilial("SE1")+PadR(cPrefixo,TamSx3('E1_PREFIXO')[1])+cNumero+PadR(cParcela,TamSx3('E1_PARCELA')[1])+PadR(cTipo,TamSx3('E1_TIPO')[1])
			
			 	aTitSE1 := {	{ "E1_PREFIXO"	, cPrefixo		   , Nil },; //Prefixo 
								{ "E1_NUM"		, cNumero		   , Nil },; //Numero
								{ "E1_PARCELA"	, cParcela 		   , Nil },; //Parcela
								{ "E1_TIPO"		, cTipo			   , Nil },; //Tipo
								{ "E1_NATUREZ"	, cNatureza		   , Nil },; //Natureza
								{ "E1_CLIENTE"	, cCliente		   , Nil },; //Cliente
								{ "E1_LOJA"		, cLoja 		   , Nil },; //Loja
								{ "E1_EMISSAO"	, dDtEmissao	   , Nil },; //Data Emissão
								{ "E1_VENCTO"	, dDtVenc		   , Nil },; //Data Vencimento
								{ "E1_VENCREA"	, dDtVencRe		   , Nil },; //Data Vencimento Real
								{ "E1_VALOR"	, nValor		   , Nil },; //Valor
								{ "E1_SALDO"	, nValor		   , Nil },; //Saldo
								{ "E1_HIST"		, cAgencia+cNumFch , Nil },; //HIstórico
								{ "E1_ORIGEM"	, "GTPA421"		   , Nil }}  //Origem
				
				DbSelectArea("SE1")
				SE1->(DbSetOrder(1))
				If  !SE1->(DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela+cTipo ))
					MsExecAuto( { |x,y| FINA040(x,y)} , aTitSE1, 3)  // 3 - Inclusao
					If lMsErroAuto
						aLog := GetAutoGrLog()
			
						For nX := 1 To Len(aLog)
							cMsgErro += aLog[nX]+CHR(13)+CHR(10)			
						Next nX
						cMsg := "Erro no execauto " + cMsgErro
						RollbackSx8()
						DisarmTransaction()
						lRet := .F.
					Endif
				Else
					cMsg := "Numero do titulo encontra - se em duplicidade no financeiro. - Contate o TI."
					lMsErroAuto := .T.
				EndIf
				cFilAnt  := cFilAtu
				
				If cStatus $ '1|5'
					cStatus := '2'
				Endif 
				
				If lRet .And. cStatus $ '2|4'
					
					G6X->(dbSetOrder(3))
					If G6X->(dbSeek(xFilial('G6X')+cAgencia+cNumFch))
						RECLOCK("G6X",.F.)
						If lNewFlds
							G6X->G6X_FILORI := xFilial("SE1")
							G6X->G6X_PREFIX := PadR(cPrefixo,TamSx3('E1_PREFIXO')[1])
							G6X->G6X_E12TIT := cNumero
							G6X->G6X_PARCEL := PadR(cParcela,TamSx3('E1_PARCELA')[1])
							G6X->G6X_TIPO   := PadR(cTipo,TamSx3('E1_TIPO')[1])
							G6X->G6X_ORITIT := 'SE1'
						Endif
						G6X->G6X_STATUS := cStatus
						G6X->G6X_NUMTIT := cTitChave
						G6X->(MsUnlock())
					Else
						cMsg := "Geracao de titulo - Erro na atualizacao da ficha"
					EndIf
										
				EndIf
				
			EndIf	
			
		End Transaction
	EndIf
Return cMsg
