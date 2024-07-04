#include "pmsc200.ch"
#include "protheus.ch"
#include "pmsicons.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSC200  ³ Autor ³ Edson Maricate        ³ Data ³ 16-04-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Planilhas de Consulta do Projeto                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±³          ³ Utiliza a funcao RenFld, definida no PMSC200                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC200()
	
If AMIIn(44) .And. !PMSBLKINT()

	
	PRIVATE cCadastro	:= STR0001 //"Planilha de Consulta do Projeto"
	Private aRotina := MenuDef()	
	PRIVATE aCores:= PmsAF8Color()
	PRIVATE cCmpPLN
	PRIVATE cArqPLN
	PRIVATE cPLNVer      := ''
	PRIVATE cPLNDescri   := ''
	PRIVATE lSenha       := .F.
	Private cPLNSenha    := ""
	Private nFreeze      := 0
	Private nIndent		 := PMS_SHEET_INDENT

	CrteFilIni()

	mBrowse(6,1,22,75,"AF8",,,,,,aCores)

	CrteFilEnd()
	
EndIf

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS200Leg³ Autor ³ Edson Maricate         ³ Data ³ 16-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Exibicao de Legendas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC200 , SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC200Leg(cAlias,nReg,nOpcx)
Local aLegenda:= {}
Local i       := 0

For i:= 1 To Len(aCores)
	Aadd(aLegenda,{aCores[i,2],aCores[i,3]})
Next i

aLegenda:= aSort(aLegenda,,,{|x,y| x[1] < y[1]})

BrwLegenda(cCadastro,STR0007,aLegenda) //"Legenda"

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMC200Dlg³ Autor ³ Edson Maricate         ³ Data ³ 16-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta a tela de exibicao do projeto selecionado.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC200 , SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMC200Dlg(cAlias,nReg,nOpcx)

Local oDlg

Local cArquivo	:= CriaTrab(,.F.)
Local aCampos	:= {}
Local aMenu		:= {}

PRIVATE cRevisa		:= AF8->AF8_REVISA

aMenu := {{TIP_PROJ_INFO,{|| PmsPrjInf()}, BMP_PROJ_INFO, TOOL_PROJ_INFO}}

aCampos := {{"AF9_TAREFA","AFC_EDT",8,,,.F.,"",},{"AF9_DESCRI","AFC_DESCRI",55,,,.F.,"",150}}
C200ChkPln(@aCampos)

PmsPlanAF8(cCadastro+"-"+cPLNDescri,cRevisa,aCampos,@cArquivo,,nFreeze,,aMenu,@oDlg,,.T.,,.T.,nIndent)


Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C200ChkPln³ Autor ³ Edson Maricate        ³ Data ³ 18.10.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica quais os campos que devem aparecer na planilha.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC200                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C200ChkPln(aCampos)
Local cCampos := cCmpPLN

While !Empty(AllTrim(cCampos))
	If AT("#",cCampos) > 0
		cAux := Substr(cCampos,1,AT("#",cCampos)-1)
		If Substr(cAux,2,1)$"$%|"
			aAdd(aCampos,{Substr(cAux,2,Len(cAux)-1),Substr(cAux,2,Len(cAux)-1),,,,.F.,"",})
		Else
			aAdd(aCampos,{"AF9"+cAux,"AFC"+cAux,,,,.F.,"",})
		EndIf
		cCampos := Substr(cCampos,AT("#",cCampos)+1,Len(cCampos)-AT("#",cCampos))
	Else
		cCampos := ''
	EndIf
End

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMC200Opn³ Autor ³ Edson Maricate         ³ Data ³ 16-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta uma tela de selecao de arquivos.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC200 , SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMC200Opn(cAlias,nReg,nOpcx)
Local oMenu
Local ni
Local aRet := {}
Local aDir := {}
Local cPath := GetNewPar("MV_PMSP200" ,Curdir())
Local aArea	:= GetArea()
Local lFWGetVersao := .T.

aDir := Directory(MountFile(cPath ,"*" ,PMS_SHEET_EXT))

MENU oMenu POPUP
MENUITEM STR0142 ACTION PMC200Opn1(cAlias,nReg,nOpcx) //"Procurar..."
For ni := 1 To Len(aDir)
	If FT_FUse(MountFile(cPath ,AllTrim(aDir[ni][1])))<> -1
		FT_FGOTOP()
		FT_FSKIP()
		If FT_FREADLN() == "101" 
			FT_FSKIP()
			MenuAddItem( AllTrim(FT_FREADLN()),AllTrim(FT_FREADLN()),.T.,.T. , ,,,oMenu, MontaBlock("{ || PMC200Opn1('"+cAlias+"',"+Str(nReg)+","+Str(nOpcx)+",'"+aDir[ni][1]+"') }" ), ,,.F., ,, .F. )
		ElseIf FT_FREADLN() == "102"
			FT_FSKIP()
			FT_FSKIP()
			MenuAddItem( AllTrim(Embaralha(FT_FREADLN(),0)),AllTrim(Embaralha(FT_FREADLN(),0)),.T.,.T. , ,,,oMenu, MontaBlock("{ || PMC200Opn1('"+cAlias+"',"+Str(nReg)+","+Str(nOpcx)+",'"+aDir[ni][1]+"') }" ), ,,.F., ,, .F. )
		EndIf
	EndIf
	FT_FUSE()
Next
ENDMENU

If !lFWGetVersao .or. GetVersao(.F.) == "P10"
	If SetMDIChild()
		oMenu:Activate(PMSResH(82),PMSResV(40),oMainWnd)
	Else
		oMenu:Activate(PMSResH(82),PMSResV(130),oMainWnd)
	EndIf
Else
	//Acoes relacionadas
	If SetMDIChild()
		oMenu:Activate( 775,23,oMainWnd)
	Else
		oMenu:Activate( 775,23,oMainWnd)
	EndIf
Endif	
	
RestArea(aArea)

Return 


Function PMC200Opn1(cAlias,nReg,nOpcx,cArq)
Local aRet	:= {}
Local aFile := {}
Local cFilePlan := ""
Local cPath := GetNewPar("MV_PMSP200" ,Curdir())
Local cPathRoot := ""

If !Empty(cPath)
	cPathRoot := "SERVIDOR"+iIf(left(cPath ,1) == "\" ,"" ,"\")+cPath
	If IsSrvUnix()
		cPathRoot := STRTRAN(cPathRoot ,"\" ,"/")
	Else
		cPathRoot := STRTRAN(cPathRoot ,"/" ,"\")
	EndIF
EndIf

DEFAULT cArq := ""

If (!Empty(cArq) .Or. ParamBox({{6,STR0010,SPACE(254),,"FILE(mv_par01)","", 55 ,.T.,STR0011,cPathRoot}},STR0012,@aRet) )//"Arquivo"###"Arquivo .PLN |*.PLN"###"Selecione o arquivo"
	If !Empty(cArq)
		aAdd(aRet,cArq)
	EndIf

	cFilePlan	:= MountFile( cPath ,AllTrim(aRet[1]) ,PMS_SHEET_EXT )	

	If ReadSheetFile(cFilePlan ,aFile)

		// {versao, campos, senha, descricao, freeze}
		cPLNVer    := aFile[1]
		cArqPLN    := cFilePlan
		cCmpPLN    := aFile[2]
		cPLNSenha  := aFile[3]
		cPLNDescri := aFile[4]
		nFreeze    := aFile[5]
		nIndent    := aFile[6]
		lSenha     := !Empty(aFile[3])
		
		If lSenha
			cCmpPLN    := Embaralha(cCmpPLN, 0)
			cPLNDescri := Embaralha(cPLNDescri, 0)
		EndIf
		
	Else
		Aviso(STR0013,STR0014,{STR0074},2) //"Falha na Abertura."###"Erro na abertura do arquivo. Verifique a existencia do arquivo selecionado." //'Ok'
	EndIf
EndIf

If AllTrim(cPLNVer) != "101" .And. AllTrim(cPLNVer) != "102"
	Aviso(STR0015,STR0016,{STR0074},2 ) //"Falha no Arquivo"###"Estrutura do arquivo incompativel. Verifique o arquivo selecionado." //'Ok'
	cCmpPLN	:= ''
Else
	PMC200Dlg(cAlias,nReg,nOpcx)
EndIf


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C200CfgCol ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Configuracao das colunas para exibicao da EDT/Tarefa na       ³±±
±±³          ³planilha.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array com os parametros MV_PMSPLN? (SX6)              ³±±
±±³          ³ExpA2 : Array com os campos padroes                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function C200CfgCol(aCamposExc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local nCnt1 := 0
Local nx := 0
Local nCampos1
Local nCampos2
Local nPos1      := 0
Local nPos2      := 0
Local cCampoAux
Local aCampos1   := {}
Local aCpsVar2   := {}
Local aBtn       := Array(6)
Local oCampos1
Local oCampos2
Local oBtn1
Local oBtn2
Local lCampos1   := .T.
Local lCampos2   := .F.
Local cPln1SX6   := cCmpPLN
Local aAuxVar := {}
Local nGetFreeze := nFreeze
Local nGetIndent := nIndent
Local lRet     := .F.
Local aFunc		 := { 	{STR0017,"$C200COTP"},; //"*COTP - Custo Orcado do Trabalho Previsto"
{STR0018,"$C200COTE"},; //"*COTE - Custo Orcado do Trabalho Executado"
{STR0019,"$C200CRTE"},; //"*CRTE - Custo Real do Trabalho Executado"
{STR0049,"$C200CP"},;  //"*Custo Total Previsto"
{STR0050,"$C200CR"},; //"*Custo Total Realizado"
{STR0075,"$C200SR"},;  //"*Saldo Realizado"
{STR0022,"$C200QR"},; //"*Quantidade Realizada"
{STR0023,"$C200PP"},; //"*%Fisico Previsto"
{STR0024,"$C200PR"},; //"*%Fisico Realizado"
{STR0051,"$C200UNIP"},;  //"*Custo Unitario Previsto"
{STR0052,"$C200UNIR"},;  //"*Custo Unitario Realizado"
{STR0053,"$C200VLPC"} ,; //"*Vlr. Prev. Pedido de Compras"
{STR0054,"$C200VLDSP"} ,; //"*Vlr. Prev. Titulos a Pagar"
{STR0055,"$C200VLPAG"},; //"*Vlr. Total Pagamentos"
{STR0056,"$C200VLPV"},; //"*Vlr. Prev. Pedido de Vendas"
{STR0057,"$C200VLDSC"},; //"*Vlr. Prev. Titulos a Receber"
{STR0058,"$C200VLREC"},; //"*Vlr. Total Receitas"
{STR0120,"$C200RTREC"},;  //"*Recursos Alocados"
{"*"+STR0137,"$C200RTREC2"},;  //"*Recursos Alocados (Nome)"
{STR0143,"$C200RTREL"} ,; //"*Relacionamentos" //"*Predecessoras"
{STR0144,"$C200RTSCS"} ,; //"*Sucessoras"
{STR0145,"$C200CEMPOP"} ,; //"*Custo Empenhado OP"
{STR0124,"$C200RTEVE"} ,;//"*Eventos"
{STR0128,"$C200DIMC"} ,; //"*Data Inicio Mais Cedo"
{STR0129,"$C200DIMT"} ,; //"*Data Inicio Mais Tarde"
{STR0130,"$C200DFMC"} ,; //"*Data Fim Mais Cedo"
{STR0131,"$C200DFMT"} ,; //"*Data Fim Mais Tarde"
{STR0132,"$C200CRITI"},; //"*Critica"
{STR0133,"$C200VLFAT"},; //"*Vlr.Faturado"
{STR0134,"$C200VLREM"} ,;//"*Vlr.Remessas"
{STR0135,"$C200SLREM"} ,;//"*Vlr.Remessas ( Pendente )"
{STR0159,"$C200DtEst"} ,;//"*Data Estimada de Termino
{STR0136,"$C200SLFAT"} }//"*Vlr.Faturado ( Pendente )"
Local lPMC200FUNC := ExistBlock( "PMC200FUNC" )
Local aFuncTemp   := {}

Local oSize

Private aCamposA   := {}
Private aCamposB   := {}
Private aCampos2   := {{STR0078,STR0122},{STR0046,STR0100}} //"Codigo"###"Descricao" //"COD"###"Descricao"

DEFAULT aCamposExc := {"FILIAL","PROJET","DESCRI","NIVEL","TAREFA","EDT","REVISA"}


If lPMC200FUNC 
	aFuncTemp := ExecBlock("PMC200FUNC",.F.,.F.)
	If ( ValType(aFuncTemp) == "A" ) .And. !Empty(aFuncTemp)
		aEval(aFuncTemp ,{|x|aAdd(aFunc,x)})
	EndIf
EndIf

nOrdSX3  := SX3->(IndexOrd())
nRegSX3  := SX3->(Recno())


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do array de campos selecionados                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While At("#",cPln1SX6) <> 0
	nPosSep := At("#",cPln1SX6)
	
	If Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),1,1)=="|"
		aAdd(aCpsVar2,{,,,,,,,})
		aCpsVar2[Len(aCpsVar2)][1] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),02,10)  // nome
		aCpsVar2[Len(aCpsVar2)][2] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),13,25)  // titulo
		aCpsVar2[Len(aCpsVar2)][4] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),70,01)  // tipo
		aCpsVar2[Len(aCpsVar2)][5] := Val(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),72,02))  // tamanhho
		aCpsVar2[Len(aCpsVar2)][6] := Val(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),75,01))  // decimal
		aCpsVar2[Len(aCpsVar2)][7] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),77,60)	 // picture

		Do Case
			Case aCpsVar2[Len(aCpsVar2)][4]=="C"
				aCpsVar2[Len(aCpsVar2)][3] := Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30)
			Case aCpsVar2[Len(aCpsVar2)][4]=="N"
				aCpsVar2[Len(aCpsVar2)][3] := Val(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30))
			Case aCpsVar2[Len(aCpsVar2)][4]=="D"
				aCpsVar2[Len(aCpsVar2)][3] := CTOD(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30))
		EndCase		

		aCpsVar2[Len(aCpsVar2)][8] := "_|"+PadR(aCpsVar2[Len(aCpsVar2)][1], 10, " ")+;                // nome
														"|"+PadR(aCpsVar2[Len(aCpsVar2)][2], 25, " ")+;                 // titulo
														"|"+PadR(Substr(AllTrim(Substr(cPln1Sx6, 2, nPosSep-2)),39,30), 30, " ")+;  // valor  - direto do arquivo
														"|"+PadR(aCpsVar2[Len(aCpsVar2)][4], 1, " ")+;                   // tipo
														"|"+StrZero(aCpsVar2[Len(aCpsVar2)][5],2,0)+;                 // tamanho
														"|"+StrZero(aCpsVar2[Len(aCpsVar2)][6],1,0)+;                 // decimal
														"|"+PadR(aCpsVar2[Len(aCpsVar2)][7], 60, " ")
	Else
		aAdd(aCampos2,{,})
		aCampos2[Len(aCampos2)][2] := AllTrim(Substr(cPln1Sx6, 2, nPosSep-2))
		
		dbSelectArea("SX3")
		dbSetOrder(2)
		If dbSeek("AF9_"+aCampos2[Len(aCampos2)][2])
			//aCampos2[Len(aCampos2)][1] := AllTrim(SX3->X3_DESCRIC)
			aCampos2[Len(aCampos2)][1] := AllTrim(X3Descric())
		ElseIf dbSeek("AFC_"+aCampos2[Len(aCampos2)][2])
			//aCampos2[Len(aCampos2)][1] := AllTrim(SX3->X3_DESCRIC)
			aCampos2[Len(aCampos2)][1] := AllTrim(X3Descric())
		ElseIf Substr(aCampos2[Len(aCampos2)][2],1,1)=="%"
			aCampos2[Len(aCampos2)][1] := "="+Substr(aCampos2[Len(aCampos2)][2],2,12)
		Else
			nPosFunc := aScan(aFunc,{|x| AllTrim(x[2])==AllTrim(aCampos2[Len(aCampos2)][2])})
			If nPosFunc > 0
				aCampos2[Len(aCampos2)]	[1] := aFunc[nPosFunc][1]
			EndIf
		Endif
	Endif
	cPln1Sx6 := Substr(cPln1SX6,nPosSep+1,Len(cPln1SX6)-nPosSep)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do array de campos disponiveis                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
