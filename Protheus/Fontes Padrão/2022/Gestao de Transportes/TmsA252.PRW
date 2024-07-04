#INCLUDE 'Protheus.ch'
#INCLUDE 'Tmsa252.ch'

//-- Diretivas indicando as colunas dos documentos da viagem Do TMSA141
#define CTSTATUS		1
#define CTSTROTA		2
#define CTMARCA		3
#define CTSEQUEN		4
#define CTARMAZE		5
#define CTLOCALI		6
#define CTFILDOC		7
#define CTDOCTO		8
#define CTSERIE		9
#define CTREGDES		10
#define CTDATEMI		11
#define CTPRZENT		12
#define CTNOMREM		13
#define CTNOMDES		14
#define CTQTDVOL		15
#define CTVOLORI		16
#define CTPLIQUI		17
#define CTPESOM3		18
#define CTVALMER		19
#define CTVIAGEM		20
#define CTSEQDA7		21
#define CTSOLICI		22			//-- DUE_NOME
#define CTENDERE		23			//-- DUE_END
#define CTBAIRRO		24			//-- DUE_BAIRRO
#define CTMUNICI		25			//-- DUE_MUN
#define CTDATSOL		26			//-- DT5_DATSOL
#define CTHORSOL		27			//-- DT5_HORSOL
#define CTDATPRV		28			//-- DT5_DATPRV
#define CTHORPRV		29			//-- DT5_HORPRV
#define CTDOCROT		30			//-- Codigo que identifica a q rota pertence o documento
#define CTBLQDOC		31			//-- Tipos de bloqueio do documento
#define CTNUMAGE		32			//-- Numero do Agendamento( Carga Fechada ).
#define CTITEAGE		33			//-- Item do Agendamento( Carga Fechada ).
#define CTSERTMS		34			//-- Tipo do Servico.
#define CTDESSVT		35			//-- Descricao do Servico.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Tmsa252  ³ Autor ³     Andre Godoi       ³ Data ³16.04.2008  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao do Contrato para Redespachante                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA252()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tmsa252()
Local   aSays     := {}
Local   aButtons  := {}
Local   nOpca     := 0
Local   cCadastro := STR0001

//-- Declaradas como Private, pois sao utilizadas na geracao do contrato, TMSA250.
Private aRota     := {}
Private cSerTms   := ""
Private cTipTra   := ""
Private aDocto    := {}
Private aCompViag := {}
Private nCarreg	:= 0
Private aRotina	:= {}
Private aMemos    := {	{ 'DTQ_CODOBS', 'DTQ_OBS' } }


//-- Carrega o pergunte com o sexto parametro como .F., para nao carregar o profile ( perguntas do usurario),
//-- pois a fabrica fez customizacoes onde e' gravado o conteudo de perguntes.
Pergunte("TMA252",.F.,,,,.F.)

