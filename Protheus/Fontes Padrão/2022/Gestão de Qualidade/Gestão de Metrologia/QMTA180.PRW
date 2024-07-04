#include "QMTA180.CH" 
#include "PROTHEUS.CH"
            
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QMTA180   ³ Autor ³ Eduardo Riera         ³ Data ³ 08.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Coleta do MSA (Avaliacao do Sistema de Medicao)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := {{ STR0001 	,"AxPesqui"  	, 0 , 1,,.F.},;	 //"Pesquisar"
					{ STR0002	,"Qmt180Visu"  	, 0 , 2},;	 //"Visual"
					{ STR0003   ,"Qmt180Incl" 	, 0 , 3},;	 //"Inclui"
					{ STR0004   ,"Qmt180Alte"	,0 	, 4},;	 //"Altera"
					{ STR0005   ,"Qmt180Excl"	,0 	, 5, 3},;//"Exclui"
					{ STR0007   ,"Qmt180Impo"	,0 	, 3}} 	 //"Importa"

Return aRotina

Function QMTA180()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oGet
Private oGetE
Private cCadastro := OemtoAnsi(STR0006)		//"Aval.do Sist. de Medi‡„o"
Private aPos   := {  15,  1, 70, 315 }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QMU")
dbSetOrder(1)
dbSeek(xFilial())
mBrowse( 6, 1,22,75,"QMU")

Return

/*/
antigo a180Inclui
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Qmt180Incl³ Autor ³ Eduardo Riera         ³ Data ³ 10.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclusao do MSA                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhuma                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Qmt180Incl(cAlias,nReg,nOpc)


Local nOpca    := 0
Local nUsado   := 0
Local nCntFor  := 0
Local nCntFor1 := 0
Local nPosCiclo:= 0
Local nSaveSX8 := GetSX8Len()     

Local aPosObj := {}  
Local aObjects:= {}   
Local aInfo   := {}      
Local aSize   := {}

Local aStruQMU := FWFormStruct(3, "QMU",,.F.)[3]
Local nX

Private aHeader := {}
Private aCols   := {}
Private aTela[0][0],aGets[0]
Private bCampo := { |nField| Field(nField) }
Private CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define tamanho da tela                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize(, .F., 400 )
AAdd( aObjects, { 100, 600, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. })

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis de Memoria da Enchoice                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QMU")
For nCntFor:= 1 To FCount()
	M->&(EVAL(bCampo,nCntFor)) := CriaVar(Eval(bCampo,nCntFor),.T.)
Next nCntFor
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o aHeader                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aStruQMU)
	If ( AllTrim(aStruQMU[nX,1])$"QMU_CICLOS#QMU_ITEM" ) 
		aadd(aHeader, Q180GetSX3(aStruQMU[nX,1], "", "") )
		nUsado++
		If ( AllTrim(aStruQMU[nX,1])$"QMU_CICLOS" )
			nPosCiclo := nUsado
		EndIf
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o aCols                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aCols,Array(nUsado+1))
aCols[1][nUsado+1] := .F.
For nCntFor := 1 To nUsado
	aCols[1,nCntFor] := CriaVar(aHeader[nCntFor,2],.T.)
	If ( AllTrim(aHeader[nCntFor,2]) $ "QMU_ITEM" )
		aCols[1,nCntFor] := "01"
	EndIf
Next nCntFor

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],000 to aSize[6],aSize[5] OF GetWndDefault() PIXEL 
oGetE:=MsMGet():New(cAlias, nReg, nOpc,,,,,aPosObj[1],,,,,,oDlg)
oGet := MSGetDados():New( aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpc, "qmt180Cicl", "Qmt180tOk", "+QMU_ITEM", .T.,,,.F.,999)   

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=1,If(Obrigatorio(aGets,aTela).And.Qmt180tOk(),oDlg:End(),nOpcA:=0)},{||nOpca:=0,oDlg:End()}) CENTERED

dbSelectArea(cAlias)
dbGoto(nReg)
If ( nOpca==1 )
	Begin Transaction
	For nCntFor := 1 To Len(aCols)
		If ( !aCols[nCntFor,nUsado+1] .And. !Empty(aCols[nCntFor,nPosCiClo]))
			dbSelectArea("QMU")
			RecLock("QMU",.T.)
			For nCntFor1 := 1 To FCount()
				FieldPut(nCntFor1,M->&(FieldName(nCntFor1)))
			Next nCntFor1
			For nCntFor1 := 1 To Len(aHeader)
				FieldPut(FieldPos(aHeader[nCntFor1,2]),aCols[nCntFor,nCntFor1])
			Next nCntFor1
			QMU->QMU_FILIAL := xFilial()
			QMU->QMU_FILRES := cFilAnt
		EndIf
	Next nCntFor
	EvalTrigger()
	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End
	End Transaction
EndIf
Return(nOpcA)

/*/
antigo a180Pc
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³q180Pc    ³ Autor ³ Eduardo Riera         ³ Data ³ 10.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ PictVar                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Picture                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function q180Pc(cCampo)

