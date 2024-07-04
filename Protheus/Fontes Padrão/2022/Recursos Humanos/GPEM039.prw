#Include 'Protheus.ch'
#Include 'GPEM039.ch'

//Integra��o com o TAF
Static lIntTaf 		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 2 )
Static lMiddleware  := If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

/*/{Protheus.doc} GPEM039
Programa respons�vel por executar os eventos:
[x] S-1295 - Solicita��o de Totaliza��o para Pagamento em Conting�ncia
[-] S-1298 - Reabertura dos Eventos Peri�dicos
[X] S-1299 - Fechamento dos Eventos Peri�dicos

@Return	Nil

@Author   Marcos.Coutinho
@Since    12/10/2017 
@Version  1.0 
@Type     Function

@History 12/10/2017 | Marcos Coutinho      | DRHESOCP-1388  | Gera��o do programa para gera��o do evento S-1295  e S-1299.
@History 18/10/2017 | Marcos Coutinho      | DRHESOCP-1595  | Ajustes necess�rios para n�o exibir o evento S-1298. Criando automa��o da rotina
@History 19/10/2017 | Marcos Coutinho      | DRHESOCP-1595  | Retirando variavel problematica
/*/


Function GPEM039()
Local aArea			:= GetArea()
Local oIndic13		:= Nil
Local cNomeResp		:= Space(TamSx3('RA_NOMECMP')[1])
Local cCPFResp		:= Space(TamSx3('RA_CIC')[1] + 4)
Local cFoneResp		:= Space(TamSx3('RA_TELEFON')[1] + 4)
Local cEmailResp	:= Space(TamSx3('RA_EMAIL')[1])
Local cTitle  		:= OemToAnsi(STR0001) + "-" + OemToAnsi(STR0002) //"Eventos peri�dicos" - "eSocial"
Local cAliasTRB		:= GetNextAlias()
Local nOpcA			:= 1
Local aIndic13		:= {"Nao", "Sim"}
Local aInfo			:= {}
Local aObjects		:= {}
Local aPosObj		:= {}
Local aArrayFil		:= {}
Local aCheck		:= {.F., .F., .F.} /*Caso seja criado novos itens, deve ser alimentado*/
Local aObjCheck		:= Array(Len(aCheck)) //Objetos dos eventos
Local aObjCoords	:= {}
Local oFont
Local aItens 		:= {}
Local oCheck1
Local bFecha		:= {||nOpcA := 2, oDlg:End()}
Local bOK1			:= {||Iif( fGp39TdOk1(cCompete, nRadio, cIndic13, cNomeResp, cCPFResp, cFoneResp, cEmailResp), (fGP039Mark(nRadio, SubStr(cCompete,3,4) + SubStr(cCompete,1,2), aArrayFil, cIndic13,cAliasTRB, AllTrim(cNomeResp), AllTrim(cCPFResp), AllTrim(cFoneResp), AllTrim(cEmailResp), aItens), nOpcA := 1), Nil)}
Local oBtFiliais
Local oBtFechar
Local aTitle		:= {}
Local lInt1295 	
Local lInt1298		 	
Local lInt1299 	
Local bOK3			:= {||Iif(fGp39TdOk3(cAliasTRB,nRadio,SubStr(cCompete,3,4) + SubStr(cCompete,1,2), aArrayFil, cIndic13, AllTrim(cNomeResp), AllTrim(cCPFResp), AllTrim(cFoneResp), AllTrim(cEmailResp), aItens), (oDlg:End(), nOpcB := 1), Nil)}
Local bFecha		:= {||oDlg:End()} 
Local lMArcar		:= .F.                                                                                   

Private cCompete	:= Space(6)
Private cIndic13		:= ""
Private aSM0    	:= FWLoadSM0(.T.,,.T.)
Private nRadio		:= 1
Private oArq1Tmp
Private cRotina		:= "GPEM039"
Private lPar06		:= .F.
Private oMark
Private oDlg                              

Private aLogs		:= {}
Private cPeriodo

Private cVersEnvio	:= ""
Private cVersGPE	:= ""
Private lIntegra	:= .T.

Private oTempTable	:= Nil
Private lSX1Perg	:= SX1->( dbSeek("GPM039") )
Private aPergAux	:= {}
Private oPanel3	
Private aColumns	:= {}

//Verifica Vers�o de Layout Dispon�vel
lInt1295 	:= fVersEsoc("S1295", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio,@cVersGPE)
If lMiddleware
	lInt1298 	:= fVersEsoc("S1298", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio,@cVersGPE)
Endif	
lInt1299 	:= fVersEsoc("S1299", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio,@cVersGPE)

//------------------------------------
//| Verifica se o MV_RHTAF esta ativo 
//------------------------------------
If !lIntTaf .And. !lMiddleware
	Help( ,, OemToAnsi(STR0004) ,,OemToAnsi(STR0003), 1, 0 ) //#"Sistema n�o est� configurado para integra��o com o m�dulo SIGATAF, verifique o par�metro MV_RHTAF." #"Atencao"
	Return()
EndIf

If FindFunction("ESocMsgVer") .And. lIntTaf .And. !lMiddleware .And. cVersGPE <> cVersEnvio .And. (cVersGPE >= "9.0" .Or. cVersEnvio >= "9.0")
	//# "Aten��o! # A vers�o do leiaute GPE � XXX e a do TAF � XXXX, sendo assim, est�o divergentes. A rotina ser� encerrada"
	ESocMsgVer(.T., /*cEvento*/, cVersGPE, cVersEnvio)
	Return()
EndIf

//-------------------------------------------------------------
//| Se nenhum dos eventos est� compatibilizado bloqueia a tela
//-------------------------------------------------------------
If cVersEnvio < "9.0.00"
	if (If(!lMiddleware, !lInt1295 /*.AND. !lInt1298*/ .AND. !lInt1299 , !lInt1295 .And. !lInt1298 .And. !lInt1299 ) )
		Help( ,, OemToAnsi(STR0004) ,,OemToAnsi(STR0038), 1, 0 ) //#"Seu ambiente n�o possui os eventos S-1295, S-1298 e S-1299 compatibilizados para o layout corrente."
		Return()
	Endif
Else
	if (If(!lMiddleware, !lInt1299 , !lInt1298 .And. !lInt1299 ) )
		Help( ,, OemToAnsi(STR0004) ,,OemToAnsi(STR0049), 1, 0 ) //#"Seu ambiente n�o possui os eventos S-1298 e S-1299 compatibilizados para o layout corrente."
		Return()
	Endif
Endif

If !lSX1Perg
	fAlertSX1()
EndIf
//----------------------------------------
//| Gera��o dos Helps dos objetos em tela
//----------------------------------------
fGp39Help()

//------------------------------
//| Cria��o das medidas da tela 
//| Foi mantida a mesma propor��o do prog GPEM034
//------------------------------------------------
aAdvSize			:= MsAdvSize( .F.,.F.,570)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 15 }
	
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize			:= MsObjSize( aInfoAdvSize , aObjCoords )

//----------------------------------
//| Cria��o da tela de apresenta��o 
//------------------------------------------------
Define MsDialog oDlg FROM 0, 0 To 380, 930 Title cTitle Pixel

If cVersEnvio < "9.0.00"
	//Cria o conteiner onde ser�o colocados os paineis
	oTela1	:= FWFormContainer():New( oDlg )
	cIdTel1	:= oTela1:CreateHorizontalBox( 15 )
	cIdTel2	:= oTela1:CreateHorizontalBox( 23 )
	cIdTel3	:= oTela1:CreateHorizontalBox( 57 )
Else
//Cria o conteiner onde ser�o colocados os paineis
	oTela1	:= FWFormContainer():New( oDlg )
	cIdTel1	:= oTela1:CreateHorizontalBox( 15 )
	cIdTel2	:= oTela1:CreateHorizontalBox( 20 )
	cIdTel3	:= oTela1:CreateHorizontalBox( 65 )