If (dbSeek("AF9"))
	While SX3->X3_ARQUIVO == "AF9"
		If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_CONTEXT <> "V"
			cCampoAux := AllTrim(Substr(SX3->X3_CAMPO,5,6))
			If Len(aCampos1) <> 0
				If  (nPosCampo := AScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := AScan(aCamposExc,cCampoAux)) == 0
					//aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
					aAdd(aCampos1,{X3Descric(),cCampoAux})
				Endif
			Else
				If  (nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := AScan(aCamposExc,cCampoAux)) == 0
					//aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
					aAdd(aCampos1,{X3Descric(),cCampoAux})
				Endif
			Endif
		Endif
		dbSkip()
	End
Endif

If (dbSeek("AFC"))
	While SX3->X3_ARQUIVO == "AFC"
		If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. X3_CONTEXT <> "V"
			cCampoAux := AllTrim(Substr(SX3->X3_CAMPO,5,6))
			If Len(aCampos1) <> 0
				If  (nPosCampo := AScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := AScan(aCamposExc,cCampoAux)) == 0
					//aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
					aAdd(aCampos1,{X3Descric(),cCampoAux})
				Endif
			Else
				If  (nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(cCampoAux)})) == 0 .And.;
					(nPosCampo := AScan(aCamposExc,cCampoAux)) == 0
					//aAdd(aCampos1,{SX3->X3_DESCRIC,cCampoAux})
					aAdd(aCampos1,{X3Descric(),cCampoAux})
				Endif
			Endif
		Endif
		dbSkip()
	End
Endif
For nx := 1 to Len(aFunc)
	If Len(aCampos1) <> 0
		If  (nPosCampo := AScan(aCampos1,{|x| AllTrim(x[2]) == AllTrim(aFunc[nx][2])})) == 0 .And.;
			(nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(aFunc[nx][2])})) == 0 .And.;
			(nPosCampo := AScan(aCamposExc,aFunc[nx][2])) == 0
			aAdd(aCampos1,{aFunc[nx][1],aFunc[nx][2]})
		Endif
	Else
		If  (nPosCampo := AScan(aCampos2,{|x| AllTrim(x[2]) == AllTrim(aFunc[nx][2])})) == 0 .And.;
			(nPosCampo := AScan(aCamposExc,aFunc[nx][2])) == 0
			aAdd(aCampos1,{aFunc[nx][1],aFunc[nx][2]})
		Endif
	Endif
Next
aSort(aCampos1,,, {|x,y| x[1] < y[1]})
aCampos3 := aClone(aCampos1)
aCampos4 := aClone(aCampos2)
aCamposA  := {}
aCamposB  := {}
For nCnt1 := 1 to Len(aCampos1)
	aAdd(aCamposA,aCampos1[nCnt1][1])
Next

RenFld(@aCamposB, aCampos2)

DEFINE MSDIALOG oDlg FROM 000,000 TO 600,600 TITLE STR0027 OF oMainWnd PIXEL 

//Faz o calculo automatico de dimensoes de objetos
oSize := FwDefSize():New(.T.,,,oDlg)

oSize:lLateral := .F.
oSize:lProp	:= .T. // Proporcional

oSize:AddObject( "1STROW" ,  100, 045, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "2NDROW" ,  100, 040, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "3RDROW" ,  100, 015, .T., .T. ) // Totalmente dimensionavel
	
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos		


a1stRow :=	{oSize:GetDimension("1STROW","LININI"),;
			oSize:GetDimension("1STROW","COLINI"),;
			oSize:GetDimension("1STROW","LINEND"),;
			oSize:GetDimension("1STROW","COLEND")}

a2ndRow :=	{oSize:GetDimension("2NDROW","LININI"),;
			oSize:GetDimension("2NDROW","COLINI"),;
			oSize:GetDimension("2NDROW","XSIZE"),;
			oSize:GetDimension("2NDROW","YSIZE")}

a3rdRow :=	{oSize:GetDimension("3RDROW","LININI"),;
			oSize:GetDimension("3RDROW","COLINI"),;
			oSize:GetDimension("3RDROW","LINEND"),;
			oSize:GetDimension("3RDROW","COLEND")}

@ a2ndRow[1] + 002,a2ndRow[2] + 002 SAY STR0091 OF oDlg PIXEL  //"Variaveis globais"
@ a2ndRow[1] + 012,a2ndRow[2] + 002 LISTBOX oCpoSel FIELDS HEADER STR0092, STR0093, STR0094 MESSAGE STR0095 ON DBLCLICK PMSEdtValPln(@aCpsVar2, oCpoSel) SIZE a2ndRow[3] - 005,a2ndRow[4] OF oDlg PIXEL

aAuxVar := aClone(aCpsVar2)

If Len(aAuxVar) < 1
	aAdd(aAuxVar, {"","","","","","","",""})
EndIf

oCpoSel:SetArray(aAuxVar)
oCpoSel:bLine:={||{aAuxVar[oCpoSel:nAt,1], aAuxVar[oCpoSel:nAt,2], Transform(aAuxVar[oCpoSel:nAt,3], aAuxVar[oCpoSel:nAt,7])}}
oCpoSel:Refresh()

@ a1stRow[1] + 000,a1stRow[2] + 005 SAY STR0028 OF oDlg PIXEL  //"Campos Disponiveis"
@ a1stRow[1] + 000,a1stRow[2] + 143 SAY STR0029 OF oDlg PIXEL  //"Campos Selecionados"
@ a1stRow[1] + 010,a1stRow[2] + 240 SAY STR0030 OF oDlg PIXEL  //"Mover"
@ a1stRow[1] + 015,a1stRow[2] + 238 SAY STR0031 OF oDlg PIXEL  //"Campos"

@ a1stRow[1] + 008,a1stRow[2] + 005  LISTBOX oCampos1 VAR nCampos1 ITEMS aCamposA SIZE 90,110 ON DBLCLICK;
AddFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB) OF oDlg PIXEL
oCampos1:SetArray(aCamposA)
oCampos1:bGotFocus  := {|| lCampos1 := .T.,lCampos2 := .F.}

@ a1stRow[1] + 008,a1stRow[2] + 143 LISTBOX oCampos2 VAR nCampos2 ITEMS aCamposB SIZE 90,110 ON DBLCLICK;
DelFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB) OF oDlg PIXEL
oCampos2:SetArray(aCamposB)
oCampos2:bGotFocus  := {|| lCampos1 := .F., lCampos2 := .T.}
oCampos2:Cargo := {{},aCampos2,"9Z"}

@ a1stRow[1] + 008,a1stRow[2] + 098  BUTTON aBtn[1] PROMPT STR0032 SIZE 42,11 OF oDlg PIXEL; //" Add.Todos >>"
ACTION AddAllFld(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB)

@ a1stRow[1] + 020,a1stRow[2] + 098  BUTTON aBtn[2] PROMPT STR0033 SIZE 42,11 OF oDlg PIXEL;  //"&Adicionar >>"
ACTION AddFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB) WHEN lCampos1

@ a1stRow[1] + 032,a1stRow[2] + 098  BUTTON aBtn[3] PROMPT STR0034 SIZE 42,11 OF oDlg PIXEL; //"<< &Remover "
ACTION DelFields(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB) WHEN lCampos2

@ a1stRow[1] + 044,a1stRow[2] + 098  BUTTON aBtn[4] PROMPT STR0035  SIZE 42,11 OF oDlg PIXEL;  //"<< Rem.Todos"
ACTION DelAllFld(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB)

@ a1stRow[1] + 056,a1stRow[2] + 098  BUTTON aBtn[6] PROMPT STR0079  SIZE 42,11 OF oDlg PIXEL;  //"Formula >>"
ACTION AddFormula(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB)

@ a1stRow[1] + 068,a1stRow[2] + 098  BUTTON aBtn[6] PROMPT STR0080  SIZE 42,11 OF oDlg PIXEL;  //"Editar"
ACTION EdtFormula(@aCampos1,oCampos1,@aCampos2,oCampos2,@aCamposA,@aCamposB)

@ a1stRow[1] + 080,a1stRow[2] + 098 BUTTON aBtn[5] PROMPT STR0036  SIZE 42,11 OF oDlg PIXEL;  //"  Restaurar "
ACTION RestFields(@aCampos1,oCampos1,@aCampos2,oCampos2,aCampos3,aCampos4,@aCamposA,@aCamposB)

@ a1stRow[1] + 090,a1stRow[2] + 480 BTNBMP oBtn1 RESOURCE BMP_SETA_UP   SIZE 25,25 ACTION MoveCell(oCampos2,-1); //UpField(@aCampos2,oCampos2,@aCamposB,nPos2);
MESSAGE STR0037 WHEN .T.	//"Mover campo para cima"

@ a1stRow [1] + 120,a1stRow[2] + 480 BTNBMP oBtn2 RESOURCE BMP_SETA_DOWN SIZE 25,25 ACTION MoveCell(oCampos2,1); //DwField(@aCampos2,oCampos2,@aCamposB,nPos2);
MESSAGE STR0038 WHEN .T.	//"Mover campo para baixo"

@ a3rdRow[1] + 143,a3rdRow[2] + 005 CHECKBOX oUsado VAR lSenha PROMPT STR0108 SIZE 86, 10 ON CHANGE ProtArq() OF oDlg PIXEL //"Proteger arquivo com senha"

// desabilitado - o remote ainda nao implementar o freeze
//@ 143, 145 SAY STR0139 Of oDlg PIXEL Size 60, 60 //"Congelar colunas:"
//@ 142, 195 MSGET nGetFreeze Picture "@E 999" Valid Empty(nGetFreeze) .Or. (nGetFreeze > 0 .And. nGetFreeze < 999) Of oDlg Pixel Size 20, 08
     
