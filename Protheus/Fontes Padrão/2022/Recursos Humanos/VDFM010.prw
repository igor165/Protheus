#include "VDFM010.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


//-------------------------------------------------------------------
/*/{Protheus.doc}  VDFM010
Importacao de dados por aquivo .txt para uma estrutura
pai/filho/neto rotina desenvolvida em MVC
@author Everson S P Junior
@since 26/06/2013
@version P11
@Obs oModelo tem que estar correto
/*/
//-------------------------------------------------------------------
Function VDFM010()
Local   aSay     := {}
Local   aButton  := {}
Local   nOpc     := 0
Local   nLin     := 0
Local   nLayout  := 1
Local   cPerSX1  := 'PERGSQG'
Local   Titulo   := STR0001//'IMPORTAÇÃO: Manutenção dos candidatos'
Local   cDesc1   := STR0002//'IMPORTAÇÃO: Manutenção dos candidatos'
Local   cDesc2   := STR0003//'a.1.) Lay-Out dos arquivos para importação de Servidores e Membros: '
Local   cDesc3   := STR0004//'b.1.) Lay-Out dos arquivos para importação de Estagiários: '
Local   lOk      := .T.
Local 	lRet	 := .T.
Private lStatus := .T.
Private aLog    := {}
Private lEnd	:= .f.

aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )

aAdd( aButton, { 1, .T., { || nOpc := 1, FechaBatch() } } )
aAdd( aButton, { 2, .T., { || FechaBatch()            } } )
FormBatch( Titulo, aSay, aButton )


If nOpc == 1
	If Pergunte(cPerSX1, .T.)
		REY->(DbSetOrder(2))
		If SRJ->(dbSeeK(FwxFilial("SRJ",MV_PAR02)+MV_PAR03)) //Filial da Função + Função
			If SQ3->(dbSeek(FwxFilial("SQ3")+SRJ->RJ_CARGO)) .AND. SQ3->Q3_CATEG $ 'EG'
				nLayout := 2
			EndIf
		End

		REY->(DbSetOrder(RetOrder("REY","REY_FILIAL+REY_CODCON+REY_FILFUN+REY_CODFUN")))
		If REY->(dbSeek(FwxFilial('REY')+mv_par01+mv_par02+mv_par03))
			If !MsgNoYes(STR0005+CRLF+STR0008+CRLF+;//"Concurso e Função foram encontrados!  Deseja Continuar? "
				STR0006+CRLF+STR0007,STR0008)//" Os Registros encontratos serão alterados "//" de acordo com arquivo de importação"//"ATENÇÃO"
					nOpc :=0
			EndIf
		EndIf

		If nOpc > 0 .And. !MsgNoYes(STR0009+CRLF+STR0061+mv_par01+" - "+SUBSTR(POSICIONE("REW",1,FwxFilial("REW")+MV_PAR01,"REW_DESCRI"),1,30)+CRLF+;//"Você selecionou para importação: "##" Concurso: "
			STR0062 + MV_PAR02 + CRLF+; //"Filial da Função: "
			STR0063+POSICIONE("SRJ",1,MV_PAR02+MV_PAR03,"RJ_DESC")+CRLF+STR0047,STR0008)//" Função: "##CONFIRMA?//ATENÇÃO
			nOpc :=0
		EndIf
	Else
		nopc := 0
	EndIf
EndIf

If nOpc == 1

	Processa( { || lRet:= Runproc(nLayout,nLin) },STR0010,STR0011,.F.)//'Aguarde'//'Processando...'

	If len(aLog) > 0
		RptStatus({|lEnd| fImpLog()},STR0048) //"Impressão do Log"
	ElseIf lRet
		ApMsgInfo( STR0013, STR0012 )//'ATENÇÃO'//'Processamento Concluido.'
	EndIf

EndIf

Return NIL


//-------------------------------------------------------------------
Static Function Runproc(nLayout,nLin)
Local aCposCab := {}
Local aCposDet := {}
Local aDetNeto := {}
Local aAux     := {}
Local lRet	   := .F.
Local cARQUIVO := ''
Local cFile	   := ''