Endif

oTela1:Activate( oDlg, .F. )

//Cria os paineis onde serao colocados os browses
oPanel1	:= oTela1:GeTPanel(cIdTel1)
oPanel2	:= oTela1:GeTPanel(cIdTel2)
oPanel3	:= oTela1:GeTPanel(cIdTel3)

//------------------
//| Primeiro Painel
//| Armazena a data de compet�ncia
//---------------------------------
@ aObjSize[1,1]*0.5, aObjSize[1,2]+2       SAY OemToAnsi(STR0006) SIZE 038,007 OF oPanel1 PIXEL //Compet�ncia (MMAAAA)
@ (aObjSize[1,1]*0.5)+8, aObjSize[1,2]+2   MSGET cCompete SIZE 028,007	OF oPanel1 PIXEL WHEN .T. PICTURE "@R 99/9999" 

@ aObjSize[1,1]*0.5, aObjSize[1,2]+80      SAY OemToAnsi(STR0007) SIZE 038,007 OF oPanel1 PIXEL //"Ref. 13 Sal�rio?"
@ (aObjSize[1,1]*0.5)+8, aObjSize[1,2]+80  MSCOMBOBOX oIndic13 VAR cIndic13 ITEMS aIndic13 SIZE 060,007 OF oPanel1 PIXEL WHEN .T.  

//-----------------
//| Segundo Painel
//| Armazena os checkbox com todos os eventos da folha
//-----------------------------------------------------
If cVersEnvio >= "9.0.00"
	If !lMiddleware
		@ 0, aObjSize[1,2] GROUP oGroup TO 28 ,aObjSize[1,4]*0.50 LABEL OemToAnsi(STR0008) OF oPanel2  PIXEL	//"Eventos Folha de Pagamento"
	Else	
		@ 0, aObjSize[1,2] GROUP oGroup TO 35 ,aObjSize[1,4]*0.50 LABEL OemToAnsi(STR0008) OF oPanel2  PIXEL	//"Eventos Folha de Pagamento"
	Endif
Else
	@ 0, aObjSize[1,2] GROUP oGroup TO 40 ,aObjSize[1,4]*0.50 LABEL OemToAnsi(STR0008) OF oPanel2  PIXEL	//"Eventos Folha de Pagamento"

	Iif(lInt1295, Aadd(aItens, OemToAnsi(STR0009) ),"") //S-1295 - Solicita��o de Totaliza��o para Pagamento em Conting�ncia
Endif

oGroup:oFont:=oFont

If lMiddleware
	Iif(lInt1298, Aadd(aItens, OemToAnsi(STR0010) ),"") //S-1298 - Reabertura dos Eventos Peri�dicos
Endif	

Iif(lInt1299, Aadd(aItens, OemToAnsi(STR0011) ),"") //S-1299 - Fechamento dos Eventos Peri�dicos
		
	//Cria o RadioButton
If cVersEnvio < "9.0.00"		
	oCheck1 := TRadMenu():New ( aObjSize[1,1]*0.750, aObjSize[1,2]+005, aItens, /*4*/,oPanel2,/*6*/,/*7*/,/*8*/,/*9*/,/*10*/,/*11*/,/*12*/,250,060,/*15*/,/*16*/,/*17*/,.T.)
	oCheck1:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)} 
Else
	oCheck1 := TRadMenu():New ( aObjSize[1,1]*0.650, aObjSize[1,2]+005, aItens, /*4*/,oPanel2,/*6*/,/*7*/,/*8*/,/*9*/,/*10*/,/*11*/,/*12*/,250,060,/*15*/,/*16*/,/*17*/,.T.)
	oCheck1:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)} 
Endif

If cVersEnvio < "9.0.00"		
	//------------------
	//| Terceiro Painel
	//| Armazena os campos para preenchimento
	//-----------------------------------------------------
	If lSX1Perg
		Pergunte("GPM039",.F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)
		cNomeResp	:= MV_PAR01
		cCPFResp	:= MV_PAR02
		cFoneResp	:= MV_PAR03
		cEmailResp	:= MV_PAR04
	EndIf

	@ 0, aObjSize[1,2]*0.25 GROUP oGroup TO 080,aObjSize[1,4]*0.50 LABEL OemToAnsi(STR0028) OF oPanel3  PIXEL	//"Dados do Respons�vel
	oGroup:oFont:=oFont

	@ aObjSize[1,1]*0.93, aObjSize[1,2]+5      SAY OemToAnsi(STR0029) SIZE 038,007 OF oPanel3 PIXEL //"Nome"
	@ aObjSize[1,1]*0.93, aObjSize[1,2]+30   MSGET cNomeResp SIZE 150,007	OF oPanel3 PIXEL WHEN .T. PICTURE "@!"

	@ aObjSize[1,1]*1.86, aObjSize[1,2]+5      SAY OemToAnsi(STR0030) SIZE 038,007 OF oPanel3 PIXEL //CPF
	@ aObjSize[1,1]*1.86, aObjSize[1,2]+30   MSGET cCPFResp SIZE 050,007	OF oPanel3 PIXEL WHEN .T. PICTURE "@R 999.999.999.99" VALID CGC(cCPFResp,,.F.)

	@ aObjSize[1,1]*2.79, aObjSize[1,2]+5     SAY OemToAnsi(STR0031) SIZE 038,007 OF oPanel3 PIXEL //"Telefone"
	@ aObjSize[1,1]*2.79, aObjSize[1,2]+30  MSGET cFoneResp SIZE 050,007	OF oPanel3 PIXEL WHEN .T. PICTURE "@R (99) 9999-99999"

	@ aObjSize[1,1]*3.72, aObjSize[1,2]+5      SAY OemToAnsi(STR0032) SIZE 038,007 OF oPanel3 PIXEL //E-mail
	@ aObjSize[1,1]*3.72, aObjSize[1,2]+30   MSGET cEmailResp SIZE 150,007	OF oPanel3 PIXEL WHEN .T. PICTURE "@!" VALID IsEmail(cEmailResp)

	//-------------------
		//| A��es dos bot�es
	//| Realiza a cria��o das a��es dos bot�es
	//-----------------------------------------------------
	oBtFiliais	:= TButton():New( aObjSize[1,1]*11.000, aObjSize[1,2]+15+300, "&" + OemToAnsi(STR0014),NIL,bOK1	, 060 , 012 , NIL , NIL , NIL , .T. )	// "Parametros"
	oBtFechar	:= TButton():New( aObjSize[1,1]*11.000, aObjSize[1,2]+15+370, "&" + OemToAnsi(STR0015),NIL,bFecha , 040 , 012 , NIL , NIL , NIL , .T. )	// "Fechar" 
Else
	fGP39MrkS1(nRadio,aArrayFil, cIndic13,cAliasTRB, AllTrim(cNomeResp), AllTrim(cCPFResp), AllTrim(cFoneResp), AllTrim(cEmailResp), aItens, aObjSize,@aColumns)

	oMark:= FWMarkBrowse():New()
	oMark:SetAlias(cAliasTRB)
	//oMark:SetFields(aColumns)
	oMark:SetTemporary(.T.)
	oMark:SetColumns(aColumns)
	oMark:SetOwner(oPanel3)	

	//--------------------------------------
	//| Aponta para qual browse sera criado
	//--------------------------------------
	oMark:SetFieldMark('OK')
	oMark:SetValid({||.T.})
	oMark:AddButton(OemToAnsi(STR0050), bOK3,,,, .F., 2 ) //'Confirmar
	oMark:AddButton(OemToAnsi(STR0051), bfecha ,,,,.F., 2 ) //'Cancelar

	oMark:SetMenuDef("GPEM039")

	oMark:bAllMark := {|| SetMarkAll(oMark:Mark(), lMarcar := !lMarcar,cAliasTRB), oMark:Refresh(.T.)}

	oMark:Activate()