Return( QA_PICT(cCampo,M->&(cCampo)) )


/*/
antiga a180Ciclos
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³qmt180Cicl³ Autor ³ Eduardo Riera         ³ Data ³ 10.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao dos Valores de Referencia                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QMT180Cicl()

Local nValor := ReadVar()
Local lRetorno := .T.
Local nValor2:= 0
Local nValor3:= 0

If ( !Empty(nValor) )
	nValor := &nValor
Else
	nValor :=  aCols[n,aScan(aHeader,{|x| x[2]$"QMU_CICLOS" })]
EndIf

nValor2 := SuperVal(M->QMU_TOLER)
nValor3 := -1*(nValor2)
nValor2 += SuperVal(M->QMU_REFER)
nValor3 += SuperVal(M->QMU_REFER)

If ( ValType(nValor)=="C" )
	nValor := SuperVal(nValor)
EndIf
If (nValor+nValor2+nValor3==0.And.n==1.And.INCLUI)
	lRetorno := .T.
Else
	If ( nValor > nValor2 .Or.;
		nValor < nValor3 )
		Help(" ",1,"QA180CICLO")
		lRetorno := .F.
	EndIf
EndIf
Return(lRetorno)

/*/
antigo a180TudOk
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Qmt180tOk ³ Autor ³ Eduardo               ³ Data ³ 10.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da GetDados                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Qmt180tOk()

Local nCntFor 	:= 1
Local nCont		:= 0
Local nUsado   	:= Len(aHeader)+1
Local lRetorno 	:= .T.
Local lErrmas	:= (X3USO(POSICIONE("SX3",2,"QMU_ERRMAS","X3_USADO")))

For nCntFor := 1 To Len(aCols)
	If ( !aCols[nCntFor,nUsado] )
		nCont++
	EndIf
Next

If ( nCont < 2 .And. nCont != 0 .And. !Empty(M->QMU_REFER) )
	Help(" ",1,"QQmt180tOk")
	lRetorno := .F.
EndIf
If (M->QMU_TPMSA == "2") .AND. lRetorno 
	If (lErrmas .and. VAL(M->QMU_ERRMAS) < 1 ) .or. (!lErrmas .and. VAL(M->QMU_ERRMSA) < 1 )
		MsgAlert(OemToAnsi(STR0016)) //"O Erro Amostral maior ou igual a 1 e requerido para alguns tipos de Grafico e Calculos do MSA 3 Edicao"
	Endif
EndIf
Return(lRetorno)