Aadd( aSays, STR0002 ) 
Aadd( aSays, STR0003 ) 
Aadd( aButtons, { 1, .T., {|o| nOpca := 1, o:oWnd:End() } } )
Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )
Aadd( aButtons, { 5, .T., {| | Pergunte("TMA252",.T.,,,,.F.) } } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas                            ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ mv_par01 - Redespachante?                                    ³
//³ mv_par02 - Loja?                                             ³
//³ mv_par03 - Periodo de?                                       ³
//³ mv_par04 - Periodo Ate?                                      ³	
//³ mv_par05 - Mostra lancamento contabeis?                      ³		
//³ mv_par06 - Aglutina lac. contabeis?                          ³		
//³ mv_par07 - Contabiliza on Line?                              ³	 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	
FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	cMv_par01 := mv_par01
	cMv_par02 := mv_par02
	cMv_par03 := mv_par03
	cMv_par04 := mv_par04
	cMv_par05 := mv_par05
	cMv_par06 := mv_par06
	cMv_par07 := mv_par07
	
	Help('',1,'TMSA25209')  //-- Favor entrar em contato com o suporte Totvs para falar sobre a rotina Geração do Contrato do Redespachante - TMSA252. 
	//Tmsa252Pro(cMv_par01, cMv_par02, cMv_par03, cMv_par04, cMv_par05, cMv_par06, cMv_par07)
EndIf

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Tmsa252Pro³ Autor ³     Andre Godoi       ³ Data ³16.04.2008  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento da Geracao do Contrato para Redespachante      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa252Pro()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tmsa252Pro(cMv_par01, cMv_par02, cMv_par03, cMv_par04, cMv_par05, cMv_par06, cMv_par07)
Local aDocAux   := Array( 34 )
Local cAlias    := ""
Local cPercur   := ""
Local cRota     := ""
Local aAreaDTQ  := DTQ->( GetArea() )
Local cNumRed   := ""
Local lRet      := .F. 
Local aVisErr   := {}
Local nA        := 0
Local nB        := 0
Local nX        := 0
Local aCampos   := {}
Local cCodVei   := GetMv('MV_VEIREDE')
Local cCodMot   := GetMv('MV_MOTREDE')
Local cFilOri   := ""
Local cViagem   := ""
Local cMay      := ""
Local lTMA252CPL:= ExistBlock("TMA252CPL")   //-- Ponto de Entrada para gravacoes complementares do processo de redespacho
Local lTM252CAL := ExistBlock("TM252CAL")    //-- Permite efetuar o calculo do contrato.
Local cBkMvPar08:= ""
Local lTM252DOC := ExistBlock("TM252DOC")		//-- Permite incluir ou retirar os doc. na geracao da viagem.
Local aParam    := {}
Local cNumCtc   := ""
Local lTMSGFE   := SuperGetMv("MV_TMSGFE",,.F.) 
Local lCmpDFV   := DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0
Local cFilRed   := ""

//-- Declaradas como Private, pois sao utilizadas na geracao do contrato, TMSA250.
Private cUniao     := ""
Private cTipCTC    := ""
Private cNatuDeb   := Padr( GetMV("MV_NATDEB"), Len( SE2->E2_NATUREZ ) ) // Natureza Utilizada nos Titulos Gerados para a Filial de Debito
Private cCodDesCTC := Padr( GetMV("MV_DESCTC"), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de contrato de carreteiro 


//-- Funcao para validacao dos Parametros.
If !TMA252Param()
	Return Nil
EndIf	

//-- Validacoes dos parametros.
If Empty(cCodVei)
	Help('',1,'TMSA25202') //--Preencher o código do veiculo no parametro MV_VEIREDE.
	Return Nil
EndIf

If Empty(cCodMot)
	Help('',1,'TMSA25203') //--Preencher o código do veiculo no parametro MV_MOTREDE.
	Return Nil
EndIf

DA8->( DbSetOrder( 1 ) )
If !DA8->( MsSeek( xFilial("DA8") + PadR( GetMv('MV_ROTGENT'), Len( DA8->DA8_COD ) ) ) )
	Help('',1,'TMSA25204') //-- Preencher o parametro MV_ROTGENT,  Rota Generica !
	Return Nil
EndIf

cAlias := GetNextAlias()
If lTMSGFE 
	cQuery := " SELECT A2_NATUREZ, A2_PAGGFE"
Else                              
	cQuery := " SELECT A2_NATUREZ"
EndIf	
cQuery += " FROM " + RetSqlName("SA2")
cQuery += " WHERE "
cQuery += "     A2_FILIAL ='" + xFilial("SA2") + "'"
cQuery += " AND A2_COD    ='" + cMv_Par01 + "'"
cQuery += " AND A2_LOJA   ='" + cMv_Par02 + "'"
cQuery += " AND D_E_L_E_T_= ' ' "
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .F. )

If (cAlias)->( Eof() )
	If Empty(Padr( GetMV("MV_NATCTC"), Len( SE2->E2_NATUREZ ) ))
		Help('',1,'TMSA25206') //-- Preencher o parametro MV_ROTGENT,  Rota Generica !
		Return Nil
	EndIf
Else
	If lTMSGFE .And. (cAlias)->A2_PAGGFE == '1'
		Help('',1,'TMSA25208') //--A integração com o SIGAGFE está ativa, portanto não será permitido gerar o Contrato do Redespachante.
		Return Nil
	EndIf
EndIf
(cAlias)->( dbCloseArea() )


//-- Selecao dos documentos, para qual o contrato sera gerado. 
cAlias := GetNextAlias()
cQuery := " SELECT DUD.R_E_C_N_O_ , DFV.DFV_NUMRED, DFV.DFV_CODFOR, DFV.DFV_LOJFOR, DUD.DUD_STATUS,"
cQuery += " DUD.DUD_SERTMS, DUD.DUD_TIPTRA, DUD.DUD_FILDOC,"
cQuery += " DUD.DUD_DOC, DUD.DUD_SERIE, DT6.DT6_QTDVOL, DT6.DT6_PESO"
If lCmpDFV
	cQuery += " , DFV.DFV_FILORI "
EndIf
cQuery += " FROM "
cQuery += RetSqlName("DFV") + " DFV, "
cQuery += RetSqlName("DUD") + " DUD, "
cQuery += RetSqlName("DT6") + " DT6, "            
cQuery += RetSqlName("DUA") + " DUA, "
cQuery += RetSqlName("DT2") + " DT2  "
//-- Documentos por Redespachante.
cQuery += "WHERE "
cQuery += "DFV.DFV_FILIAL 		 = '" + xFilial('DFV') + "' AND "
cQuery += "DFV.DFV_CODFOR 		 = '" + cMv_Par01 + "' AND "
cQuery += "DFV.DFV_LOJFOR 		 = '" + cMv_Par02 + "' AND "
cQuery += "DFV.DFV_STATUS		 = '" + StrZero(3, Len(DFV->DFV_STATUS)) + "' AND "
cQuery += "DFV.DFV_NUMCTC		 = ' ' AND "
cQuery += "DFV.DFV_CHVEXT 		 = '' AND "
//-- Movimento de Viagem.
cQuery += "DUD.DUD_FILIAL		 = '" + xFilial('DUD') + "' AND "
cQuery += "DUD.DUD_FILDOC		 =  DFV.DFV_FILDOC AND "
cQuery += "DUD.DUD_DOC			 =  DFV.DFV_DOC AND "
cQuery += "DUD.DUD_SERIE		 =  DFV.DFV_SERIE AND "
cQuery += "DUD.DUD_FILORI		 =  '" + cFilAnt + "' AND "
cQuery += "DUD.DUD_NUMRED		 =  DFV.DFV_NUMRED AND "
cQuery += "DUD.DUD_STATUS		 =  '" + StrZero(4, Len(DUD->DUD_STATUS)) + "' AND "  
//-- Documentos de Transporte.
cQuery += "DT6.DT6_FILIAL 		 = '" + xFilial('DT6') + "' AND "
cQuery += "DT6.DT6_FILDOC 		 =  DUD.DUD_FILDOC AND "
cQuery += "DT6.DT6_DOC    		 =  DUD.DUD_DOC AND "
cQuery += "DT6.DT6_SERIE  		 =  DUD.DUD_SERIE AND "
//-- Ocorrencias.
cQuery += "DUA.DUA_FILIAL 		 =  '" + xFilial('DUA') + "' AND "
cQuery += "DUA.DUA_FILDOC 		 =  DUD.DUD_FILDOC AND "
cQuery += "DUA.DUA_DOC    		 =  DUD.DUD_DOC AND "
cQuery += "DUA.DUA_SERIE  		 =  DUD.DUD_SERIE AND "
cQuery += "DUA.DUA_DATOCO 		 >= '" + Dtos( cMv_par03 ) + "' AND "
cQuery += "DUA.DUA_DATOCO 		 <= '" + Dtos( cMv_par04 ) + "' AND "
//-- Tipo de Ocorrencias.
cQuery += "DT2.DT2_FILIAL 		 =  '" + xFilial('DT2') + "' AND "
cQuery += "DT2.DT2_CODOCO 		 =  DUA.DUA_CODOCO AND "
cQuery += "DT2.DT2_TIPOCO 		 =  '" + StrZero(1, Len(DT2->DT2_TIPOCO)) + "' AND "
cQuery += "DT2.DT2_ATIVO  		 =  '" + StrZero(1, Len(DT2->DT2_ATIVO))  + "' AND "
//-- Nao Deletado                      
cQuery += "DFV.D_E_L_E_T_	 = ' ' AND "
cQuery += "DUD.D_E_L_E_T_	 = ' ' AND "
cQuery += "DT6.D_E_L_E_T_	 = ' ' AND "
cQuery += "DUA.D_E_L_E_T_   = ' ' AND "
cQuery += "DT2.D_E_L_E_T_   = ' ' "
If lCmpDFV
	cQuery += "ORDER BY DFV.DFV_FILORI, DFV.DFV_NUMRED, DFV.DFV_CODFOR, DFV.DFV_LOJFOR"
Else
	cQuery += "ORDER BY DFV.DFV_NUMRED, DFV.DFV_CODFOR, DFV.DFV_LOJFOR"
EndIf	 
cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .F. )