Endif

ACTIVATE MSDIALOG oDlg CENTERED
 
//Finaliza qualquer �rea ainda aberta
If ValType(oTempTable) == "O"
	oTempTable:Delete()
	oTempTable	:= Nil
EndIf

Return

/*/{Protheus.doc}
@Author   Marcos.Coutinho
@Date      06/10/2017
@Type      Static Function
Fun��o respons�vel por fazer a valida��o da Data de Compet�ncia informada no campo
/*/
Function fGp39MAno( cMesAno, nTipo )     
Local cMes
Local cAno
Local dData
Local lRet 	:= .F.
Local nTam

Default nTipo := 1

If Empty( cMesAno ) .Or. ( Len(cMesAno) <> Len(AllTrim(cMesAno)) )
	Return( .F. )
EndIf 

nTam := Len( cMesAno )

If nTipo == 1
	If nTam == 4
		cMes := StrZero(Val(Substr( cMesAno, 1, 2)), 2)
		cAno := StrZero(Val(Substr( cMesAno, 3, 2)), 2)
	ElseIf nTam == 5
		cMes := StrZero(Val(Substr( cMesAno, 1, 2)), 2)
		cAno := StrZero(Val(Substr( cMesAno, 4, 2)), 2)
	ElseIf nTam == 6
		cMes := StrZero(Val(Substr( cMesAno, 1, 2)), 2)
		cAno := StrZero(Val(Substr( cMesAno, 3, 4)), 4)
	ElseIf nTam == 7
		cMes := StrZero(Val(Substr( cMesAno, 1, 2)), 2)
		cAno := StrZero(Val(Substr( cMesAno, 4, 4)), 4)
	EndIf
ElseIf nTipo == 2
	If nTam == 4
		cAno := StrZero(Val(Substr( cMesAno, 1, 2)), 2)
		cMes := StrZero(Val(Substr( cMesAno, 3, 2)), 2)
	ElseIf nTam == 5
		cAno := StrZero(Val(Substr( cMesAno, 1, 2)), 2)
		cMes := StrZero(Val(Substr( cMesAno, 4, 2)), 2)
	ElseIf nTam == 6
		cAno := StrZero(Val(Substr( cMesAno, 1, 4)), 4)
		cMes := StrZero(Val(Substr(cMesAno, 5, 2 )), 2)
	ElseIf nTam == 7
		cAno := StrZero(Val(Substr( cMesAno, 1, 4)), 4)
		cMes := StrZero(Val(Substr( cMesAno, 6, 2)), 2)
	EndIf
EndIf

dData := Ctod( "01/" + cMes + "/" + cAno )

If !Empty(dData) .and. dData >= Ctod( "01/01/1900" ) 
	lRet := .T.
EndIf
Return lRet

/*/{Protheus.doc}
@Author   Marcos.Coutinho
@Date      06/10/2017
@Type      Static Function
Fun��o respons�vel por fazer a valida��o de TudOk dos par�metros informados
/*/
Function fGp39TdOk1(cCompete, nRadio, cIndic13, cNome, cCPF, cFone, cEmail)
Local aArea			:= GetArea()
Local nErro			:= 0
Local nI			:= 0
Local lRet			:= .T.

lTela := .F.   

//-------------------------------
//| Valida��o dos campos em tela
//| Realiza a valida��o se todos os campos est�o preenchidos em tela
//-------------------------------------------------------------------

//-----------------------------------------
//| Consiste a Compet�ncia (forma escrita)
//-----------------------------------------
If !fGp39MAno( cCompete, 1)
	Help( ,, OemToAnsi(STR0004) ,,OemToAnsi(STR0016), 1, 0 )//"Competencia inconsistente"  
	lRet := .F.	
	nErro := 1
Endif

//---------------------------------
//| Consiste a Compet�ncia (vazia)
//---------------------------------	
If Empty(cCompete) .and. nErro = 0
	Help( ,, OemToAnsi(STR0004) ,,OemToAnsi(STR0017), 1, 0 )//#"Necess�rio preencher a compet�ncia."
	lRet := .F.	
	nErro += nErro
Endif

//---------------------------------
//| Consiste o Nome do trabalhador
//---------------------------------
If Empty(cNome) .and. nErro = 0
	Help( ,, OemToAnsi(STR0004) ,,OemToAnsi(STR0033), 1, 0 )//#"Necess�rio preencher o nome do respons�vel."
	lRet := .F.	
	nErro += nErro
Endif

//--------------------------------
//| Consiste o CPF do trabalhador
//--------------------------------
If Empty(cCPF) .and. nErro = 0
	Help( ,, OemToAnsi(STR0004) ,,OemToAnsi(STR0034), 1, 0 )//#"Necess�rio preencher o CPF do respons�vel."
	lRet := .F.	
	nErro += nErro
Endif

//-------------------------------------
//| Consiste o Telefone do trabalhador
//-------------------------------------
If Empty(cFone) .and. nErro = 0
	Help( " ", 1, OemToAnsi(STR0004) ,,OemToAnsi(STR0035), 1 )//#"Necess�rio preencher o telefone do respons�vel."
	lRet := .F.	
	nErro += nErro
Endif

//--------------------------------------------
//| Se encontrado algum erro, aborta processo
//--------------------------------------------
if nErro> 0
	lRet := .F.
eNDIF

If lSX1Perg
	MV_PAR01 	:= cNome
	MV_PAR02	:= cCPF
	MV_PAR03	:= cFone
	MV_PAR04	:= cEmail
	__SaveParam("GPM039", aPergAux)
EndIf

RestArea(aArea)
Return(lRet)

/*/{Protheus.doc}
@Author   Marcos.Coutinho
@Date      06/10/2017
@Type      Static Function
Fun��o respons�vel por fazer a cria��o dos dados tempor�rios das filiais cadastradas no TAF
/*/
Static Function fCriaTmp(cAliasTRB)   

Local oMarkFil		:= Nil
Local oFilAll		:= Nil
Local cArq			:= ""
Local cQryWhere		:= ""
Local nPos			:= 0
Local aArea			:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())
Local aAreaC1E		:= C1E->(GetArea())
Local cAliasC1E  	:= GetNextAlias()
Local oView 		:= FWViewActive()	
Local aStru   		:= {}

Local lInverte  	:= .F.
Local lContinua		:= .T.
Local cMark			:= GetMark()
Local aLstIndices	:= {}
Private cCadastro	:= OemToAnsi(STR0023) //"Filiais"
Private aRotina		:= {}

If Select(cAliasTRB) > 0
	DbSelectArea(cAliasTRB)
	DbCloseArea()
EndIf

//--------------------------------
//| Estrutura da tabela | Colunas
//--------------------------------
Aadd(aStru, {"OK"		, "C", 2						, 0})
Aadd(aStru, {"FILTAF"	, "C", TamSx3("C1E_FILTAF")[1]	, 0})
Aadd(aStru, {"NOME"  	, "C", 100						, 0})
Aadd(aStru, {"CNPJ"  	, "C", TamSx3("CTT_CEI")[1]  	, 0})
Aadd(aStru, {"DTINI" 	, "C", TamSx3("C1E_DTINI")[1]	, 0})
Aadd(aStru, {"DTFIN" 	, "C", TamSx3("C1E_DTFIN")[1]	, 0})

oTempTable := FWTemporaryTable():New(cAliasTRB)
oTempTable:SetFields( aStru )
oTempTable:Create()

//------------------------------------------
//| Buscando dados Complemento Empresa (C1E)
//------------------------------------------	
cQryWhere := "%C1E_ATIVO = '1' AND C1E_MATRIZ = 'T'%"
	