@ a3rdRow[1] + 010,a3rdRow[2] + 005 SAY STR0140 OF oDlg PIXEL Size 60, 60 //"Indentacao"
@ a3rdRow[1] + 010,a3rdRow[2] + 070 MSGET nGetIndent Picture "@E 99" Valid Empty(nGetIndent) .Or. (nGetIndent >= 0 .And. nGetIndent < 100) OF oDlg Pixel Size 20, 08

@ a3rdRow[1] + 025,a3rdRow[2] + 005 BUTTON STR0096 SIZE 42, 11 PIXEL ACTION AddVarPln(@aCpsVar2, @oCpoSel)
@ a3rdRow[1] + 025,a3rdRow[2] + 060 BUTTON STR0097 SIZE 42, 11 PIXEL ACTION DelVarPln(@aCpsVar2, @oCpoSel)
@ a3rdRow[1] + 025,a3rdRow[2] + 115 BUTTON STR0098 SIZE 42, 11 PIXEL ACTION EdtVarPln(@aCpsVar2, @oCpoSel)

ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lRet := .T., nFreeze := nGetFreeze, nIndent := nGetIndent, SalvarPln(aCampos2, aCpsVar2, cArqPln)},{|| oDlg:End()}) CENTERED

dbSelectArea("SX3")
dbSetOrder(nOrdSX3)
dbGoTo(nRegSX3)

Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AddFields  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move campo disponivel para array de campos selecionados       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AddFields(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0
Local nPos1 := oCampos1:nAt
Local nPos2 := oCampos2:nAt

If nPos1 <> 0 .And. Len(aCampos1) <> 0
	aAdd(aCampos2,{aCampos1[nPos1][1],aCampos1[nPos1][2]})
	aDel(aCampos1,nPos1)
	aSize(aCampos1,Len(aCampos1)-1)
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposA  := {}
	aCamposB  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1][1])
	Next
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos1:SetArray(aCamposA)
	If Len(aCamposA) > 0
		oCampos1:nAt := 1
	EndIf
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:Cargo[2] := aCampos2
	oCampos2:Refresh()
	oCampos1:SetFocus()
Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AddFormula ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Adiciona um campo de formula nos campos selecionados          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AddFormula(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0
Local aRet	:= {}

If ParamBox({	{1,STR0081,SPACE(12),"","","","", 85 ,.T.},;  //"Titulo"
	{3,STR0082,2,{STR0083,STR0084,STR0085},60,,.F.},; //"Tipo"###"Caracter"###"Numerico"###"Data"
	{1,STR0086,12,"","","","", 30 ,.T.},;  //"Tamanho"
	{1,STR0087,0,"","","","", 15 ,.F.},; //"Decimal"
	{1,STR0088,SPACE(35),"","","","", 85 ,.F.},; //"Picture"
	{1,STR0089,SPACE(60),"","","","", 85 ,.T.} },STR0090,@aRet) //"Formula"###"Configuracoes"
	
	Do Case
		Case aRet[2]==1
			cTipo := "C"
		Case aRet[2]==2
			cTipo := "N"
		Case aRet[2]==3
			cTipo := "D"
	EndCase
	aAdd(aCampos2,{aRet[1],"%"+aRet[1]+"%"+cTipo+"%"+StrZero(aRet[3],2,0)+"%"+StrZero(aRet[4],1,0)+"%"+aRet[5]+"%"+aRet[6]})
	aCamposA  := {}
	aCamposB  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1][1])
	Next
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos1:SetArray(aCamposA)
	If Len(aCamposA) > 0
		oCampos1:nAt := 1
	EndIf
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:Refresh()
	oCampos1:SetFocus()
	
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EdtFormula ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Edita a formula .                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function EdtFormula(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nPos2 := oCampos2:nAt

Local nCnt1 := 0
Local aRet	:= {}

If nPos2 > 0 .And. Len(aCampos2) > 0
	If Substr(aCampos2[nPos2][2],1,1)=="%"
		//%123456789012%C%99%2%12345678901234567890123456789012345%123456789012345678901234567890123456789012345678901234567890¨
		Do case
			Case Substr(aCampos2[nPos2][2],15,1)=="C"
				nTipo := 1
			Case Substr(aCampos2[nPos2][2],15,1)=="N"
				nTipo := 2
			Case Substr(aCampos2[nPos2][2],15,1)=="D"
				nTipo := 3
		EndCase
		If ParamBox({	{1,STR0081,Substr(aCampos2[nPos2][2],2,12),"","","","", 85 ,.T.},;  //"Titulo"
			{3,STR0082,nTipo,{STR0083,STR0084,STR0085},60,,.F.},; //"Tipo"###"Caracter"###"Numerico"###"Data"
			{1,STR0086,Val(Substr(aCampos2[nPos2][2],17,2)),"","","","", 30 ,.T.},;  //"Tamanho"
			{1,STR0087,Val(Substr(aCampos2[nPos2][2],20,1)),"","","","", 15 ,.F.},; //"Decimal"
			{1,STR0088,Substr(aCampos2[nPos2][2],22,35),"","","","", 85 ,.F.},; //"Picture"
			{1,STR0089,Substr(aCampos2[nPos2][2],58,60)+SPACE(60-LEN(Substr(aCampos2[nPos2][2],58,60))),"","","","", 85 ,.T.} },STR0090,@aRet) //"Formula"###"Configuracoes"
			
			Do Case
				Case aRet[2]==1
					cTipo := "C"
				Case aRet[2]==2
					cTipo := "N"
				Case aRet[2]==3
					cTipo := "D"
			EndCase
			aCampos2[nPos2] := {aRet[1],"%"+aRet[1]+"%"+cTipo+"%"+StrZero(aRet[3],2,0)+"%"+StrZero(aRet[4],1,0)+"%"+aRet[5]+"%"+aRet[6]}
			aCamposA  := {}
			aCamposB  := {}
			For nCnt1 := 1 to Len(aCampos1)
				aAdd(aCamposA,aCampos1[nCnt1][1])
			Next
			
			RenFld(@aCamposB, aCampos2)
			
			oCampos1:SetArray(aCamposA)
			If Len(aCamposA) > 0
				oCampos1:nAt := 1
			EndIf
			oCampos1:Refresh()
			oCampos2:SetArray(aCamposB)
			oCampos2:Refresh()
			oCampos1:SetFocus()
			
		EndIf
	EndIf
Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DelFields  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move campo selecionados para array de campos disponiveis      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DelFields(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0

Local nPos1 := oCampos1:nAt
Local nPos2 := oCampos2:nAt

If nPos2 <> 0 .And. Len(aCampos2) <> 0 .ANd. nPos2 > 2
	If Substr(aCampos2[nPos2][2],1,1) != "%"
		aAdd(aCampos1,{aCampos2[nPos2][1],aCampos2[nPos2][2]})
		aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	EndIf
	aDel(aCampos2,nPos2)
	aSize(aCampos2,Len(aCampos2)-1)
	aCamposA  := {}
	aCamposB  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1][1])
	Next
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos1:SetArray(aCamposA)
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:Cargo[2] := aCampos2
	oCampos2:nAt := 1
	oCampos2:Refresh()
	oCampos2:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AddAllFld  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move todos os campos do array de campos disponiveis para      ³±±
±±³          ³array de campos selecionados.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AddAllFld(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0

If Len(aCampos1) <> 0
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCampos2,{aCampos1[nCnt1][1],aCampos1[nCnt1][2]})
	Next
	aCampos1 := {}
	aCamposA := {}
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposB  := {}
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos1:SetArray(aCamposA)
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt := 1
	oCampos2:Refresh()
	oCampos2:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DelAllFld  ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move todos os campos do array de campos selecionados para     ³±±
±±³          ³array de campos disponiveis.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DelAllFld(aCampos1,oCampos1,aCampos2,oCampos2,aCamposA,aCamposB)
Local nCnt1 := 0

If Len(aCampos2) <> 0
	For nCnt1 := 3 to Len(aCampos2)
		If Substr(aCampos2[nCnt1][2], 1, 1) # "%"
			aAdd(aCampos1,{aCampos2[nCnt1][1],aCampos2[nCnt1][2]})
		Endif
	Next
	aCampos2   := {{STR0078,STR0122},{STR0046,STR0100}} //"Codigo"###"Descricao" //"COD"###"Descricao"
	aCamposB := {}
	aSort(aCampos1,,, {|x,y| x[1] < y[1]})
	aCamposA  := {}
	For nCnt1 := 1 to Len(aCampos1)
		aAdd(aCamposA,aCampos1[nCnt1][1])
	Next
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos1:SetArray(aCamposA)
	If Len(aCamposA) > 0
		oCampos1:nAt   := 1
	EndIf
	oCampos1:Refresh()
	oCampos2:SetArray(aCamposB)
	
	oCampos2:Cargo[2] := aCampos2
	oCampos2:Refresh()
	oCampos1:SetFocus()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³UpField    ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move o campo para uma posicao acima dentro do array           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function UpField(aCampos2,oCampos2,aCamposB,nPos2)
Local cCampoAux
      
DEFAULT nPos2 := oCampos2:nAt

If nPos2 <> 1 .And. nPos2 <> 0 .And. nPos2 > 3
	cCampoAux := aCampos2[nPos2-1][1]
	aCampos2[nPos2-1][1] := aCampos2[nPos2][1]
	aCampos2[nPos2][1] := cCampoAux
	cCampoAux := aCampos2[nPos2-1][2]
	aCampos2[nPos2-1][2] := aCampos2[nPos2][2]
	aCampos2[nPos2][2] := cCampoAux
	aCamposB  := {}
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt:=nPos2-1
	oCampos2:Refresh()
Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³UpField    ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Move o campo para uma posicao abaixo dentro do array          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DwField(aCampos2,oCampos2,aCamposB,nPos2)
Local cCampoAux

DEFAULT nPos2 := oCampos2:nAt

If nPos2 < Len(aCampos2) .And. nPos2 <> 0 .And. nPos2 > 2
	cCampoAux := aCampos2[nPos2+1][1]
	aCampos2[nPos2+1][1] := aCampos2[nPos2][1]
	aCampos2[nPos2][1] := cCampoAux
	cCampoAux := aCampos2[nPos2+1][2]
	aCampos2[nPos2+1][2] := aCampos2[nPos2][2]
	aCampos2[nPos2][2] := cCampoAux
	aCamposB  := {}
	
	RenFld(@aCamposB, aCampos2)
	
	oCampos2:SetArray(aCamposB)
	oCampos2:nAt:=nPos2+1
	oCampos2:Refresh()
Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RestFields ³ Autor ³ Cristiano G. Cunha   ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Restaura arrays originais                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RestFields(aCampos1,oCampos1,aCampos2,oCampos2,aCampos3,aCampos4,aCamposA,aCamposB)
Local nCnt1 := 0

aCampos1  := aClone(aCampos3)
aCampos2  := aClone(aCampos4)
aSort(aCampos1,,, {|x,y| x[1] < y[1]})
aCamposA  := {}
aCamposB  := {}
For nCnt1 := 1 to Len(aCampos1)
	aAdd(aCamposA,aCampos1[nCnt1][1])
Next

RenFld(@aCamposB, aCampos2)

oCampos1:SetArray(aCamposA)
oCampos2:SetArray(aCamposB)
If Len(aCampos1) > 0
	oCampos1:nAt := 1
	oCampos1:Refresh()
	oCampos1:SetFocus()
Else
	If Len(aCampos2) > 0
		oCampos2:nAt := 1
		oCampos2:Refresh()
		oCampos2:SetFocus()
	Else
		oCampos1:Refresh()
		oCampos2:Refresh()
	Endif
EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200COTP  ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o Custo Orcado do Trabalho Previsto na Data Base      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200COTP(nRet,cAlias,nRecNo,aCampos)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200COTP","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0065,"C200COTP","@E 999,999,999,999.99",15,"N"} //"Vlr. COTP"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor do COTP                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetCOTP(aHandCOTP,1,AF9->AF9_TAREFA,.T.)[1]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetCOTP(aHandCOTP,2,AFC->AFC_EDT,.T.)[1]
	EndIf
	Return nRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 4 // Inicializa os valores da planilha          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==4
	If aScan(aCampos,{|x| AllTrim(x[1])=="$C200COTP"})>0
		aHandCOTP	:= PmsIniCOTP(AF8->AF8_PROJET,cRevisa,dDataBase)
	EndIf
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200COTP  ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o Custo Orcado do Trabalho Executado na Data Base     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200COTE(nRet,cAlias,nRecNo,aCampos)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200COTE","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0076,"C200COTE","@E 999,999,999,999.99",15,"N"} //"Vlr. COTE"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor do COTP                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetCOTE(aHandCOTE,1,AF9->AF9_TAREFA,.T.)[1]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetCOTE(aHandCOTE,2,AFC->AFC_EDT,.T.)[1]
	EndIf
	Return nRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 4 // Inicializa os valores da planilha          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==4
	If aScan(aCampos,{|x| AllTrim(x[1])=="$C200COTE"})>0
		aHandCOTE	:= PmsIniCOTE(AF8->AF8_PROJET,cRevisa,dDataBase)
	EndIf
