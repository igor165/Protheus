// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 05     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "protheus.ch"
#include "OFINJD02.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OFINJD02   | Autor |  Luis Delorme         | Data | 23/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Importacao da arquivo da JD contendo as ultimas atualizacoes |##
##|          | de substituição de itens                                     |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Pecas JD                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINJD02()
// Variaveis da ParamBox
Local aSay    := {}
Local aButton := {}
Local nOpc    := 0
//
Local cTitulo := STR0001
Local cDesc1  := STR0002
Local cDesc2  := STR0003
//
Private lSchedule := FWGetRunSchedule()
//
Private cPerg   := "OFINJD02"	// Pergunte pelo MENU
Private cPerg_S := "OFINJD02_S"	// Pergunte pelo Schedule
//
Private cLog
Private cFilSB1 := xFilial("SB1")
Private lGruNov := (VE9->(FieldPos("VE9_GRUNOV"))>0)
//
CriaSX1()
AcertaSXD()
//

if lSchedule
	
	conout("OFINJD02 - Iniciando")
	conout("OFINJD02 - Parametros: ")
	conout("OFINJD02 -    "+Alltrim(STR0016)+": "+MV_PAR01)

	RunProc() // Executar

Else

	Pergunte(cPerg,.f.)
	If !Pergunte(cPerg,.t.)
		Return
	EndIf

	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	//
	aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
	aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
	aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
	//
	Pergunte(cPerg,.f.)
	//
	FormBatch( cTitulo, aSay, aButton )
	//
	If nOpc <> 1
		Return
	Endif
	//#############################################################################
	//# Chama a rotina de importacao do cadastro de pecas GM                      #
	//#############################################################################
	RptStatus( {|lEnd| RunProc(@lEnd)}, STR0004,STR0005, .T. )

EndIf
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | RunProc    | Autor |  Luis Delorme         | Data | 17/04/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Importacao da arquivo da JD contendo as ultimas atualizacoes |##
##|          | do cadastro substituição de peças                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function RunProc(lEnd)
Local nCntFor
Local aVetNome := {}
Local aVetTam  := {}
Local aVetData := {}
Local aVetHora := {}

//#############################################################################
//# Tenta abrir o arquivo texto                                               #
//#############################################################################
cArquivo := MV_PAR01

if lSchedule
	if aDir(cArquivo+"PARTSUBS_*.DAT" ,aVetNome,aVetTam,aVetData,aVetHora) > 0 
		cArquivo += aVetNome[1]
		Conout("OFINJD02 - Arquivo: "+cArquivo)
	Endif	
Endif

//
if !File(cArquivo)
	if lSchedule
		Conout("OFINJD02 - "+STR0006+cArquivo+STR0007)
	Else
		MsgStop(STR0006+cArquivo+STR0007,STR0008)
	EndIf
	Return
endif
//
nHnd := FOPEN(Alltrim(cArquivo), 0)
//
//#############################################################################
//# Calcula quantidade de linhas do arquivo                                   #
//#############################################################################
aVetNome := {} 
aVetTam := {} 
aVetData := {}
aVetHora := {}
if lSchedule
	aDir( cArquivo ,aVetNome,aVetTam,aVetData,aVetHora)
Else		
	aDir( MV_PAR01 ,aVetNome,aVetTam,aVetData,aVetHora)
	SetRegua(100)
Endif