//Query para buscar informacoes de processos e varas		
BeginSql alias cAliasC1E
	SELECT 
		C1E_FILTAF, C1E_NOME, C1E_DTINI, C1E_DTFIN 	, 	C1E_CODFIL 		
	FROM 
		%table:C1E% C1E									
	WHERE
		%exp:cQryWhere% AND C1E.%notDel%	
EndSql				

//Posiciona no inicio do arquivo
dbSelectArea(cAliasC1E)

//----------------------------------------
//| "Gravando" dados na tabela tempor�ria
//---------------------------------------- 
While (cAliasC1E)->(!EOF())
	lContinua := .T.	
	
	//Busca CNPJ
	nPos := aScan(aSM0, {|x| alltrim(x[1] + X[2]) == AllTrim((cAliasC1E)->C1E_CODFIL/*FILTAF*/)})  

	//Alimentando a tabela 
	RecLock(cAliasTRB, .T.)
		(cAliasTRB)->FILTAF	:= (cAliasC1E)->C1E_FILTAF
		(cAliasTRB)->NOME  	:= (cAliasC1E)->C1E_NOME
		(cAliasTRB)->CNPJ 	:= IIF(nPos > 0, aSM0[nPos, 18], "")
		(cAliasTRB)->DTINI 	:= (cAliasC1E)->C1E_DTINI
		(cAliasTRB)->DTFIN 	:= (cAliasC1E)->C1E_DTFIN
	(cAliasTRB)->(MsUnlock()) 
	
	(cAliasC1E)->(dbSkip())
EndDo

//--------------------------------------------
//| Apontando para o primeiro registro v�lido
//--------------------------------------------
(cAliasTRB)->(dbGoTop())
(cAliasC1E)->(DbCloseArea())

RestArea(aAreaSM0)
RestArea(aAreaC1E)
RestArea(aArea)


Return()

/*/{Protheus.doc}
@Author   Marcos.Coutinho
@Date      06/10/2017
@Type      Static Function
Fun��o respons�vel por realizar a checagem das filiais para carga
/*/
Static Function fGP039Mark(nRadio, cCompete, aArrayFil, cIndic13, cAliasTRB, cNome, cCPF, cFone, cEmail, aItens)
Local oSize
Local oPanel4
Local oTela2
Local oGroup
Local oFont    
Local lMArcar		:= .F.                                                                                   
Local bOK2			:= {||Iif(fGp39TdOk2(cAliasTRB), (oDlgGrid:End(), nOpcB := 1), Nil)}
Local bFecha		:= {||oDlgGrid:End()}  
Local nOpcB			:= 0
Local aButtons		:= {}
Local aStru			:= {}
Local aStruCTT		:= {}
Local nX			:= 0
Local nPosFilTaf	:= 0	
Local nPosNome		:= 0 	
Local nPosCnpj		:= 0 
Local nPosDini		:= 0 
Local nPosDfin		:= 0 
Local cPrefixo      := ""
Local cAliasTaf		:= ""

Private cRotina		:= "GPEM039"
Private oMark
Private oDlgGrid
Private aColumns	:= {}

//Tabela Auxiliar
If !lMiddleware
	fCriaTmp(cAliasTRB)
	cPrefixo 	:= "C1E_"
	cAliasTaf 	:= "C1E"
	Dbselectarea(cAliasTaf)
	aStru		    := C1E->(DBSTRUCT())
	Dbselectarea('CTT')
	aStruCTT		    := CTT->(DBSTRUCT())
		
	nPosFilTaf	:= aScan( aStru , { |x| x[1] == "C1E_FILTAF" } )
	nPosNome	:= aScan( aStru , { |x| x[1] == "C1E_NOME" } )
	nPosCnpj	:= aScan( aStruCTT , { |x| x[1] == "CTT_CEI" } )
	nPosDini	:= aScan( aStru , { |x| x[1] == "C1E_DTINI" } )
	nPosDfin	:= aScan( aStru , { |x| x[1] == "C1E_DTFIN" } )
Else
	fCriaTmpMd(cAliasTRB)
	cPrefixo 	:= "RJ9_"
	cAliasTaf 	:= "RJ9"
	Dbselectarea(cAliasTaf)
	aStru		    := RJ9->(DBSTRUCT())
		
	nPosFilTaf	:= aScan( aStru , { |x| x[1] == "RJ9_FILIAL" } )
	nPosNome	:= aScan( aStru , { |x| x[1] == "RJ9_NOME" } )
	nPosCnpj	:= aScan( aStru , { |x| x[1] == "RJ9_NRINSC" } )
	nPosDini	:= aScan( aStru , { |x| x[1] == "RJ9_INI" } )
Endif	

//--------------------------------------------------------------
//| Criando coluna Filial | Atribuindo nome | Dados estruturais 
//--------------------------------------------------------------
If nPosFilTaf > 0 			
	AAdd(aColumns,FWBrwColumn():New())
	If !lMiddleware
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran( aStru[nPosFilTaf][1], cPrefixo, "",1,1   ) +"}") )
	Else
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosFilTaf][1],"RJ9_FILIAL", "FILTAF",1,1   )+"}") )
	Endif	
	aColumns[Len(aColumns)]:SetTitle("Filial" ) 
	aColumns[Len(aColumns)]:SetSize(aStru[nPosFilTaf][3]) 
	aColumns[Len(aColumns)]:SetDecimal(aStru[nPosFilTaf][4])
	aColumns[Len(aColumns)]:SetPicture(PesqPict( cAliasTaf ,  aStru[nPosFilTaf][1]))
EndIf		

//--------------------------------------------------------------
//| Criando coluna Nome   | Atribuindo nome | Dados estruturais 
//--------------------------------------------------------------
If nPosNome > 0 		 	
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosNome][1],cPrefixo, "",1,1   )+"}") )
	aColumns[Len(aColumns)]:SetTitle("Nome") 
	aColumns[Len(aColumns)]:SetSize(aStru[nPosNome][3]) 
	aColumns[Len(aColumns)]:SetDecimal(aStru[nPosNome][4])
	aColumns[Len(aColumns)]:SetPicture(PesqPict( cAliasTaf,  aStru[nPosNome][1]))
EndIf	

//--------------------------------------------------------------
//| Criando coluna CNPJ   | Atribuindo nome | Dados estruturais 
//--------------------------------------------------------------
If nPosCnpj > 0 		 	
	AAdd(aColumns,FWBrwColumn():New())	
	If !lMiddleware
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStruCTT[nPosCnpj][1],"CTT_CEI", "CNPJ",1,1   )+"}") )
	Else
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosCnpj][1],"RJ9_NRINSC", "CNPJ",1,1   )+"}") )
	Endif	
	aColumns[Len(aColumns)]:SetTitle("Cnpj") 
	If !lMiddleware
		aColumns[Len(aColumns)]:SetSize(aStruCTT[nPosCnpj][3]) 
		aColumns[Len(aColumns)]:SetDecimal(aStruCTT[nPosCnpj][4])
	Else
		aColumns[Len(aColumns)]:SetSize(aStru[nPosCnpj][3]) 
		aColumns[Len(aColumns)]:SetDecimal(aStru[nPosCnpj][4])
	Endif	
	aColumns[Len(aColumns)]:SetPicture(  "@R 99.999.999/9999-99"   )
EndIf	