EndIf


Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200CRTE  ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o Custo Real do Trabalho Executado na Data Base       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200CRTE(nRet,cAlias,nRecNo,aCampos)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200CRTE","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0066,"C200CRTE","@E 999,999,999,999.99",15,"N"} //"Vlr. CRTE"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor do COTP                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetCRTE(aHandCRTE,1,AF9->AF9_TAREFA)[1]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetCRTE(aHandCRTE,2,AFC->AFC_EDT)[1]
	EndIf
	Return nRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 4 // Inicializa os valores da planilha          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==4
	If aScan(aCampos,{|x| AllTrim(x[1])=="$C200CRTE"})>0
		aHandCRTE	:= PmsIniCRTE(AF8->AF8_PROJET,AF8->AF8_REVISA,dDataBase)
	EndIf
EndIf


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200CP    ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o Custo Total Previsto do Projeto                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200CP(nRet,cAlias,nRecNo,aCampos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200CP","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0067,"C200CP","@E 999,999,999,999.99",15,"N"}  //"Custo Previsto"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor do COTP                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetCOTP(aHandCP,1,AF9->AF9_TAREFA,.T.)[1]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetCOTP(aHandCP,2,AFC->AFC_EDT,.T.)[1]
	EndIf
	Return nRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 4 // Inicializa os valores da planilha          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==4
	If aScan(aCampos,{|x| AllTrim(x[1])$"$C200CP".Or.AllTrim(x[1])$"$C200UNIP".Or.AllTrim(x[1])$"$C200SR" })>0
		aHandCP	:= PmsIniCOTP(AF8->AF8_PROJET,cRevisa,PMS_MAX_DATE)
	EndIf
EndIf


Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200CR    ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o Custo Total Realizado do Projeto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200CR(nRet,cAlias,nRecNo,aCampos)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200CR","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0068,"C200CR","@E 999,999,999,999.99",15,"N"}  //"Custo Realizado"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor do COTP                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetCRTE(aHandCR,1,AF9->AF9_TAREFA)[1]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetCRTE(aHandCR,2,AFC->AFC_EDT)[1]
	EndIf
	Return nRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 4 // Inicializa os valores da planilha          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==4
	If aScan(aCampos,{|x| AllTrim(x[1])$"$C200CR".Or.AllTrim(x[1])$"$C200UNIR".Or.AllTrim(x[1])$"$C200SR"})>0
		aHandCR	:= PmsIniCRTE(AF8->AF8_PROJET,AF8->AF8_REVISA,PMS_MAX_DATE)
	EndIf
EndIf


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200SR    ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o Saldo Realizado do projeto                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200SR(nRet,cAlias,nRecNo,aCampos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200SR","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0077,"C200SR","@E 999,999,999,999.99",15,"N"}   //"Saldo Realizado"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor do Saldo Realizado         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetCOTP(aHandCP,1,AF9->AF9_TAREFA,.T.)[1]-PmsRetCRTE(aHandCR,1,AF9->AF9_TAREFA)[1]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetCOTP(aHandCP,2,AFC->AFC_EDT,.T.)[1]-PmsRetCRTE(aHandCR,2,AFC->AFC_EDT)[1]
	EndIf
	Return nRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 4 // Inicializa os valores da planilha          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==4

EndIf


Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200DIMC  ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a data inicio mais cedo da tarefa / EDT               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200DIMC(nRet,cAlias,nRecNo,aCampos)
Local cRet
Local nPosTsk


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200DIMC","C",16,0}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0146,"C200DIMC","",16,"C"}  //"Custo Realizado" //"Inicio Mais Cedo"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor do COTP                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		cRet := "  /  /     :  "
		nPosTsk := aScan(aHTaskCPM,{|x| x[1] == AF9->AF9_TAREFA })
		If nPosTsk > 0
			cRet := DTOC(aHTaskCPM[nPosTsk][11][1])+" "+aHTaskCPM[nPosTsk][11][2]
		EndIf
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		cRet := "  /  /     :  "
		nPosTsk := aScan(aHEDTCPM,{|x| x[1] == AFC->AFC_EDT })
		If nPosTsk > 0
			cRet := DTOC(aHEDTCPM[nPosTsk][2][1])+" "+aHEDTCPM[nPosTsk][2][2]
		EndIf
	EndIf
	Return cRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 4 // Inicializa os valores da planilha          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==4
	If aScan(aCampos,{|x| AllTrim(x[1])=="$C200DIMC" .Or. AllTrim(x[1])=="$C200DIMT" .Or.AllTrim(x[1])=="$C200DFMC".Or.AllTrim(x[1])=="$C200DFMT" .Or.AllTrim(x[1])=="$C200CRITI"})>0
		aRet := PmsCalcCPM(AF8->AF8_PROJET,cRevisa)
		aHTaskCPM := aRet[1]
		aHEDTCPM := aRet[2]
	EndIf
EndIf


Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200DIMT  ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a data inicio mais tarde da tarefa / EDT              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200DIMT(nRet,cAlias,nRecNo,aCampos)
Local cRet
Local nPosTsk

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200DIMT","C",16,0}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0147,"C200DIMT","",16,"C"}   //"Inicio Mais Tarde"
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		cRet := "  /  /     :  "
		nPosTsk := aScan(aHTaskCPM,{|x| x[1] == AF9->AF9_TAREFA })
		If nPosTsk > 0
			cRet := DTOC(aHTaskCPM[nPosTsk][12][1])+" "+aHTaskCPM[nPosTsk][12][2]
		EndIf
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		cRet := "  /  /     :  "
		nPosTsk := aScan(aHEDTCPM,{|x| x[1] == AFC->AFC_EDT })
		If nPosTsk > 0
			cRet := DTOC(aHEDTCPM[nPosTsk][3][1])+" "+aHEDTCPM[nPosTsk][3][2]
		EndIf
	EndIf
	Return cRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 4 // Inicializa os valores da planilha          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==4

EndIf


Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200DFMC  ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a data fim mais cedo da tarefa / EDT                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200DFMC(nRet,cAlias,nRecNo,aCampos)
Local cRet
Local nPosTsk

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200DFMC","C",16,0}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0148,"C200DFMC","",16,"C"}   //"Fim Mais Cedo"
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		cRet := "  /  /     :  "
		nPosTsk := aScan(aHTaskCPM,{|x| x[1] == AF9->AF9_TAREFA })
		If nPosTsk > 0
			cRet := DTOC(aHTaskCPM[nPosTsk][11][3])+" "+aHTaskCPM[nPosTsk][11][4]
		EndIf
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		cRet := "  /  /     :  "
		nPosTsk := aScan(aHEDTCPM,{|x| x[1] == AFC->AFC_EDT })
		If nPosTsk > 0
			cRet := DTOC(aHEDTCPM[nPosTsk][2][3])+" "+aHEDTCPM[nPosTsk][2][4]
		EndIf
	EndIf
	Return cRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 4 // Inicializa os valores da planilha          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==4

EndIf


Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200CRITI ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a data fim mais cedo da tarefa / EDT                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200CRITI(nRet,cAlias,nRecNo,aCampos)
Local cRet
Local nPosTsk
Local aRet2  := Iif(Type('aRet') <> 'U', aRet, {})
Local aHEDT := Iif(Type('aHEDTCPM') <> 'U', aHEDTCPM, {})
Local aHTask := Iif(Type('aHTaskCPM') <> 'U', aHTaskCPM, {} )
                                        
If (Type('aHEDTCPM') == 'U') .or. (Type('aHTaskCPM') == 'U')
	aRet2 := PmsCalcCPM(AF8->AF8_PROJET,cRevisa)
	aHTask := aRet2[1]
	aHEDT := aRet2[2]
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200CRITI","C",3,0}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {Substr(STR0132,2,LEN(STR0132)),"C200CRITI","",3,"C"}   //"*Critica"
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		cRet := STR0149 //"Nao"
		nPosTsk := aScan(aHTask,{|x| x[1] == AF9->AF9_TAREFA })
		If nPosTsk > 0
			If 	DTOS(AF9->AF9_FINISH)+AF9->AF9_HORAF==;
				DTOS(aHTask[nPosTsk][12][3])+aHTask[nPosTsk][12][4]
				cRet := STR0150 //"Sim"
			Else
				cRet := STR0149 //"Nao"
			EndIf
		EndIf
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		cRet := STR0149 //"Nao"
		nPosTsk := aScan(aHEDT,{|x| x[1] == AFC->AFC_EDT })
		If nPosTsk > 0
			If 	DTOS(AFC->AFC_FINISH)+AFC->AFC_HORAF==;
				DTOS(aHEDT[nPosTsk][3][3])+aHEDT[nPosTsk][3][4]
				cRet := STR0150 //"Sim"
			Else
				cRet := STR0149 //"Nao"
			EndIf
		EndIf
	EndIf
	Return cRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 4 // Inicializa os valores da planilha          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==4

EndIf


Return




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200DFMT  ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna a data fim mais cedo da tarefa / EDT                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200DFMT(nRet,cAlias,nRecNo,aCampos)
Local cRet
Local nPosTsk

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200DFMT","C",16,0}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0151,"C200DFMT","",16,"C"}   //"Fim Mais Tarde"
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		cRet := "  /  /     :  "
		nPosTsk := aScan(aHTaskCPM,{|x| x[1] == AF9->AF9_TAREFA })
		If nPosTsk > 0
			cRet := DTOC(aHTaskCPM[nPosTsk][12][3])+" "+aHTaskCPM[nPosTsk][12][4]
		EndIf
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		cRet := "  /  /     :  "
		nPosTsk := aScan(aHEDTCPM,{|x| x[1] == AFC->AFC_EDT })
		If nPosTsk > 0
			cRet := DTOC(aHEDTCPM[nPosTsk][3][3])+" "+aHEDTCPM[nPosTsk][3][4]
		EndIf
	EndIf
	Return cRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 4 // Inicializa os valores da planilha          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==4