cFile := cGetFile( "Arquivo Texto (*.tx*) |*.TxT|" , STR0019, 1, "C:\" )//"Selecione o fonte"
FT_FUSE(cFile)
QueryREX()

While ! FT_FEof() .AND. !Empty(cFile)
	cARQUIVO := FT_FREADLN()
	nLin     := nLin+1
	aCposCab := {}
	aCposDet := {}

	IF nLayOut == 2 // Layout Estagio!
		aAdd( aCposCab, { 'QG_FILIAL '   , xFilial("SQG")} )
		aAdd( aCposCab, { 'QG_CIC '   , SUBSTR( cARQUIVO,0092,0011)} )
		aAdd( aCposCab, { 'QG_NOME'   , SUBSTR( cARQUIVO,0007,00070)} )
	    aAdd( aCposCab, { 'QG_ENDEREC', ''} )
		aAdd( aCposCab, { 'QG_COMPLEM', ''} )
		aAdd( aCposCab, { 'QG_BAIRRO' , ''} )
		aAdd( aCposCab, { 'QG_MUNICIP', ''} )
		aAdd( aCposCab, { 'QG_ESTADO' , ''} )
		aAdd( aCposCab, { 'QG_CEP'    , ''} )
		aAdd( aCposCab, { 'QG_FONE'   , ''} )
		aAdd( aCposCab, { 'QG_EMAIL'  , ''} )
	    aAdd( aCposCab, { 'QG_RG'     , SUBSTR( cARQUIVO,0077,0015)} )
		aAdd( aCposCab, { 'QG_MAE '   , ''} )
		aAdd( aCposCab, { 'QG_SEXO '  , ''} )
	    aAdd( aCposCab, { 'QG_DTNASC ', STOD(SUBSTR( cARQUIVO,0107,0004)+SUBSTR( cARQUIVO,0105,0002)+SUBSTR( cARQUIVO,0103,0002))} )

		aAux := {}
		aAdd( aAux, { 'REY_FILIAL'   ,xFilial("REY")} )
		aAdd( aAux, { 'REY_CPF'   ,SUBSTR( cARQUIVO,0092,0011)} )
		aAdd( aAux, { 'REY_CODCON', mv_par01   } )
		aAdd( aAux, { 'REY_FILFUN', mv_par02   } )
		aAdd( aAux, { 'REY_CODFUN', mv_par03   } )
		aAdd( aAux, { 'REY_CLASSI',VAL(SUBSTR( cARQUIVO,0111,0006))} )
		aAdd( aAux, { 'REY_CLAORI',VAL(SUBSTR( cARQUIVO,0111,0006))} )
		aAdd( aAux, { 'REY_SITUAC','2'} )
		aAdd( aAux, { 'REY_COMARC',SUBSTR( cARQUIVO,0001,0006)})
		aAdd( aAux, { 'REY_NOTA'  ,VAL(SUBSTR( cARQUIVO,0117,0005))} )
		aAdd( aAux, { 'REY_STATUS'   ,'I'} )
		aAdd( aCposDet, aAux )
		While TRBREX->(!EOF())
			aAux := {}
			aAdd( aAux, { 'REZ_FILIAL' , xFilial("REZ")} )
			aAdd( aAux, { 'REZ_CPF' , SUBSTR( cARQUIVO,0092,0011)} )
			aAdd( aAux, { 'REZ_CODCON', mv_par01   } )
			aAdd( aAux, { 'REZ_FILFUN', mv_par02   } )
			aAdd( aAux, { 'REZ_CODFUN', mv_par03   } )
			aAdd( aAux, { 'REZ_CODREQ' ,TRBREX->REX_CODREQ  } )
			aAdd( aAux, { 'REZ_DTENTR', CTOD("//")     } )
			aAdd( aDetNeto, aAux )
			TRBREX->(DbSkip())
		EndDo
	Else //Quando For Funcionario servidor
		aAdd( aCposCab, { 'QG_FILIAL '   , xFilial("SQG")} )
		aAdd( aCposCab, { 'QG_CIC '   , SUBSTR( cARQUIVO,0088,0011)} )
		aAdd( aCposCab, { 'QG_NOME'   , SUBSTR( cARQUIVO,0018,0070)} )
		aAdd( aCposCab, { 'QG_ENDEREC', SUBSTR( cARQUIVO,0173,0030)} )
		aAdd( aCposCab, { 'QG_COMPLEM', SUBSTR( cARQUIVO,0203,0015)} )
		aAdd( aCposCab, { 'QG_BAIRRO' , SUBSTR( cARQUIVO,0218,0015)} )
		aAdd( aCposCab, { 'QG_MUNICIP', SUBSTR( cARQUIVO,0233,0020)} )
		aAdd( aCposCab, { 'QG_ESTADO' , SUBSTR( cARQUIVO,0253,0002)} )
		aAdd( aCposCab, { 'QG_CEP'    , SUBSTR( cARQUIVO,0255,0008)} )
		aAdd( aCposCab, { 'QG_FONE'   , SUBSTR( cARQUIVO,0263,0020)} )
		aAdd( aCposCab, { 'QG_EMAIL'  , SUBSTR( cARQUIVO,0283,0050)} )
		aAdd( aCposCab, { 'QG_RG'     , SUBSTR( cARQUIVO,0148,0015)} )
		aAdd( aCposCab, { 'QG_MAE '   , SUBSTR( cARQUIVO,0100,0040)} )
		aAdd( aCposCab, { 'QG_SEXO '  , SUBSTR( cARQUIVO,0099,0001)} )
		aAdd( aCposCab, { 'QG_DTNASC ', STOD(SUBSTR( cARQUIVO,0144,0004)+SUBSTR( cARQUIVO,0142,0002)+SUBSTR( cARQUIVO,0140,0002))} )

		aAux := {}
		aAdd( aAux, { 'REY_FILIAL' , xFilial("REY")} )
		aAdd( aAux, { 'REY_CPF'   ,SUBSTR( cARQUIVO,0088,0011)} )
		aAdd( aAux, { 'REY_CODCON', mv_par01   } )
		aAdd( aAux, { 'REY_FILFUN', mv_par02   } )
		aAdd( aAux, { 'REY_CODFUN', mv_par03   } )
		aAdd( aAux, { 'REY_CLASSI',VAL(SUBSTR( cARQUIVO,0001,0006))} )
		aAdd( aAux, { 'REY_CLAORI',VAL(SUBSTR( cARQUIVO,0001,0006))} )
		aAdd( aAux, { 'REY_SITUAC',SUBSTR( cARQUIVO,0007,0001)} )
		aAdd( aAux, { 'REY_STATUS'   ,'I'} )
		aAdd( aCposDet, aAux )

		While TRBREX->(!EOF())
			aAux := {}
			aAdd( aAux, { 'REZ_FILIAL' , xFilial("REZ")} )
		    aAdd( aAux, { 'REZ_CPF' , SUBSTR( cARQUIVO,0088,0011)} )
			aAdd( aAux, { 'REZ_CODCON', mv_par01   } )
			aAdd( aAux, { 'REZ_FILFUN', mv_par02   } )
			aAdd( aAux, { 'REZ_CODFUN', mv_par03   } )
			aAdd( aAux, { 'REZ_CODREQ' ,TRBREX->REX_CODREQ   } )
			aAdd( aAux, { 'REZ_DTENTR', CTOD("//")    } )
			aAdd( aDetNeto, aAux )
			TRBREX->(DbSkip())
		EndDo
	EndIf
	If !Empty(aCposCab) .And. !Empty(aCposDet)
		lRet:= Import( aCposCab, aCposDet,aDetNeto,nLin,nLayout )
	EndIf
	TRBREX->(dbGoTop())
	aDetNeto :={}
	FT_FSKIP()
EndDo
TRBREX->(DbCloseArea())
If Empty(cFile)
	lRet:= .F.
EndIf
Return lRet


//-------------------------------------------------------------------
Static Function Import(aCpoMaster,aCpoDetail,aDetNeto,nLin,nLayout )
Local aArea      := GetArea()
Local aAreaSQG   := SQG->( GetArea() )
Local aAreaREY   := REY->( GetArea() )
Local aAreaREZ   := REZ->( GetArea() )
Local nX, nM, nD, nN, cCampo
Local lRet := .T.

dbSelectArea( "SQG" )
dbSetOrder( 3 )

dbSelectArea( "REY" )
REY->(DbSetOrder(RetOrder("REY","REY_FILIAL+REY_CPF+REY_CODCON+REY_FILFUN+REY_CODFUN")))

dbSelectArea( "REZ" )
REZ->(DbSetOrder(RetOrder("REZ","REZ_FILIAL+REZ_CPF+REZ_CODCON+REZ_FILFUN+REZ_CODFUN+REZ_CODREQ")))

//Grava SQG-Curriculos
If Len(aCpoMaster) > 0

	IF empty(aCpoMaster[2,2])
		aAdd(aLog,{strzero(nLin,6)+' -> '+STR0049}) //'CPF em branco'
		lRet := .f.
	EndIf
	IF len(alltrim(aCpoMaster[2,2])) <> 11
		aAdd(aLog,{strzero(nLin,6)+' -> '+STR0050+aCpoMaster[1,2]}) //'CPF com tamanho inválido: '
		lRet := .f.
	EndIf
	IF empty(aCpoMaster[3,2])
		aAdd(aLog,{strzero(nLin,6)+' -> '+STR0051}) //'Nome em branco'
		lRet := .f.
	EndIf
	IF empty(aCpoMaster[12,2])
		aAdd(aLog,{strzero(nLin,6)+' -> '+STR0052}) //'RG em branco'
		lRet := .f.
	EndIf
	IF Len(aCpoDetail) > 0 .and. !(aCpoDetail[1,6,2]>0)
		aAdd(aLog,{strzero(nLin,6)+' -> '+STR0053+strzero(aCpoDetail[1,6,2],6)}) //'Classificação inválida: '
		lRet := .f.
	EndIf
	IF Len(aCpoDetail) > 0 .and. !(aCpoDetail[1,8,2]$"12")
		aAdd(aLog,{strzero(nLin,6)+' -> '+STR0054+cValToChar(aCpoDetail[1,8,2])}) //'Situação inválida: '
		lRet := .f.
	EndIf
	IF Len(aCpoDetail) > 0 .and. nLayOut == 2 .and. !(REC->(dbseek(fwxfilial("REC")+aCpoDetail[1,9,2])))
		aAdd(aLog,{strzero(nLin,6)+' -> '+STR0055+aCpoDetail[1,9,2] }) //'Comarca inválida: '
		lRet := .f.
	EndIf

	If lRet

		If SQG->(dbseek(fwxFilial("SQG")+aCpoMaster[2,2])) //Filial+CPF
			RecLock("SQG",.f.)
		Else
			RecLock("SQG",.t.)
			SQG->QG_CURRIC := GetSX8Num("SQG","QG_CURRIC")
		    ConfirmSx8()
		EndIf

		SQG->QG_FILIAL = xfilial("SQG")
		For nM := 1 to len(aCpoMaster)
	    	cCampo  := "SQG->"+aCpoMaster[nM,1]
	    	&cCampo := aCpoMaster[nM,2]
	    Next nM

		SQG->(MsUnlock())

		//Grava REY-
		If Len(aCpoDetail) > 0
			//Filial+CPF+Concurso+Fil.Funcao+Funcao
			If REY->(dbseek(fwxFilial("REY")+aCpoDetail[1,2,2]+aCpoDetail[1,3,2]+aCpoDetail[1,4,2]+aCpoDetail[1,5,2]))
				RecLock("REY",.f.)
			Else
				RecLock("REY",.t.)
			EndIf

			For nD := 1 to len(aCpoDetail[1])
		    	cCampo  := "REY->"+aCpoDetail[1,nD,1]
	    		&cCampo := aCpoDetail[1,nD,2]
		 	Next nD

			REY->(MsUnlock())

		EndIf

		//Grava REZ-
		If Len(aDetNeto) > 0

			For nX := 1 to len(aDetNeto)

				If REZ->(dbseek(fwxFilial("REZ")+aDetNeto[nX,2,2]+aDetNeto[nX,3,2]+aDetNeto[nX,4,2]+aDetNeto[nX,5,2]+aDetNeto[nX,6,2])) //Filial+CPF+Concurso+Fil.Funcao+Funcao+Requisito
					RecLock("REZ",.f.)
				Else
					RecLock("REZ",.t.)
				EndIf

				For nN := 1 to len(aDetNeto[nX])
			    	cCampo  := "REZ->"+aDetNeto[nX,nN,1]
		    		&cCampo := aDetNeto[nX,nN,2]
			 	Next nN

				REZ->(MsUnlock())

			Next nX

		EndIf

	Endif

EndIf

RestArea( aAreaREZ )
RestArea( aAreaREY )
RestArea( aAreaSQG )
RestArea( aArea )

Return(lRet)


//======================================================
//Query com todas Informações de Requisitos.
//======================================================
Static Function QueryREX()
Local cQuery  := ""


	cQuery := " SELECT * "
	cQuery += " FROM "
	cQuery += + RetSqlName("REX") +  " REX "
	cQuery += " WHERE "
	cQuery += " REX.REX_CODCON = '"+MV_PAR01+ "' AND "
	cQuery += " REX.REX_FILFUN = '"+MV_PAR02+ "' AND "
	cQuery += " REX.REX_CODFUN = '"+MV_PAR03+ "' AND "
	cQuery += " REX.REX_FILIAL = '"+FwxFilial("REX")+"' AND "
	cQuery += " REX.D_E_L_E_T_ = ' ' "

	cQuery = ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),'TRBREX',.T.,.T.)
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³   fImpLog    ³ Autor ³                   ³ Data ³ 24.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Listagem de Log                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fImpLog()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpLog()

