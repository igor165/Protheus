#INCLUDE "AP5MAIL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TBICONN.CH"
//#INCLUDE "SIGAWF.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณJURA091    บAutor  ณMarcos Kato          บ Data ณ  26/04/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Envia Email de acordo com a configuracao efetuada na rotina  บฑฑ
ฑฑบ          ณ Configuracao de Email                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณJURIDICO                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function JURA091(aCodCab)
Local nCont			:=0
Local cStructSQL 	:=""
Local cQuery		:=""
Local cTabFlg		:=""
Local cOrdFlg		:=""
Local cCpoFlg		:=""
Local cIndFlg		:=""
Local cChvFlg		:=""
Local cObs			:=""
Local cChvMail	    :=""
Local cLink		    :=""
Local cMail		    :=""
Local cChvFil		:=""
Local aStruct		:={}
Local aUsrEmail	    :={}
Local aInfMail	    :={}
Local aInCpos		:={}
Local aIndice		:={}
Local aIndMail      :={}
Local aIndLink      :={}
Local aChvFlg		:={}
Local aInfFil		:={}
Local lPadrJur	    := .T.
Local lJMetrics     := .F.

Default aCodCab :={}

If Len(aCodCab)==0
	AADD(aCodCab,{'000001','01','01'})
Endif

/*
	Abertura do ambiente em rotinas automแticas
	RpcSetEnv
	 ( [ cRpcEmp ]
	   [ cRpcFil ]
	   [ cEnvUser ]
	   [ cEnvPass ]
	   [ cEnvMod ]
	   [ cFunName ]
	   [ aTables ]
	   [ lShowFinal ]
	   [ lAbend ]
	   [ lOpenSX ]
	   [ lConnect ] ) --> lRet
	*/
	// Empresa, Filial, C๓d Usu Protheus  { Config. Env Email, Empresa, Filial}
	//{'99'   , '01'  , '000000'        , { '000001'         , '99'   , '01'  }}
	RpcSetType(3)
	RPCSetEnv( aCodCab[4][2],aCodCab[4][3], , , ,"JURA091")


//=====================================================
//NSX-Cabecalho da configuracao de Email
//NT8-Item do cabecalho de Email
//=====================================================

cStructSQL:="SELECT NSX.R_E_C_N_O_ RECNO,NSX_COD,NSX_ASSUNT,NSX_TABFLG,NSX_ORDEM,NSX_INDICE,NSX_CPOFLG,NT8_TITULO, NT8_CAMPO,  "
cStructSQL+="NSX_QUERY,NSX_OBS,NSX_EMAIL, "
cStructSQL+="NSX_LINK01,NSX_LINK02,NSX_CPOMAI "
cStructSQL+="FROM "+RetSQlName("NSX")+" NSX "
cStructSQL+="INNER JOIN "+RetSQlName("NT8")+" NT8 ON "
cStructSQL+="NSX_COD=NT8_CODCAB "
cStructSQL+="AND NT8.D_E_L_E_T_ = ' ' "
cStructSQL+="WHERE NSX.D_E_L_E_T_ = ' ' "

If Len(aCodCab)>0
	  cStructSQL+="AND NSX_COD= '"+aCodCab[4][1]+"' "
Endif

cStructSQL+="ORDER BY NSX_COD, NT8_CODITE "

If Select("STRUCT")>0
	dbSelectArea("STRUCT")
	STRUCT->(dbCloseArea())
Endif

cStructSQL  := ChangeQuery(cStructSQL)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cStructSQL), "STRUCT", .T., .T. )

dbSelectArea("STRUCT")
STRUCT->(dbGoTop())
Do While STRUCT->(!Eof())
	aStruct:= {}
	cCodCab   := STRUCT->NSX_COD
	cAssunto  :=STRUCT->NSX_COD+"-"+Alltrim(STRUCT->NSX_ASSUNT)

	If  STRUCT->RECNO > 0
		NSX->( dbGoTo( STRUCT->RECNO ))
		cQuery    := Alltrim( NSX->NSX_QUERY )
		cObs      := Alltrim( NSX->NSX_OBS   )
		cQryEmail := Alltrim( NSX->NSX_EMAIL )
	EndIf