//-------------------------------------------------------------------
//| Criando coluna Data Inicio | Atribuindo nome | Dados estruturais 
//-------------------------------------------------------------------
If nPosDini > 0 		 	
	AAdd(aColumns,FWBrwColumn():New())
	If !lMiddleware
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosDini][1], cPrefixo, "",1,1   )+"}") )
	Else
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosDini][1],"RJ9_INI", "DTINI",1,1   )+"}") )
	Endif	
	aColumns[Len(aColumns)]:SetTitle("Dt. Ini. Validade") 
	aColumns[Len(aColumns)]:SetSize(aStru[nPosDini][3]) 
	aColumns[Len(aColumns)]:SetDecimal(aStru[nPosDini][4])
	aColumns[Len(aColumns)]:SetPicture(PesqPict( cAliasTaf,  aStru[nPosDini][1]))
EndIf	

//-------------------------------------------------------------------
//| Criando coluna Data Final  | Atribuindo nome | Dados estruturais 
//-------------------------------------------------------------------
If nPosDfin > 0 .And. !lMiddleware 		 	
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosDfin][1],"C1E_", "",1,1   )+"}") )
	aColumns[Len(aColumns)]:SetTitle("Dt. Fin. Validade") 
	aColumns[Len(aColumns)]:SetSize(aStru[nPosDfin][3]) 
	aColumns[Len(aColumns)]:SetDecimal(aStru[nPosDfin][4])
	aColumns[Len(aColumns)]:SetPicture(PesqPict("C1E",  aStru[nPosDfin][1]))
EndIf	
	
DbSelectArea(cAliasTRB)

//--------------------------
//| Realiza cria��o da tela 
//--------------------------
oSize := FwDefSize():New(.F.)
oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.1),(oSize:aWindSize[3]*0.4) , .F., .F. )
oSize:aMargins	:= { 0, 0, 0, 0 }	// Espaco ao lado dos objetos 0, entre eles 3		
oSize:lProp		:= .F.				// Proporcional             
oSize:Process()						// Dispara os calculos  

//-----------------------------
//| Cria��o de tela de filiais
//-----------------------------
DEFINE MSDIALOG oDlgGrid TITLE  OemToAnsi( STR0001 ) From 0,0 TO 380,930 OF oMainWnd PIXEL //STR0001

//-----------------------------
//| Cria��o Container de Dados
//-----------------------------
oTela2		:= FWFormContainer():New( oDlgGrid )
cIdGrid  	:= oTela2:CreateHorizontalBox( 80 )        

oTela2:Activate( oDlgGrid, .F. )

//---------------------------------------------------
//| Cria��o dos Paineis onde ser�o exibidos os dados
//---------------------------------------------------
oPanel4	:= oTela2:GeTPanel( cIdGrid )
	
@ oSize:GetDimension("CABECALHO","LININI")+1 , oSize:GetDimension("CABECALHO","COLINI")+4	GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090 ,oSize:GetDimension("CABECALHO","COLEND") * 0.431   LABEL OemToAnsi(STR0001) OF oDlgGrid PIXEL
oGroup:oFont:=oFont
@ oSize:GetDimension("CABECALHO","LININI")+9 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY OemToAnsi(STR0024) Of oDlgGrid Pixel //"Financeiro/Faturamento"
			
oMark:= FWMarkBrowse():New()
oMark:SetAlias(cAliasTrb)
oMark:SetTemporary(.T.)
oMark:SetColumns(aColumns)

//--------------------------------------
//| Aponta para qual browse sera criado
//--------------------------------------
oMark:SetOwner(oPanel4)
oMark:bAllMark := { || SetMarkAll(oMark:Mark(),lMarcar := !lMarcar,cAliasTRB ), oMark:Refresh(.T.)  }

oMark:SetFieldMark('OK')
oMark:SetMenuDef("GPEM039")
oMark:Activate()

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, bOK2 ,bFecha,NIL, aButtons)	                              

if nOpcB == 1      
	 aArrayFil		:= {}
	//Adiciona filiais selecionadas
	(cAliasTRB)->(dbGoTop())
	
	While (cAliasTRB)->(!EOF())
		If !Empty((cAliasTRB)->OK) 
			aAdd(aArrayFil, {Padr((cAliasTRB)->FILTAF, FWSIZEFILIAL()),substr((CALIASTRB)->CNPJ,1,8),{Padr((cAliasTRB)->FILTAF, FWSIZEFILIAL())}})
			For nX := 1 To Len(aSM0)
				If aSM0[nX, 1] == cEmpAnt .And. aSM0[nX, 2] != Padr((cAliasTRB)->FILTAF, FwSizeFilial()) .And. SubStr((cAliasTRB)->CNPJ, 1, 8) == SubStr(aSM0[nX, 18], 1, 8)
					aAdd( aArrayFil[Len(aArrayFil), 3], aSM0[nX, 2] )
				EndIf
			Next nX
		EndIf
		(cAliasTRB)->(dbSkip())	
	EndDo 
	
	fGp39InTaf(nRadio, cCompete, aArrayFil, cIndic13, cNome, cCPF, cFone, cEmail, aItens)
	
	//Finaliza a tela
	oDlg:END()
Endif

Return()

/*/{Protheus.doc}
@Author   Marcos.Coutinho
@Date      06/10/2017
@Type      Static Function
Fun��o respons�vel por fazer a execu��o das fun��es de acordo com o Check marcado
/*/
Static Function fGp39InTaf(nRadio, cCompete, aArrayFil, cIndic13, cNome, cCPF, cFone, cEmail, aItens)

Local aArea	 		:= GetArea()
Local lIndic13		:= cIndic13 == "Sim" //Tipo de Folha
Local aTitle		:= {}
Local aFilInTaf		:= {}
Local cFilEnv		:= ""
Local cEvAux		:= ""
Local nX			:= 1
Local aEvAux		:= {}
Local aFilAux		:= {}
Local lRet			:= .F.


Aadd(aTitle, If(!lMiddleware,OemToAnsi(STR0036),OemToAnsi(STR0041))) //##"Monitoramento Envio de Eventos - TAF" #Middleware
	

//Se existirem filiais com periodo vigente aArrayFil contera informacoes
If Len(aArrayFil) > 0

	//--------------------------------------------
	//| L�gica para defini��o do nRadio - DE/PARA
	//| Se aItens tiver tamanho 3, segue fluxo normal
	//| Se aItens tiver tamanho 2, faz um descobra qual evento temos, faz de-para para saber qual fun��o executar
	//| Se aItens tiver tamanho 1, faz um descobra qual evento temos, faz de-para para saber qual fun��o executar
	//------------------------------------------------------------------------------------------------------------
	//Monta array auxiliar
	For nX := 1 To Len( aItens )
		Aadd(aEvAux, Substr( aItens[nX], 1, 6 ))
	Next
	
	If( Len(aItens) == 2 )
		If aEvAux[1] == "S-1295" .AND. aEvAux[2] == "S-1299"
			If ( nRadio == 1 )
				nRadio := 1
			Else
				nRadio := 3
			EndIf 
		ElseIf aEvAux[1] == "S-1298" .AND. aEvAux[2] == "S-1299"
			If ( nRadio == 1 )
				nRadio := 2
			Else
				nRadio := 3
			EndIf 
		EndIf
	ElseIf( Len(aItens) == 1 )
		If aEvAux[1] == "S-1295"
			nRadio := 1
		ElseIf aEvAux[1] == "S-1298"
			nRadio := 2
		ElseIf aEvAux[1] == "S-1299"
			nRadio := 3
		EndIf
	EndIf

	fGp23Cons(@aFilInTaf, @aFilAux,@cFilEnv)

	//---------------------------------------------------------------------
	//| S-1295 - Solicita��o de Totaliza��o para Pagamento em Conting�ncia
	//---------------------------------------------------------------------	
	If nRadio == 1
		aAdd(aLogs, OemToAnsi(STR0009)) //"S-1295 - Solicita��o de Totaliza��o para Pagamento em Conting�ncia"
		lRet := fNew1295(cCompete, cFilEnv, lIndic13, cVersEnvio, cNome, cCPF, cFone, cEmail, @aLogs, aArrayFil)
	EndIf
	
	//---------------------------------------------
	//| S-1298 - Reabertura dos Eventos Peri�dicos
	//---------------------------------------------
	If nRadio == 2
		aAdd(aLogs, OemToAnsi(STR0010)) //"S-1298 - Reabertura dos Eventos Peri�dicos"
		lRet := fNew1298(cCompete, cFilEnv, lIndic13, cVersEnvio, cNome, cCPF, cFone, cEmail, @aLogs, aArrayFil)
	EndIf
	
	//---------------------------------------------
	//| S-1299 - Fechamento dos Eventos Peri�dicos
	//---------------------------------------------
	If nRadio == 3
		aAdd(aLogs, OemToAnsi(STR0011)) //"S-1299 - Fechamento dos Eventos Peri�dicos"
		lRet := fNew1299(cCompete, cFilEnv, lIndic13, cVersEnvio, cNome, cCPF, cFone, cEmail, @aLogs, aArrayFil)
	EndIf

	//------------------------------
	//| Gera��o do Relat�rio de LOG 
	//------------------------------
	If Len(aLogs) > 0	
		fMakeLog({aLogs}, aTitle, Nil, Nil, , If(!lMiddleware,OemToAnsi(STR0026),OemToAnsi(STR0039)) , "M", "P",, .F.) //"Log de Ocorrencias - Cargas TAF"//Carga Middleware
		aLogs := {}
	Endif