EndIf


Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200QR    ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Quantidade realizada da tarefa                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200QR(nRet,cAlias,nRecNo,aCampos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200QR","N",16,4}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0041,"C200QR","@E 9999999999.9999",16,"N"} //"Qtd.Realizada"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor do COTP                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PMS_MAX_DATE)*AF9->AF9_QUANT/100
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsPOCAFC(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,CTOD("31/12/2030"))*AFC->AFC_QUANT/100
	EndIf
	Return nRet
EndIf


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200PP    ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o percentual fisico previsto do projeto.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200PP(nRet,cAlias,nRecNo,aCampos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200PP","N",14,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0042,"C200PP","@E 999.99%",14,"N"} //"%Fisico Prv."
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor do COTP                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PMSPrvAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataBase)/AF9->AF9_HUTEIS*100
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PMSPrvAFC(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,dDataBase)/AFC->AFC_HUTEIS*100
	EndIf
	Return nRet
EndIf


Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200PR    ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o percentual fisico realizado.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200PR(nRet,cAlias,nRecNo,aCampos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200PR","N",14,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0043,"C200PR","@E 999.99%",14,"N"} //"%Fisico Realizado"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor do COTP                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PMSPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataBase)
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PMSPOCAFC(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,dDataBase)
	EndIf
	Return nRet
EndIf


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200UNIP  ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o Valor Unitario precisto da tarefa / EDT            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200UNIP(nRet,cAlias,nRecNo,aCampos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200UNIP","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0069,"C200UNIP","@E 999,999,999,999.99",15,"N"} //"Custo Unit.Prv."
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor unitario                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetCOTP(aHandCP,1,AF9->AF9_TAREFA,.T.)[1]/AF9->AF9_QUANT
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetCOTP(aHandCP,2,AFC->AFC_EDT,.T.)[1]/AFC->AFC_QUANT
	EndIf
	Return nRet
EndIf


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200UNIR  ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o Valor Unitario precisto da tarefa / EDT            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200UNIR(nRet,cAlias,nRecNo,aCampos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200UNIR","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0070,"C200UNIR","@E 999,999,999,999.99",15,"N"}  //"Custo Unit. Real"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor unitario                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetCRTE(aHandCR,1,AF9->AF9_TAREFA)[1]/(AF9->AF9_QUANT*PMSPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,PMS_MAX_DATE)/100)
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetCRTE(aHandCR,1,AFC->AFC_EDT)[1]/(AFC->AFC_QUANT*PMSPOCAFC(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,PMS_MAX_DATE)/100)
	EndIf
	Return nRet
EndIf


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMC200New³ Autor ³ Edson Maricate         ³ Data ³ 16-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta uma nova configuracao de planilha.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC200 , SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMC200New(cAlias,nReg,nOpcx)
Local aRet
Local aFile    := {}
Local nFrz     := nFreeze
Local cCmpPLN2 := cCmpPLN
Local cArqPLN2 := cArqPLN
Local nOldInd  := nIndent
Local cPath    := GetNewPar("MV_PMSP200" ,Curdir())
Local cPathRoot := ""

If !Empty(cPath)
	cPathRoot := "SERVIDOR"+iIf(left(cPath ,1) == "\" ,"" ,"\")+cPath
	If IsSrvUnix()
		cPathRoot := STRTRAN(cPathRoot ,"\" ,"/")
	Else
		cPathRoot := STRTRAN(cPathRoot ,"/" ,"\")
	EndIF
EndIf

cCmpPLN := ''
cArqPLN	:= ''
nFreeze := 0             
nIndent := PMS_SHEET_INDENT

If ParamBox({	{1,STR0046,SPACE(200),"","","","", 85 ,.T.},;  //"Descricao"
	{6,STR0010,SPACE(254),,,"", 55 ,.T.,STR0011,cPathRoot} },STR0047,@aRet)  //"Arquivo"###"Arquivo .PLN |*.PLN"###"Nova Planilha"
	
	lSenha := .F.
	cArqPLN	:= MountFile( cPath ,AllTrim(aRet[2]) ,PMS_SHEET_EXT )	
	cPLNDescri := AllTrim(aRet[1])
		
	If C200CfgCol()
		If ReadSheetFile(cArqPLN ,aFile)

			// {versao, campos, senha, descricao, freeze}
			cPLNVer    := aFile[1]
			cArqPLN    := AllTrim(cArqPLN)
			cCmpPLN    := aFile[2]
			cPLNSenha  := aFile[3]
			cPLNDescri := aFile[4]
			nFreeze    := aFile[5]
			nIndent    := aFile[6]
			lSenha := !Empty(aFile[3])

			If lSenha
				cCmpPLN    := Embaralha(cCmpPLN, 0)
				cPLNDescri := Embaralha(cPLNDescri, 0)
			EndIf
			
			PMC200Dlg(cAlias,nReg,nOpcx)
		Else
			Aviso(STR0013,STR0014,{STR0074},2) //"Falha na Abertura."###"Erro na abertura do arquivo. Verifique a existencia do arquivo selecionado." //'Ok'
		EndIf

	Else

		cCmpPLN := cCmpPLN2
		cArqPLN	:= cArqPLN2		
		nFreeze	:= nFrz		      
		nIndent := nOldInd
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMC200Cfg³ Autor ³ Edson Maricate         ³ Data ³ 16-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta uma nova configuracao de planilha.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSC200 , SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMC200Cfg(cAlias,nReg,nOpcx)
Local aRet2 := {}
Local aFile := {}
Local lRet	:=	.F.

If !Empty(cArqPLN)
	lSenha := .F.

	If ReadSheetFile(AllTrim(cArqPLN) ,aFile)

		// {versao, campos, senha, descricao, freeze}
		cPLNVer    := aFile[1]
		cArqPLN    := AllTrim(cArqPLN)
		cCmpPLN    := aFile[2]
		cPLNSenha  := aFile[3]
		cPLNDescri := aFile[4]
		nFreeze    := aFile[5]
		nIndent    := aFile[6]
		lSenha     := !Empty(aFile[3])
		
		If lSenha
			cCmpPLN    := Embaralha(cCmpPLN, 0)
			cPLNDescri := Embaralha(cPLNDescri, 0)

			// Verifica a senha
			// Se a senha estiver errada, cancela a abertura
			If Parambox({{8, STR0109, SPACE(10), "@A!", "", "", "", 30, .T.}}, STR0110, @aRet2) //"Senha"###"Desproteger arquivo"
				If Encript(aRet2[1], 1)#cPLNSenha
					Alert(STR0111) //"Senha incorreta"
					Return lRet
				EndIf
			Else
				Alert(STR0111) //"Senha incorreta"
		   	Return lRet
			EndIf
		EndIf

		lRet	:=	C200CfgCol()
	Else
		Aviso(STR0013,STR0014,{STR0074},2) //"Falha na Abertura."###"Erro na abertura do arquivo. Verifique a existencia do arquivo selecionado." //'Ok'
	EndIf
Else
	Aviso(STR0013,STR0014,{STR0074},2) //"Falha na Abertura."###"Erro na abertura do arquivo. Verifique a existencia do arquivo selecionado." //'Ok'
EndIf

Return lRet

Function C200Excel()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200VLPC  ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor previsto em Pedido de Compras.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200VLPC(nRet,cAlias,nRecNo,aCampos)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200VLPC","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0059,"C200VLPC","@E 999,999,999,999.99",15,"N"} //"Vlr.Prev.PC"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor previsto em Pedidos        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFin,1,AF9->AF9_TAREFA)[1]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFin,2,AFC->AFC_EDT)[1]
	EndIf
	Return nRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 4 // Inicializa os valores da planilha          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==4
	If aScan(aCampos,{|x| AllTrim(x[1])$"$C200VLPC".Or.AllTrim(x[1])$"$C200VLPC".Or.AllTrim(x[1])$"$C200VLDSP".Or.AllTrim(x[1])$"$C200VLPAG".Or.AllTrim(x[1])$"$C200VLPV".Or.AllTrim(x[1])$"$C200VLDSC".Or.AllTrim(x[1])$"$C200VLREC"})>0
		aHandFin := PmsIniFin(AF8->AF8_PROJET,AF8->AF8_REVISA,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)))
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200VLFAT ³ Autor ³ Edson Maricate       ³ Data ³ 27-09-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor total faturado do projeto.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200VLFAT(nRet,cAlias,nRecNo,aCampos)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200VLFAT","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0133,"C200VLFAT","@E 999,999,999,999.99",15,"N"} 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor previsto em Pedidos        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFat,1,AF9->AF9_TAREFA)[1]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFat,2,AFC->AFC_EDT)[1]
	EndIf
	Return nRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 4 // Inicializa os valores da planilha          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==4
	If aScan(aCampos,{|x| AllTrim(x[1])$"$C200VLFAT".Or.AllTrim(x[1])$"$C200VLREM".Or.AllTrim(x[1])$"$C200SLFAT".Or.AllTrim(x[1])$"$C200SLREM"})>0
		aHandFat := PmsIniFat(AF8->AF8_PROJET,AF8->AF8_REVISA,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)),,dDataBase)
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200SLFAT ³ Autor ³ Edson Maricate       ³ Data ³ 27-09-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor total faturado do projeto.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200SLFAT(nRet,cAlias,nRecNo,aCampos)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200SLFAT","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0136,"C200SLFAT","@E 999,999,999,999.99",15,"N"}//"Vlr.Faturado ( Pendente )"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor previsto em Pedidos        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFat,1,AF9->AF9_TAREFA)[3]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFat,2,AFC->AFC_EDT)[3]
	EndIf
	Return nRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 4 // Inicializa os valores da planilha          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==4
	Return Nil
EndIf

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200VLREM ³ Autor ³ Edson Maricate       ³ Data ³ 27-09-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor total faturado do projeto.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200VLREM(nRet,cAlias,nRecNo,aCampos)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200VLREM","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0134,"C200VLREM","@E 999,999,999,999.99",15,"N"} //"*Vlr.Remessas"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor previsto em Pedidos        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFat,1,AF9->AF9_TAREFA)[2]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFat,2,AFC->AFC_EDT)[2]
	EndIf
	Return nRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 4 // Inicializa os valores da planilha          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==4
  Return Nil
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200SLREM ³ Autor ³ Edson Maricate       ³ Data ³ 27-09-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor total faturado do projeto.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200SLREM(nRet,cAlias,nRecNo,aCampos)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200SLREM","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0135,"C200SLREM","@E 999,999,999,999.99",15,"N"} //"*Vlr.Remessas ( Pendente )"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor previsto em Pedidos        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFat,1,AF9->AF9_TAREFA)[4]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFat,2,AFC->AFC_EDT)[4]
	EndIf
	Return nRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 4 // Inicializa os valores da planilha          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==4
  Return Nil
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200VLDSP ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor previsto em Titulos a Pagar /NF Entrada      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200VLDSP(nRet,cAlias,nRecNo,aCampos)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200VLDSP","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0060,"C200VLDSP","@E 999,999,999,999.99",15,"N"} //"Vlr.Prev.Despesas"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor do Vlr. Previsto Despesas  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFin,1,AF9->AF9_TAREFA)[2]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFin,2,AFC->AFC_EDT)[2]
	EndIf
	Return nRet
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200VLPAG ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor total pago.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200VLPAG(nRet,cAlias,nRecNo,aCampos)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200VLPAG","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0061,"C200VLPAG","@E 999,999,999,999.99",15,"N"} //"Vlr.Total Pagtos."
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor total de pagamentos        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFin,1,AF9->AF9_TAREFA)[3]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFin,2,AFC->AFC_EDT)[3]
	EndIf
	Return nRet
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200VLPV  ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor previsto de receitas em Pedido de Vendas     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200VLPV(nRet,cAlias,nRecNo,aCampos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200VLPV","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0062,"C200VLPV","@E 999,999,999,999.99",15,"N"} //"Vlr.Prev.PV"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor total de pagamentos        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFin,1,AF9->AF9_TAREFA)[4]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFin,2,AFC->AFC_EDT)[4]
	EndIf
	Return nRet
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200VLDSC ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor previsto em titulos a receber                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200VLDSC(nRet,cAlias,nRecNo,aCampos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200VLDSC","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0063,"C200VLDSC","@E 999,999,999,999.99",15,"N"} //"Vlr.Prev.Receitas"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor total de pagamentos        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFin,1,AF9->AF9_TAREFA)[5]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFin,2,AFC->AFC_EDT)[5]
	EndIf
	Return nRet
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200VLREC ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor total das receitas                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200VLREC(nRet,cAlias,nRecNo,aCampos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200VLREC","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0064,"C200VLREC","@E 999,999,999,999.99",15,"N"} //"Vlr.Total Receitas"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor total de pagamentos        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFin,1,AF9->AF9_TAREFA)[6]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetFinVal(aHandFin,2,AFC->AFC_EDT)[6]
	EndIf
	Return nRet
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200RTREC ³ Autor ³ Edson Maricate       ³ Data ³ 11-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os recursos alocados na tarefa                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200RTREC(nRet,cAlias,nRecNo,aCampos)
Local cRet	:= ""
Local aArea	:= GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200RTREC","C",100,0}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0121,"C200RTREC","@!",100,"C"}  //"Recursos Alocados"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor total de pagamentos        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		cRet := ""
		AF9->(MsGoto(nRecNo))
		dbSelectArea("AFA")
		dbSetOrder(1)
		If dbSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
			While !Eof() .And. AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA_REVISA+AFA->AFA_TAREFA==xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
				If !Empty(AFA->AFA_RECURS)
					cRet += AllTrim(AFA->AFA_RECURS)+":"+TransForm(AFA->AFA_ALOC,"@E 999%")+";"
					EndIf
				dbSkip()
			End
		EndIf
	EndIf
	RestArea(aArea)
	Return cRet
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200RTREC2³ Autor ³ Edson Maricate       ³ Data ³ 11-08-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os recursos alocados na tarefa com nome              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200RTREC2(nRet,cAlias,nRecNo,aCampos)
Local cRet			:= ""
Local aArea			:= GetArea()
Local aAreaAE8		:= AE8->(GetArea())
Local cObfNRecur	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200RTREC2","C",100,0}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0137,"C200RTREC2","@!",100,"C"}  //"Recursos Alocados (Nome)"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna os recursos alocados               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		cObfNRecur	:= IIF(FATPDIsObfuscate("AE8_DESCRI",,.T.),FATPDObfuscate("RESOURCE NAME","AE8_DESCRI",,.T.),"")        
		cRet 		:= ""
		AF9->(MsGoto(nRecNo))
		dbSelectArea("AFA")
		dbSetOrder(1)
		If dbSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
			While !Eof() .And. AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA_REVISA+AFA->AFA_TAREFA==xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
				If !Empty(AFA->AFA_RECURS)
					AE8->(DbSetOrder(1))
					AE8->(MsSeek(xFilial()+AFA->AFA_RECURS))  
					cRet += IIF(Empty(cObfNRecur),AllTrim(AE8->AE8_DESCRI),cObfNRecur)+":"+TransForm(AFA->AFA_ALOC,"@E 999%")+";"
				EndIf
				dbSkip()
			End
		EndIf
	EndIf
	RestArea(aAreaAE8) 
	RestArea(aArea) 
	Return cRet
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200RTREL ³ Autor ³ Edson Maricate       ³ Data ³ 31-07-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os relacionamentos da tarefa                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200RTREL(nRet,cAlias,nRecNo,aCampos)
Local cRet	:= ""
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local cTp 	:= ""                       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200RTREL","C",120,0}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0152,"C200RTREL","@!",120,"C"}  //"Predecessoras"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor total de pagamentos        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		cRet := ""
		AF9->(MsGoto(nRecNo))
		dbSelectArea("AFD")
		dbSetOrder(1)
		If dbSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
			While !Eof() .And. AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA==xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
				aAuxArea := AF9->(GetArea())
				AF9->(dbSetOrder(1))
				If AF9->(dbSeek(xFilial()+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_PREDEC))
					Do Case
						Case AFD->AFD_TIPO == "1"
							cTp	:= AllTrim(AF9->AF9_DESCRI)+":FI"
						Case AFD->AFD_TIPO == "2"
							cTp := AllTrim(AF9->AF9_DESCRI)+":II"
						Case AFD->AFD_TIPO == "3"
							cTp := AllTrim(AF9->AF9_DESCRI)+":FF"
						Case AFD->AFD_TIPO == "4"
							cTp := AllTrim(AF9->AF9_DESCRI)+":IF"
					EndCase
					cRet += AllTrim(AFD->AFD_PREDEC)+"-"+cTp+";"
				Else
					cRet += STR0153+AllTrim(AFD->AFD_PREDEC)+";" //"Erro Predecessora:"
				EndIf
				RestArea(aAuxArea)
				dbSelectArea("AFD")
				dbSkip()
			End
		EndIf
		dbSelectArea("AJ4")
		dbSetOrder(1)
		If dbSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
			While !Eof() .And. AJ4->AJ4_FILIAL+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA+AJ4->AJ4_TAREFA==xFilial("AJ4")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
				AFC->(dbSetOrder(1))
				If AFC->(dbSeek(xFilial()+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA+AJ4->AJ4_PREDEC))
					Do Case
						Case AJ4->AJ4_TIPO == "1"
							cTp	:= AllTrim(AFC->AFC_DESCRI)+":FI"
						Case AJ4->AJ4_TIPO == "2"
							cTp := AllTrim(AFC->AFC_DESCRI)+":II"
						Case AJ4->AJ4_TIPO == "3"
							cTp := AllTrim(AFC->AFC_DESCRI)+":FF"
						Case AJ4->AJ4_TIPO == "4"
							cTp := AllTrim(AFC->AFC_DESCRI)+":IF"
					EndCase
					cRet += AllTrim(AJ4->AJ4_PREDEC)+"-"+cTp+";"
				Else
					cRet += STR0153+AllTrim(AJ4->AJ4_PREDEC)+";" //"Erro Predecessora:"
				EndIf
				dbSelectArea("AJ4")
				dbSkip()
			End
		EndIf
	EndIf
	RestArea(aAreaAF9)
	RestArea(aArea)
	Return cRet
