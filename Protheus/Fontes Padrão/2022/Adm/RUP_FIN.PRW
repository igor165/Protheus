#Include 'Protheus.ch'

//------------------------------------------------------------------------------
/*/{Protheus.doc} RUP_FIN()

Funções de compatibilização e/ou conversão de dados para as tabelas do sistema.

@sample		RUP_FIN("12", "2", "003", "005", "BRA")

@param		cVersion	- Versão do Protheus 
@param		cMode		- Modo de execução		- "1" = Por grupo de empresas / "2" =Por grupo de empresas + filial (filial completa)
@param		cRelStart	- Release de partida	- (Este seria o Release no qual o cliente está)
@param		cRelFinish	- Release de chegada	- (Este seria o Release ao final da atualização)
@param		cLocaliz	- Localização (país)	- Ex. "BRA"

@return		Nil

@author	Caique Bispo Ferreira
@since		12/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function RUP_FIN(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

Local aArea As Array
Local aAreaSX3 As Array
Local nTam As Numeric
Local nX As Numeric
Local cOrdem1 As Char
Local cOrdem2 As Char

conout("[RUP_FIN] Verificando necessidade de atualizacao... ")
conout('[RUP_FIN] Versao: ' + cVersion + ' / Modo: ' + cMode + ' / Release Inicial: ' + cRelStart + ' Release Final:  ' + cRelFinish)

// Necessidade de alteração única por grupo de empresas
If cMode == "1"

	aArea := GetArea()
	aAreaSX3 := SX3->(GetArea())
	nTam := 0
	nX := 0
	cOrdem1	:= ""
	cOrdem2	:= ""

	If cRelStart <= "017" .and. cLocaliz == "BRA"

		conout("[RUP_FIN] Ajustando a ordenacao de campos das tabelas SED e SE2...")
		conout("[RUP_FIN] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

		SX3->(dbSetOrder(2)) // X3_CAMPO

		If SX3->(DbSeek("ED_CDDEDA"))
			RecLock("SX3",.F.)
			Replace X3_ORDEM  With "62"
			MsUnlock()
		EndIf
	
		If SX3->(DbSeek("ED_DTFCCZ"))
			RecLock("SX3",.F.)
			Replace X3_ORDEM  With "58"
			MsUnlock()
		EndIf
		
		//ordena a ordem dos campos do dados bancarios do fornecedor no titulo
		// para todos os paises, caso esteja fora de ordem
		If SX3->(DbSeek("E2_FORBCO"))
			cOrdem1 := SX3->X3_ORDEM
		EndIf
	
		If SX3->(DbSeek("E2_FORAGE"))
			cOrdem2 := SX3->X3_ORDEM
		EndIf
	
		If cOrdem1 > cOrdem2
			
			If SX3->(DbSeek("E2_FORBCO"))
				RecLock("SX3",.F.)
				Replace X3_ORDEM  With cOrdem2
				MsUnlock()
			EndIf	
			
			If SX3->(DbSeek("E2_FORAGE"))
				cOrdem2 := Val( RetAsc( cOrdem2, 3, .F. ) )
				cOrdem2 := RetAsc(Str(cOrdem2+1),2,.T.)
				RecLock("SX3",.F.)
				Replace X3_ORDEM  With cOrdem2
				MsUnlock()
			EndIf
		
			If SX3->(DbSeek("E2_FAGEDV"))
				cOrdem2 := Val( RetAsc( cOrdem2, 3, .F. ) )
				cOrdem2 := RetAsc(Str(cOrdem2+1),2,.T.)
				RecLock("SX3",.F.)
				Replace X3_ORDEM  With cOrdem2
				MsUnlock()
			EndIf
		
			If SX3->(DbSeek("E2_FORCTA"))
				cOrdem2 := Val( RetAsc( cOrdem2, 3, .F. ) )
				cOrdem2 := RetAsc(Str(cOrdem2+1),2,.T.)
				RecLock("SX3",.F.)
				Replace X3_ORDEM  With cOrdem2
				MsUnlock()
			EndIf
		
			If SX3->(DbSeek("E2_FCTADV"))
				cOrdem2 := Val( RetAsc( cOrdem2, 3, .F. ) )
				cOrdem2 := RetAsc(Str(cOrdem2+1),2,.T.)
				RecLock("SX3",.F.)
				Replace X3_ORDEM  With cOrdem2
				MsUnlock()
			EndIf
	
		EndIf

		//Corrige os titulos dos campos da tabela de complemento do titulo
		FINATUTit()

		//Redefine alguns campos do cadastro de parâmetros de bancos
		FinAtuBco() 

		RestArea(aAreaSX3)
		RestArea(aArea)

		FINAtuSX6()

		//Atualiza relacionamentos entre tabelas
		FinAtuSX1()

		FINAtuSX9( cLocaliz,cRelFinish )	
	
	Endif

	conout("[RUP_FIN] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

Endif

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc}  FINAtuTit()
Filtro 

@author Karen Yoshie Honda
   
@version P12.1.17
@since   12/06/2017
@return  Nil
@obs
/*/
//------------------------------------------------------------------------------
Static Function FINAtuTit()