EndIf

RestArea(aArea)
		
Return lRet	

/*/{Protheus.doc}
@Author   Marcos.Coutinho
@Date      06/10/2017
@Type      Static Function
Fun��o respons�vel por fazer a valida��o de TudOk da tela de sele��o de filiais
/*/
Function fGp39TdOk2(cAliasTRB)
Local aArea	:= GetArea()
Local nErro	:= 0
Local nI	:= 0
Local lRet	:= .T.

//Limpa array
aArrayFil := {}     

//Adiciona filiais selecionadas
(cAliasTRB)->(dbGoTop())

While (cAliasTRB)->(!EOF())
	If !Empty((cAliasTRB)->OK) 
		aAdd(aArrayFil, Padr((cAliasTRB)->FILTAF, FWSIZEFILIAL()))
	EndIf
	(cAliasTRB)->(dbSkip())	
EndDo 
			
//Valida filiais 
If Len(aArrayFil) == 0 		
	MsgStop(If(!lMiddleware,OemToAnsi(STR0027),OemToAnsi(STR0040))) //#"Necess�rio selecionar uma filial para integra��o com o TAF"//Middleware
	lRet := .F.
EndIf

RestArea(aArea)
Return(lRet)

/*/{Protheus.doc}
@Author   Marcos.Coutinho
@Date      06/10/2017
@Type      Static Function
Fun��o respons�vel por Criar os Helps utilizados nos campos TGET
/*/
Static Function fGp39Help()

Local aArea		:= GetArea()
Local cKey  	:= ""
Local aHelpPor	:= {}
Local aHelpSpa	:= {}
Local aHelpEng	:= {}

//----------------------
//| Help da Compet�ncia
//----------------------
cKey  := "PCCOMPETE"

If !lMiddleware
	AAdd(aHelpPor, "Insira a compet�ncia para as integra��es")
	AAdd(aHelpPor, "dos eventos peri�dicos com o SIGATAF.")
	AAdd(aHelpEng, "Insira a compet�ncia para as integra��es")
	AAdd(aHelpEng, "dos eventos peri�dicos com o SIGATAF.")
	AAdd(aHelpSpa, "Insira a compet�ncia para as integra��es")
	AAdd(aHelpSpa, "dos eventos peri�dicos com o SIGATAF.")
Else
	AAdd(aHelpPor, "Insira a compet�ncia para as integra��es")
	AAdd(aHelpPor, "dos eventos peri�dicos com o Middleware.")
	AAdd(aHelpEng, "Insira a compet�ncia para as integra��es")
	AAdd(aHelpEng, "dos eventos peri�dicos com o Middleware.")
	AAdd(aHelpSpa, "Insira a compet�ncia para as integra��es")
	AAdd(aHelpSpa, "dos eventos peri�dicos com o Middleware.")
Endif
PutHelp(cKey, aHelpPor, aHelpEng, aHelpSpa)

If cVersEnvio <= "9.0.00"
	//------------------------------
	//| Help do Nome do Trabalhador
	//------------------------------
	aHelpPor	:= {}
	aHelpSpa	:= {}
	aHelpEng	:= {}
	cKey		:= "PCNOMERESP"

	AAdd(aHelpPor, "Insira a nome do trabalhador respons�vel")
	AAdd(aHelpPor, "pela gera��o do evento.")
	AAdd(aHelpEng, "Insira a nome do trabalhador respons�vel")
	AAdd(aHelpEng, "pela gera��o do evento.")
	AAdd(aHelpSpa, "Insira a nome do trabalhador respons�vel")
	AAdd(aHelpSpa, "pela gera��o do evento.")

	PutHelp(cKey, aHelpPor, aHelpEng, aHelpSpa)

	//-----------------------------
	//| Help do CPF do Respons�vel
	//-----------------------------
	aHelpPor	:= {}
	aHelpSpa	:= {}
	aHelpEng	:= {}
	cKey		:= "PCCPFRESP"

	AAdd(aHelpPor, "Insira o CPF do trabalhador respons�vel")
	AAdd(aHelpPor, "pela gera��o do evento.")
	AAdd(aHelpEng, "Insira o CPF do trabalhador respons�vel")
	AAdd(aHelpEng, "pela gera��o do evento.")
	AAdd(aHelpSpa, "Insira o CPF do trabalhador respons�vel")
	AAdd(aHelpSpa, "pela gera��o do evento.")

	PutHelp(cKey, aHelpPor, aHelpEng, aHelpSpa)

	//----------------------------------
	//| Help do Telefone do Respons�vel
	//----------------------------------
	aHelpPor	:= {}
	aHelpSpa	:= {}
	aHelpEng	:= {}
	cKey		:= "PCFONERESP"

	AAdd(aHelpPor, "Insira o telefone do trabalhador respons�vel")
	AAdd(aHelpPor, "pela gera��o do evento.")
	AAdd(aHelpEng, "Insira o telefone do trabalhador respons�vel")
	AAdd(aHelpEng, "pela gera��o do evento.")
	AAdd(aHelpSpa, "Insira o telefone do trabalhador respons�vel")
	AAdd(aHelpSpa, "pela gera��o do evento.")

	PutHelp(cKey, aHelpPor, aHelpEng, aHelpSpa)

	//-------------------------------
	//| Help do Email do Respons�vel
	//-------------------------------
	aHelpPor	:= {}
	aHelpSpa	:= {}
	aHelpEng	:= {}
	cKey		:= "PCEMAILRESP"

	AAdd(aHelpPor, "Insira o Email do trabalhador respons�vel")
	AAdd(aHelpPor, "pela gera��o do evento.")
	AAdd(aHelpEng, "Insira o Email do trabalhador respons�vel")
	AAdd(aHelpEng, "pela gera��o do evento.")
	AAdd(aHelpSpa, "Insira o Email do trabalhador respons�vel")
	AAdd(aHelpSpa, "pela gera��o do evento.")

	PutHelp(cKey, aHelpPor, aHelpEng, aHelpSpa)

Endif
RestArea(aArea)

Return()

/*/{Protheus.doc}
@Author   Marcos.Coutinho
@Date      06/10/2017
@Type      Static Function
Fun��o respons�vel por Marcar/Desmarcar todos os itens
/*/
Static Function SetMarkAll(cMarca,lMarcar,cAliasTRB)