//	cQuery    :=Alltrim(STRUCT->NSX_QUERY)
//  	cObs      :=Alltrim(STRUCT->NSX_OBS)

	cTabFlg   :=STRUCT->NSX_TABFLG
	cOrdFlg   :=STRUCT->NSX_ORDEM
	cIndFlg   :=STRUCT->NSX_INDICE
	cCpoFlg   :=STRUCT->NSX_CPOFLG
	aChvFlg   :={cTabFlg,Val(cOrdFlg),cCpoFlg}
//	cQryEmail :=Alltrim(STRUCT->NSX_EMAIL)
	cLink     :=STRUCT->NSX_LINK01
	cChvMail  :=STRUCT->NSX_LINK02
	cMail     :=STRUCT->NSX_CPOMAI

	//chave de flag a ser utilizada para poder posicionar no registro
	If !Empty(cIndFlg)
		Do While At("+",Alltrim(cIndFlg))>0
			aAdd(aIndice,Substr(Alltrim(cIndFlg),1,At("+",Alltrim(cIndFlg))-1))
		    cIndFlg:=Substr(Alltrim(cIndFlg),At("+",Alltrim(cIndFlg))+1,Len(Alltrim(cIndFlg))-At("+",Alltrim(cIndFlg)))
		End
		Aadd(aIndice,Alltrim(cIndFlg))
	Endif

	//chave de email a ser utilizada para poder posicionar no registro
	If !Empty(cChvMail)
		Do While At("+",Alltrim(cChvMail))>0
			aAdd(aIndMail,Substr(Alltrim(cChvMail),1,At("+",Alltrim(cChvMail))-1))
		    cChvMail:=Substr(Alltrim(cChvMail),At("+",Alltrim(cChvMail))+1,Len(Alltrim(cChvMail))-At("+",Alltrim(cChvMail)))
		End
		Aadd(aIndMail,Alltrim(cChvMail))
	Endif

	//relacionamento da query
	If !Empty(cLink)
		Do While At("+",Alltrim(cLink))>0
			aAdd(aIndLink,Substr(Alltrim(cLink),1,At("+",Alltrim(cLink))-1))
		    cLink:=Substr(Alltrim(cLink),At("+",Alltrim(cLink))+1,Len(Alltrim(cLink))-At("+",Alltrim(cLink)))
		End
		Aadd(aIndLink,Alltrim(cLink))
    Endif


	Do While STRUCT->(!Eof()) .And. cCodCab==STRUCT->NSX_COD
		If Alltrim(STRUCT->NT8_CAMPO)$Alltrim(cQuery)
			aAdd(aStruct,{STRUCT->NSX_COD,STRUCT->NT8_TITULO,STRUCT->NT8_CAMPO})//STRUCT->NT8_TAMCPO
		Endif
		STRUCT->(DbSkip())
	End

	If !Empty(cQuery)

		If !Empty(cQryEmail)
			If Select("TRBMAIL")>0
				dbSelectArea("TRBMAIL")
				TRBMAIL->(dbCloseArea())
			Endif

			cQryEmail := ChangeQuery(cQryEmail)

			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQryEmail), "TRBMAIL", .T., .F. )
			DbSelectArea("TRBMAIL")

			TRBMAIL->(DbGoTop())

			If TRBMAIL->(!Eof())
				Do While TRBMAIL->(!Eof())
    				cChvMail:=""
					If !Empty(TRBMAIL->&(cMail))

						For nCont:=1 To Len(aIndMail)
							cChvMail+=TRBMAIL->&(aIndMail[nCont])
						Next nCont

						Aadd(aUsrEmail,{cChvMail,TRBMAIL->&(cMail)})
					Endif
					TRBMAIL->(DbSkip())
				End
				aSort(aUsrEmail, , , { |x,y| y[1] > x[1] } )
			Endif
		Endif

		If Len(aUsrEmail)>0
			If Select("TRBSQL")>0
				dbSelectArea("TRBSQL")
				TRBSQL->(dbCloseArea())
			Endif

			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRBSQL", .T., .F. )

			DbSelectArea("TRBSQL")
			TRBSQL->(DbGoTop())

			If TRBSQL->(!Eof())
				Do While TRBSQL->(!Eof())
					aInfCpos:={}
					cChvFlg:=""
					cChvFil:=""

					For nCont:=1 To Len(aIndice)
						cChvFlg += TRBSQL->&(aIndice[nCont])
					Next nCont

					cLink:=""

					For nCont:=1 To Len(aIndLink)
						cLink+=TRBSQL->&(aIndLink[nCont])
					Next nCont

					For nCont := 1 to Len(aStruct)
						Aadd(aInfCpos,TRBSQL->&(aStruct[nCont][3]))
					Next nCont

					cChvFil := TRBSQL->&(cTabFlg+"_FILIAL")

					nPos:= aScan( aUsrEmail, {|x| AllTrim (x[1])==Alltrim(cLink)} )

					If nPos>0
						cEnvio:=""

						For nCont :=nPos To Len(aUsrEmail)
							If !Alltrim(aUsrEmail[ncont][1])==Alltrim(cLink)
								Exit
							ElseIf !Empty(cEnvio)
								cEnvio+=";"+Alltrim(aUsrEmail[nCont][2])
							Else
								cEnvio+=Alltrim(aUsrEmail[nCont][2])
							Endif
						Next nCont

						Aadd( aInfCpos , cChvFlg )
						Aadd( aInfCpos , cChvFil )
						Aadd( aInfCpos , cEnvio  )
						Aadd( aInfMail , aInfCpos)
					Endif

					TRBSQL->(DbSkip())
				End

				If Len(aInfMail)>0
					If lPadrJur
						lJMetrics := .T.
	    				ENVJUR(cAssunto,aStruct,aInfMail,aChvFlg,cObs)
					Else
						ENVEMAIL(cAssunto,aStruct,aInfMail,aChvFlg,cObs)
					Endif
				Endif

			Endif
		Endif
	Endif