/*/
antigo a180Altera
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Qmt180Alte³ Autor ³ Eduardo Riera         ³ Data ³ 10.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Alteracao do MSA                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhuma                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Qmt180Alte(cAlias,nReg,nOpc)

Local nOpca     := 0
Local nUsado    := 0
Local nCntFor   := 0
Local nCntFor1  := 0
Local nPosCiclo := 0
Local cChave    := ""
Local nPosItem  := 0
Local nSaveSX8	:= GetSX8Len()  

Local aPosObj   := {}  
Local aObjects  := {}   
Local aInfo     := {}      
Local aSize     := {}

Local aStruQMU := FWFormStruct(3, "QMU",,.F.)[3]
Local nX

Private aHeader := {}
Private aCols   := {}
Private aTela[0][0],aGets[0]
Private bCampo := { |nField| FieldName(nField) }
Private CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define tamanho da tela                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize(, .F., 400 )
AAdd( aObjects, { 100, 600, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. })

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis de Memoria da Enchoice                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QMU")
For nCntFor:= 1 To FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next nCntFor
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o aHeader                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aStruQMU)
	If ( AllTrim(aStruQMU[nX,1])$"QMU_CICLOS#QMU_ITEM" ) 
		aadd(aHeader, Q180GetSX3(aStruQMU[nX,1], "", "") )
		nUsado++
		If ( AllTrim(aStruQMU[nX,1])$"QMU_ITEM" )
			nPosItem := nUsado
		EndIf
		If ( AllTrim(aStruQMU[nX,1])$"QMU_CICLOS" )
			nPosCiclo := nUsado
		EndIf
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o aCols                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cChave := xFilial("QMU")+QMU->QMU_TIPO+QMU->QMU_INSTR+QMU->QMU_REVINS+Dtos(QMU->QMU_DATA)+QMU_REFER
cChave := xFilial("QMU")+QMU->QMU_INSTR+QMU->QMU_REVINS+Dtos(QMU->QMU_DATA)+QMU_REFER
dbSelectArea("QMU")
dbSetOrder(1)
dbSeek(cChave)
While ( !Eof() .And. cChave==;
	QMU->QMU_FILIAL+QMU->QMU_INSTR+QMU->QMU_REVINS+;
	Dtos(QMU->QMU_DATA)+QMU->QMU_REFER )
	aadd(aCols,Array(nUsado+1))
	aCols[Len(aCols),nUsado+1] := .F.
	For nCntFor := 1 To Len(aHeader)
		If ( aHeader[nCntFor,10] != "V" )
			aCols[Len(aCols),nCntFor] := FieldGet(FieldPos(aHeader[nCntFor,2]))
		Else
			aCols[Len(aCols),nCntFor] := CriaVar(aHeader[nCntFor,2])
		EndIf
	Next
	dbSkip()
EndDo
dbSelectArea(cAlias)
dbGoto(nReg)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],000 to aSize[6],aSize[5] OF GetWndDefault() PIXEL 
oGetE:=MsMGet():New(cAlias, nReg, nOpc,,,,,aPosObj[1],,,,,,oDlg)
oGet := MSGetDados():New(  aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpc, "qmt180Cicl", "Qmt180tOk", "+QMU_ITEM", .T.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=1,If(Obrigatorio(aGets,aTela).And.Qmt180tOk(),oDlg:End(),nOpcA:=0)},{||nOpca:=0,oDlg:End()}) CENTERED
If ( nOpca==1 )
	Begin Transaction
	For nCntFor := 1 To Len(aCols)
		If ( !aCols[nCntFor,nUsado+1] .And. !Empty(aCols[nCntFor,nPosCiClo]))
			dbSelectArea("QMU")
			dbSetOrder(1)
			If ( dbSeek(cChave+aCols[nCntFor,nPosItem]) )
				RecLock("QMU",.F.)
			Else
				RecLock("QMU",.T.)
			EndIf
			For nCntFor1 := 1 To FCount()
				FieldPut(nCntFor1,M->&(FieldName(nCntFor1)))
			Next nCntFor1
			For nCntFor1 := 1 To Len(aHeader)
				FieldPut(FieldPos(aHeader[nCntFor1,2]),aCols[nCntFor,nCntFor1])
			Next nCntFor1
			QMU->QMU_FILIAL := xFilial("QMU")
			QMU->QMU_FILRES := cFilAnt
		Else
			dbSelectArea("QMU")
			dbSetOrder(1)
			If ( dbSeek(cChave+aCols[nCntFor,nPosItem]) )
				RecLock("QMU",.F.)
				dbDelete()
			EndIf
		EndIf
	Next nCntFor
	EvalTrigger()
	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End
	End Transaction
EndIf
dbSelectArea(cAlias)
dbGoto(nReg)
Return(nOpcA)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Qmt180Visu³ Autor ³ Eduardo Riera         ³ Data ³ 10.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizacao do MSA                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhuma                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Qmt180Visu(cAlias,nReg,nOpc)

Local nOpca     := 0
Local nUsado    := 0
Local nCntFor   := 0
Local cChave    := ""
Local nPosItem  := 0    

Local aPosObj := {}  
Local aObjects:= {}   
Local aInfo   := {}      
Local aSize   := {}

Local aStruQMU := FWFormStruct(3, "QMU",,.F.)[3]
Local nX

Private aHeader := {}
Private aCols   := {}
Private aTela[0][0],aGets[0]
Private bCampo := { |nField| FieldName(nField) }
Private CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define tamanho da tela                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize(, .F., 400 )
AAdd( aObjects, { 100, 600, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. })

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis de Memoria da Enchoice                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QMU")
For nCntFor:= 1 To FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next nCntFor
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o aHeader                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aStruQMU)
	If ( AllTrim(aStruQMU[nX,1])$"QMU_CICLOS#QMU_ITEM" ) 
		aadd(aHeader, Q180GetSX3(aStruQMU[nX,1], "", "") )
		nUsado++
		If ( AllTrim(aStruQMU[nX,1])$"QMU_ITEM" )
			nPosItem := nUsado
		EndIf
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o aCols                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cChave := xFilial("QMU")+QMU->QMU_INSTR+QMU->QMU_REVINS+Dtos(QMU->QMU_DATA)+QMU_REFER
dbSelectArea("QMU")
dbSetOrder(1)
dbSeek(cChave)
While ( !Eof() .And. cChave==;
	QMU->QMU_FILIAL+QMU->QMU_INSTR+QMU->QMU_REVINS+;
	Dtos(QMU->QMU_DATA)+QMU->QMU_REFER )
	aadd(aCols,Array(nUsado))
	For nCntFor := 1 To Len(aHeader)
		If ( aHeader[nCntFor,10] != "V" )
			aCols[Len(aCols),nCntFor] := FieldGet(FieldPos(aHeader[nCntFor,2]))
		Else
			aCols[Len(aCols),nCntFor] := CriaVar(aHeader[nCntFor,2])
		EndIf
	Next
	dbSkip()
EndDo
dbSelectArea(cAlias)
dbGoto(nReg)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],000 to aSize[6],aSize[5] OF GetWndDefault() PIXEL 
oGetE:=MsMGet():New(cAlias, nReg, nOpc,,,,,aPosObj[1],,,,,,oDlg)
oGet := MSGetDados():New(  aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"qmt180Cicl","Qmt180tOk","+QMU_ITEM",.F.,,,.F.,999)   
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=1,oDlg:End()},{||nOpca:=0,oDlg:End()}) CENTERED
dbSelectArea(cAlias)
dbGoto(nReg)
Return(nOpcA)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Qmt180Excl³ Autor ³ Eduardo Riera         ³ Data ³ 10.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclusao do MSA                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhuma                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Qmt180Excl(cAlias,nReg,nOpc)

Local nOpcA     := 0
Local nUsado    := 0
Local nCntFor   := 0
Local cChave    := ""
Local nPosItem  := 0  

Local aPosObj := {}  
Local aObjects:= {}   
Local aInfo   := {}      
Local aSize   := {}

Local aStruQMU := FWFormStruct(3, "QMU",,.F.)[3]
Local nX

Private aHeader := {}
Private aCols   := {}
Private aTela[0][0],aGets[0]
Private bCampo := { |nField| FieldName(nField) }
Private CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define tamanho da tela                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize(, .F., 400 )
AAdd( aObjects, { 100, 600, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. })

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis de Memoria da Enchoice                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QMU")
For nCntFor:= 1 To FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next nCntFor
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o aHeader                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aStruQMU)
	If ( AllTrim(aStruQMU[nX,1])$"QMU_CICLOS#QMU_ITEM" ) 
		aadd(aHeader, Q180GetSX3(aStruQMU[nX,1], "", "") )
		nUsado++
		If ( AllTrim(aStruQMU[nX,1])$"QMU_ITEM" )
			nPosItem := nUsado
		EndIf
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o aCols                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cChave := xFilial("QMU")+QMU->QMU_INSTR+QMU->QMU_REVINS+Dtos(QMU->QMU_DATA)+QMU_REFER
dbSelectArea("QMU")
dbSetOrder(1)
dbSeek(cChave)
While ( !Eof() .And. cChave==;
	QMU->QMU_FILIAL+QMU->QMU_INSTR+QMU->QMU_REVINS+;
	Dtos(QMU->QMU_DATA)+QMU->QMU_REFER )
	aadd(aCols,Array(nUsado))
	For nCntFor := 1 To Len(aHeader)
		If ( aHeader[nCntFor,10] != "V" )
			aCols[Len(aCols),nCntFor] := FieldGet(FieldPos(aHeader[nCntFor,2]))
		Else
			aCols[Len(aCols),nCntFor] := CriaVar(aHeader[nCntFor,2])
		EndIf
	Next
	dbSkip()
EndDo
dbSelectArea(cAlias)
dbGoto(nReg)
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],000 to aSize[6],aSize[5] OF GetWndDefault() PIXEL 
oGetE:=MsMGet():New(cAlias, nReg, nOpc,,,,,aPosObj[1],,,,,,oDlg)
oGet := MSGetDados():New(  aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"qmt180Cicl","Qmt180tOk","+QMU_ITEM",.F.,,,.F.,999)   
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=2,oDlg:End()},{||nOpca:=0,oDlg:End()}) CENTERED
If ( nOpcA==2 )
	Begin Transaction
	dbSelectArea("QMU")
	dbSetOrder(1)
	dbSeek(cChave)
	While ( !Eof() .And. cChave==;
		QMU->QMU_FILIAL+QMU->QMU_INSTR+QMU->QMU_REVINS+;
		Dtos(QMU->QMU_DATA)+QMU->QMU_REFER )
		
		RecLock("QMU",.F.)
		dbDelete()
		dbSkip()
	EndDo
	End Transaction
EndIf
dbSelectArea(cAlias)
dbGoto(nReg)
Return(nOpcA)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Qmt180Impo³ Autora³ Iuri Seto             ³ Data ³ 23/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importação de Medições da Calibração                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 20/06/00 ³ Iuri Seto     ³Inclusao do tipo de calibracao Relogio.     ³±±
±±³          ³               ³(TIPAFE = "9")                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Qmt180Impo()                                 

Local cImportou
Local nItem := 0        
Local lMsgToler := .F.

cImportou := "1"	// Calibração não encontrada

If Pergunte("QMA180",.T.)
	               
	QMU->( dbSetOrder(1) )
	If QMU->(DbSeek(xFilial('QMU')+' '+mv_par01+mv_par02+DTOS(mv_par03)))
		Help(" ",1,"JAGRAVADO")
		Return(Nil)
	EndIf 

	dbSelectArea("QM6")
	QM6->( DbSetOrder(1) )

	dbSelectArea("QM7")
	QM7->( DbSetOrder(1) )

	If QM6->(DbSeek(xFilial("QM6")+mv_par01+mv_par02+DTOS(mv_par03))) .and.;
	   QM7->(DbSeek(xFilial("QM7")+mv_par01+mv_par02+DTOS(mv_par03)))		
		
		Begin Transaction 
	    
			While ! eof() .and. xFilial('QM7') == QM7->QM7_FILIAL .and.;
				QM7->QM7_INSTR == mv_par01 .and.; 
			    QM7->QM7_REVINS == mv_par02 .and.;
				DTOS(QM7->QM7_DATA) == DTOS(mv_par03)	
	            
				// Busca a tolerancia do processo //
				dbSelectArea("QMR")
				QMR->( DbSetOrder(1) )
				QMR->(DbSeek(xFilial('QMR')+mv_par01+mv_par02+QM7->QM7_ESCALA))

				// Busca o Tipo de Calibração //
				dbSelectArea("QM9")
				QM9->( DbSetOrder(1) )
				QM9->(DbSeek(xFilial('QM9')+QM7->QM7_ESCALA+Inverte(QM7->QM7_REVESC)))

				dbSelectArea("QM8")
				QM8->( DbSetOrder(1) )
				
				If QM8->(DbSeek(xFilial('QM8')+mv_par01+mv_par02+DTOS(mv_par03)+QM7->QM7_CSEQ+;
					QM7->QM7_ESCALA+QM7->QM7_REVESC+QM7->QM7_PONTO+QM7->QM7_REVPAD))		
					
					nItem := 1					
					
					While !Eof() .and. xFilial('QM8') == QM8->QM8_FILIAL .and.;
						QM8->QM8_INSTR == mv_par01 .and.; 
					   	QM8->QM8_REVINS == mv_par02 .and.;
					   	DTOS(QM8->QM8_DATA) == DTOS(mv_par03) .and.; 
					   	QM8->QM8_CSEQ == QM7->QM7_CSEQ .and.; 
					   	QM7->QM7_ESCALA == QM8->QM8_ESCALA .and.; 
					   	QM7->QM7_REVESC == QM8->QM8_REVESC .and.;
					   	QM7->QM7_PONTO == QM8->QM8_PADRAO .and.;
					   	QM7->QM7_REVPAD == QM8->QM8_REVPAD
 
						If (QM9->QM9_TIPAFE $ "12359")	
							// Se for tipo de afericao (1)Simples, (2)Completo, (3)Pressao , (5)Soma e (9)Relogio
							dbSelectArea("QM3")
							QM3->( DbSetOrder(1) )
							If QM3->(DbSeek(xFilial('QM3')+QM7->QM7_PONTO+Inverte(QM7->QM7_REVPAD))) .and.;
								QM3->QM3_TIPPAD = "A"
		  			  			cImportou := "4"	// Padrão do Tipo Atributo não é importado.
					  			Exit
						   	EndIf                    
						Endif

						If EMPTY(QM8->QM8_VLRFIM)
	  			  			cImportou := "5"	// Medição não encontrada.
						EndIf
						If Empty(QMR->QMR_TOLPRO)
				  			lMsgToler := .T.
						EndIf
						
						dbSelectArea("QMU")
						QMU->( DbSetOrder(1) )
						If !QMU->(DbSeek(xFilial('QMU')+mv_par01+mv_par02+;
							DTOS(mv_par03)+QM7->QM7_ESPEC+QM8->QM8_NUMMED))		

							RecLock("QMU",.T.)
							QMU->QMU_FILIAL := QM6->QM6_FILIAL		  					
							QMU->QMU_INSTR  := QM6->QM6_INSTR		  					
							QMU->QMU_REVINS := QM6->QM6_REVINS		  					
							QMU->QMU_DATA   := QM6->QM6_DATA		  					
							QMU->QMU_FILRES := cFilAnt
							QMU->QMU_RESP   := QM6->QM6_RESP		  					
							QMU->QMU_REFER  := QM7->QM7_ESPEC		  					
							QMU->QMU_TOLER  := QMR->QMR_TOLPRO		  					
							QMU->QMU_ITEM   := StrZero(nItem++,2)
							If (QM9->QM9_TIPAFE $ "3,9")		// Pressao ou Relogio
								QMU->QMU_CICLOS := QM8->QM8_VLRFID		  					
							Else								
								QMU->QMU_CICLOS := QM8->QM8_VLRFIM		  					
							EndIf								
							MsUnLock()

							cImportou := "2"	// Importação concluída
							
	  						dbSelectArea("QM8")
				  			QM8->(DbSkip()) 
	  			  		Else
	  			  			cImportou := "3"	// Medição já cadastrada
				  			Exit
		    	  		EndIf 
		    	  	EndDo     
		    	  	           
					dbSelectArea("QM7")
		    	  	QM7->(DbSkip())
		    	  	
		    	  	If cImportou == "3"		// Medição já cadastrada
		    	  		Exit
		    	  	EndIf
		    	  	
		    	EndIf 
	   		EndDo
		End Transaction			
   	EndIf 
   	            
   	Do Case
   	Case cImportou == "1"
		MsgInfo( STR0010, STR0009 ) // "Calibração não encontrada !!!" ### "Importação de Medições"
	Case cImportou == "2" 
		MsgInfo( STR0008, STR0009 ) // "Importação Concluída !!!" ### "Importação de Medições"  
		If lMsgToler
			MsgAlert( STR0014 ) //"Alguma medicoes foram importadas sem tolerancia, informe a Tolerancia. Atencao, o sistema so permite informar a tolerancia uma unica vez."
		EndIf
	Case cImportou == "3"
		MsgInfo( STR0011, STR0009 ) // "Medição já cadastrada !!!" ### "Importação de Medições"
	Case cImportou == "4"
		MsgInfo( STR0012, STR0009 ) // "Padrão do Tipo Atributo não é importado !!!" ### "Importação de Medições"
	Case cImportou == "5"
		MsgInfo( STR0013, STR0009 ) // "Medição não encontrada !!!" ### "Importação de Medições"
	EndCase
EndIf 

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Qmt180HTol³ Autora³ Cicero Cruz           ³ Data ³ 23/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Habilita o campo de Tolerancia na  alteracao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±4    
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Qmt180HTol()                                 
Local lRet := .F.
If INCLUI .OR. Empty(QMU->QMU_TOLER)
   lRet:=.T.
EndIf
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} Q180GetSX3 
Busca dados da SX3 
@author Brunno de Medeiros da Costa
@since 16/04/2018
@version 1.0
@return aHeaderTmp
/*/
//---------------------------------------------------------------------- 
Static Function Q180GetSX3(cCampo, cTitulo, cWhen)
Local aHeaderTmp := {}
aHeaderTmp:= {IIf(Empty(cTitulo), QAGetX3Tit(cCampo), cTitulo),;
				GetSx3Cache(cCampo,'X3_CAMPO'),;
				GetSx3Cache(cCampo,'X3_PICTURE'),;
				GetSx3Cache(cCampo,'X3_TAMANHO'),;
				GetSx3Cache(cCampo,'X3_DECIMAL'),;
				GetSx3Cache(cCampo,'X3_VALID'),;
				GetSx3Cache(cCampo,'X3_USADO'),;
				GetSx3Cache(cCampo,'X3_TIPO'),;
				GetSx3Cache(cCampo,'X3_F3'),;
				GetSx3Cache(cCampo,'X3_CONTEXT') } 
Return aHeaderTmp