conout("[RUP_FIN] Ajustando os titulos dos campos da tabela de complemento do titulo...")
conout("[RUP_FIN] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

AjustaSx3("FKE_IDFKE",	 	{ { "X3_TITULO", 'Código' }, { "X3_DESCRIC", 'Cod. complemento imposto' }, {"X3_ORDEM", '02'} }, { }, { }, {|| .T.} )
AjustaSx3("FKE_DESCR",	 	{ { "X3_TITULO", 'Descrição' }, { "X3_DESCRIC", 'Desc. Complemento imposto' } ,{"X3_ORDEM", '03'} }, { }, { }, {|| .T.} )
AjustaSx3("FKE_TPIMP",	 	{ { "X3_TITULO", 'Tipo Imposto' }, { "X3_DESCRIC", 'Tipo do Imposto' },{"X3_ORDEM", '04'} }, { }, { }, {|| .T.} )
AjustaSx3("FKE_DEDACR",	 	{ { "X3_TITULO", 'Ação' }, { "X3_DESCRIC", 'Deduz ou Adic. ao Imposto' },{"X3_ORDEM", '05'} }, { }, { }, {|| .T.} )
AjustaSx3("FKE_APLICA",	 	{ { "X3_TITULO", 'Aplicação' }, { "X3_DESCRIC", 'Ap.regra na base ou valor' } ,{"X3_ORDEM", '06'}}, { }, { }, {|| .T.} )
AjustaSx3("FKE_CARTEI",	 	{ { "X3_TITULO", 'Carteira' }, { "X3_DESCRIC", 'Regra valida p/ carteira' },{"X3_ORDEM", '07'} }, { }, { }, {|| .T.} )
AjustaSx3("FKE_CALCUL",	 	{ {"X3_ORDEM", '08'} }, { }, { }, {|| .T.} )
AjustaSx3("FKE_PERCEN",	 	{ {"X3_ORDEM", '09'} }, { }, { }, {|| .T.} )
AjustaSx3("FKE_TPATRB",	 	{ { "X3_TITULO", 'Tipo Ação' }, { "X3_DESCRIC", 'Tipo ação do complem. imp' },{"X3_ORDEM", '10'} }, { }, { }, {|| .T.} )
AjustaSx3("FKE_DESATR",	 	{ { "X3_TITULO", 'Descr.Compl' }, { "X3_DESCRIC", 'Descrição complemento' } , {"X3_ORDEM", '11'} }, { }, { }, {|| .T.} )

AjustaSx3("FKF_CPRB",	 	{ { "X3_TITULO", 'Ret. CPRB' }, { "X3_DESCRIC", 'Indicativo Retenção CPRB' }, {"X3_RELACAO", "F986CPRBIni()"} }, { }, { }, {|| .T.} )
AjustaSx3("FKF_CNAE",	 	{ { "X3_TITULO", 'CNAE' }, { "X3_DESCRIC", 'Código atividade econômic' } }, { }, { }, {|| .T.} )
AjustaSx3("FKF_TPREPA",	 	{ { "X3_TITULO", 'Tp. Repasse' }, { "X3_DESCRIC", 'Tipo de Repasse' } , {"X3_F3","0G"}, {"X3_CBOX", ""},{"X3_CBOXSPA", ""},{"X3_CBOXENG", ""}}, { }, { }, {|| .T.} )
AjustaSx3("FKF_INDSUS",	 	{ { "X3_TITULO", 'Susp. INSS' }, { "X3_DESCRIC", 'Ind.Exigibilidade Suspens' } }, { }, { }, {|| .T.} )
AjustaSx3("FKF_INDDEC",	 	{ { "X3_TITULO", 'Ind 13o. Sal' }, { "X3_DESCRIC", 'Indicativo de 13o Salário' } }, { }, { }, {|| .T.} )
AjustaSx3("FKF_TPSERV",	 	{ { "X3_TITULO", 'Tipo serviço' }, { "X3_DESCRIC", 'Classif tipo de serviço' } }, { }, { }, {|| .T.} )
AjustaSx3("FKF_CNO",	 	{ { "X3_TITULO", 'Cod. CNO' }, { "X3_DESCRIC", 'Código do CNO' } }, { }, { }, {|| .T.} )

AjustaSx3("FKG_IDFKE",	 	{ { "X3_TITULO", 'Código' }, { "X3_DESCRIC", 'Cod. complemento imposto' }, {"X3_ORDEM", '04'} }, { }, { }, {|| .T.} )
AjustaSx3("FKG_TPIMP",	 	{ { "X3_TITULO", 'Tipo Imposto' }, { "X3_DESCRIC", 'Tipo do Imposto' }, {"X3_ORDEM", '05'} }, { }, { }, {|| .T.} )
AjustaSx3("FKG_DEDACR",	 	{ { "X3_TITULO", 'Ação' }, { "X3_DESCRIC", 'Deduz ou Adic. ao Imposto' }, {"X3_ORDEM", '06'} }, { }, { }, {|| .T.} )
AjustaSx3("FKG_APLICA",	 	{ { "X3_TITULO", 'Aplicação' }, { "X3_DESCRIC", 'Ap.regra na base ou valor' }, {"X3_ORDEM", '07'} }, { }, { }, {|| .T.} )
AjustaSx3("FKG_CALCUL",	 	{ {"X3_ORDEM", '08'} }, { }, { }, {|| .T.} )
AjustaSx3("FKG_PERCEN",	 	{ {"X3_ORDEM", '09'} }, { }, { }, {|| .T.} )

AjustaSx3("FKG_TPATRB",	 	{ { "X3_TITULO", 'Tipo Ação' }, { "X3_DESCRIC", 'Tipo ação do complem. imp' }, {"X3_ORDEM", '10'} }, { }, { }, {|| .T.} )
AjustaSx3("FKG_DESATR",	 	{ { "X3_TITULO", 'Descr.Compl' }, { "X3_DESCRIC", 'Descrição complemento' }, {"X3_ORDEM", '11'} }, { }, { }, {|| .T.} )
AjustaSx3("FKG_DESCR",	 	{ { "X3_TITULO", 'Descrição' }, { "X3_DESCRIC", 'Descrição' } , {"X3_ORDEM", '12'} }, { }, { }, {|| .T.} )
AjustaSx3("FKG_VALOR",	 	{ { "X3_TITULO", 'Valor' }, { "X3_DESCRIC", 'Valor de dedução/adição' } , {"X3_ORDEM", '14'}}, { }, { }, {|| .T.} )
AjustaSx3("FKG_NUMPRO", 	{ { "X3_TITULO", 'Processo Jud' }, { "X3_DESCRIC", 'Numero Processo Judicial' } , {"X3_ORDEM", '15'} }, { }, { }, {|| .T.} )
AjustaSx3("FKG_TPPROC", 	{ { "X3_TITULO", 'Tipo Process' }, { "X3_DESCRIC", 'Tipo Processo' }, {"X3_ORDEM", '16'} }, { }, { }, {|| .T.} )
AjustaSx3("FKG_TITINS",	 	{ {"X3_ORDEM", '17'} }, { }, { }, {|| .T.} )
AjustaSx3("FKG_APURIN",	 	{ {"X3_ORDEM", '18'} }, { }, { }, {|| .T.} )

conout("[RUP_FIN] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} FinAtuBco
Atualiza campos da tabela de parâmetros de bancos

@author Pedro Pereira Lima
@since 17/05/2018
@version v12.1.17
/*/
//-------------------------------------------------------------------
Static Function FinAtuBco()

Local lDicInDdb := MPDicInDB()
Local cUsado	:= ""
Local cReser	:= ""

	If !lDicInDdb
		cUsado := '€€€€€€€€€€€€€€ '
		cReser := '‚A'
	Else
		cUsado := X3TreatUso('€€€€€€€€€€€€€€ ')
		cReser := X3TreatUso('‚A')
	EndIf

	AjustaSX3('EE_TAMOCOR', {{'X3_USADO'	, cUsado}}	, {}, {}, {|| .T.})
	AjustaSX3('EE_TAMOCOR', {{'X3_RESERV'	, cReser}}	, {}, {}, {|| .T.})
	AjustaSX3('EE_TAMOCOR', {{'X3_VISUAL'	, 'R'	}}	, {}, {}, {|| .T.})
	AjustaSX3('EE_TAMOCOR', {{'X3_FOLDER'	, '1'	}}	, {}, {}, {|| .T.})

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}  AjustaSX3(cCampo, aCpoPor, aCpoSpa, aCpoEng, cCondicao)
Filtro 

@author Alvaro Camillo Neto
   
@version P12
@since   27/03/2015
@return  Nil
@obs
/*/
//-------------------------------------------------------------------
Static Function AjustaSx3(cCampo, aCpoPor, aCpoSpa, aCpoEng, cCondicao)

Local aArea := GetArea(), nIndice, lCondicao

If ValType(aCpoPor) = "C"		// A variavel pode ser passada tambem como string
	aCpoPor := { { "X3_CBOX", aCpoPor } }		// Pois eh convertida para matriz
	aCpoSpa := { { "X3_CBOXSPA", aCpoSpa } }
	aCpoEng := { { "X3_CBOXENG", aCpoEng } }
Endif

DbSelectArea("SX3")
DbSetOrder(2)
MsSeek(cCampo)

If ValType(cCondicao) = "B"
	lCondicao := Eval(cCondicao)
Else
	lCondicao := ! cCondicao $ AllTrim(&(aCpoPor[1][1]))
Endif
If Found() .And. lCondicao
	RecLock("SX3", .F.)
	For nIndice := 1 To Len(aCpoPor)
		Replace &(aCpoPor[nIndice][1]) With aCpoPor[nIndice][2]
	Next
	For nIndice := 1 To Len(aCpoSpa)
		Replace &(aCpoSpa[nIndice][1]) With aCpoSpa[nIndice][2]
	Next
	For nIndice := 1 To Len(aCpoEng)
		Replace &(aCpoEng[nIndice][1]) With aCpoEng[nIndice][2]
	Next
	MsUnLock()
Endif

RestArea(aArea)

Return .T.

/*/{Protheus.doc}  FinAtuSX6()
Atualiza Valid do SX6

@author Karen Honda
   
@version P12.1.7
@since   05/08/2016
@return  Nil
@obs
/*/
//-------------------------------------------------------------------
Static Function FinAtuSX6()
Local nTamFil := 0

conout("[RUP_FIN] Ajustando parametros (SX6)...")
conout("[RUP_FIN] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

dbSelectArea("SX6")
dbSetOrder(1)
nTamFil := Len(SX6->X6_FIL)
//colocado validaao nos parametros MV_ISS,MV_IRF,MV_INSS para que o mesmo retorne caracter na macro execução
If SX6->(dbSeek(SPACE(nTamFil)+"MV_ISS")) .and. Empty(SX6->X6_VALID) 
	RecLock("SX6",.F.)	
	SX6->X6_VALID:= 'ValParFin(X6_CONTEUD, X6_CONTSPA, X6_CONTENG)'
	SX6->(MsUnlock())
Endif

If SX6->(dbSeek(SPACE(nTamFil)+"MV_IRF")) .and. Empty(SX6->X6_VALID) 
	RecLock("SX6",.F.)	
	SX6->X6_VALID:= 'ValParFin(X6_CONTEUD, X6_CONTSPA, X6_CONTENG)'
	SX6->(MsUnlock())
Endif

If SX6->(dbSeek(SPACE(nTamFil)+"MV_INSS")) .and. Empty(SX6->X6_VALID) 
	RecLock("SX6",.F.)	
	SX6->X6_VALID:= 'ValParFin(X6_CONTEUD, X6_CONTSPA, X6_CONTENG)'
	SX6->(MsUnlock())
Endif

conout("[RUP_FIN] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

Return 

/*/{Protheus.doc} FINAtuSX9()
Atualiza relacionamentos entre tabelas

@author Pedro Alencar
@version P12.1.17
@since 23/06/2017
@return Nil
/*/
Static Function FINAtuSX9( cLocaliz, cRelFinish )
	
	conout("[RUP_FIN] Ajustando relacionamentos entre tabelas...")
	conout("[RUP_FIN] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

	//Caso não seja argentina, exclui o relacionamento do campo FB_NATUREZ com a SED, pois esse campo só existe na Argentina (em bases migradas da 11 o campo e relacionamento era ALL, por isso precisa desse ajuste)
	dbSelectArea("SX9")
	SX9->( dbSetOrder( 2 ) ) //X9_CDOM+X9_DOM
	If cLocaliz <> "ARG"
		If SX9->( DbSeek( "SFB" + "SED" ) ) //X9_CDOM+X9_DOM
			While SX9->( !EOF() .AND. X9_CDOM == "SFB" .AND. X9_DOM == "SED" )
				If AllTrim( SX9->X9_EXPCDOM ) == "FB_NATUREZ"
					RecLock( "SX9", .F. )
					SX9->( dbDelete() )
					SX9->( MsUnlock() )
					Exit
				EndIf
				SX9->( dbSkip() )
			EndDo
		Endif

		If SX9->( DbSeek( "FV1" + "SA2" ) ) //X9_CDOM+X9_DOM
			While SX9->( !EOF() .AND. X9_CDOM == "FV1" .AND. X9_DOM == "SA2" )
				If AllTrim( SX9->X9_EXPCDOM ) == "FV1_EMITEN"
					RecLock( "SX9", .F. )
					SX9->( dbDelete() )
					SX9->( MsUnlock() )
					Exit
				EndIf
				SX9->( dbSkip() )
			EndDo
		Endif

	Endif
	
	If cRelFinish >= '017'
		If SX9->( DbSeek( "SED" + "SED") )  //X9_CDOM+X9_DOM
			While SX9->( !EOF() .AND. X9_CDOM == "SED" .AND. X9_DOM == "SED" )
			   If AllTrim(SX9->X9_EXPCDOM) == "ED_PAI"
					If AllTrim( SX9->X9_ENABLE ) == "N"
						RecLock( "SX9", .F. )
						SX9->X9_ENABLE := "S"
						SX9->( MsUnlock() )
						Exit
					EndIf
				EndIf
				SX9->( dbSkip() )
			EndDo
		Endif
	EndIf
	
	conout("[RUP_FIN] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

Return Nil

/*/{Protheus.doc}  FinAtuSIX()
As ordens das perguntas do fin403 na versao 11 estao como 01,02,03,04,
na versao 12 esta como 1,2,3,4...logo ao rodar o upddistr está duplicando as perguntas
Este AJUSTA está sendo feito aqui somente por causa do pacote da DIRF 2017 estar sem marca e por este 
motivo, nao roda o RUP_FIN. 
Valido somente para a versao 12
Deverá ser retirada nas proximas versões. 

@author Karen Honda
   
@version P12.1.7
@since   20/01/2017
@return  Nil
@obs
/*/
Static Function FinAtuSX1() 
Local cPerg := ""
Local ni := 1
Local nj := 1
Local cOrdem := ""

Local aSX1      := {}
Local nTamCli	:= TAMSX3("A1_COD")[1]
Local nTamLoj	:= TAMSX3("A1_LOJA")[1]
Local aEstrutSX1 := {"X1_GRUPO"	, "X1_ORDEM"	, "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO"	, "X1_TAMANHO", ;
				 "X1_DECIMAL"	, "X1_PRESEL"	, "X1_GSC"	   	, "X1_VALID"	, "X1_VAR01"	, "X1_DEF01"	, ;
				 "X1_CNT01"	, "X1_DEF02"	, "X1_DEF03"	, "X1_DEF04"	, "X1_DEF05"	,"X1_F3" 		,;
				 "X1_PYME"		, "X1_GRPSXG"	, "X1_PICTURE" }

conout("[RUP_FIN] Ajustando grupos de perguntas (SX1)...")
conout("[RUP_FIN] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

dbSelectArea("SX1")
dbSetOrder(1)

cPerg := padr("FIN403",10)
For ni := 1 to 6
	cOrdem := Alltrim(Str(ni))
	If SX1->(DBSeek(cPerg+StrZero(ni,2)))
		If SX1->(DBSeek(cPerg+padr(cOrdem,2)))
			RecLock("SX1",.F.)
			SX1->(DBDelete())
			SX1->(MsUnlock())
		EndIf
	Else
		If SX1->(DBSeek(cPerg+padr(cOrdem,2)))
			RecLock("SX1",.F.)
			SX1->X1_ORDEM := StrZero(ni,2)
			SX1->(MsUnlock())
		EndIf
	EndIf	
Next ni		

//apaga o grupo FINTAF para recriar novamente
cPerg := padr("FINTAF",10)
If SX1->(DBSeek(cPerg))
	
	While SX1->X1_GRUPO == cPerg
		RecLock("SX1",.F.)
		SX1->(DBDelete())	
		SX1->(MsUnlock())
		SX1->(DBSkip())
	EndDo
EndIF

// PERGUNTE FINTAF
aAdd( aSX1, {'FINTAF', '01', 'Considera Data C. Receber?  '	, 'MV_CH0', 'N', 1		, 0, 1	, 'C', '', 'MV_PAR01', 'Data Contabiliz'	, ''                    , 'Data Emissao', '', '', '', '', 'S', '', '' })
aAdd( aSX1, {'FINTAF', '02', 'Data de ?'					, 'MV_CH1', 'D', 8		, 0, 0	, 'G', '', 'MV_PAR02', ''					, ''                    , '', '', '', '', '', 'S', '', '' })
aAdd( aSX1, {'FINTAF', '03', 'Data ate ?'					, 'MV_CH2', 'D', 8		, 0, 0	, 'G', '', 'MV_PAR03', ''					, ''                    , '', '', '', '', '', 'S', '', '' })
aAdd( aSX1, {'FINTAF', '04', 'Tipo Pessoa Contas Receber ?'	, 'MV_CH3', 'N', 1		, 0, 4	, 'C', '', 'MV_PAR04', 'Pessoa Fisica'		, ''                    , 'Pessoa Juridica', 'Estrangeiro', 'Todas', '', '', 'S', '', '' })
aAdd( aSX1, {'FINTAF', '05', 'Cliente de ?'					, 'MV_CH4', 'C', nTamCli, 0, 0	, 'G', '', 'MV_PAR05', ''					, ''                    , '', '', '', '', 'CLI', 'S', '001', '@!' })
aAdd( aSX1, {'FINTAF', '06', 'Cliente ate ?'				, 'MV_CH5', 'C', nTamCli, 0, 0	, 'G', '', 'MV_PAR06', ''					, 'ZZZZZZ', '', '', '', '', 'CLI', 'S', '001', '@!' })
aAdd( aSX1, {'FINTAF', '07', 'Loja de ?'					, 'MV_CH6', 'C', nTamLoj, 0, 0	, 'G', '', 'MV_PAR07', ''					, ''                    , '', '', '', '', '', 'S', '002', '@!' })
aAdd( aSX1, {'FINTAF', '08', 'Loja ate ?'					, 'MV_CH7', 'C', nTamLoj, 0, 0	, 'G', '', 'MV_PAR08', ''					, 'ZZ', '', '', '', '', '', 'S', '002', '@!' })
aAdd( aSX1, {'FINTAF', '09', 'Considera Data Emissao CP ? '	, 'MV_CH8', 'N', 1		, 0, 1	, 'C', '', 'MV_PAR09', 'Data Contabiliz'	, ''                    , 'Data Emissao', '', '', '', '', 'S', '', '' })
aAdd( aSX1, {'FINTAF', '10', 'Considera Data Pagto CP?    '	, 'MV_CH9', 'N', 1		, 0, 3	, 'C', '', 'MV_PAR10', 'Data Venct Real'	, ''                    , 'Data Vencimento', 'Data Baixa', '', '', '', 'S', '', '' })
aAdd( aSX1, {'FINTAF', '11', 'Data de ?'					, 'MV_CHA', 'D', 8		, 0, 0	, 'G', '', 'MV_PAR11', ''					, ''                    , '', '', '', '', '', 'S', '', '' })
aAdd( aSX1, {'FINTAF', '12', 'Data ate ?'					, 'MV_CHB', 'D', 8		, 0, 0	, 'G', '', 'MV_PAR12', ''					, ''                    , '', '', '', '', '', 'S', '', '' })
aAdd( aSX1, {'FINTAF', '13', 'Tipo de Pessoa Contas Pagar?'	, 'MV_CHC', 'N', 1		, 0, 4	, 'C', '', 'MV_PAR13', 'Pessoa Fisica'		, ''                    , 'Pessoa Juridica', 'Estrangeiro', 'Todas', '', '', 'S', '', '' })
aAdd( aSX1, {'FINTAF', '14', 'Fornecedor de ?'				, 'MV_CHD', 'C', nTamCli, 0, 0	, 'G', '', 'MV_PAR14', ''					, ''                    , '', '', '', '', 'SA2', 'S', '001', '@!' })
aAdd( aSX1, {'FINTAF', '15', 'Fornecedor ate ?'				, 'MV_CHE', 'C', nTamCli, 0, 0	, 'G', '', 'MV_PAR15', ''					, 'ZZZZZZ', '', '', '', '', 'SA2', 'S', '001', '@!' })
aAdd( aSX1, {'FINTAF', '16', 'Loja de ?'					, 'MV_CHF', 'C', nTamLoj, 0, 0	, 'G', '', 'MV_PAR16', ''					, ''                    , '', '', '', '', '', 'S', '002', '@!' })
aAdd( aSX1, {'FINTAF', '17', 'Loja ate ?'					, 'MV_CHG', 'C', nTamLoj, 0, 0	, 'G', '', 'MV_PAR17', ''					, 'ZZ', '', '', '', '', '', 'S', '002', '@!' })
aAdd( aSX1, {'FINTAF', '18', 'Tipo de saida ? '				, 'MV_CHH', 'N', 1		, 0, 2	, 'C', '', 'MV_PAR18', 'Arquivo TXT'		, ''                    , 'Banco a banco  ', '', '', '', '', 'S', '', '' })
aAdd( aSX1, {'FINTAF', '19', 'Diretório do arquivo?       '	, 'MV_CHI', 'C', 60		, 0, 0	, 'G', '', 'MV_PAR19', ''					, '\reinf\'   , '', '', '', '', '', 'S', '', '' })
aAdd( aSX1, {'FINTAF', '20', 'Nome do arquivo ?'			, 'MV_CHJ', 'C', 20		, 0, 0	, 'G', '', 'MV_PAR20', ''					, 'expfintaf.txt', '', '', '', '', '', 'S', '', '' })
aAdd( aSX1, {'FINTAF', '21', 'Exportar Processos Jud/Adm? '	, 'MV_CHK', 'N', 1		, 0, 1	, 'C', '', 'MV_PAR21', 'Sim'				, ''                    , 'Não', '', '', '', '', 'S', '', '' })
aAdd( aSX1, {'FINTAF', '22', 'Exportar Participantes?     '	, 'MV_CHL', 'N', 1		, 0, 1	, 'C', '', 'MV_PAR22', 'Sim'				, ''                    , 'Não', '', '', '', '', 'S', '', '' })
aAdd( aSX1, {'FINTAF', '23', 'Exportar títulos a receber? '	, 'MV_CHM', 'N', 1		, 0, 1	, 'C', '', 'MV_PAR23', 'Sim'				, ''                    , 'Não', '', '', '', '', 'S', '', '' })
aAdd( aSX1, {'FINTAF', '24', 'Exportar títulos a pagar?   '	, 'MV_CHN', 'N', 1		, 0, 1	, 'C', '', 'MV_PAR24', 'Sim'				, ''                    , 'Não', '', '', '', '', 'S', '', '' })
aAdd( aSX1, {'FINTAF', '25', 'Exportar tipos de serviços? '	, 'MV_CHO', 'N', 1		, 0, 1	, 'C', '', 'MV_PAR25', 'Sim'				, ''                    , 'Não', '', '', '', '', 'S', '', '' })


//apaga o grupo AFI382 para recriar novamente
cPerg := padr("AFI382",10)
If SX1->(DBSeek(cPerg))
	
	While SX1->X1_GRUPO == cPerg
		RecLock("SX1",.F.)
		SX1->(DBDelete())	
		SX1->(MsUnlock())
		SX1->(DBSkip())
	EndDo
EndIF

// PERGUNTE AFI382
aAdd( aSX1, {'AFI382', '01', 'Data Inicial'			, 'MV_CH1', 'D', 8		, 0, 0	, 'G', '', 'MV_PAR01', ''		, ''  , ''		, '', '', '', ''	, 'S', ''	, '' })
aAdd( aSX1, {'AFI382', '02', 'Data Final'			, 'MV_CH2', 'D', 8		, 0, 0	, 'G', '', 'MV_PAR02', ''		, ''  , ''		, '', '', '', ''	, 'S', ''	, '' })
aAdd( aSX1, {'AFI382', '03', 'Seleciona Titulos'	, 'MV_CH3', 'C', 1		, 0, 1	, 'C', '', 'MV_PAR03', '1=Sim '	, '1' , '2=Nao'	, '', '', '', ''	, 'S', ''	, '' })
aAdd( aSX1, {'AFI382', '04', 'Seleciona Filiais'	, 'MV_CH4', 'C', 1		, 0, 2	, 'C', '', 'MV_PAR04', '1=Sim ' , '2' , '2=Nao'	, '', '', '', ''	, 'S', ''	, '' })
aAdd( aSX1, {'AFI382', '05', 'Impr. Relatorio'		, 'MV_CH5', 'C', 1		, 0, 1	, 'C', '', 'MV_PAR05', '1=Sim '	, '1' , '2=Nao'	, '', '', '', ''	, 'S', ''	, '' })
aAdd( aSX1, {'AFI382', '06', 'Cod. Retencao'		, 'MV_CH6', 'C', 4		, 0, 0	, 'G', '', 'MV_PAR06', ''		, ''  , ''		, '', '', '', '37'	, 'S', ''	, '' })
aAdd( aSX1, {'AFI382', '07', 'Imposto'				, 'MV_CH7', 'C', 6		, 0, 0	, 'G', '', 'MV_PAR07', ''		, ''  , ''		, '', '', '', '0C'	, 'S', ''	, '' })
aAdd( aSX1, {'AFI382', '08', 'Fornecedor'			, 'MV_CH8', 'C', nTamCli, 0, 0	, 'G', '', 'MV_PAR08', ''		, ''  , ''		, '', '', '', 'SA2A', 'S', '001', '' })
aAdd( aSX1, {'AFI382', '09', 'Loja'					, 'MV_CH9', 'C', nTamLoj, 0, 0	, 'G', '', 'MV_PAR09', ''		, ''  , ''		, '', '', '', 'SA22', 'S', '002', '' })
aAdd( aSX1, {'AFI382', '10', 'Contabiliza Online'	, 'MV_CHA', 'C', 1		, 0, 2	, 'C', '', 'MV_PAR10', '1=Sim '	, '2' , '2=Nao'	, '', '', '', ''	, 'S', ''	, '' })
aAdd( aSX1, {'AFI382', '11', 'Mostra Lançamento'	, 'MV_CHB', 'C', 1		, 0, 2	, 'C', '', 'MV_PAR11', '1=Sim '	, '2' , '2=Nao'	, '', '', '', ''	, 'S', ''	, '' })
aAdd( aSX1, {'AFI382', '12', 'Aglutina Lançamento'	, 'MV_CHC', 'C', 1		, 0, 2	, 'C', '', 'MV_PAR12', '1=Sim '	, '2' , '2=Nao'	, '', '', '', ''	, 'S', ''	, '' })

SX1->(DbSetOrder(1)) //--X1_GRUPO + X1_ORDEM
For ni := 1 To Len(aSX1)
	If !Empty(aSX1[Ni,1])
		If !SX1->(dbseek( padr(aSX1[ni,1],10) + aSX1[ni,2]))
			RecLock("SX1",.T.)
		Else	
			RecLock("SX1",.F.)
		Endif	
		For nj :=1 To Len(aSX1[ni])
			If !Empty(SX1->(FieldName(FieldPos(aEstrutSX1[nj]))))
				SX1->(FieldPut(FieldPos(aEstrutSX1[nj]),aSX1[ni,nj]))
			EndIf
		Next nj
		SX1->(MsUnLock())
	EndIf
Next ni

cPerg := PadR("FIR898", 10)
If SX1->(DBSeek(cPerg + "12"))
	RecLock("SX1", .F.)
	SX1->(DBDelete())
	SX1->(MsUnlock())
EndIF

conout("[RUP_FIN] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

Return