End

If lJMetrics
	J106SetMet("true")
EndIf

RpcClearEnv() // Reseta o ambiente

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ENVJUR    บAutor  ณMarcos Kato          บ Data ณ  26/04/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que chama o funcao de email padrao do juridico        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Juridico                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ENVJUR(cTitMail,aMailCab,aMailCols,aChave,cObs)
Local nCont       := 0
Local nItem       := 0
Local cHTML       := ""
Local cHtmlHead   := ""
Local cHtmlBody   := ""
Local cHtmlFoot   := ""
Local cTableCab   := ""
Local cTableItem  := ""
Local cTmpCod     := ""
Local cTmpFil     := ""
Local lCont       := .T.

Default cObs	:=""
Default cTitMail:="-"


For nCont:=1 To Len(aMailCols)

	// Cabe็alho
	cHtmlHead :=   '<tr>'
	cHtmlHead +=     '<td width="100%" bordercolor="#FFFFFF" bgcolor="#F7F7F7" colspan="3" >'
	cHtmlHead +=       '<div align="center"><b>'+cTitMail+'</b></div>
	cHtmlHead +=     '</td>'
	cHtmlHead +=   '</tr>'

	// Corpo
	For nItem :=1 To Len(aMailCab)
		cTableCab:=aMailCab[nItem][2]
		cTableItem:= aMailCols[nCont][nItem]

		cHtmlBody += '<tr>'
		cHtmlBody +=   '<td border="0" align="left" width="100%">'
		cHtmlBody +=     '<font face="Arial" size="2" color="#19167D" lass="texto">'
		cHtmlBody +=       '<b>'+cTableCab+': </b>'
		cHtmlBody +=     '</font>'
		cHtmlBody +=     '<font face="Arial" size="2" color="#000000" lass="texto">'+cTableItem+'</font>'
		cHtmlBody +=   '</td>'
		cHtmlBody += '</tr>'
	Next nItem

	// Observa็ใo
	cHtmlBody += '<tr>'
	cHtmlBody +=   '<td border="0" width="10%"><font face="Arial, Helvetica, sans-serif"></font>'
	cHtmlBody +=     '<font face="Arial" size="2" color="#19167D" lass="texto"><b>Observa็ใo:</b></font>'
	cHtmlBody +=     '<font face="Arial" size="2" color="#000000" lass="texto">'+cOBS+'</font>'
	cHtmlBody +=   '</td>'
	cHtmlBody += '</tr>'

	// Rodap้
	cHtmlFoot += '<tr>'
	cHtmlFoot +=   '<table width="100%" border="1" align="center" cellpadding="6" cellspacing="0" bordercolor="#F7F7F7" bgcolor="#F7F7F7" >'//+CHR(13)+CHR(10)
	cHtmlFoot +=     '<td width="100%" bordercolor="#FFFFFF" colspan="3" >'
	cHtmlFoot +=       '<div align="right">WorkFlow @ Microsiga Protheus</div>'
	cHtmlFoot +=     '</td>'
	cHtmlFoot +=   '</table>'
	cHtmlFoot += '</tr>'


	cHtml := '<html><table width="100%" >' + cHtmlHead + cHtmlBody + cHtmlFoot + '</table></html>'

	lCont := JurEnvMail( GetMV( 'MV_RELACNT',, 'workflow' ), aMailCols[nCont][LEN(AMAILCOLS[NCONT])], "", "", cTitMail, "", cHtml)

	If Len(aChave)>0
		cTabela:=aChave[1]
		cCampo :=aChave[3]

		DbSelectArea(cTabela)
		(cTabela)->(DbSetOrder(aChave[2]))
		(cTabela)->(DbGoTop())

		cTmpCod := aMailCols[nCont][LEN(AMAILCOLS[NCONT])-2]
		cTmpFil := aMailCols[nCont][LEN(AMAILCOLS[NCONT])-1]

		If (cTabela)->( DbSeek( cTmpFil + cTmpCod ) ) .AND. lCont
			Begin Transaction
				RecLock(cTabela,.F.)
				(cTabela)->(&cCampo):="2"
				(cTabela)->(MsUnLock())
			End Transaction
		Else
		  Conout("Nใo foi localizado o codigo: " + Alltrim(cTmpCod)  +" para atualizar o FLAG de envio de emails")
		Endif

	Endif

	cHtmlHead := ""
	cHtmlBody := ""
	cHtmlFoot := ""