If (cAlias)->( Eof() )
	Help('',1,'TMSA25201') //--Não existem redespachos encerrados ou já existe contrato gerado para este redespachante.
	Return Nil
EndIf


DA9->( dbSetOrder( 1 ) )
//-- Posiciona em Zonas por Rota para obter zona e setor
If DA9->( MsSeek( xFilial("DA9") + DA8->DA8_COD ) )
	cPercur := DA9->DA9_PERCUR
	cRota   := DA9->DA9_ROTA
EndIf

Aadd( aRota, { .T.,DA8->DA8_COD,,,,,,,.F. } )

DUD->( dbSetOrder( 1 ) )

While (cAlias)->( !Eof() )
	
	aCampos   := {}
	
	//-- Cria um novo DUD, na geracao de contrato, s/ viagem  !Empty( DUD->DUD_VIAGEM ).
	DUD->(DbGoto((cAlias)->R_E_C_N_O_))
	
	If !Empty( AllTrim(DUD->DUD_VIAGEM) )
		For nB := 1 To DUD->( FCount() )
			If AllTrim( DUD->( FieldName( nB ) ) ) == "DUD_VIAGEM"
				Aadd( aCampos, { DUD->( FieldName( nB ) ), "" } )
			ElseIf AllTrim( DUD->( FieldName( nB ) ) ) == "DUD_SERTMS"
				Aadd( aCampos, { DUD->( FieldName( nB ) ), "3" } )
			ElseIf AllTrim( DUD->( FieldName( nB ) ) ) == "DUD_STATUS"
				Aadd( aCampos, { DUD->( FieldName( nB ) ), StrZero( 1, Len( DUD->DUD_STATUS ) ) } )
			Else
				Aadd( aCampos, { DUD->( FieldName( nB ) ), DUD->( FieldGet( nB ) ) } )
			EndIf
		Next nB
		DUD->( TmsCopyReg( aCampos ) )
	EndIf

	aDocAux := Array( 34 )

	Afill( aDocAux, NIL )

	aDocAux[CTSTATUS]	:= (cAlias)->DUD_STATUS
	aDocAux[CTSTROTA]	:= ''
	aDocAux[CTMARCA] 	:= .T.
	aDocAux[CTSEQUEN]	:= Replicate( 'x', Len( DUD->DUD_SEQUEN ) )
	aDocAux[CTARMAZE]	:= ''
	aDocAux[CTLOCALI]	:= ''
	aDocAux[CTFILDOC]	:= (cAlias)->DUD_FILDOC
	aDocAux[CTDOCTO ]	:= (cAlias)->DUD_DOC
	aDocAux[CTSERIE ]	:= (cAlias)->DUD_SERIE
	aDocAux[CTQTDVOL]	:= (cAlias)->DT6_QTDVOL
	aDocAux[CTPLIQUI]	:= (cAlias)->DT6_PESO
	aDocAux[CTVIAGEM]	:= .T.
	aDocAux[CTDOCROT]	:= DA8->DA8_COD + cPercur + cRota

	Aadd( aDocto, AClone( aDocAux ) )

	(cAlias)->( dbSkip() )