Local cAliasMark:=cAliasTRB
Local aAreaMark  := (cAliasMark)->( GetArea() )

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

While !(cAliasMark)->( Eof() )
	RecLock( (cAliasMark), .F. )
	(cAliasMark)->OK := IIf( lMarcar , cMarca, '  ' )
	MsUnLock()
	(cAliasMark)->( dbSkip() )
EndDo

RestArea(aAreaMark)
Return .T.


/*/{Protheus.doc}
@Author   Silvia Taguti  
@Date      13/11/2019
@Type      Static Function
Fun��o respons�vel por fazer a cria��o dos dados tempor�rios das filiais cadastradas no Middleware
/*/
Static Function fCriaTmpMd(cAliasTRB)   

Local oMarkFil		:= Nil
Local oFilAll		:= Nil
Local cArq			:= ""
Local cQryWhere		:= ""
Local nPos			:= 0
Local aArea			:= GetArea()
Local aAreaRJ9		:= RJ9->(GetArea())
Local cAliasRJ9  	:= GetNextAlias()
Local oView 		:= FWViewActive()	
Local aStru   		:= {}
Local aSM0    		:= FWLoadSM0(.T.,,.T.)
Local nPos			:= 0

Local cMark			:= GetMark()
Local aLstIndices	:= {}
Private cCadastro	:= OemToAnsi(STR0023) //"Filiais"
Private aRotina		:= {}

If Select(cAliasTRB) > 0
	DbSelectArea(cAliasTRB)
	DbCloseArea()
EndIf

//--------------------------------
//| Estrutura da tabela | Colunas
//--------------------------------

DbSelectArea("RJ9")
RJ9->(dbSetOrder(5))

    //Estrutura da tabela temporaria
    Aadd(aStru, {"OK"		, "C", 2						, 0})
    Aadd(aStru, {"FILTAF"	, "C", TamSx3("RJ9_FILIAL")[1]	, 0})
    Aadd(aStru, {"NOME"  	, "C", 100						, 0})
    Aadd(aStru, {"CNPJ"  	, "C", TamSx3("RJ9_NRINSC")[1]  	, 0})
    Aadd(aStru, {"DTINI" 	, "C", TamSx3("RJ9_INI")[1]	, 0})

    oTempTable := FWTemporaryTable():New(cAliasTRB)
    oTempTable:SetFields(aStru)
    oTempTable:AddIndex( "01", {"FILTAF"} )
    oTempTable:Create()

	RJ9->(dbGoTop())
	While !RJ9->(EOF())
		nPos := aScan(aSM0, {|x| Alltrim(x[1] + X[18]) ==  Alltrim(cEmpAnt+RJ9->RJ9_NRINSC) })
		If nPos > 0
			RecLock(cAliasTRB, .T.)
				(cAliasTRB)->FILTAF	:= aSM0[nPos, 2]		
				(cAliasTRB)->NOME  	:= RJ9->RJ9_NOME       
				(cAliasTRB)->CNPJ 	:= RJ9->RJ9_NRINSC		
				(cAliasTRB)->DTINI  := RJ9->RJ9_INI
				(cAliasTRB)->(MsUnlock())
		Endif
		RJ9->(dbSkip())
		
	Enddo

//--------------------------------------------
//| Apontando para o primeiro registro v�lido
//--------------------------------------------
RJ9->(DbCloseArea())

RestArea(aAreaRJ9)
RestArea(aArea)

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} fAlertSX1
Fun��o para exibi��o de alerta e link para o TDN com orienta��o sobre atualiza��o do SX1
@author Allyson Mesashi
@since 24/03/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fAlertSX1()
Local oButton1
Local oButton2
Local oCheckBo1
Local lCheckBo1 	:= .F.
Local oGroup1
Local oPanel1
Local oSay1
Local cSession		:= "AlertaGPEM039_"
Local lChkMsg 		:= fwGetProfString(cSession,"MSG_GPEM039_" + cUserName,'',.T.) == ""
Local oDlg

If lChkMsg
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0042) FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL //"Atualiza��o de dicion�rio"

		@ 000, 000 MSPANEL oPanel1 SIZE 300, 150 OF oDlg COLORS 0, 16777215 RAISED
		@ 005, 012 GROUP oGroup1 TO 055, 237 PROMPT OemToAnsi(STR0004) OF oPanel1 COLOR 0, 16777215 PIXEL //"Aten��o"
		@ 020, 017 SAY oSay1 PROMPT OemToAnsi(STR0043) SIZE 215, 035 OF oPanel1 COLORS 0, 16777215 PIXEL //'Foi liberada uma atualiza��o de dicion�rio para melhoria no processo de gera��o dos eventos de fechamento, que permite salvar os dados do respons�vel pela gera��o. Clique em "Abrir Link" para consultar a documenta��o no TDN'
		@ 080, 012 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT OEMToAnsi(STR0044) SIZE 067, 008 OF oPanel1 COLORS 0, 16777215 PIXEL //"N�o exibir novamente"
		@ 070, 160 BUTTON oButton1 PROMPT STR0045 SIZE 037, 012 OF oPanel1 PIXEL//"Abrir Link"
		@ 070, 200 BUTTON oButton2 PROMPT "OK" SIZE 037, 012 OF oPanel1 PIXEL

		oButton1:bLClicked := {|| ShellExecute("open","https://tdn.totvs.com/x/n5h3I","","",1) }
		oButton2:bLClicked := {|| oDlg:End() }

	ACTIVATE MSDIALOG oDlg CENTERED

	If lCheckBo1
		fwWriteProfString(cSession, "MSG_GPEM039_" + cUserName, 'CHECKED', .T.)
	EndIf	
EndIf

Return

/*/{Protheus.doc}
@Author   Silvia Taguti
@Date      12/04/2021
@Type      Static Function
Fun��o respons�vel por realizar a checagem das filiais para carga
/*/
Static Function fGP39MrkS1(nRadio, aArrayFil, cIndic13, cAliasTRB, cNome, cCPF, cFone, cEmail, aItens,aObjSize,aColumns)

Local lMArcar		:= .F.                                                                                   
Local nOpcB			:= 0
Local aStru			:= {}
Local aStruCTT		:= {}
Local nPosFilTaf	:= 0	
Local nPosNome		:= 0 	
Local nPosCnpj		:= 0 
Local nPosDini		:= 0 
Local nPosDfin		:= 0 
Local cPrefixo      := ""
Local cAliasTaf		:= ""

Private cRotina		:= "GPEM039"
Private oMark
Private oDlgGrid
//Private aColumns	:= {}

//Tabela Auxiliar
If !lMiddleware
	fCriaTmp(cAliasTRB)
	cPrefixo 	:= "C1E_"
	cAliasTaf 	:= "C1E"
	Dbselectarea(cAliasTaf)
	aStru		    := C1E->(DBSTRUCT())
	Dbselectarea('CTT')
	aStruCTT		    := CTT->(DBSTRUCT())
		
	nPosFilTaf	:= aScan( aStru , { |x| x[1] == "C1E_FILTAF" } )
	nPosNome	:= aScan( aStru , { |x| x[1] == "C1E_NOME" } )
	nPosCnpj	:= aScan( aStruCTT , { |x| x[1] == "CTT_CEI" } )
	nPosDini	:= aScan( aStru , { |x| x[1] == "C1E_DTINI" } )
	nPosDfin	:= aScan( aStru , { |x| x[1] == "C1E_DTFIN" } )
Else
	fCriaTmpMd(cAliasTRB)
	cPrefixo 	:= "RJ9_"
	cAliasTaf 	:= "RJ9"
	Dbselectarea(cAliasTaf)
	aStru		    := RJ9->(DBSTRUCT())
		
	nPosFilTaf	:= aScan( aStru , { |x| x[1] == "RJ9_FILIAL" } )
	nPosNome	:= aScan( aStru , { |x| x[1] == "RJ9_NOME" } )
	nPosCnpj	:= aScan( aStru , { |x| x[1] == "RJ9_NRINSC" } )
	nPosDini	:= aScan( aStru , { |x| x[1] == "RJ9_INI" } )