Next nCont

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณENVEMAIL   บAutor  ณMarcos Kato          บ Data ณ  26/04/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que chama o HTML e inicia o processo do wf            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Juridico                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ENVEMAIL(cTitMail,aMailCab,aMailCols,aChave,cObs)
Local oProcess
Local oHtml
Local nCont		 := 0
Local nItem		 := 0
Local cTableCab	 :=""
Local cTableItem :=""
Local cTmpCod	 :=""

Default cObs:=""
Default cTitMail:="-"

For nCont:=1 To Len(aMailCols)
	oProcess := TWFProcess():New( "JURA091", cTitMail )
	oProcess :NewTask(cTitMail,"\WORKFLOW\HTML\JURWF01.HTM")
	oProcess :cTo := aMailCols[nCont][LEN(AMAILCOLS[NCONT])]
	oProcess :cSubject := cTitMail
	oHtml :=oProcess:oHtml
	oHtml:ValByName("ASSUNTO",cTitMail)

	For nItem:=1 To Len(aMailCab)
		cTableCab:=aMailCab[nItem][2]
		cTableItem:= aMailCols[nCont][nItem]
		aadd(oHtml:ValByName("IT.HEADER"), cTableCab)
		aadd(oHtml:ValByName("IT.ITENS"),  cTableItem)
	Next nItem

	If Len(aChave)>0

		cTabela:=aChave[1]
		cCampo :=aChave[3]

		DbSelectArea(cTabela)
		(cTabela)->(DbSetOrder(aChave[2]))
		(cTabela)->(DbGoTop())

		cTmpCod	:= aMailCols[nCont][LEN(AMAILCOLS[NCONT])-1]

		If (cTabela)->( DbSeek( xFilial(cTabela) + cTmpCod ) )
			Begin Transaction
				RecLock(cTabela,.F.)
				 (cTabela)->(&cCampo):="2"
				 (cTabela)->(MsUnLock())
			End Transaction
		Else
		  Conout("Nใo foi localizado o codigo: " + Alltrim(cTmpCod)  +" para atualizar o FLAG de envio de emails")
		Endif
	Endif
	oHtml:ValByName("OBS",cObs)

	oProcess:Start()
	oProcess:Finish()

Next nCont


Return
