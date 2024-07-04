#INCLUDE "MATA992.ch"
#INCLUDE "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATA992   º Autor ³ Julio Cesar        º Fecha³  02-06-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Realiza o cadastro do arquivo SFP, onde eh determinado o   º±±
±±º          ³ CAI para cada range de notas e serie.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±      
±±ºUso       ³ MATA992                                                    º±±
±±º         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºProgramador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M. Camargo  ³14/07/16³DMINA-3376³Se agrega funcionalidad para PERU para³±±
±±³            ³        ³          ³permitir que FP_SERIE2  sea editable  ³±±
±±³            ³        ³          ³al alterar un registro.               ³±±
±±³            ³        ³          |Se valida que el campo FP_SERIE2 no   ³±±
±±³            ³        ³          ³se pueda modificar si tiene registros ³±±
±±³            ³        ³          ³Se valida que el campo FP_SERIE2 no   ³±±
±±³            ³        ³          ³se pueda modificar si tiene registros ³±±
±±³            ³        ³          ³llamada función M486MODS2             ³±±
±±³Alf. Medrano³04/12/19³DMINA-5912³Se realizan adecuaciones a las func.  ³±±
±±³            ³        ³          ³A992altera, MA992TudOK, se excluye el ³±±
±±³            ³        ³          ³campo F9_NRCERT para Bolivia          ³±±
±±³LuisEnríquez³09/02/21³DMINA-    ³Se modifica funcion A992Altera(), para³±±
±±³              ³      ³10582     ³habilitar campo FP_TPDOC al utilizar  ³±±
±±³              ³      ³          ³la opcion "Modificar". (DOM)          ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATA992
Local aGerarCFD := {}
Local cMsgCFD   := ""
Local nX        := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Controle de Formularios ³
//³Paises:Chile/Colombia  - F1CHI		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lCFolLocR5 :=	GetRpoRelease ("R5") .AND. ;
					SuperGetMv("MV_CTRLFOL",,.F.) .AND. ;
					cPaisLoc$"CHI|COL"
Local  nTamPV	  	:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracion de Variables                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := STR0001 //"Archivo de Control de Formularios"
Private cString   := "SFP"
Private cDelFunc  := "MA992DelOk()"
Private lGerarCFD := .F.
Private aRotina   := MenuDef()
Private cSDocF1	  :=SerieNfId("SF1",3,"F1_SERIE")
Private cSDocF2	  :=SerieNfId("SF2",3,"F2_SERIE")


If  SFP->(ColumnPos("FP_PV")) > 0 
	nTamPV	  	:= TamSX3("FP_PV")[1]
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Controle de Formularios                       ³
//³Para os seguintes paises localizados, a rotina sera executada³
//³no SIGALOJA apenas p/ release 11.5 e parametro MV_CTRLFOL = T³
//³Paises: Chile/Colombia   - F1CHI                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc $ "CHI|COL" .AND. nModulo == 12
	If !lCFolLocR5
		Return NIL
	EndIf
EndIf	      

lGerarCFD := .F.
aGerarCFD := CFDVerific()
If aGerarCFD[1] <> "0" 
	If Empty(aGerarCFD[2])
		lGerarCFD := .T.
	Else
	    If !Empty(aGerarCFD[2])
			cMsgCFD := ""
			For nX := 1 To Len(aGerarCFD[2])
				cMsgCFD += aGerarCFD[2][nX][2] + CRLF
			Next
			MsgAlert(cMsgCFD,STR0017)
		Endif
	Endif
Endif

MA992GRVPV()

dbSelectArea("SFP")
dbSetOrder(1)

If aGerarCFD[1] == "0" .Or. lGerarCFD
	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString)