EndIf

RestArea(aAreaAF9)
RestArea(aArea)
Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200RTSCS ³ Autor ³ Edson Maricate       ³ Data ³ 23-09-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna as sucessoras da tarefa/EDT                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200RTSCS(nRet,cAlias,nRecNo,aCampos)
Local cRet	:= ""
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFC	:= AFC->(GetArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200RTSCS","C",120,0}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0154,"C200RTSCS","@!",120,"C"}  //"Sucessoras"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor total de pagamentos        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		cRet := ""
		AF9->(MsGoto(nRecNo))
		dbSelectArea("AFD")
		dbSetOrder(2)
		If dbSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
			While !Eof() .And. AFD->AFD_FILIAL+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_PREDEC==xFilial("AFD")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
				aAuxArea := AF9->(GetArea())
				AF9->(dbSetOrder(1))
				If AF9->(dbSeek(xFilial()+AFD->AFD_PROJET+AFD->AFD_REVISA+AFD->AFD_TAREFA))
					Do Case
						Case AFD->AFD_TIPO == "1"
							cTp	:= AllTrim(AF9->AF9_DESCRI)+":FI"
						Case AFD->AFD_TIPO == "2"
							cTp := AllTrim(AF9->AF9_DESCRI)+":II"
						Case AFD->AFD_TIPO == "3"
							cTp := AllTrim(AF9->AF9_DESCRI)+":FF"
						Case AFD->AFD_TIPO == "4"
							cTp := AllTrim(AF9->AF9_DESCRI)+":IF"
					EndCase
					cRet += AllTrim(AFD->AFD_TAREFA)+"-"+cTp+";"
				Else
					cRet += STR0155+AllTrim(AFD->AFD_TAREFA)+";" //"Erro Sucessora:"
				EndIf
				RestArea(aAuxArea)
				dbSkip()
			End
		EndIf
	ElseIf cAlias=="AFC"
		cRet := ""
		AFC->(MsGoto(nRecNo))
		dbSelectArea("AJ4")
		dbSetOrder(2)
		If dbSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
			While !Eof() .And. AJ4->AJ4_FILIAL+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA+AJ4->AJ4_PREDEC==xFilial("AJ4")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT
				AF9->(dbSetOrder(1))
				If AF9->(dbSeek(xFilial()+AJ4->AJ4_PROJET+AJ4->AJ4_REVISA+AJ4->AJ4_TAREFA))
					Do Case
						Case AJ4->AJ4_TIPO == "1"
							cTp	:= AllTrim(AF9->AF9_DESCRI)+":FI"
						Case AJ4->AJ4_TIPO == "2"
							cTp := AllTrim(AF9->AF9_DESCRI)+":II"
						Case AJ4->AJ4_TIPO == "3"
							cTp := AllTrim(AF9->AF9_DESCRI)+":FF"
						Case AJ4->AJ4_TIPO == "4"
							cTp := AllTrim(AF9->AF9_DESCRI)+":IF"
					EndCase
					cRet += AllTrim(AJ4->AJ4_TAREFA)+"-"+cTp+";"
				Else
					cRet += STR0155+AllTrim(AJ4->AJ4_TAREFA)+";" //"Erro Sucessora:"
				EndIf
				dbSkip()
			End
		EndIf
	EndIf
	RestArea(aAreaAFC)
	RestArea(aAreaAF9)
	RestArea(aArea)
	Return cRet
EndIf

RestArea(aAreaAFC)
RestArea(aAreaAF9)
RestArea(aArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C200RTEVE ³ Autor ³ Edson Maricate       ³ Data ³ 31-07-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os eventos da EDT;Tarefa                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200RTEVE(nRet,cAlias,nRecNo,aCampos)
Local cRet	:= ""
Local aArea	:= GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200RTEVE","C",120,0}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0126,"C200RTEVE","@!",120,"C"} //"Eventos"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor total de pagamentos        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		cRet := ""
		AF9->(MsGoto(nRecNo))
		dbSelectArea("AFP")
		dbSetOrder(1)
		If dbSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
			While !Eof() .And. AFP->AFP_FILIAL+AFP->AFP_PROJET+AFP_REVISA+AFP->AFP_TAREFA==xFilial("AFP")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
				cRet += STR0127+AFP->AFP_USO+AllTrim(AFP->AFP_DESCRI)+"-"+Transform(AFP->AFP_PERC,"@E 999%")+";"
				dbSkip()
			End
		EndIf
		RestArea(aArea)
		Return cRet
	ElseIf cAlias=="AFC"
		cRet := ""
		AFC->(MsGoto(nRecNo))
		dbSelectArea("AFP")
		dbSetOrder(2)
		If dbSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
			While !Eof() .And. AFP->AFP_FILIAL+AFP->AFP_PROJET+AFP_REVISA+AFP->AFP_EDT==xFilial("AFP")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT
				cRet += STR0127+AFP->AFP_USO+"-"+AllTrim(AFP->AFP_DESCRI)+"-"+Transform(AFP->AFP_PERC,"@E 999%")+";" //"Uso:"
				dbSkip()
			End
		EndIf
	EndIf
	RestArea(aArea)
	Return cRet
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RenFld    ³ Autor ³ Adriano Ueda         ³ Data ³ 09-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Renomeia automaticamente os campos a serem inclusos na       ³±±
±±³          ³ planilha                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array destino                                         ³±±
±±³          ³ExpA2 : Array origem                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200 - PMSC050                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function RenFld(aCpoDest, aCpoOri)
Local nCntLet := 0, nCount := 0, nCnt := 0

For nCnt := 1 to Len(aCpoOri)
	nCntLet++
	If nCntLet > 26
		nCntLet	:= 1
		nCount++
	EndIf
	If nCount > 0
		aAdd(aCpoDest,"("+Chr(64+nCntLet)+Chr(48+nCount)+")"+aCpoOri[nCnt][1])
	Else
		aAdd(aCpoDest,"("+Chr(64+nCntLet)+")"+aCpoOri[nCnt][1])
	EndIf
Next
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AddVarPln ³ Autor ³ Adriano Ueda         ³ Data ³ 09-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Adiciona variavel global para ser utilizada em formulas      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array para ser incluido                               ³±±
±±³          ³ExpA2 : Listbox para exibicao                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AddVarPln(aVars, oCpoSel)

Local xBuffer
Local cBuffer
Local aRet := {}
Local cTipo := ""
Local aAuxVar	

Private aVars2 := aClone(aVars)

If ParamBox({ {1,STR0099, SPACE(10), "","VldVarNome(MV_PAR01) .And. !VarExists(aVars2, MV_PAR01)","","", 85, .T.},; // Nome
	{1,STR0100,SPACE(25),"","","","", 85 ,.T.},;  // Descricao
	{3,STR0102,2,{STR0083,STR0084,STR0085},60,,.T.},;  // Tipo"###"Caracter"###"Numerico"###"Data"
	{1,STR0103,12,"@E 99","VldVarTam(MV_PAR03, MV_PAR04, MV_PAR05)","","", 30 ,.T.},;           // Tamanho
	{1,STR0104,0,"@E 9","VldVarTam(MV_PAR03, MV_PAR04, MV_PAR05)","","(MV_PAR03==2)", 15 ,.F.},;            // Decimal
	{1,STR0105,SPACE(60),"","","","", 85 ,.F.};     // Picture
	},STR0106,@aRet)
	
	Do Case
		Case aRet[3]==1
			cTipo := "C"
			cBuffer := Space(30)
			xBuffer := Space(30)     
			aRet[5] := 0
		Case aRet[3]==2
			cTipo := "N"
			cBuffer := PadL("0", 30, " ")
			xBuffer := 0
		Case aRet[3]==3
			cTipo := "D"
			cBuffer := PadR("01/01/80", 30, " ")
			xBuffer := PMS_MIN_DATE
			aRet[5] := 0			
	EndCase

	If Chr(0) $ aRet[6]
		aRet[6] := RetNulos(aRet[6])
	EndIf
	
	aAdd(aVars, {aRet[1], aRet[2], xBuffer, cTipo, aRet[4], aRet[5], aRet[6], "_|"+PadR(aRet[1], 10, " ")+;                // nome
																																					  "|"+PadR(aRet[2], 25, " ")+;                 // titulo
																																						"|"+cBuffer+;  // valor
																																						"|"+PadR(cTipo, 1, " ")+;                   // tipo
																																						"|"+StrZero(aRet[4],2,0)+;                 // tamanho
																																						"|"+StrZero(aRet[5],1,0)+;                 // decimal
																																						"|"+PadR(aRet[6], 60, " ")})
	aAuxVar := aClone(aVars)
	
	If Len(aAuxVar) > 0
		oCpoSel:SetArray(aAuxVar)
		oCpoSel:bLine:={||{aAuxVar[oCpoSel:nAt,1], aAuxVar[oCpoSel:nAt,2], TransForm(aAuxVar[oCpoSel:nAt,3],aAuxVar[oCpoSel:nAt,7] )}}
		oCpoSel:Refresh()
	EndIf
EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EdtVarPln ³ Autor ³ Adriano Ueda         ³ Data ³ 09-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Edita variavel global a ser utilizada em formulas            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array para ser editado                                ³±±
±±³          ³ExpA2 : Listbox para exibicao                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function EdtVarPln(aVars, oCpoSel)
Local aRet := {}
Local cTipo := ""
Local nBuffer := 0
Local aAuxVar
Local cPict := SPACE(60)

Private cNomeAnt
Private aVars2 := aClone(aVars)

If oCpoSel:nAt < 1
	Return
EndIf
If Len(aVars) < 1
	Return
EndIf

cNomeAnt := aVars[oCpoSel:nAt, 1]
cTipo := aVars[oCpoSel:nAt, 4]
cPict := PadR(aVars[oCpoSel:nAt, 7], 60, " ")

If Chr(0) $ cPict
	cPict := RetNulos(cPict)
EndIf
		
Do Case
	Case cTipo=="C"
		nBuffer := 1
	Case cTipo=="N"
		nBuffer := 2
	Case cTipo=="D"
		nBuffer := 3
End Case

If ParamBox({ {1,STR0099, aVars[oCpoSel:nAt, 1], "","VldVarNome(MV_PAR01) .And. !VarExists2(aVars2, MV_PAR01, cNomeAnt)","","", 85, .T.},; // Nome
	{1,STR0100,aVars[oCpoSel:nAt, 2],"","","","", 85 ,.T.},;                                   // Descricao
	{3,STR0102,nBuffer,{STR0083,STR0084,STR0085},60,,.T.},;                                    // Tipo"###"Caracter"###"Numerico"###"Data"
	{1,STR0103,aVars[oCpoSel:nAt, 5],"@E 99","VldVarTam(MV_PAR03, MV_PAR04, MV_PAR05)","","", 30 ,.T.},;                                   // Tamanho
	{1,STR0104,aVars[oCpoSel:nAt, 6],"@E 9","VldVarTam(MV_PAR03, MV_PAR04, MV_PAR05)","","(MV_PAR03==2)", 15 ,.F.},;                                   // Decimal
	{1,STR0105,cPict,"@!","","","", 85 ,.F.};     // Picture
	},STR0107,@aRet)
	
	Do Case
		Case aRet[3]==1
			cTipo := "C"
			aRet[5] := 0
		Case aRet[3]==2
			cTipo := "N"
		Case aRet[3]==3
			cTipo := "D"
			aRet[5] := 0
	EndCase
	
	If Len(aVars) > 0
		aVars[oCpoSel:nAt,1] := aRet[1]
		aVars[oCpoSel:nAt,2] := aRet[2]
		
		If nBuffer # aRet[3]
			Do Case
				Case aRet[3]==1
					aVars[oCpoSel:nAt,3] := Space(30)
				Case aRet[3]==2
					aVars[oCpoSel:nAt,3] := PadL("0", 30, " ")
				Case aRet[3]==3
					aVars[oCpoSel:nAt,3] := PadR(DToC(MSDate()), 30, " ")
			EndCase
		EndIf
		
		aVars[oCpoSel:nAt,4] := cTipo
		aVars[oCpoSel:nAt,5] := aRet[4]
		aVars[oCpoSel:nAt,6] := aRet[5] 

		If Chr(0) $ aRet[6]
			aRet[6] := RetNulos(aRet[6])
		EndIf
		
		aVars[oCpoSel:nAt,7] := PadR(AllTrim(aRet[6]), 60, " ") // + Space(60-Len(aRet[6]))
		
		If Chr(0) $ aVars[oCpoSel:nAt,7]
			aVars[oCpoSel:nAt,7] := RetNulos(aVars[oCpoSel:nAt,7])
		EndIf
		
		aVars[oCpoSel:nAt,8] := "_|"+aRet[1]+;                // nome
														"|"+aRet[2]+;                 // titulo
														"|"+PadR(aVars[oCpoSel:nAt,3], 30, " ")+;  // valor
														"|"+cTipo+;                   // tipo
														"|"+StrZero(aRet[4],2,0)+;                 // tamanho
														"|"+StrZero(aRet[5],1,0)+;                 // decimal
														"|"+PadR(AllTrim(aRet[6]), 60, " ")

		aAuxVar := aClone(aVars)
	
		oCpoSel:SetArray(aAuxVar)
		oCpoSel:bLine:={||{aAuxVar[oCpoSel:nAt,1], aAuxVar[oCpoSel:nAt,2], TransForm(aAuxVar[oCpoSel:nAt,3],aAuxVar[oCpoSel:nAt,7] )}}
		oCpoSel:Refresh()
	EndIf
EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DelVarPln ³ Autor ³ Adriano Ueda         ³ Data ³ 15-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui variavel global utilizada em formulas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array a ser excluido                                  ³±±
±±³          ³ExpA2 : Listbox para exibicao                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function DelVarPln(aVars, oCpoSel)
Local aLen := 0
Local aVarVis

If Len(aVars) > 0
	aDel(aVars, oCpoSel:nAt)
	aLen := Len(aVars) - 1
	aSize(aVars, aLen)
	aVarVis := aClone(aVars)
	
	oCpoSel:SetArray(aVarVis)
	If Len(aVarVis) > 0
		oCpoSel:bLine:={||{aVarVis[oCpoSel:nAt,1], aVarVis[oCpoSel:nAt,2], Transform(aVarVis[oCpoSel:nAt,3], aVarVis[oCpoSel:nAt,7])}}
	EndIf
	oCpoSel:Refresh()
EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GravaPln  ³ Autor ³ Adriano Ueda         ³ Data ³ 15-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os campos, formulas e variaveis em arquivo             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Campos e formulas a serem gravados                    ³±±
±±³          ³ExpA2 : Variaveis a serem gravadas                            ³±±
±±³          ³ExpC3 : Arquivo a ser salvo (pode ou nao conter a extensao    ³±±
±±³          ³        .pln - a extensao nao e obrigatoria)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.      ³ a variavel cVersao indica a versao do arquivo                ³±±
±±³          ³                                                              ³±±
±±³          ³ 101 - arquivo nao codificado                                 ³±±
±±³          ³ 102 - arquivo codificado                                     ³±±
±±³          ³                                                              ³±±
±±³          ³ lSenha indica se o arquivo sera protegido ou nao             ³±±
±±³          ³ .T. - o arquivo sera gravado com os dados codificados        ³±±
±±³          ³ .F. - o arquivo sera gravado sem os dados codificados        ³±±
±±³          ³                                                              ³±±
±±³          ³ cPLNSenha contem a senha para acessar o arquivoo             ³±±
±±³          ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GravaPln(aCampos, aVars, cArquivo, nStart)

Local cMvFldPln  := ""
Local cWrite
Local nCount := 0

Default nStart := 3

// campos e formulas
For nCount := nStart to Len(aCampos)
	cMvFldPln += ("_"+aCampos[nCount][2]+"#")
Next

// variaveis
For nCount := 1 To Len(aVars)
	If !Empty(aVars[nCount][1])
		If Chr(0) $ aVars[nCount][8]
			cMvFldPln += RetNulos(aVars[nCount][8]) +"#"
		Else
			cMvFldPln += aVars[nCount][8] +"#"
		Endif
	EndIf
Next

// acrescenta extensao ao arquivo se nao existir
// no nome do arquivo
If Upper(Right(AllTrim(cArquivo), 4)) != Upper(PMS_SHEET_EXT)
	cArquivo := AllTrim(cArquivo) + PMS_SHEET_EXT
EndIf

// Codifica o arquivo
If lSenha
	cWrite := Embaralha(cMvFldPln, 1) + CRLF
	cWrite += "102" + CRLF  // arquivo codificado
	cWrite += cPLNSenha + CRLF
	cWrite += Embaralha(cPLNDescri, 1)
Else
	cWrite := cMvFldPln + CRLF
	cWrite += "101" + CRLF  // arquivo nao codificado (default)
	cWrite += cPLNDescri
EndIf

If Type("nFreeze") == "U"
	cWrite += CRLF + "0"
Else
	cWrite += CRLF + AllTrim(Str(nFreeze))
EndIf

If Type("nIndent") == "U"
	cWrite += CRLF + AllTrim(Str(PMS_SHEET_INDENT))
Else
	cWrite += CRLF + AllTrim(Str(nIndent))
EndIf

MemoWrit(cArquivo,cWrite)
cCmpPLN	:= cMvFldPln
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VldVarNome³ Autor ³ Adriano Ueda         ³ Data ³ 15-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o nome de variavel e valido                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Nome da variavel                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VldVarNome(cVarNome)
// caracteres validos para a formacao do nome
Local cValid := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
Local Nx := 0

cVarNome := Upper(AllTrim(cVarNome))

For nx := 1 To Len(cVarNome)
	// Verifica se a variavel contem caracteres invalidos
	If !(Substr(cVarNome, nx, 1) $ cValid)
		Alert(STR0112+cVarNome+STR0113) //"A variavel "###" contem caracteres invalidos no nome"
		Return .F.
	EndIf
	// Verifica se o nome da variavel comeca
	// com um caracter alfabetico
	If !IsAlpha(cVarNome)
		Alert(STR0114) //"O nome da variavel deve comecar com um caracter alfabetico"
		Return .F.
	EndIf
Next
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VarExists ³ Autor ³ Adriano Ueda         ³ Data ³ 22-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o nome de variavel ja existe                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 : Array com os nomes ja existentes                     ³±±
±±³          ³ ExpC1 : Nome da variavel                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VarExists(aVars, cVarNome)
Local nx := 0

For nx := 1 To Len(aVars)
	If (Upper(aVars[nx][1])==Upper(cVarNome))
		Return .T.
	EndIf
Next	
Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VarExists2³ Autor ³ Adriano Ueda         ³ Data ³ 22-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o nome de variavel ja existe                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 : Array com os nomes ja existentes                     ³±±
±±³          ³ ExpC1 : Nome da variavel                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.      ³ Utilizado apenas na edicao de variaveis                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VarExists2(aVars, cVarNome, cAnt)
Local nx := 0

For nx := 1 To Len(aVars)
	If (Upper(aVars[nx][1])==Upper(cVarNome))
		If Upper(cVarNome) # Upper(cAnt)
			Return .T.	
		EndIf		
	EndIf
Next	
Return .F.
  
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSEdtValPln³ Autor ³ Adriano Ueda         ³ Data ³ 22-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Permite a edicao de valores na listbox contendo as variaveis ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 : Arrays contendo as variaveis                         ³±±
±±³          ³ ExpO1 : Listbox                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PMSEdtValPln(aVars, oCpoSel)
Local xBuffer
Local cPict

If Len(aVars) < 1
	Return .F.
EndIf

xBuffer := aVars[oCpoSel:nAt][3]
cPict := aVars[oCpoSel:nAt][7]

MaFisEditCell(@xBuffer, oCpoSel, @cPict, 3, '!Vazio()')

aVars[oCpoSel:nAt, 3] := xBuffer

Do Case
	Case ValType(xBuffer)=="C"
		xBuffer := PadR(xBuffer, 30, " ")
	Case ValType(xBuffer)=="N"
		xBuffer := PadL(Str(xBuffer), 30, " ")
	Case ValType(xBuffer)=="D"
		xBuffer := PadR(DToC(xBuffer), 30, " ")
EndCase

aVars[oCpoSel:nAt,8] := "_|"+aVars[oCpoSel:nAt,1]+;                 // nome
												"|" +aVars[oCpoSel:nAt,2]+;                 // titulo
												"|" +xBuffer             +;                 // valor
												"|" +aVars[oCpoSel:nAt,4]+;                 // tipo
												"|" +StrZero(aVars[oCpoSel:nAt,5],2,0)+;    // tamanho
												"|" +StrZero(aVars[oCpoSel:nAt,6],1,0)+;    // decimal
												"|" +PadR(aVars[oCpoSel:nAt,7], 60, " ")    // picture
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ProtArq   ³ Autor ³ Adriano Ueda         ³ Data ³ 22-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controla a protecao do arquivo com senha                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ProtArq() 
Local aRet := {}
Local cTitulo := ""
			
If lSenha
	// arquivo estava desprotegido
	cTitulo := STR0115 //"Proteger arquivo"
Else
	cTitulo := STR0110 //"Desproteger arquivo"
EndIf

If Parambox({{8, STR0109, SPACE(10), "@A!", "", "", "", 30, .T.}}, cTitulo, @aRet) //"Senha"
	If lSenha
		// arquivo estava desprotegido
		cPLNSenha := Encript(aRet[1], 1)
		Alert(STR0116) //"Arquivo protegido"
	Else
		// arquivo estava protegido
		If Encript(aRet[1], 1)==cPLNSenha
			Alert(STR0117) //"Arquivo desprotegido"
			cPLNSenha := ""			
		Else
			Alert(STR0111) //"Senha incorreta"
			
			// volta estado original do check
			lSenha := !lSenha
			oUsado:lActive := !oUsado:lActive
			oUsado:Refresh()
		EndIf
	EndIf
Else
	// volta estado original do check
	lSenha := !lSenha
	oUsado:lActive := !oUsado:lActive
	oUsado:Refresh()
	
EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SalvarPln ³ Autor ³ Adriano Ueda         ³ Data ³ 29-10-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para salvar a planilha com senha                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 : Arrays contendo os campos                            ³±±
±±³          ³ ExpA2 : Arrays contendo as variaveis                         ³±±
±±³          ³ ExpC1 : Nome do arquivo                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SalvarPln(aCpos, aVars, cArq)
Local aRet := {}

If lSenha
	// Verifica a senha
	// Se a senha estiver errada, cancela o salvamento
	If Parambox({{8, STR0109, SPACE(10), "@A!", "", "", "", 30, .T.}}, STR0118, @aRet) //"Senha"###"Digite a senha para a gravacao"
		If Encript(aRet[1], 1)#cPLNSenha
			Alert(STR0111) //"Senha incorreta"
			Return .F.
		EndIf
	Else
		Alert(STR0111) //"Senha incorreta"
    Return .F.
	EndIf
EndIf

GravaPln(aCpos, aVars, cArq)
oDlg:End()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VldVarTam ³ Autor ³ Adriano Ueda         ³ Data ³ 06-11-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para validar o tamanho dos campos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 : Tipo de dado                                         ³±±
±±³          ³ ExpN2 : Tamanho                                              ³±±
±±³          ³ ExpN1 : Decimais                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VldVarTam(nTipo, nTam, nDec)
Local lErro := .F.

Do Case
	// caracter
	Case nTipo==1
		lErro := (nTam > 30) .Or. (nTam < 0)

	// numerico
	Case nTipo==2
		lErro := (nTam > 30) .Or. (nTam < 0) .Or. (nDec < 0)
	
	// data
	Case nTipo==3
		lErro := !(nTam==8 .Or. nTam==10)
	
	Otherwise
		lErro := .T.
EndCase

If lErro
	Alert(STR0119) //"Tamanho invalido. O tamanho maximo permitido e de 30 caracteres para o tipo caracter e numerico; 8 para o tipo data."
EndIf
Return !lErro


Function PMC200Exc(cAlias,nReg,nOpcx,cArq)

If Aviso(STR0156,STR0157,{STR0150,STR0149},2)==1 .And. !Empty(cArq)  //"Atencao!"###"Deseja realmente excluir a configuração selecionada ?"###"Sim"###"Nao"
	FErase(cArq)
EndIf

Return

Function ReadSheetFile(cFile, aFile)
	Local cCols   := ""  // colunas
	Local cId     := ""  // id
	Local cPwd    := ""  // password
	Local cDesc   := ""  // description
	Local nFrze   := 0     // freeze
	Local nInd	  := PMS_SHEET_INDENT	// indent
	
	Local lRet      := .F.
	Local lPassword := .F.

	cFile := AllTrim(cFile)

	If File(cFile)

		If FT_FUse(cFile) <> -1
      
			// colunas
			cCols := FT_FREADLN()			
			FT_FSKIP()
			
			// id
			cId := FT_FREADLN()
			FT_FSKIP()
			
			If Right(Alltrim(cId), 1) == "2" 
				
				// password
				cPwd := FT_FREADLN()
				FT_FSKIP()
				
				lPassword := .T.
			EndIf
			
			// desc
			cDesc := FT_FREADLN()
			FT_FSKIP()

			// freeze
			nFrze := Val(FT_FREADLN())
			FT_FSKIP()
			
			// indent
			nInd := If(Empty(FT_FREADLN()), PMS_SHEET_INDENT, Val(FT_FREADLN()))
				
			//If lPassword					
			//	cCols := Embaralha(cCols, 0)
			//	cDesc := Embaralha(cDesc, 0)
			//EndIf
			
			FT_FUSE()
		
			aFile := {cId, cCols, cPwd, cDesc, nFrze, nInd}
			
			lRet := .T.
		EndIf
	EndIf
Return lRet

Function WriteSheetFile(cFile, aFile)
	Local cCols   := ""  // colunas
	Local cId     := ""  // id
	Local cPwd    := ""  // password
	Local cDesc   := ""  // description
	Local cFreeze := ""  // freeze
	Local cInd    := ""  // indent

	Local cBuffer := 0

	If Len(aFile) > 0

		cId     := AllTrim(aFile[1]) // cId
		cPwd    := AllTrim(aFile[3]) // cPwd

		If Empty(cPwd)
			cCols   := aFile[2] // colunas
			cDesc   := aFile[4]
			cFreeze := aFile[5]
			cInd    := aFile[6]
		Else
			cCols   := Embaralha(aFile[2], 1) // colunas
			cDesc   := Embaralha(aFile[4], 1)
			cFreeze := Embaralha(Str(aFile[5]), 1)
			cInd    := Embaralha(Str(aFile[6]), 1)
		EndIf   
		
		cBuffer := cCols + cId + cPwd + cDesc + cFreeze + cInd
		
		MemoWrite(cFile, cBuffer)
	EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C200CEMPOP ³ Autor ³ Edson Maricate       ³ Data ³ 08-04-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o custo empenhado por OP.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSC200                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C200CEMPOP(nRet,cAlias,nRecNo,aCampos)

If Type("aHandCEMPOP") == "U"
	aHandCEMPOP := {}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200CEMPOP","N",15,2}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0158,"C200CEMPOP","@E 999,999,999,999.99",15,"N"}  //"Vlr.Emp.OP"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor do COTP                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==3
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		nRet := PmsRetCRTE(aHandCEMPOP,1,AF9->AF9_TAREFA)[1]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		nRet := PmsRetCRTE(aHandCEMPOP,2,AFC->AFC_EDT)[1]
	EndIf
	Return nRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 4 // Inicializa os valores da planilha          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==4
	If aScan(aCampos,{|x| AllTrim(x[1])=="$C200CEMPOP"})>0
		aHandCEMPOP	:= PmsIniCEMPOP(AF8->AF8_PROJET,AF8->AF8_REVISA,dDataBase)
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³01/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
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
	Local aRotina 	:= {	{ STR0048, STR0002  , 0 , 1},; //"AxPesqui" //"Pesquisar"
	{ STR0003, "PMC200New", 0 , 2},; //"Nova "
	{ STR0004, "PMC200Opn", 0, 2}, ; //"Abrir"
	{ STR0005, "PMC200Cfg", 0 , 2},; //"Configurar"
	{ STR0006, "PMC200Dlg", 0 , 2},; //Consultar
	{ STR0141, "PMS200Leg", 0 , 2, ,.F.}} //"Legenda"
Return(aRotina)

Static Function MountFile( cPath ,cFile ,cExtension )
Local cBarra := iIf(IsSrvUnix() ,"/" ,"\")

DEFAULT cPath := ""
DEFAULT cFile := ""
DEFAULT cExtension := ""

	cPath := Alltrim(cPath)
	
	If IsSrvUnix()
		cPath := STRTRAN(cPath ,"\" ,"/")
	Else
		cPath := STRTRAN(cPath ,"/" ,"\")
	EndIF
	
	If !(Right(cPath ,1) == cBarra)
		cPath += cBarra
	EndIf
	
	cFile := Alltrim(cFile)
	cExtension := Alltrim(cExtension)
	
	If !(upper(Right( cFile ,len(cExtension))) == upper(cExtension))
		cFile	+= cExtension
	EndIf

Return(cFile)	



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ PMSResH ³ Autores ³                        ³ Data ³27/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PMSResH(nTam)
Local aRes  :=	GetScreenRes()
Local nHRes	:=	0	// Resolucao horizontal do monitor
	
	// se houver retorno e houve valor no elemento 1
	nHRes := iIf( Len(aRes)>1 .and. aRes[1]>0 ,aRes[1], 800 )
	
	If nHRes <= 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.625 // 0.8
	ElseIf (nHRes >640 .and. nHRes <= 800)	// Resolucao 800x600
		nTam *= 0.78125 //1
	ElseIf (nHRes >800 .and. nHRes <= 1024)	// // Resolucao 1024x768 
		nTam *= 1 // 1.28
	Else	// Acima
		nTam *= 1.25
	EndIf
	
Return Int(nTam)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ PMSResV ³ Autores ³                        ³ Data ³27/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao vertical do Monitor do Usuario.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PMSResV(nTam)
Local aRes  :=	GetScreenRes()
Local nVRes	:=	0	// Resolucao vertical do monitor
	
	// se houver retorno e houve valor no elemento 1
	nVRes := iIf( Len(aRes)>1 .and. aRes[2]>0 ,aRes[2], 600 )
	
	If nVRes <= 480	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.625 // 0.8
	ElseIf (nVRes >480 .and. nVRes <= 600)	// Resolucao 800x600
		nTam *= 0.78125 //1
	ElseIf (nVRes >600 .and. nVRes <= 768)	// // Resolucao 1024x768 
		nTam *= 1
	Else // acima
		nTam *= 1.333333
	EndIf
	
	// tratamento para tema "TEMAP10"
	If "P10" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "TEMAP10") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
	
Return Int(nTam)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³C200DtEst ºAutor  ³Clovis Magenta      º Data ³  14/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao utilizada para coluna calculada DET - Data Estimada  º±±
±±º          ³de Termino.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSC200                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C200DtEst(nRet,cAlias,nRecNo,aCampos)

Local aArea    := GetArea()
Local dDataRef := ddatabase
Local dET
Local nCOTP    := 0
Local nCOTE    := 0
Local nIDP     := 0
Local aAlltasks:= {}
Local aAllEDT  := {}
Local nY			:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ nRet = 1 // Retorna as informacoes do campo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRet==1
	Return {"C200DtEst","D",10,0}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 2 // Retorna as informacoes do campo + Picture  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nRet==2
	Return {STR0160 , "C200DtEst","  /  /    ",10,"D"} //"%Fisico Realizado"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nRet = 3 // Retorna o valor do COTP                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else
	dbSelectArea(cAlias)
	dbGoTo(nRecNo)
	
	Do Case
		Case cAlias=="AF9"
	
			aHandle	:= PmsIniCOTP(AF9->AF9_PROJET,AF9->AF9_REVISA,dDataRef,AF9->AF9_TAREFA,AF9->AF9_TAREFA)
			nCOTP		:= PmsRetCOTP(aHandle,1,AF9->AF9_TAREFA)[1]
			aHandle	:= PmsIniCOTE(AF9->AF9_PROJET,AF9->AF9_REVISA,dDataRef,AF9->AF9_TAREFA,AF9->AF9_TAREFA)
			nCOTE		:= PmsRetCOTE(aHandle,1,AF9->AF9_TAREFA)[1]
			nIDP	:= nCOTE/nCOTP*100
			
			// se não existe um IDP, não é possível calcular o DET		
			If nIDP == 0
				dET := PMS_EMPTY_DATE
			Else
				dET := Int((AF9->AF9_FINISH - AF9->AF9_START) / nIDP * 100) + AF9->AF9_START
			EndIf
	
		Case cAlias=="AFC"
		   
			PmsLoadTrf(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aAllEDT,,@aAllTasks)
			aHandle	:=	{}
			For	nY	:=	1	TO Len(aAlltasks)	                                              
				AF9->(MsGoTo(aAlltasks[nY]))
				aHandle	:= PmsIniCOTP(AFC->AFC_PROJET,AFC->AFC_REVISA,dDataRef,AF9->AF9_TAREFA,AF9->AF9_TAREFA,,aHandle)
			Next
			nCOTP		:= PmsRetCOTP(aHandle,2,AFC->AFC_EDT)[1]
			aHandle	:=	{}
			For	nY	:=	1	To Len(aAlltasks)	                                              
				AF9->(MsGoTo(aAlltasks[nY]))
				aHandle	:= PmsIniCOTE(AFC->AFC_PROJET,AFC->AFC_REVISA,dDataRef,AF9->AF9_TAREFA,AF9->AF9_TAREFA,aHandle)
			Next
			nCOTE		:= PmsRetCOTE(aHandle,2,AFC->AFC_EDT)[1]
			nIDP	:= nCOTE/nCOTP*100
	
			// se não existe um IDP, não é possível calcular o DET
			If nIDP == 0
				dET   := PMS_EMPTY_DATE
			Else
				dET		:= Int((AFC->AFC_FINISH - AFC->AFC_START) / nIDP * 100) + AFC->AFC_START
			EndIf
	EndCase
Endif
  
RestArea(aArea)

Return dET


Static Function MoveCell(oListCell,nMove)
Local nAt := oListCell:nAt
Local nNext := oListCell:nAt + nMove
Local nPos1
Local nPos2
Local cAt        := ""
Local cName      := ""
Local aCampos3	:= {}
Local aCamCol2 := aClone(oListCell:aItems)
Local lContinua := .T.

aAdd(aCamCol2,"")

If nAt == 1 .OR. nAt == 2 .OR. nNext == 1 .OR. nNext == 2
	Aviso("Configurar colunas","As colunas 'Código' e 'Descrição' não devem ter sua ordem alterada.",{STR0074},1)
	lContinua := .F.
EndIf

If lContinua
	If nAt > 0 .and. nAt <= Len(oListCell:Cargo[2]) .and. nNext > 0 .and. nNext <= Len(oListCell:Cargo[2])
		
		oListCell:SetArray(aCamCol2)
		
		nPos1 := Ascan(aCampos2,{|x| x == oListCell:Cargo[2][nAt] })
		If nPos1 > 0
			cAt := aCampos2[nPos1][1]
			cAt := "("+Chr(64+nNext)+")"+cAt
		EndIf
	
		nPos2 := Ascan(aCampos2,{|x| x == oListCell:Cargo[2][nNext] })
		If nPos2 > 0
			cNext := aCampos2[nPos2][1]
			cNext := "("+Chr(64+nAt)+")"+cNext
		EndIf
	    
	    If nPos2>0 .and. nPos1>0
		    aCampos3 := aCampos2[nPos1]
			aCampos2[nPos1] := aClone(aCampos2[nPos2])
			aCampos2[nPos2] := aClone(aCampos3)
		Endif	
	
		If !Empty(cAt) .and. !Empty(cNext)
			
			If nMove < 0
		//		cName := oListCell:Cargo[2][nAt][1]
				oListCell:Cargo[2][nAt] := aClone(aCampos2[nAt])
				oListCell:Cargo[2][nNext] := aClone(aCampos2[nNext])
		
				oListCell:Modify( cNext,nAt)
				oListCell:Modify( cAt,nNext)
		                                                     	
				aCamposB[nPos1] := cNext
				aCamposB[nPos2] := cAt
				
				oListCell:nAt := nNext
				oListCell:Refresh()
			Else
				oListCell:Cargo[2][nNext] := aClone(aCampos2[nNext])
				oListCell:Cargo[2][nAt] := aClone(aCampos2[nAt])
		
				oListCell:Modify( cAt,nNext)
				oListCell:Modify( cNext,nAt)
	                                                     	
				aCamposB[nPos2] := cAt
				aCamposB[nPos1] := cNext
				
				oListCell:nAt := nNext
				oListCell:Refresh()
			EndIf
		EndIf
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSC200   ºAutor  ³Microsiga           º Data ³  07/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function WhenMove(cButtom,oCampos2,oBtn)

If !Empty(oBtn)
	If		cButtom == 'BTN_DOWN'
		oBtn:lActive := (oCampos2:nAt > 2) .and. (oCampos2:nAt < Len(oCampos2:Cargo[2]))
	ElseIf	cButtom == 'BTN_UP'
		oBtn:lActive := (oCampos2:nAt > 3)
	EndIf
EndIf

Return NIL

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  