EndDo
(cAlias)->( dbCloseArea() )

If lTM252DOC
	aParam := ExecBlock("TM252DOC",.F.,.F.,{aDocto})
	If ValType(aParam) == "A"
		aDocto := aClone(aParam)
	EndIf
EndIf

If !Empty( aDocto )

	Inclui := .T.
	RegToMemory( 'DTQ', .T. )

	// Ajusta SXE e SXF caso estejam corrompidos.
	cFilOri := M->DTQ_FILORI
	cViagem := M->DTQ_VIAGEM
	cMay := AllTrim(xFilial('DTQ'))+cFilOri+cViagem
	FreeUsedCode()
	DTQ->( DbSetOrder( 2 ) )
	While DTQ->(MsSeek(xFilial('DTQ')+cFilOri+cViagem)) .OR. !MayIUseCode(cMay)
		ConfirmSx8()
		cViagem := CriaVar("DTQ_VIAGEM")
		FreeUsedCode()
		cMay := AllTrim(xFilial('DTQ'))+cFilOri+cViagem
	EndDo
	M->DTQ_FILORI := cFilOri
	M->DTQ_VIAGEM := cViagem
	RestArea( aAreaDTQ )
	cSerTms       	:= StrZero( 3, Len( DUD->DUD_SERTMS ) )
	cTipTra       	:= StrZero( 1, Len( DUD->DUD_TIPTRA ) )
	nTipVia       	:= 5
	lTmsCFec      	:= TmsCFec()
	lColeta       	:= .F.
	M->DTQ_SERTMS	:= cSerTms
	M->DTQ_TIPTRA 	:= cTipTra
		 

	//-- Para evitar de gravar mais de uma vez o mesmo numero de Redespacho na viagem.	
	For nX:= 1 To Len(aDocto)

		cAlias := GetNextAlias()
		If lCmpDFV
			cQuery := " SELECT DISTINCT DFV_FILORI, DFV_NUMRED"
		Else
			cQuery := " SELECT DISTINCT(DFV_NUMRED) DFV_NUMRED"
		EndIf	
		cQuery += " FROM " + RetSqlName("DFV")
		cQuery += " WHERE DFV_FILIAL ='" + xFilial("DFV") + "'"
		cQuery += "   AND DFV_FILDOC ='" + aDocto[nX][7] + "'"
		cQuery += "   AND DFV_DOC    ='" + aDocto[nX][8] + "'"
		cQuery += "   AND DFV_SERIE  ='" + aDocto[nX][9] + "'"
		cQuery += "   AND DFV_STATUS ='" + StrZero(3, Len(DFV->DFV_STATUS)) + "'"
		cQuery += "   AND DFV_NUMCTC =' '"
		cQuery += "   AND D_E_L_E_T_<>'*'"

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)

		If !((cAlias)->DFV_NUMRED $ cNumRed)
			If lCmpDFV
				cFilRed += " - " + (cAlias)->DFV_FILORI
			EndIf	
			cNumRed += " - " + (cAlias)->DFV_NUMRED
		EndIf
		(cAlias)->( dbCloseArea() )
		
	Next


	M->DTQ_OBS    	:= STR0033 + cFilRed + ' ' + cNumRed	//-- "Viagem gerada automaticamente (TMSA252) para o pagamento do Redespacho :"

	//-- Carrega o grupo de perguntas p/ gerar a viagem, altera para Tipo de Redespacho (TIPVIA == 5 )
	Pergunte("TMA141", .F.)
	MV_PAR03 := 5

	Begin Transaction

	MsgRun( STR0010 , STR0011 , {|| CursorWait(), lRet := TmsA141Grv( 3 ), CursorArrow()})

	If lRet
		
		//-- Gera complemento de Viagem.
		TMSA252Dtr( M->DTQ_FILORI, M->DTQ_VIAGEM, cCodVei, cCodMot )
		
		Pergunte( "TMA250",.F. )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega as perguntas selecionadas                            ³
      //ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
		//³ mv_par01 - Viagem De       ?                                 ³
		//³ mv_par02 - Viagem Ate      ?                                 ³
		//³ mv_par03 - Mostra lancamentos contabeis    ?                 ³
		//³ mv_par04 - Aglutina lancamentos contabeis  ?                 ³
		//³ mv_par05 - Tipo da Frota      ?  ( Fixo 2 Propria )          ³
		//³ mv_par06 - Contabiliza on Line ?                             ³
		//³ mv_par07 - Gera Contratos para ? ( Fixo 1 Veiculo )          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		mv_par01 	:= M->DTQ_VIAGEM
		mv_par02 	:= M->DTQ_VIAGEM
		mv_par03 	:= cMv_par05
		mv_par04 	:= cMv_par06
		mv_par05 	:= 2
		mv_par06 	:= cMv_par07
 		mv_par07 	:= 1
 		cFilOri  	:= M->DTQ_FILORI
 		cViagem  	:= M->DTQ_VIAGEM
		cBkMvPar08	:= mv_par08
		mv_par08    := ""
		
		If lTM252CAL
			ExecBlock("TM252CAL",.F.,.F.,{cFilOri,cViagem})	
		EndIf

      //-- Geracao o contrato carreteiro.		      
		SetFunName('TMSA250')
		Processa( {|lEnd| lRet := TMSA250Prc( "DTY", 		3, cFilOri, cViagem,			 .T.,				 , @aVisErr,		    ,'7'		  ,cMv_Par01, cMv_Par02) }, STR0001, STR0012,.F.)
		SetFunName('TMSA252')     

		//-- Volta o BackUp do parametro que nao e' utilizado.
		mv_par08 := cBkMvPar08

		//-- Em caso de Erro na Geracao do Contrato, exclui a viagem.
		If !Empty( aVisErr ) .Or. !lRet
			TmsMsgErr( aVisErr )
			TmsA141Grv( 5 )
			lRet := .F.
		EndIf

		If lRet
			cAlias := GetNextAlias()
			cQuery := " SELECT DTY_NUMCTC, R_E_C_N_O_ "
			cQuery += " FROM " + RetSqlName("DTY")
			cQuery += " WHERE DTY_FILIAL='" + xFilial("DTY") + "'" 
			cQuery += "   AND DTY_FILORI='" + cFilOri + "'" 
			cQuery += "   AND DTY_VIAGEM='" + cViagem + "'" 
			cQuery += "   AND D_E_L_E_T_<>'*'"  						
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .F. )

			If (cAlias)->(!Eof())
				cNumCtc := (cAlias)->DTY_NUMCTC
				//-- Posiciona na DTY, pois os ponto de entrada abaixo utiliza o DTY.
				DTY->(DbGoto((cAlias)->R_E_C_N_O_))

				DFV->( dbSetOrder( 2 ) )
				DUD->( dbSetOrder( 1 ) )
				For nA :=1 to Len(aDocto)
					If DUD->( MsSeek( xFilial("DUD") + aDocto[nA, CTFILDOC] + aDocto[nA, CTDOCTO] + aDocto[nA, CTSERIE] + cFilOri + cViagem  ))
						RecLock('DUD',.F.)
						DUD->DUD_STATUS := StrZero( 4, Len(DUD->DUD_STATUS) )
						MsUnLock()
				  		If DFV->( MsSeek( xFilial('DFV') + DUD->(DUD_FILDOC + DUD_DOC + DUD_SERIE + StrZero(3,Len(DFV->DFV_STATUS)))  )  )
				  			RecLock( "DFV", .F.)
				   		DFV->DFV_NUMCTC	:= cNumCtc
							MsUnLock()
						EndIf
					EndIf
				Next nA
				
				//-- Encerra a Vaigem.
				DTQ->( dbSetOrder( 2 ) )
				If DTQ->( MsSeek( xFilial("DTQ") + cFilOri + cViagem ) )
					RecLock( "DTQ", .F.)
					DTQ->DTQ_STATUS := StrZero( 3, Len( DTQ->DTQ_STATUS ) )
					DTQ->DTQ_DATENC := dDataBase
					DTQ->DTQ_HORENC := StrTran( Left( Time(), 5 ), ":", "" )
					MsUnLock()
				EndIf
				(cAlias)->( dbCloseArea() )
			Else	//-- Nao gerou o contrato e nao deu erro,exclui a viagem.
				TmsA141Grv( 5 )  //-- As vezes nao gera contrato e não da erro.
				lRet := .F.
			EndIf
		EndIf      

		If lTMA252CPL
	 		lRet := ExecBlock("TMA252CPL",.F.,.F.,{lRet})
		EndIf	
	EndIf
	
	End Transaction