// le o cabeçalho do arquivo
nQtdReg := INT(aVetTam[1] / 256)
nCont	:= 0
//#############################################################################
//# Faz a leitura dos arquivos                                                #
//#############################################################################
FT_FGotop() 
cBuffer = SPACE(141)
FREAD(nHnd, @cBuffer, 141)
//
cStr := SPACE(141)
While FREAD(nHnd, @cStr, 141) > 0
	while AT("'",cSTR) > 0
		nChar := AT("'",cSTR)
		cStr := Left(cSTR,nChar-1)+" "+Subs(cSTR,nChar+1)
	enddo
	//
	If !lSchedule
		nCont++
		if nCont >  (nQtdReg / 100)
			nCont = 0
			IncRegua()
		Endif
	Endif
	// Armazena codigo do item do arquivo 
	cSubPart := SUBS(cStr,1,12)
	cFiller := SUBS(cStr,13,1)
	cSubType := SUBS(cStr,14,1)
	cFiller := SUBS(cStr,15,1)
	cFactoryCode := SUBS(cStr,16,2)
	cFiller := SUBS(cStr,18,1)
	cSubNew1 := SUBS(cStr,19,12)
	cFiller := SUBS(cStr,31,1)
	cSubQtd1 := SUBS(cStr,32,3)
	cFiller := SUBS(cStr,35,1)
	cSubNew2 := SUBS(cStr,36,12)
	cFiller := SUBS(cStr,48,1)
	cSubQtd2 := SUBS(cStr,49,3)
	cFiller := SUBS(cStr,52,1)
	cSubNew3 := SUBS(cStr,53,12)
	cFiller := SUBS(cStr,65,1)
	cSubQtd3 := SUBS(cStr,66,3)
	cFiller := SUBS(cStr,69,1)
	cSubNew4 := SUBS(cStr,70,12)
	cFiller := SUBS(cStr,82,1)
	cSubQtd4 := SUBS(cStr,83,3)
	cFiller := SUBS(cStr,86,1)
	cSubNew5 := SUBS(cStr,87,12)
	cFiller := SUBS(cStr,99,1)
	cSubQtd5 := SUBS(cStr,100,3)
	cFiller := SUBS(cStr,103,1)
	cSubNew6 := SUBS(cStr,104,12)
	cFiller := SUBS(cStr,116,1)
	cSubQtd6 := SUBS(cStr,117,3)
	cFiller := SUBS(cStr,120,1)
	cSubNew7 := SUBS(cStr,121,12)
	cFiller := SUBS(cStr,133,1)
	cSubQtd7 := SUBS(cStr,134,3)
	cFiller := SUBS(cStr,137,1)
	cTypeSub := SUBS(cStr,138,1)
	cFiller := SUBS(cStr,139,1)
	cInterInd := SUBS(cStr,140,1)
    //
    DBSelectArea("VE9")
    DBSetOrder(1)
	aPecaOld := {}
	aPecaOld := RETGRUITE(cSubPart)    
	if Len(aPecaOld) > 0
		if !Empty(cSubNew1)
			aPecaN1 := RETGRUITE(cSubNew1)    
			if Len(aPecaN1) > 0
				INSEREVE9(aPecaOld,aPecaN1,cSubQtd1)
			endif
		endif 
		if !Empty(cSubNew2)
			aPecaN2 := RETGRUITE(cSubNew2)    
			if Len(aPecaN2) > 0
				INSEREVE9(aPecaOld,aPecaN2,cSubQtd2)
			endif
		endif
		if !Empty(cSubNew3)
			aPecaN3 := RETGRUITE(cSubNew3)    
			if Len(aPecaN3) > 0
				INSEREVE9(aPecaOld,aPecaN3,cSubQtd3)
			endif
		endif
		if !Empty(cSubNew4)
			aPecaN4 := RETGRUITE(cSubNew4)    
			if Len(aPecaN4) > 0
				INSEREVE9(aPecaOld,aPecaN4,cSubQtd4)
			endif
		endif
		if !Empty(cSubNew5)
			aPecaN5 := RETGRUITE(cSubNew5)    
			if Len(aPecaN5) > 0
				INSEREVE9(aPecaOld,aPecaN5,cSubQtd5)
			endif
		endif
		if !Empty(cSubNew6)
			aPecaN6 := RETGRUITE(cSubNew6)    
			if Len(aPecaN6) > 0
				INSEREVE9(aPecaOld,aPecaN6,cSubQtd6)
			endif
		endif
		if !Empty(cSubNew7)
			aPecaN7 := RETGRUITE(cSubNew7)    
			if Len(aPecaN7) > 0
				INSEREVE9(aPecaOld,aPecaN7,cSubQtd7)
			endif
		endif
	endif