Endif	

//--------------------------------------------------------------
//| Criando coluna Filial | Atribuindo nome | Dados estruturais 
//--------------------------------------------------------------
If nPosFilTaf > 0 			
	AAdd(aColumns,FWBrwColumn():New())
	If !lMiddleware
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran( aStru[nPosFilTaf][1], cPrefixo, "",1,1   ) +"}") )
	Else
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosFilTaf][1],"RJ9_FILIAL", "FILTAF",1,1   )+"}") )
	Endif	
	aColumns[Len(aColumns)]:SetTitle("Filial" ) 
	aColumns[Len(aColumns)]:SetSize(aStru[nPosFilTaf][3]) 
	aColumns[Len(aColumns)]:SetDecimal(aStru[nPosFilTaf][4])
	aColumns[Len(aColumns)]:SetPicture(PesqPict( cAliasTaf ,  aStru[nPosFilTaf][1]))
EndIf		

//--------------------------------------------------------------
//| Criando coluna Nome   | Atribuindo nome | Dados estruturais 
//--------------------------------------------------------------
If nPosNome > 0 		 	
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosNome][1],cPrefixo, "",1,1   )+"}") )
	aColumns[Len(aColumns)]:SetTitle("Nome") 
	aColumns[Len(aColumns)]:SetSize(aStru[nPosNome][3]) 
	aColumns[Len(aColumns)]:SetDecimal(aStru[nPosNome][4])
	aColumns[Len(aColumns)]:SetPicture(PesqPict( cAliasTaf,  aStru[nPosNome][1]))
EndIf	

//--------------------------------------------------------------
//| Criando coluna CNPJ   | Atribuindo nome | Dados estruturais 
//--------------------------------------------------------------
If nPosCnpj > 0 		 	
	AAdd(aColumns,FWBrwColumn():New())	
	If !lMiddleware
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStruCTT[nPosCnpj][1],"CTT_CEI", "CNPJ",1,1   )+"}") )
	Else
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosCnpj][1],"RJ9_NRINSC", "CNPJ",1,1   )+"}") )
	Endif	
	aColumns[Len(aColumns)]:SetTitle("Cnpj") 
	If !lMiddleware
		aColumns[Len(aColumns)]:SetSize(aStruCTT[nPosCnpj][3]) 
		aColumns[Len(aColumns)]:SetDecimal(aStruCTT[nPosCnpj][4])
	Else
		aColumns[Len(aColumns)]:SetSize(aStru[nPosCnpj][3]) 
		aColumns[Len(aColumns)]:SetDecimal(aStru[nPosCnpj][4])
	Endif	
	aColumns[Len(aColumns)]:SetPicture(  "@R 99.999.999/9999-99"   )
EndIf	

//-------------------------------------------------------------------
//| Criando coluna Data Inicio | Atribuindo nome | Dados estruturais 
//-------------------------------------------------------------------
If nPosDini > 0 		 	
	AAdd(aColumns,FWBrwColumn():New())
	If !lMiddleware
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosDini][1], cPrefixo, "",1,1   )+"}") )
	Else
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosDini][1],"RJ9_INI", "DTINI",1,1   )+"}") )
	Endif	
	aColumns[Len(aColumns)]:SetTitle("Dt. Ini. Validade") 
	aColumns[Len(aColumns)]:SetSize(aStru[nPosDini][3]) 
	aColumns[Len(aColumns)]:SetDecimal(aStru[nPosDini][4])
	aColumns[Len(aColumns)]:SetPicture(PesqPict( cAliasTaf,  aStru[nPosDini][1]))
EndIf	

//-------------------------------------------------------------------
//| Criando coluna Data Final  | Atribuindo nome | Dados estruturais 
//-------------------------------------------------------------------
If nPosDfin > 0 .And. !lMiddleware 		 	
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosDfin][1],"C1E_", "",1,1   )+"}") )
	aColumns[Len(aColumns)]:SetTitle("Dt. Fin. Validade") 
	aColumns[Len(aColumns)]:SetSize(aStru[nPosDfin][3]) 
	aColumns[Len(aColumns)]:SetDecimal(aStru[nPosDfin][4])
	aColumns[Len(aColumns)]:SetPicture(PesqPict("C1E",  aStru[nPosDfin][1]))
EndIf	
	
Return()

/*/{Protheus.doc}
@Author   Silvia Taguti
@Date      12/04/2021
@Type      Static Function
Fun��o respons�vel por fazer a valida��o de TudOk da tela de sele��o de filiais
/*/
Function fGp39TdOk3(cAliasTRB,nRadio,cCompete,aArrayFil, cIndic13, cNome, cCPF, cFone, cEmail, aItens)
Local aArea	:= GetArea()
Local nErro	:= 0
Local lRet	:= .T.
Local nx 	:= 0	

//-----------------------------------------
//| Consiste a Compet�ncia (forma escrita)
//-----------------------------------------
If !fGp39MAno( cCompete, 2)
	Help( ,, OemToAnsi(STR0004) ,,OemToAnsi(STR0016), 1, 0 )//"Competencia inconsistente"  
	lRet := .F.	
	nErro := 1
Endif

//---------------------------------
//| Consiste a Compet�ncia (vazia)
//---------------------------------	
If Empty(cCompete) .and. nErro = 0
	Help( ,, OemToAnsi(STR0004) ,,OemToAnsi(STR0017), 1, 0 )//#"Necess�rio preencher a compet�ncia."
	lRet := .F.	
	nErro += nErro
Endif

If lRet
	//Limpa array
	aArrayFil := {}     

	//Adiciona filiais selecionadas
	(cAliasTRB)->(dbGoTop())

	While (cAliasTRB)->(!EOF())
		If !Empty((cAliasTRB)->OK) 
			aAdd(aArrayFil, Padr((cAliasTRB)->FILTAF, FWSIZEFILIAL()))
		EndIf
		(cAliasTRB)->(dbSkip())	
	EndDo 
				
	//Valida filiais 
	If Len(aArrayFil) == 0 		
		MsgStop(If(!lMiddleware,OemToAnsi(STR0027),OemToAnsi(STR0040))) //#"Necess�rio selecionar uma filial para integra��o com o TAF"//Middleware
		lRet := .F.
	EndIf
Endif

If lRet
	 aArrayFil		:= {}
	//Adiciona filiais selecionadas
	(cAliasTRB)->(dbGoTop())
	
	While (cAliasTRB)->(!EOF())
		If !Empty((cAliasTRB)->OK) 
			aAdd(aArrayFil, {Padr((cAliasTRB)->FILTAF, FWSIZEFILIAL()),substr((CALIASTRB)->CNPJ,1,8),{Padr((cAliasTRB)->FILTAF, FWSIZEFILIAL())}})
			For nX := 1 To Len(aSM0)
				If aSM0[nX, 1] == cEmpAnt .And. aSM0[nX, 2] != Padr((cAliasTRB)->FILTAF, FwSizeFilial()) .And. SubStr((cAliasTRB)->CNPJ, 1, 8) == SubStr(aSM0[nX, 18], 1, 8)
					aAdd( aArrayFil[Len(aArrayFil), 3], aSM0[nX, 2] )
				EndIf
			Next nX
		EndIf
		(cAliasTRB)->(dbSkip())	
	EndDo 
	
	fGp39InTaf(nRadio, cCompete, aArrayFil, cIndic13, cNome, cCPF, cFone, cEmail, aItens)
Endif	

RestArea(aArea)

Return(lRet)