EndIf


If lRet
	Aviso( STR0004, STR0013 + cNumCtc , {"OK"} )
Else
	Help('',1,'TMSA25205') //-- Contrato não foi gerado com sucesso !.	
EndIf
Return Nil	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Tmsa252Dtr³ Autor ³     Andre Godoi       ³ Data ³16.04.2008  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava o veiculo e motorista da vaigem                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tmsa252Dtr(cFilOri, cViagem, cCodVei, cCodMot)

RecLock( "DTR", .T.)
DTR->DTR_FILIAL := xFilial("DTR")
DTR->DTR_FILORI := cFilOri
DTR->DTR_VIAGEM := cViagem
DTR->DTR_ITEM   := StrZero( 1, Len( DTR->DTR_ITEM ) )
DTR->DTR_CODVEI := cCodVei
MsUnLock()

RecLock( "DUP", .T.)
DUP->DUP_FILIAL := xFilial("DUP")
DUP->DUP_FILORI := cFilOri
DUP->DUP_VIAGEM := cViagem
DUP->DUP_ITEDTR := StrZero( 1, Len( DUP->DUP_ITEDTR ) )
DUP->DUP_CODVEI := cCodVei
DUP->DUP_CODMOT := cCodMot
MsUnLock()

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA252Param ³ Autor ³ Andre Godoi			  ³ Data ³29.04.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica o preenchimento de alguns parametros necessarios pa³±±
±±³          ³ra gerar o contrato de Redespacho	                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA252			                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function TMA252Param()
Local ny
Local aEmptyCpo     := {}              
Local aCpSED		:= {}