SetPrvt("cString,aOrd,aReturn,nTamanho,Titulo,cDesc1,cDesc2,cDesc3,cPerg,cCancel,wCabec1,wCabec2,NomeProg")
SetPrvt("nLastKey,m_pag,li,ContFl,nOrdem,lEnd,wnrel")

//Inicia Variaveis
cString  := '' // Alias do Arquivo Principal
aOrd     := {" "}
aReturn  := { 'Especial', 1,'Administra‡„o', 1, 2, 2,'',1 }
nTamanho := 'P'
Titulo   := STR0057 //'LOG ERROS IMPORTACAO DE CONCURSOS'
cDesc1   := ''
cDesc2   := ''
cDesc3   := ''
cPerg    := ''
cCancel  := STR0058 //'*** ABORTADO PELO OPERADOR ***'
wCabec1	 := ''
wCabec2  := ' '
NomeProg := 'fImpLog'
cArqInd  := ''
cInd	 := ''
nLastKey := 0
m_pag    := 0
li       := 0
ContFl   := 1
nOrdem	 := 0
nX_		 := 0
lEnd     := .F.
wnrel    := 'fImpLog'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,nTamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nOrdem   := aReturn[8]

//Processa Impressao
RptStatus({|lEnd| fImprime()},STR0059) //'Imprimindo...'

Return

//Fim da Rotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  fImprime    ³ Autor ³                   ³ Data ³ 13.01.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Log                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fImprime()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImprime()

Local nX

// Carrega Regua
SetRegua(Len(aLog))

If Len(aLog) == 0
	cDet	:= STR0060 //'Nao Houveram Inconsistencias'
	Impr(cDet,'C')
Endif

For nX := 1 to Len(aLog)

	//Abortado Pelo Operador
	If lAbortPrint
		lEnd := .T.
	Endif

	If lEnd
		cDet := cCancel
		Impr(cDet,'C')
		Exit
	EndIF

	cDet := STR0056+aLog[nX,1] //'Linha '

	Impr(cDet,'C')

	IncRegua(STR0059) //'Imprimindo...'

Next

cDet := Replic('*',80)
Impr(cDet,'C')

cDet := ''
Impr(cDet,'F')

If aReturn[5] == 1
	Set Printer TO
	ourspool(wnrel)
Endif

MS_FLUSH()

Return