EndDo
//
ConfirmSX8()
FClose(nHnd)

//#############################################################################
//# Move o arquivo para o diretorio SALVA                                     #
//#############################################################################
lErro := .f.
cPath := ""
if lSchedule
	cArq := cArquivo
Else
	cArq := MV_PAR01
Endif	
cArquivo := ""
For nCntFor := Len(cArq) to 1 step -1
	if Subs(cArq,nCntFor,1) == "\"
		cPath = Left(cArq,nCntFor)
		cArquivo := SUBS(cArq,nCntFor+1,60)
		exit
	endif
next

cPathS = cPath + "SALVA"
aDir := Directory(cPathS,"D")
If Len(aDir) = 0
    If MakeDir(cPathS) <> 0
    	lErro := .t.
    EndIf
endif
if !lErro
	Copy File &(cPath+cArquivo) to &(cPath+"SALVA\"+cArquivo)
	Dele File &(Alltrim(cArq))
endif

if !lSchedule 
	if !Empty(cLog)
		DEFINE MSDIALOG oDlgLog TITLE OemtoAnsi(STR0009) FROM  08.1,10.6 TO 30.4,80.3 OF oMainWnd
		@ 001,001 GET oMsgLog VAR cLog OF oDlgLog MEMO SIZE 273,140 PIXEL READONLY MEMO
		DEFINE SBUTTON FROM 152,240 TYPE 1 ACTION oDlgLog:End() ENABLE OF oDlgLog
	     //
		ACTIVATE MSDIALOG oDlgLog CENTER
	     //
	   	if !(cQryAl001)->(eof())
			nRecWhere = (cQryAl001)->(CNT)
			cB1pB5 = (cQryAl001)->(B1_COD)
			lJaExiste := .t.
		endif
		(cQryAl001)->(dbCloseArea())
	Endif
Endif
DBSelectArea("SB1")
DBSetOrder(1)

if !lSchedule
	MsgInfo(STR0010,STR0008) // Arquivo importado com sucesso.
Else
	Conout("OFINJD02 - "+STR0010) // Arquivo importado com sucesso.
Endif

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | RETGRUITE  | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Retorna Grupo e Cod.Item a partir do CODANT                  |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function RETGRUITE(cPeca)

Local aRet := {}

cQryAl001 := GetNextAlias()

cQuery := "SELECT B1_GRUPO, B1_CODITE FROM " + RetSqlName("SB1")
cQuery += " WHERE B1_FILIAL ='" + cFilSB1 + "' AND B1_CODFAB ='" + Alltrim(cPeca) + "' AND"
cQuery += " D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
if !(cQryAl001)->(eof())
	aAdd(aRet,(cQryAl001)->(B1_GRUPO))
	aAdd(aRet,(cQryAl001)->(B1_CODITE))
endif
//
(cQryAl001)->(dbCloseArea())
//
return aRet

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | INSEREVE9  | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Insere no VE9                                                |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function INSEREVE9(aPecaOld,aPecaNov,cSubQtd)

Local cQryAl001 := GetNextAlias()

DBSelectArea("VE9")

nNro := StrZero(reccount()+1,6)
dDataSub := ddatabase

cQuery := "SELECT R_E_C_N_O_ RECN FROM " + RetSqlName("VE9")
cQuery += " WHERE VE9_FILIAL ='" + cFilSB1 + "'"
cQuery += " AND VE9_GRUITE ='" + Alltrim(aPecaOld[1]) + "'"
cQuery += " AND VE9_ITEANT ='" + Alltrim(aPecaOld[2]) + "'"
cQuery += " AND VE9_ITENOV ='" + Alltrim(aPecaNov[2]) + "'"
cQuery += " AND D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
nRecNo := -1
if !(cQryAl001)->(eof())
	nRecNo	 := (cQryAl001)->(RECN)
	VE9->(DBGoTo(nRecNo))
	nNro := VE9->VE9_NROSEQ
	dDataSub := VE9->VE9_DATSUB
endif
(cQryAl001)->(dbCloseArea())
//
DbSelectArea("VE9")
//
reclock("VE9",(nRecNo == -1))
VE9->VE9_FILIAL := xFilial("VE9")
VE9->VE9_NROSEQ := nNro
VE9->VE9_NROSUB := nNro
VE9->VE9_GRUITE := aPecaOld[1]
if lGruNov
	VE9->VE9_GRUNOV := aPecaNov[1]
endif
VE9->VE9_ITEANT := aPecaOld[2]
VE9->VE9_ITENOV := aPecaNov[2] 
VE9->VE9_QTDADE := VAL(cSubQtd)
VE9->VE9_DATSUB := dDataSub
msunlock()	

return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | CriaSX1    | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function CriaSX1()
Local aSX1    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lSX1	  := .F.
Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE // + GETF_RETDIRECTORY
Local nOpcDiret  := GETF_RETDIRECTORY

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aAdd a Pergunta                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Pergunte quando chamado pelo Menu
aAdd(aSX1,{cPerg,"01",STR0013,"","","MV_CH1","C",99,0,0,"G","Mv_Par01:=cGetFile('Arquivos |*.DAT','',,,,"+AllTrim(Str(nOpcGetFil))+")","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})

// Pergunte quando chamado pelo Schedule
aAdd(aSX1,{cPerg_S,"01",STR0016,"","","MV_CH1","C",99,0,0,"G","MV_PAR01:=cGetFile('Diretorio','',,,,"+AllTrim(Str(nOpcDiret))+")"             ,"MV_PAR01",""     ,"","","","",""     ,"","","","","","","","","","","","","","","","","","",""   ,"","S"})

dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
			lSX1 := .T.
			RecLock("SX1",.T.)
			For j:=1 To Len(aSX1[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				EndIf
			Next j
			dbCommit()
			MsUnLock()
		EndIf
	EndIf
Next i
dbSelectArea("SX1")
dbSetOrder(1)
If dbSeek(Left(cPerg+SPACE(20),Len(SX1->X1_GRUPO))+"02") // Excluir parametro de MARCA - a rotina nao utiliza esse parametro!
	RecLock("SX1",.F.,.T.)
		SX1->(dbDelete())
	MsUnLock()
EndIf

return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | AcertaSXD  | Autor | Andre Luis Almeida    | Data | 13/04/17 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Criacao do SXD - tabela utilizada no cadastro de Schedule    |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function AcertaSXD()
Local aArea	:= GetArea()
SXD->(DbSetOrder(1))
If !SXD->(DbSeek("OFINJD02"))
	DbSelectArea("SXD")
	RecLock("SXD",.T.)
	SXD->XD_TIPO    := "P"
	SXD->XD_FUNCAO  := "OFINJD02"
	SXD->XD_PERGUNT := "OFINJD02_S"
	SXD->XD_PROPRI  := "S"
	SXD->XD_TITBRZ  := STR0014 // Substituição de Peças JD
	SXD->XD_TITSPA  := STR0014 // Substituição de Peças JD
	SXD->XD_TITENG  := STR0014 // Substituição de Peças JD
	SXD->XD_DESCBRZ := STR0015 // Este programa tem o objetivo importar a substituição de Peças.
	SXD->XD_DESCSPA := STR0015 // Este programa tem o objetivo importar a substituição de Peças.
	SXD->XD_DESCENG := STR0015 // Este programa tem o objetivo importar a substituição de Peças.
	MsUnLock()
EndIf
RestArea(aArea)
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | SchedDef   | Autor | Andre Luis Almeida    | Data | 13/04/17 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Funcao utilizada no cadastro de Schedule                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function SchedDef()
Local aParam := {;
	"P",;
	"OFINJD02_S",;
	"",;
	"",;
	"" ;
	}
Return aParam