//-- Declaradas como Private, na Tmsa252Pro, pois sao utilizadas na geracao do contrato, TMSA250.
cUniao    := GetMV("MV_UNIAO")	// Cod. para Pagto. do Imposto de Renda
cTipCTC   := Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) )    // Tipo Contrato de Carreteiro

If Empty(cNatuDEB)
    AADD(aEmptyCpo,"MV_NATDEB")
EndIf
If Empty(cCodDesCTC)
    AADD(aEmptyCpo,"MV_DESCTC")
EndIf

If Empty(cUniao)
    AADD(aEmptyCpo,"MV_UNIAO")
EndIf

If Empty(cTipCTC)
	cTipCTC := Padr( "C"+cFilAnt, Len( SE2->E2_TIPO ) ) // Tipo Contrato de Carreteiro
EndIf

For nY:=1 To Len(aEmptyCpo)
   Help("",1,"TMSA25003",,aEmptyCpo[nY],5,5) // Este Parametro esta vazio ... E Obrigatorio preenche-lo para geracao do Contrato de Carreteiro
Next

For nY:=1 To Len(aEmptyCpo)
   Help("",1,"TMSA25003",,aEmptyCpo[nY],5,5) // Este Parametro esta vazio ... E Obrigatorio preenche-lo para geracao do Contrato de Carreteiro