Endif

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A992Inclui³ Autor ³ Julio Cesar           ³ Data | 02/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Controle de Formularios         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A992Inclui(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA992                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION A992Inclui(cAlias,nReg,nOpc)
LOCAL nOpcA 
LOCAL l992Inc  := (ExistBlock("M992Inc"))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa algum filtro do SFP                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cOldFilter := SFP->( dbFilter() ) 
SFP->( dbClearFilter() ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]

While .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA:=0
	
	Begin Transaction
	nOpcA:=AxInclui( cAlias, nReg, nOpc,,,,"MA992TudOk(nOpc,nReg)")
	If l992Inc
		ExecBlock("M992Inc",.f.,.f., nOpcA )
	Endif
	If cPaisLoc = "ARG"
		MA992GRVX5()
	EndIf
	End Transaction
	Exit
EndDo
dbSelectArea(cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o filtro original                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( cOldFilter )                                          
	SET FILTER TO &cOldFilter
EndIf                     
	
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A992Altera³ Autor ³ Julio Cesar           ³ Data | 02/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de alteracao de Controle de Formularios           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A992Altera(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA992                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION A992Altera(cAlias,nReg,nOpc)

Local nOpcA 
Local l992Alt    := (ExistBlock("M992Alt")) 
Local aCpos      := {"FP_NUMINI","FP_NUMFIM","FP_CAI","FP_DTAVAL","FP_ATIVO"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Controle de Formularios ³
//³Paises:Chile/Colombia - F1CHI		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lCFolLocR5 :=	GetRpoRelease ("R5") .AND. ;
					SuperGetMv("MV_CTRLFOL",,.F.) .AND. ;
					cPaisLoc$"CHI|COL"

If cPaisLoc == "ARG"  .and. SFP->(ColumnPos("FP_RG1415")) > 0 
	aCpos      := {"FP_NUMINI","FP_NUMFIM","FP_CAI","FP_DTAVAL","FP_ATIVO","FP_RG1415"}
EndIf


If cPaisLoc <> 'EQU' 
	Private aDadosOri := {SFP->FP_NUMINI,SFP->FP_NUMFIM,SFP->FP_CAI}
Else
	Private aDadosOri := {SFP->FP_NUMINI,SFP->FP_NUMFIM,SFP->FP_NUMAUT}
EndIf					

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Localizacao Bolivia                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "BOL" .And. LocBol()
	aCpos := {"FP_NUMINI","FP_NUMFIM","FP_CAI","FP_DTAVAL","FP_ATIVO","FP_SERIE","FP_NUMAUT","FP_CODCTR","FP_CHAVE","FP_ESPECIE","FP_LOTE", "FP_PV", "FP_DOCFIS"} 
	If SFP->(ColumnPos("FP_TPTRANS")) > 0 
		aAdd(aCpos,"FP_TPTRANS")
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³       Tratamento especifico para localizado Peru        ³
//³  Abaixo estão os campos ficam editaveis na alteração da ³ 
//³ tabela SFP (Controle de formulários)                    ³  
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "PER"
	If M486MODS2(SFP->FP_SERIE2)
		aCpos := {"FP_DTAVAL","FP_SERIE","FP_FILUSO","FP_NUMINI","FP_NUMFIM","FP_NUMAUT","FP_ATIVO","FP_SERIE2"}
	Else
		aCpos := {"FP_DTAVAL","FP_SERIE","FP_FILUSO","FP_NUMINI","FP_NUMFIM","FP_NUMAUT","FP_ATIVO"}
	EndIF 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Localizacao Colombia                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "COL"
	aCpos := {"FP_DTAVAL","FP_SERIE","FP_FILUSO","FP_NUMINI","FP_NUMFIM","FP_NUMAUT","FP_ATIVO"}
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Localizacao Equador                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If cPaisLoc == "EQU" 
	aCpos      := {"FP_NUMINI","FP_NUMFIM","FP_NUMAUT","FP_DTAVAL","FP_ATIVO"}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Localizacao Republica Dominicana           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If cPaisLoc == "DOM" 
	aCpos := {"FP_NUMINI","FP_NUMFIM","FP_CAI","FP_ATIVO","FP_DTAVAL"}
	If SFP->(ColumnPos( "FP_TPDOC" )) > 0
		aAdd(aCpos, "FP_TPDOC")
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Localizacao Chile - Release 11.5  - F1CHI  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If lCFolLocR5
	If cPaisLoc == "CHI" 
		aCpos      := {"FP_DTAVAL","FP_ATIVO"}
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Localizacao Paraguay			           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If cPaisLoc == "PAR" 
	If SFP->(ColumnPos("FP_SERIE2")) > 0 
		aAdd(aCpos,"FP_SERIE2")
	EndIf
	If SFP->(ColumnPos("FP_FINITIM")) > 0 
		aAdd(aCpos,"FP_FINITIM")
	EndIf
	If SFP->(ColumnPos("FP_AUTOFAC")) > 0 
		aAdd(aCpos,"FP_AUTOFAC")
	EndIf
EndIf

If lGerarCFD .AND. !(cPaisLoc $ "BOL|PAR|")
	Aadd(aCpos,"FP_NRCERT")
	Aadd(aDadosOri,SFP->FP_NRCERT)
Endif

While .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA:=0
	
	Begin Transaction                                      
	nOpcA:=AxAltera(cAlias,nReg,nOpc,,aCpos,,,"MA992TudOk(nOpc,nReg)")
	If l992Alt
		ExecBlock("M992Alt",.f.,.f., nOpcA )
	Endif
	End Transaction
	Exit
EndDo
dbSelectArea(cAlias)
	
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA992TudOkº Autor ³ Julio Cesar        º Fecha³  02-06-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Realiza a validacao que verifica se a chave informada ja   º±±
±±º          ³ existe no arquivo SFP.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA992                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MA992TudOk(nOpc,nReg)

Local lRet     := .T.
Local aAreaAtu := GetArea()
Local cMsg := ""
Local aDadosNew:= {} 
Local cChave	 := "" 
Local cChave2	 := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Controle de Formularios ³
//³Paises:Chile/Colombia  - F1CHI		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lCFolLocR5 :=	GetRpoRelease ("R5") .AND. ;
					SuperGetMv("MV_CTRLFOL",,.F.) .AND. ;
					cPaisLoc$"CHI|COL"
Local  nTamPV	  	:= 0

If  SFP->(ColumnPos("FP_PV")) > 0 
	nTamPV	  	:= TamSX3("FP_PV")[1]
EndIf

// Isaac Silva 14/01/2010
// Rotina para validar os campos, nao esquecer de SUBSTITUIR MSGALERT POR STR

If SFP->(FieldPos("FP_TIPOFOR")) > 0  .And. SFP->(FieldPos("FP_QTDITEM"))  > 0
	If M->FP_TIPOFOR=="1" .And. M->FP_QTDITEM == 0
		MsgAlert(STR0018) // "O Tipo Form. Pré-Impresso, o campo QtItPreImp,não deverá ser Zero"
		lRet := .F.
	ElseIf M->FP_TIPOFOR=="2" .And. M->FP_QTDITEM > 0
		MsgAlert(STR0019) //"O Tipo Form. Normal, o campo QtItPreImp,deverá ser Zero"
		lRet := .F.
	ElseIf M->FP_TIPOFOR=="1" .And. Empty(M->FP_NUMFIM)
		MsgAlert(STR0020) //" Numero final de formulario é obrigatorio"        
		lRet := .F.
	ElseIf M->FP_TIPOFOR=="2" .And. !Empty(M->FP_NUMFIM)
		MsgAlert(STR0021) //"Numero final nao deve ser preenchido para o formulario auto impresso"
		lRet := .F.
	Endif
EndIf

If lRet .And. cPaisLoc=="ARG" .And. Len(Alltrim(M->FP_PV)) <> nTamPV 
	MSGALERT(STR0029  + Alltrim(STR(nTamPV)) + STR0030, STR0031)
	lRet:=.F.

EndIf

//
If lGerarCFD
	M->FP_NUMINI := PadL(AllTrim(M->FP_NUMINI),TamSX3("FP_NUMINI")[1],"0")
	M->FP_NUMFIM := PadL(AllTrim(M->FP_NUMFIM),TamSX3("FP_NUMFIM")[1],"0")
	If !(cPaisLoc $ "BOL|PAR|") 
		If (Empty(M->FP_NRCERT) .Or. Empty(M->FP_NUMINI) .Or. Val(M->FP_NUMFIM) <= 0) .OR. ( cPaisLoc != "MEX" .And. Empty(M->FP_CAI))
			cMsg := STR0013 + CRLF
			cMsg += RetTitle("FP_FILUSO") + CRLF
			If (cPaisLoc != "MEX")
				cMsg += RetTitle("FP_CAI") + CRLF
			EndIf
			cMsg += RetTitle("FP_NRCERT") + CRLF
			cMsg += RetTitle("FP_NUMINI") + CRLF
			cMsg += RetTitle("FP_NUMFIM") + CRLF + CRLF
			cMsg += STR0014 //"Por favor complételos."
			MsgAlert(cMsg)
			lRet := .F.
		EndIf
	ElseIf Empty(M->FP_NUMINI) .Or. Val(M->FP_NUMFIM) <= 0
		cMsg += RetTitle("FP_NUMINI") + CRLF
		cMsg += RetTitle("FP_NUMFIM") + CRLF + CRLF
		cMsg += STR0014 //"Por favor complételos."
		MsgAlert(cMsg)
		lRet := .F.
	Endif
Endif

M->FP_FILUSO := Iif(Empty(M->FP_FILUSO), cFilAnt,M->FP_FILUSO)

If !(cPaisLoc $ 'EQU|ARG|BOL') 
	aDadosNew:= {M->FP_FILUSO,M->FP_SERIE,M->FP_CAI,M->FP_NUMINI,; 
             M->FP_NUMFIM,M->FP_ESPECIE}
ElseIf cPaisLoc $ 'ARG|BOL|'
	aDadosNew:= {M->FP_FILUSO,M->FP_SERIE,M->FP_CAI,M->FP_NUMINI,; 
             M->FP_NUMFIM,M->FP_ESPECIE, M->FP_PV}
Else
	aDadosNew:= {M->FP_FILUSO,M->FP_SERIE,M->FP_NUMAUT,M->FP_NUMINI,; 
             M->FP_NUMFIM,M->FP_ESPECIE}	
EndIf

//So valida a existencia de registros igual quando se trata de inclusoes
If lRet
	If nOpc == 3
		If (cPaisLoc $ 'ARG|BOL|')			
			cChave := xFilial("SFP")+aDadosNew[1]+aDadosNew[2]+aDadosNew[3]+;
		          		aDadosNew[4]+aDadosNew[5]+aDadosNew[6]+aDadosNew[7]
		Else
			cChave := xFilial("SFP")+aDadosNew[1]+aDadosNew[2]+aDadosNew[3]+;
		          		aDadosNew[4]+aDadosNew[5]+aDadosNew[6]
		EndIf
		SFP->(dbSetOrder(3))
		If SFP->( dbSeek(cChave) )
		    
		    If lGerarCFD      
				MsgAlert(STR0015)
			Else
				MsgAlert(STR0007) //"Ja existe o CAI informado. Inclusao na realizada."
			Endif
			lRet := .F.
		EndIf
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Controle de Formularios ³
//³Paises:Chile/Colombia - F1CHI		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCFolLocR5
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Um range de numeracao deve ser unico exclusivo ³
	//³para uma determinada serie , Exemplo: 		  ³
	//³                                               ³
	//³SERIE 	ESPECIE	INICIO  FIM                   ³
	//³------ 	------- -------	------				  ³
	//³SR1     	FCT     00001   00010                 ³
	//³SR2     	BLT     00011   00020                 ³
	//³SR2     	BLT     00001   00010 <----ERRADO !!  ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. dbSeek(xFilial("SFP"))
	 	While !Eof() .And.	SFP->FP_FILIAL==xFilial("SFP")   
			If (nOpc == 4 .And. RecNo() <> nReg) .Or. nOpc == 3
				//Verifica se o numero inicial informado ja pertence a algum range...
				If aDadosNew[4] >= SFP->FP_NUMINI .And. aDadosNew[4] <= SFP->FP_NUMFIM .AND. SFP->FP_SERIE== aDadosNew[2] .AND. SFP->FP_ESPECIE == aDadosNew[6]		   
					MsgAlert(STR0008) //"Ja existe um intervalo para o numero inicial informado. Inclusao na realizada"
					lRet := .F.
					Exit
				EndIf
								
				//Verifica se o numero final informado ja pertence a algum range...
				If aDadosNew[5] >= SFP->FP_NUMINI .And. aDadosNew[5] <= SFP->FP_NUMFIM .AND. SFP->FP_SERIE== aDadosNew[2] .AND. SFP->FP_ESPECIE == aDadosNew[6]	 			   
					MsgAlert(STR0009) //"Ja existe um intervalo para o numero final informado. Inclusao na realizada"
					lRet := .F.
					Exit
				EndIf 				
				
				//Verifica se a serie ja esta em uso por outro lote de formulario.
				If aDadosNew[2] == SFP->FP_SERIE .And. aDadosNew[4] >= SFP->FP_NUMINI .And. aDadosNew[5] <= SFP->FP_NUMFIM .And. SFP->FP_ESPECIE == aDadosNew[6] 
					MsgAlert(STR0022)//"A série informada já está em uso !"
					lRet := .F.
					Exit
				EndIf
									
			EndIf	
			dbSkip()
		End	
	EndIf
Else 

If (cPaisLoc $ 'ARG|BOL|')
	cChave := xFilial("SFP")+aDadosNew[1]+aDadosNew[2]+aDadosNew[6]+aDadosNew[7]
Else
	cChave := xFilial("SFP")+aDadosNew[1]+aDadosNew[2]+aDadosNew[6]
EndIf

SFP->(dbSetOrder(5)) //FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE+FP_PV 
If lRet .And. SFP->( dbSeek( cChave ))
	If (cPaisLoc $ 'ARG|BOL|')
		cChave2 := xFilial("SFP")+SFP->FP_FILUSO+SFP->FP_SERIE+SFP->FP_ESPECIE+SFP->FP_PV 
	Else
		cChave2 := xFilial("SFP")+SFP->FP_FILUSO+SFP->FP_SERIE+SFP->FP_ESPECIE 
	EndIf
	
	While SFP->(!Eof()) .And.	cChave2 == cChave
	
			If (nOpc == 4 .And. SFP->(Recno()) <> nReg) .Or. nOpc == 3
				//Verifica se o numero inicial informado ja pertence a algum range...
				If aDadosNew[4] >= SFP->FP_NUMINI .And. aDadosNew[4] <= SFP->FP_NUMFIM 			   
					MsgAlert(STR0008) //"Ja existe um range para o numero inicial informado. Inclusao na realizada"
					lRet := .F.
					Exit
				EndIf
								
				//Verifica se o numero inicial informado ja pertence a algum range...
				If aDadosNew[5] >= SFP->FP_NUMINI .And. aDadosNew[5] <= SFP->FP_NUMFIM 			   
					MsgAlert(STR0009) //"Ja existe um range para o numero final informado. Inclusao na realizada"
					lRet := .F.
					Exit
				EndIf
							
			EndIf
			SFP->(dbSkip())
			If (cPaisLoc $ 'ARG|BOL|')
				cChave2 := xFilial("SFP")+SFP->FP_FILUSO+SFP->FP_SERIE+SFP->FP_ESPECIE+SFP->FP_PV 
			Else
				cChave2 := xFilial("SFP")+SFP->FP_FILUSO+SFP->FP_SERIE+SFP->FP_ESPECIE 
			EndIf
		End
	EndIf
EndIf

If (lRet) .And. (cPaisLoc == "ARG")
	If (Left(M->FP_NUMINI,nTamPV) <> M->FP_PV) 
		MsgAlert(STR0027) //"Os quatro primeiros dígitos da numeração inicial diferem do número do ponto de venda."
		lRet := .F.
   ElseIf   M->FP_TIPOFOR=="1"  .And. (Left(M->FP_NUMFIM,nTamPV) <> M->FP_PV)   
		MsgAlert(STR0028) //"Os quatro primeiros dígitos da numeração final diferem do número do ponto de venda."
		lRet := .F.
	EndIf
EndIf


//Executa funcao que valida a alteracao dos ranges das Facturas X CAI
If lRet .And. nOpc == 4
	lRet := VlAltRange(aDadosOri,aDadosNew)
EndIf 

If !lGerarCFD
	//Valida a especie caso o parametro MV_CONTNF seja igual a "I"
	If lRet .And. GetMV("MV_CONTNF",,"I") == "I" .And. Empty(M->FP_ESPECIE)
		MsgAlert(STR0012) //"Es necesario ingresar una especie valida. Inclusion no realizada."
		lRet := .F.
	EndIf
EndIf

A992Lote() 

RestArea(aAreaAtu)

Return(lRet)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA992DelOkº Autor ³ Julio Cesar        º Fecha³  02-06-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Realiza a validacao que verifica se pode ser realizada a   º±±
±±º          ³ exclusao do registro selecionado.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA992                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MA992DelOk()

Local lRet     := .T.
Local aAreaAtu := GetArea()
Local aAreaSF2 := {} 
Local aAreaSF1 := {}
Local cModAcSF2:= Posicione("SX2",1,"SF2","X2_MODO")  
Local cModAcSF1:= Posicione("SX2",1,"SF1","X2_MODO") 
Local cFilSF2  := "" 
Local cFilSF1  := ""
Local alEspec  := {}
Local clEspec  := ""
Local clPos	   := ""
Local nI	   := 0	
Local llAux	   := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Release 11.5 - Controle de Formularios ³
//³Paises:Chile/Colombia  - F1CHI		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lCFolLocR5 :=	GetRpoRelease ("R5") .AND. ;
					SuperGetMv("MV_CTRLFOL",,.F.) .AND. ;
					cPaisLoc$"CHI|COL"
Local cEstRes	:= ""										//Codigo da estacao em que a serie esta reservada
Local cSerie	:= ""										//Codigo da serie

If lCFolLocR5
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Release 11.5 - Controle de Formularios ³
	//³Paises:Chile/Colombia  - F1CHI		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
	cSerie := SFP->FP_SERIE
	//Verificar se a serie do lote de formulario esta reservada para alguma estacao.		
	If ChkResEst (cSerie,@cEstRes)
	    MsgAlert(STR0023 + cSerie + STR0024 + cEstRes + "." + STR0025)//"A série "#" está reservada para a estacao "#"Operacao cancelada." 
		lRet := .F.
		Return(lRet) 			
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificar se existem notas de saida gravadas (SF2) com ³
	//³a serie do controle de formulario                      ³
	//³                                                       ³
	//³1=FCT (Factura)                                        ³
	//³2=FCX(Factura Exenta)                                  ³
	//³3=BLT (Boleta)                                         ³
	//³4=BLX(Boleta Exenta)                                   ³
	//³6=NDC (Nota De Debito P/Cliente)                       ³
	//³7=NDI (Nota De Debito Interna)                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	If Empty(SFP->FP_ESPECIE) .Or. SFP->FP_ESPECIE$"1|2|3|4|6|7"

		cFilSF2 := Iif(Empty(cModAcSF2),TAMSX3("F2_FILIAL")[1],SFP->FP_FILUSO)
		/*
		Projeto Chave unica - Tiago Silva 11/05/2015 - DBSEEK que utilizava um campo FP_SERIE para posicionar a
		SF2 foi substituido pela função M992VLRG. 
		*/
		If M992VLRG("SF2",SFP->FP_FILUSO,SFP->FP_NUMINI,SFP->FP_SERIE,SFP->FP_NUMFIM)
			If lGerarCFD
				MsgAlert(STR0016)
			Else
				MsgAlert(STR0026 + STR0025)//"Controle de formulário ja utilizado na geracao de notas fiscais."#"Operacao cancelada."
			EndIf
			lRet := .F.
		EndIf
	EndIf		 
	
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza validacao para as facturas ³
	//³gravadas no Arquivo SF1	          ³
	//³                                   ³
	//³1=FCT (Factura)                    ³
	//³2=FCX (Factura Exenta)	          ³
	//³8=NCC (Nota De Credito P/Cliente)  ³
	//³9=NCI (Nota De Crédito Interna)    ³
	//³A=NCX (Nota De Crédito Exenta)     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. (Empty(SFP->FP_ESPECIE) .Or. SFP->FP_ESPECIE$"1|2|8|9|A")
		cFilSF1 := Iif(Empty(cModAcSF1),TAMSX3("F1_FILIAL")[1],SFP->FP_FILUSO)	
		/*
		Projeto Chave unica - Tiago Silva 11/05/2015 - DBSEEK que utilizava um campo FP_SERIE para posicionar a
		SF1 foi substituido pela função M992VLRG. 
		*/
		If	M992VLRG("SF1",SFP->FP_FILUSO,SFP->FP_NUMINI,SFP->FP_SERIE,SFP->FP_NUMFIM)	 
			If lGerarCFD
				MsgAlert(STR0016)
			Else		
				MsgAlert(STR0026 + STR0025)//"Lote de formulário ja utilizado na geracao de notas fiscais."#"Operacao cancelada."
			EndIf
			lRet := .F.
		EndIf
		/* Seek original substituido pela função M992VLRG() 
		dbSelectArea("SF1") 
   		SF1->(DBGoTop())
		aAreaSF1 := GetArea()
		While SF1->(!EOF()) .AND. F1_FILIAL == cFilSF1   											  
			If	F1_FILIAL+&cSDocF1+E+F1_DOC >= SFP->FP_FILUSO+SFP->FP_SERIE+SFP->FP_NUMINI .And.; 
				F1_FILIAL+&cSDocF1+F1_DOC <= SFP->FP_FILUSO+SFP->FP_SERIE+SFP->FP_NUMFIM			 
				If lGerarCFD
					MsgAlert(STR0016)
				Else		
					MsgAlert(STR0026 + STR0025)//"Lote de formulário ja utilizado na geracao de notas fiscais."#"Operacao cancelada."
				EndIf
				lRet := .F.
				Exit
			EndIf
			dbSkip()
		End
		RestArea(aAreaSF1)
		*/
	EndIf				
	RestArea(aAreaAtu)

Else

	If cPaisLoc <> "VEN"
	      
		//Realiza validacao para as notas gravadas no arquivo SF2...
		If Empty(SFP->FP_ESPECIE) .Or. SFP->FP_ESPECIE$"1|3|5" .OR. cPaisLoc == "DOM"
			
			cFilSF2 := Iif(Empty(cModAcSF2),TAMSX3("F2_FILIAL")[1],SFP->FP_FILUSO)
			/*
			Projeto Chave unica - Tiago Silva 11/05/2015 - DBSEEK que utilizava um campo FP_SERIE para posicionar a
			SF2 foi substituido pela função M992VLRG. 
			*/
			If  M992VLRG("SF2",SFP->FP_FILUSO,SFP->FP_NUMINI,SFP->FP_SERIE,SFP->FP_NUMFIM) 
				If lGerarCFD
					MsgAlert(STR0016)
				Else
					MsgAlert(STR0010) //"Esse CAI ja foi utilizado na geracao de notas fiscais. Exclusao nao realizada."
				Endif
				lRet := .F.
			EndIf
			/* seek original substituido pela M992VLRG()
			dbSelectArea("SF2") 
			aAreaSF2 := GetArea()
			dbSetOrder(1)
			If dbSeek(cFilSF2+SFP->FP_NUMINI+SFP->FP_SERIE,Iif(cPaisLoc == "DOM",.T.,.F.)) .OR. cPaisLoc == "DOM" 
				While !Eof() .And. F2_FILIAL == cFilSF2
					If	F2_FILIAL+F2_SERIE+F2_DOC >= SFP->FP_FILUSO+SFP->FP_SERIE+SFP->FP_NUMINI .And.; 
						F2_FILIAL+F2_SERIE+F2_DOC <= SFP->FP_FILUSO+SFP->FP_SERIE+SFP->FP_NUMFIM			 
						If lGerarCFD
							MsgAlert(STR0016)
						Else
							MsgAlert(STR0010) //"Esse CAI ja foi utilizado na geracao de notas fiscais. Exclusao nao realizada."
						Endif
						lRet := .F.
						Exit
					EndIf
					dbSkip()
				End
			EndIf
			RestArea(aAreaSF2)
			*/
		EndIf
		
		//Realiza validacao para as facturas gravadas no Arquivo SF1
		If lRet .And. (Empty(SFP->FP_ESPECIE) .Or. SFP->FP_ESPECIE$"1|2|4")
			/*
			Projeto Chave unica - Tiago Silva 11/05/2015 - DBSEEK que utilizava um campo FP_SERIE para posicionar a
			SF1 foi substituido pela função M992VLRG. 
			*/
			cFilSF1 := Iif(Empty(cModAcSF1),TAMSX3("F1_FILIAL")[1],SFP->FP_FILUSO)
			If  M992VLRG("SF1",SFP->FP_FILUSO,SFP->FP_NUMINI,SFP->FP_SERIE,SFP->FP_NUMFIM)
				If lGerarCFD
					MsgAlert(STR0016)
				Else
					MsgAlert(STR0010) //"Esse CAI ja foi utilizado na geracao de notas fiscais. Exclusao nao realizada."
				Endif
				lRet := .F.
			EndIf			
			/* seek original substituido pela função M992VLRG()
			Projeto Chave unica
			*/
			/*
			dbSelectArea("SF1") 
			aAreaSF1 := GetArea()
			dbSetOrder(1)
			If dbSeek(cFilSF1+SFP->FP_NUMINI+SFP->FP_SERIE,.F.)//Tiago Silva
				While !Eof() .And. F1_FILIAL == cFilSF1
					If	F1_FILIAL+F1_SERIE+F1_DOC >= SFP->FP_FILUSO+SFP->FP_SERIE+SFP->FP_NUMINI .And.; //Tiago Silva
						F1_FILIAL+F1_SERIE+F1_DOC <= SFP->FP_FILUSO+SFP->FP_SERIE+SFP->FP_NUMFIM		//Tiago Silva	 
						If lGerarCFD
							MsgAlert(STR0016)
						Else
							MsgAlert(STR0010) //"Esse CAI ja foi utilizado na geracao de notas fiscais. Exclusao nao realizada."
						Endif
						lRet := .F.
						Exit
					EndIf
					dbSkip()
				End
			EndIf
			RestArea(aAreaSF1)
			*/
		EndIf
		RestArea(aAreaAtu)
	Else
		clEspec := SuperGetMv("MV_ESPCF")
		alEspec := Separa(clEspec,";")					
		For nI := 1 to Len(alEspec)
			If SFP->FP_ESPECIE == alltrim(str(nI))
				clPos := alEspec[nI]
				llAux := .T.
				Exit
			EndIF
		Next nI     
	 
		//Realiza validacao para as notas gravadas no arquivo SF2...
		If Empty(SFP->FP_ESPECIE) .Or. SFP->FP_ESPECIE$"1|3|4|6"
			dbSelectArea("SF2") 
			SF2->(DBGotop())			
			aAreaSF2 := GetArea()
			cFilSF2 := Iif(Empty(cModAcSF2),TAMSX3("F2_FILIAL")[1],SFP->FP_FILUSO)		
			If llAux
				While SF2->(!EOF()) .AND. F2_FILIAL == cFilSF2   											  
					If clPos == alltrim(SF2->F2_ESPECIE)
						If SF2->F2_DOC >= SFP->FP_NUMINI .AND. SF2->F2_DOC <= SFP->FP_NUMFIM
							If lGerarCFD
								MsgAlert(STR0016)								
							Else
								MsgAlert(STR0010) //"Esse CAI ja foi utilizado na geracao de notas fiscais. Exclusao nao realizada."
							Endif
							lRet := .F.
							Exit
						EndIF
					EndIF 
					SF2->(DBSkip())
				EndDo
			EndIF
		EndIF
				
		//Realiza validacao para as facturas gravadas no Arquivo SF1
		If lRet .And. (Empty(SFP->FP_ESPECIE) .Or. SFP->FP_ESPECIE$"1|2|5|6")
			dbSelectArea("SF1") 
			SF1->(DBGoTop())
			aAreaSF1 := GetArea()
			cFilSF1 := Iif(Empty(cModAcSF1),TAMSX3("F1_FILIAL")[1],SFP->FP_FILUSO)
			If llAux
				While SF1->(!EOF()) .AND. F1_FILIAL == cFilSF1   											  
					If clPos == alltrim(SF1->F1_ESPECIE)
						If SF1->F1_DOC >= SFP->FP_NUMINI .AND. SF1->F1_DOC <= SFP->FP_NUMFIM
							If lGerarCFD
								MsgAlert(STR0016)								
							Else
								MsgAlert(STR0010) //"Esse CAI ja foi utilizado na geracao de notas fiscais. Exclusao nao realizada."
							Endif
							lRet := .F.
							Exit
						EndIF
					EndIF 
					SF1->(DBSkip())
				EndDo
			EndIF
		EndIF	
	EndIF
EndIf
	
Return(lRet) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VlAltRangeº Autor ³ Julio Cesar        º Fecha³  02-06-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se o range de numero das facturas pode ser        º±±
±±º          ³ alterado.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA992                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VlAltRange(aDadosOri,aDadosNew)

Local lRet      := .T.
Local aAreaSF2  := {}                                
Local aAreaSF1  := {}
Local cModAcSF2 := Posicione("SX2",1,"SF2","X2_MODO") 
Local cModAcSF1 := Posicione("SX2",1,"SF1","X2_MODO")
Local cFilSF2   := "" 
Local cFilSF1   := "" 

//Realiza validacao para as facturas gravadas no Arquivo SF2
If Empty(aDadosNew[6]) .Or. aDadosNew[6]$"1|3|5" 
	//Realiza validacoes caso o numero inicial tenha sido alterado...
	If aDadosOri[1] < aDadosNew[4]
		cFilSF2 := Iif(Empty(cModAcSF2),TAMSX3("F2_FILIAL")[1],aDadosNew[1])

		//Caso o numero original seja menor que o informado verifica se existe
		//alguma factura impressa para o range e se o campo CAI esta gravado...
		/*
		Projeto Chave unica - Tiago Silva 11/05/2015 - DBSEEK que utilizava um campo FP_SERIE para posicionar a
		SF2 foi substituido pela função M992VLRG. 
		*/		
		If M992VLRG("SF2",cFilSF2,aDadosNew[4],aDadosNew[2],)
			MsgAlert(STR0011) //"O numero inicial nao podera ser alterado, pois o seu range ja foi utilizado."
			lRet := .F.
		EndIf
		/* seek original substituido pela função M992VLRG()
		dbSelectArea("SF2")
		aAreaSF2 := GetArea()
		dbSetOrder(1)
		If dbSeek(cFilSF2+aDadosOri[1]+aDadosNew[2],.F.)
			If F2_FILIAL+F2_DOC+F2_SERIE <= aDadosNew[1]+aDadosNew[4]+aDadosNew[6] 
				MsgAlert(STR0011) //"O numero inicial nao podera ser alterado, pois o seu range ja foi utilizado."
				lRet := .F.
			EndIf
		EndIf
		RestArea(aAreaSF2)
		*/
	EndIf	   

	//Realiza validacoes caso o numero inicial tenha sido alterado...
	If lRet .And. aDadosOri[2] > aDadosNew[5]
		cFilSF2 := Iif(Empty(cModAcSF2),TAMSX3("F2_FILIAL")[1],aDadosNew[1])
		/*
		Projeto Chave unica - Tiago Silva 11/05/2015 - DBSEEK que utilizava um campo FP_SERIE para posicionar a
		SF2 foi substituido pela função M992VLRG. 
		*/
		If M992VLRG("SF2",cFilSF2,aDadosOri[2],aDadosNew[2],)
			MsgAlert(STR0011) //"O numero inicial nao podera ser alterado, pois o seu range ja foi utilizado."
			lRet := .F.
		EndIf
		/* seek original substituido pela função M992VLRG()
		dbSelectArea("SF2")
		aAreaSF2 := GetArea()
		dbSetOrder(1)
		//Caso o numero original seja menor que o informado verifica se existe
		//alguma factura impressa para o range e se o campo CAI esta gravado...
		If dbSeek(cFilSF2+aDadosNew[5]+aDadosNew[2],.F.)
			If F2_FILIAL+F2_DOC+F2_SERIE <= aDadosNew[1]+aDadosOri[2]+aDadosNew[2] 
				MsgAlert(STR0011) //"O numero inicial nao podera ser alterado, pois o seu range ja foi utilizado."
				lRet := .F.
			EndIf
		EndIf
		RestArea(aAreaSF2)
		*/
	EndIf	   
EndIf

//Realiza validacao para as facturas gravadas no Arquivo SF1
If lRet .And. (Empty(aDadosNew[6]) .Or. aDadosNew[6]$"1|2|4")
	//Realiza validacoes caso o numero inicial tenha sido alterado...
	If aDadosOri[1] < aDadosNew[4]
		cFilSF1 := Iif(Empty(cModAcSF1),TAMSX3("F1_FILIAL")[1],aDadosNew[1])
		//Caso o numero original seja menor que o informado verifica se existe
		//alguma factura impressa para o range e se o campo CAI esta gravado...
		/*
		Projeto Chave unica - Tiago Silva 11/05/2015 - DBSEEK que utilizava um campo FP_SERIE para posicionar a
		SF1 foi substituido pela função M992VLRG. 
		*/
		If M992VLRG("SF1",cFilSF1,aDadosNew[4],aDadosNew[2],)
			MsgAlert(STR0011) //"O numero inicial nao podera ser alterado, pois o seu range ja foi utilizado."
			lRet := .F.
		EndIf
		/* seek original substituido pela função M992VLRG
		dbSelectArea("SF1")
		aAreaSF1 := GetArea()
		dbSetOrder(1)
		If dbSeek(cFilSF1+aDadosOri[1]+aDadosNew[2],.F.)
			If F1_FILIAL+F1_DOC+F1_SERIE <= aDadosNew[1]+aDadosNew[4]+aDadosNew[2] //Tiago Silva
				MsgAlert(STR0011) //"O numero inicial nao podera ser alterado, pois o seu range ja foi utilizado."
				lRet := .F.
			EndIf
		EndIf
		RestArea(aAreaSF1)
		*/
	EndIf	   

	//Realiza validacoes caso o numero inicial tenha sido alterado...
	If lRet .And. aDadosOri[2] > aDadosNew[5]
		cFilSF1 := Iif(Empty(cModAcSF1),TAMSX3("F1_FILIAL")[1],aDadosNew[1])

		//Caso o numero original seja menor que o informado verifica se existe
		//alguma factura impressa para o range e se o campo CAI esta gravado...
		/*
		Projeto Chave unica - Tiago Silva 11/05/2015 - DBSEEK que utilizava um campo FP_SERIE para posicionar a
		SF1 foi substituido pela função M992VLRG. 
		*/
		If M992VLRG("SF1",cFilSF1,aDadosNew[2],aDadosOri[2],)
			MsgAlert(STR0011) //"O numero inicial nao podera ser alterado, pois o seu range ja foi utilizado."
			lRet := .F.
		EndIf
		/* seek original substituido pela função M992VLRG()
		dbSelectArea("SF1")
		aAreaSF1 := GetArea()
		dbSetOrder(1)
		If dbSeek(cFilSF1+aDadosNew[5]+aDadosNew[2],.F.)
			If F1_FILIAL+F1_DOC+F1_SERIE <= aDadosNew[1]+aDadosOri[2]+aDadosNew[2]//Tiago Silva
				MsgAlert(STR0011) //"O numero inicial nao podera ser alterado, pois o seu range ja foi utilizado."
				lRet := .F.
			EndIf
		EndIf
		RestArea(aAreaSF1)
		*/
	EndIf	   
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M992TpFactº Autor ³ Julio Cesar        º Fecha³  02-06-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Determina se o campo FP_ESPECIE pode ser editado ou nao.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA992                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M992TpFact()

lRet := Iif(GetMV("MV_CONTNF",,"I")=="I",.T.,.F.)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
     
Private aRotina := {	{STR0002,"AxPesqui"	,0,1,0,.F.} ,;	//"Buscar"
                    	{STR0003,"AxVisual"	,0,2,0,NIL} ,;		//"Visualizar"
             			{STR0004,"A992Inclui",0,3,0,NIL} ,;	//"Incluir"
             			{STR0005,"A992Altera",0,4,0,NIL} ,;	//"Modificar"
             			{STR0006,"AxDeleta"	,0,5,0,NIL} }		//"Borrar"

If ExistBlock("M992MNU")
	ExecBlock("M992MNU",.F.,.F.)
EndIf

Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A992Lote  º Autor ³ Sergio S. Fuzinaka º Fecha³  20.07.07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao do campo Lote                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA992                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A992Lote()

If cPaisLoc == "BOL" .And. LocBol() .And. M->FP_LOTE == "2"
	M->FP_CODCTR := Space(TamSx3("FP_CODCTR")[1])
Endif

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M992VCAI  º Autor ³ Paulo Augusto      º Fecha³  23.12.09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao do codigo de CAI                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA992                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M992VCAI(cTipo) 

Local nTipoDc:=1
Local lRet:=.T.                        
Local  nTamPV	  	:= 0

If  SFP->(ColumnPos("FP_PV")) > 0 
	nTamPV	  	:= TamSX3("FP_PV")[1]
EndIf


Default cTipo:="1"
If FindFunction("VldCAIE")
	nTipoDc:=Iif(cTipo="1",1,Iif(cTipo="5",2,3))
	lRet:=VldCAIE(SM0->M0_CGC,Alltrim(M->FP_SERIE),nTipoDc,SUBS(M->FP_NUMINI,1,nTamPV),M->FP_CAI,M->FP_DTAVAL )
EndIf

Return(lRet)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ChkResEst º Autor ³ Vendas CRM		 º Data ³  24/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se a serie do formulario esta reservado p/ estacaoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA992                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ChkResEst (cSerie,cEstRes)
Local lRet	:= .F. 			//Retorno
Local aArea := GetArea()   	//Area
DEFAULT cSerie:= ""
DEFAULT cEstRes:=""

DbSelectArea("SL6")
DbSetOrder(1)

If DbSeek(xFilial("SL6")+cSerie)
	cEstRes:= SL6->L6_ESTACAO
	lRet:= .T.
EndIf

SL6->(DbCloseArea())
RestArea(aArea) 

Return lRet 
//-------------------------------------------------------------------
/*/{Protheus.doc} MA992GRVPV
Rotina desenvolvida para carregar para o campo de ponto de venda (FP_PV)
os  primeiros digitos do número do FP_NUMINI.
Essa rotina foi desenvolvida apenas para carga inicial do campo, 
levando-se em consideração todo o legado.

Rotina feita especificamente para argentina 
Item de RoadMap: M_FIS004 - REQ002:001692

@author Leandro Prado
@since 18/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function MA992GRVPV
Local cPV	:= ""   
Local  nTamPV	  	:= 0

If  SFP->(ColumnPos("FP_PV")) > 0 
	nTamPV	  	:= TamSX3("FP_PV")[1]
EndIf

If cPaisLoc = "ARG"
	dbSelectArea("SFP")
	dbSetOrder(9)
	If SFP->(MsSeek(xFilial("SFP")+"  "))
		While SFP->(!EOF()) .And. (Empty(SFP->FP_PV))
			cPV := SubStr(SFP->FP_NUMINI,1,nTamPV) //As quatro primeiras posições correspondem ao número do PV.
			("CFH")->(dbSetOrder(1))
			If !(("CFH")->(MsSeek(xFilial("CFH") + cPV))) 
				//Se não existe na tabela de Ponto de Venda, cria um novo registro. 
				If RecLock("CFH",.T.)
					("CFH")->CFH_FILIAL := xFilial("CFH")
					("CFH")->CFH_CODIGO := cPV //Grava os quatro primeiros dígitos do FP_NUMINI.
					("CFH")->CFH_DESCRI := cPV //Replico o código apenas para não deixar em branco a descrição.
					("CFH")->CFH_IDPV   := GetSx8Num("CFH","CFH_IDPV") //Incrementa CFH_IDPV; 
					("CFH")->(MsUnlock())
				EndIf
			EndIf		
			//Preenche o campo de Ponto de Venda, criando assim o relacionamento com CFH.
			If RecLock("SFP",.F.)
				SFP->FP_PV := cPV
				SFP->(MsUnlock())
			EndIf
			//Mecanismo para gravar SX5.
			MA992GRVX5(.T.)
			
			
			SFP->(DBSkip())
			dbSelectArea("SFP")
			dbSetOrder(9)
			SFP->(MsSeek(xFilial("SFP")+"  "))
		EndDo
	EndIf	
EndIf
Return (.T.)


//-------------------------------------------------------------------
/*/{Protheus.doc} MA992GRVX5
Rotina desenvolvida para criar a númeração no sx5.

Rotina feita especificamente para argentina 
Item de RoadMap: M_FIS004 - REQ002:001692

@param lCarIni : Informa se está sendo chamado pela rotina de carga inicial.

@author Leandro Prado
@since 17/03/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function MA992GRVX5(lCarIni)

Local cIDPV	  := POSICIONE("CFH",1, xFilial("CFH")+SFP->FP_PV,"CFH_IDPV")
Local cChaveSX5 := "01" + AllTrim(SFP->FP_SERIE) + cIDPV //Tiago Silva
Local cDescri	  := SFP->FP_NUMINI      
Local  nTamPV	  	:= 0

If  SFP->(ColumnPos("FP_PV")) > 0 
	nTamPV	  	:= TamSX3("FP_PV")[1]
EndIf

Default lCarIni := .F.

SX5->(dbSetOrder(1))
If !(SX5->(dbSeek(xFilial("SX5")+cChaveSX5)))
 	
 	If lCarIni //Se for carga inicial e número inicial do range menor q o da X5, pega o número da X5.
		If (SX5->(dbSeek(xFilial("SX5")+"01" + AllTrim(SFP->FP_SERIE))))
			If (cDescri < SX5->X5_DESCRI) .And. ;
									(SubStr(cDescri,1,nTamPV) == SubStr(SX5->X5_DESCRI,1,nTamPV))
				cDescri := SX5->X5_DESCRI
			EndIf
 		EndIf
 	EndIf
 	
	If RecLock("SX5",.T.)
		("SX5")->X5_FILIAL 	:= xFilial("SX5")
		("SX5")->X5_TABELA 	:= '01' //Grava os quatro primeiros dígitos do FP_NUMINI.
		("SX5")->X5_CHAVE		:= AllTrim(SFP->FP_SERIE) + cIDPV
		("SX5")->X5_DESCRI	:= cDescri
		("SX5")->X5_DESCSPA	:= cDescri
		("SX5")->X5_DESCENG	:= cDescri
		("SX5")->(MsUnlock())
	EndIf

EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} M992GTLPV
Rotina desenvolvida para gatilhar o ID do PV.

Rotina feita especificamente para argentina 
Item de RoadMap: M_FIS004 - REQ002:001692

@param cPV: Código do PV.

@author Leandro Prado
@since 28/03/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function M992GTLPV(cPV)    

M->FP_IDPV := POSICIONE("CFH",1, xFilial("CFH")+cPV,"CFH_IDPV")

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} M992VLRG
Rotina desenvolvida para verificar o range de notas com uma determinada
serie para o controle de folios. PROJETO CHAVE UNICA. 

@param nOp: Opção para selecionar o arquivo a ser verificado, 1 = SF1, 2 = SF2. 
	   cFil: Filial cadastrada na SFP.
	   cNfIni: Número inicial de nota do range. 
	   cSer: Serie pesquisada.
	   cNfFim: Número final de nota do range. 

@author Tiago Silva
@since 12/05/2015
@version 1.0

/*/
//-------------------------------------------------------------------

Function M992VLRG(cAlias,cFil,cNfIni,cSer,cNfFim)

local lRet:=.F.
local cQuery:=""
local cCP:=substr(cAlias,2,2)
local cSDoc:=iif(substr(cSDocF1,1,2)==cCP,cSDocF1,cSDocF2)
local cAliasQry:=""

cQuery:=" SELECT "
cQuery+=" "+cCP+"_FILIAL "
cQuery+=" FROM "+retSqlName(cAlias)+" "+cAlias+" "
cQuery+=" WHERE "+cAlias+"."+cCP+"_FILIAL ='"+cFil+"' "
If !empty(cNfIni) .and. !empty(cNfFim)
	cQuery+="   AND "+cAlias+"."+cCP+"_DOC between '"+cNfIni+"' AND '"+cNfFim+"' "
Else
	cQuery+="   AND "+cAlias+"."+cCP+"_DOC <='"+cNfIni+"' "
EndIf		
cQuery+="   AND "+cAlias+"."+cSDoc+" ='"+cSer+"' "
cQuery+="   AND "+cAlias+".D_E_L_E_T_='' "
cQuery	  := ChangeQuery(cQuery)

cAliasQry := CriaTrab(Nil,.F.)
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .T., .T. )
dbSelectArea(cAliasQry)
if (cAliasQry)->(!EOF())
	lRet:=.T.
else
	lRet:=.F.
endif
(cAliasQry)->(dbCloseArea())

return (lRet)

Function VLDTAMPV(cPV)

Local lRet:=.T.
Local nTamPV:= TAMSX3("FP_PV")[1]

Default cPV:= ""

If Len(Alltrim(cPV)) <> nTamPV 
	MSGALERT(STR0029  + Alltrim(STR(nTamPV)) + STR0030, STR0031)
EndIf

Return(lRet)