Next

If Len(aEmptyCpo) > 0
	Return .F.
EndIf        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o Conteudo de alguns Parametros                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !SED->(MsSeek(xFilial('SED')+cNatuDeb) )
	Help(" ",1,"TMSA25004",,"MV_NATDEB" + " : " + cNatuDeb,04,01) // Conteudo do parametro invalido MV_NATDEB 	
	Return .F.	
Else                                                                                  
	//--A Natureza de Debito nao deve calcular impostos para nao gerar duplicidade nos titulos.
	AAdd(aCpSED,"ED_CALCIRF")
	AAdd(aCpSED,"ED_CALCISS")	
	AAdd(aCpSED,"ED_CALCINS")
	AAdd(aCpSED,"ED_CALCCSL")
	AAdd(aCpSED,"ED_CALCCOF")
	AAdd(aCpSED,"ED_CALCPIS")
	AAdd(aCpSED,"ED_CALCSES")	
	AAdd(aCpSED,"ED_IRRFCAR")
	AAdd(aCpSED,"ED_INSSCAR")
	
	For ny:=1 To Len(aCpSED)
	    If SED->(FieldGet(FieldPos(aCpSED[ny]))) == "S"
        	Help(" ",1,"TMSA25027",,"MV_NATDEB" + " : " + cNatuDeb,05,01) // Conteudo do parametro invalido MV_NATDEB, a Natureza de Debito não deve calcular impostos para não gerar titulos indevidos. 
			Return .F.	
		EndIf
	Next	                       
EndIf

DT7->(dbSetOrder(1))
If !DT7->(MsSeek(xFilial('DT7')+cCodDesCTC))
	Help(" ",1,"TMSA25006",,"MV_DESCTC" + " : " + cCodDesCTC,04,01) // Conteudo do parametro invalido MV_DESCTC 	
	Return .F.	
EndIf

Return .T.
