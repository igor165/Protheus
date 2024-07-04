#INCLUDE "PLSA791.CH"
#include "PROTHEUS.CH"
#include "PLSMGER2.CH"
#include "COLORS.CH"
#include "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA791   ºAutor  ³Geraldo Felix Juniorº Data ³  24/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para Inclusao das agendas medicas por local de       º±±
±±º          ³atendimento e especialidade medica.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Marcacao de consultas...                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA791()        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cSql := ''
LOCAL cUsuario := retcodusr()  // ---> Codigo do Usuario
LOCAL cBAUName := RetSqlName("BAU")
PRIVATE aRotina :=	MenuDef()
PRIVATE cCadastro 	:= __cNameBAU
PRIVATE aHeader     := {}
PRIVATE aCols       := {}
PRIVATE n           := 1
PRIVATE cCodEsp		:= ""
PRIVATE cCodInt		:= ""
PRIVATE cCodLoc		:= ""
PRIVATE cCodSub		:= ""

If BAU->(FieldPos("BAU_FILTRO")) > 0 .And. BAU->(FieldPos("BAU_USRFIL")) > 0
	cSql := "UPDATE "+cBAUName+" SET BAU_FILTRO = ' ', BAU_USRFIL = '' "
	cSql += "WHERE BAU_USRFIL = '"+cUsuario+"'"
	TcSqlExec(cSql)
Endif
	                                           
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pergunte para filtro...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_F12,{|a,b| Pergunte("PL791F",.T.),PL791FILTRO() })

Pergunte("PL791F",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Filtro...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cFilter := "@BAU_TIPPE = 'F' AND BAU_DATBLO = '       '"
cFilter := "@BAU_DATBLO = '       '"
dbSelectarea("BAU")
SET FILTER TO &cFilter
BAU->( MsSeek(xFilial("BAU")) )
                                           
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Starta mBrowse...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BAU->(DBSetOrder(2))
BAU->(mBrowse(06,01,22,75,"BAU",,"BAU_CODBLO <> SPACE(03)",20))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Filtro...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectarea("BAU")
SET FILTER TO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefine teclas de atalhos...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                     
SET KEY VK_F5  TO 
SET KEY VK_F6  TO 
SET KEY VK_F7  TO 
SET KEY VK_F8  TO 
SET KEY VK_F9  TO
SET KEY VK_F10 TO
SET KEY VK_F11 TO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                          ³                            
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                           
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS791CFG ºAutor  ³Geraldo Felix Juniorº Data ³  24/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Configuracao das agendas...                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS791AGE(cAlias, nReg, nOpc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nCnt
Local oDlg
Local nOpcx := If(nOpc==K_Visualizar,K_Visualizar,0)
Local nOpca := 0

Local cVar:="", nCtd
Local bCodOpe, bCodEsp, bCodLoc

Local bCancel 	:= {|| dbSelectArea("BB7"), PlsEndBrw(), oDlg:End() }
Local bTudoOk 	:= {|| dbSelectArea("BB7"), If(PLSA366TOK(), (nOpca := K_OK,PlsEndBrw(), oDlg:End()), nOpca := 0) }
LOCAL aButtons 	:= {}
LOCAL aCampora 	:= {}
LOCAL aAux		:= {}
LOCAL aVetAux	:= {}
Local oFont
LOCAL oFontDat
LOCAL bClear 	:= {||PLS791CLS()}     
LOCAL bMirror 	:= {||PLS791MIRROR()}
LOCAL bMultpl	:= {||PLS791MULT(nOpcx)}
LOCAL bVoltar	:= {||PLS791AVANCA(.F.,nOpcx,oBrwBB7,oDlg)}
LOCAL bSeguir	:= {||PLS791AVANCA(.T.,nOpcx,oBrwBB7,oDlg)}
LOCAL cHora		:= ''
PRIVATE aAuxCabBAX 	:= {}
PRIVATE aCabBAX 	:= {}
PRIVATE aAuxDadBAX  := {}
PRIVATE aDadBAX 	:= {}
PRIVATE aVetBAX 	:= {}
PRIVATE aHeaderBAX  := {}
PRIVATE aAgeAux		:= {}
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aHeader := {}
PRIVATE aCols 	:= {}
PRIVATE aCopy	:= {}
PRIVATE n
PRIVATE BAX_CODINT
PRIVATE BAX_CODLOC
PRIVATE BAX_CODESP
PRIVATE BAX_DESESP
PRIVATE cAno
PRIVATE cMes 
PRIVATE oSMes1
PRIVATE oSMes2
PRIVATE oSayAno1
PRIVATE oSayAno2
PRIVATE oBrwBAX
PRIVATE oBrwBB7
PRIVATE aCabBB7 	:= {}
PRIVATE aDadBB7 	:= {}
PRIVATE aTrbBB7 	:= {}
PRIVATE bAtuBB7
PRIVATE oSayTxt1
PRIVATE oSayTxt2
PRIVATE oFolder

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama o grupo de perguntas...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Pergunte("PLS791",.T.)						
	Return()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza variaveis com valores dos parametros...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAno := mv_par01
cMes := mv_par02

bAtuBB7	:= {||	cCodInt := oBrwBAX:aCols[oBrwBAX:Linha(),oBrwBAX:FieldPos("BAX_CODINT")],;
						cCodEsp := oBrwBAX:aCols[oBrwBAX:Linha(),oBrwBAX:FieldPos("BAX_CODESP")],;
						cCodLoc := oBrwBAX:aCols[oBrwBAX:Linha(),oBrwBAX:FieldPos("BAX_CODLOC")]}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os botoes da enchoicebar...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aButtons, {"S4WB004N"  ,bClear  ,STR0001 + " - <F7>", STR0002 }) //"Limpar agenda"###"Limpar"
aadd(aButtons, {"NOVACELULA",bMirror ,STR0003 + " - <F8>", STR0004}) //"Espelhar agenda"###"Espelhar"
aadd(aButtons, {"BMPPARAM"  ,bMultpl ,STR0005 + " - <F9>", STR0006}) //"Multiplicar agenda"###"Multip"
aadd(aButtons, {"LEFT"      ,bVoltar ,STR0007 + " - <F10>", STR0007}) //"Voltar"###"Voltar"
aadd(aButtons, {"RIGHT"     ,bSeguir ,STR0008 + " - <F11>", STR0008}) //"Avancar"###"Avancar"
      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Teclas de atalhos...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_F5 ,{|a,b| Eval({||uCopiar()}) }) // Copiar
SetKey(VK_F6 ,{|a,b| Eval({||uColar() }) }) // Colar                                                               
SetKey(VK_F7 ,{|a,b| Eval(bClear ) })
SetKey(VK_F8 ,{|a,b| Eval(bMirror) })
SetKey(VK_F9 ,{|a,b| Eval(bMultpl) })
SetKey(VK_F10,{|a,b| Eval(bVoltar) })
SetKey(VK_F11,{|a,b| Eval(bSeguir) })

cCadastro 	:= BAU->BAU_CODIGO+"-"+BAU->BAU_NOME

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define fontes utilizadas somente nesta funcao...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFont 	 NAME "Arial" SIZE 0,-11 BOLD                               
DEFINE FONT oFontDat NAME "Arial" SIZE 000,-017 
DEFINE FONT oFontRod NAME "Arial" SIZE 000,-014 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ monta browse que ira funcionar como listbox...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BAX->(DbSetOrder(1))
aHeaderBAX := {"BAX_CODINT", "BAX_CODLOC", "BAX_CODESP"}
aCabBAX := FunHeader("BAX", aHeaderBAX)

If ! BAX->(DbSeek(xFilial("BAX")+BAU->(BAU_CODIGO))) 
    MsgStop(STR0009) //"Não ha Especialidade cadastrada para esta RDA!"
    Return
Else
   RegToMemory("BAX",.F.)
   cCodint 	:= BAX->BAX_CODINT
   cCodEsp	:= BAX->BAX_CODESP
   cCodLoc	:= BAX->BAX_CODLOC
   cCodSub	:= BAX->BAX_CODSUB
   Store COLS "BAX" TO aDadBAX FROM aCabBAX VETTRAB aVetBAX ;
   While BAX->(BAX_FILIAL+BAX_CODIGO) == xFilial("BAX")+BAU->BAU_CODIGO
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ preserva os valores originais para utilizacao na execucao dos code blocks... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAuxCabBAX := ACLONE(aCabBAX)
aAuxDadBAX := ACLONE(aDadBAX)
                    	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Operadora... 																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bCodOpe := {|nCtd|cVar := aAuxDadBAX[nCtd][ASCAN(aAuxCabBAX,{|aVal| aVal[2] == "BAX_CODINT"})],;
				Padr(Posicione("BA0",1, xFilial("BA0")+cVar,"BA0_NOMINT"),30)}
InsColuna(aCabBAX, aDadBAX, 2, "BAX", STR0010, "BAX_NOMINT", bCodOpe) //"Desc.Operadora"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Local de atendimento...							 							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bCodLoc := {|nCtd|cVar := BAU->BAU_CODIGO, ;
				cVar += aAuxDadBAX[nCtd][ASCAN(aAuxCabBAX,{|aVal| aVal[2] == "BAX_CODINT"})],;
				cVar += aAuxDadBAX[nCtd][ASCAN(aAuxCabBAX,{|aVal| aVal[2] == "BAX_CODLOC"})],;
				Padr(Posicione("BB8",1, xFilial("BB8")+cVar,"BB8_DESLOC"),30)}
InsColuna(aCabBAX, aDadBAX, 4, "BAX", STR0011, "BAX_NOMLOC", bCodLoc) //"Desc.Local"
               
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Especialidade...															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bCodEsp := {|nCtd|cVar := aAuxDadBAX[nCtd][ASCAN(aAuxCabBAX,{|aVal| aVal[2] == "BAX_CODINT"})],;
				cVar += aAuxDadBAX[nCtd][ASCAN(aAuxCabBAX,{|aVal| aVal[2] == "BAX_CODESP"})],;
				Padr(Posicione("BAQ",1, xFilial("BAQ")+cVar,"BAQ_DESCRI"),30)}
InsColuna(aCabBAX, aDadBAX, 6, "BAX", STR0012, "BAX_NOMESP", bCodEsp) //"Desc.Especialidade"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Agenda RDAxOperadoraxLocal de atendimentoxEspecialidade             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BB7" TO aCabBB7 For !Alltrim(SX3->X3_CAMPO) $ "BB7_MES,BB7_ANO,BB7_ORIGEM,BB7_CODIGO"

BB7->(DbSetOrder(3))
If !BB7->(DbSeek(xFilial("BB7")+BAU->BAU_CODIGO+cAno+cMes))
	nOpcx := K_Incluir
	lInclui := .T.
	lAltera := .F.

Else
	If nOpcx != K_Visualizar
		nOpcx := K_Alterar
		lInclui := .F.
		lAltera := .T.
	EndIf		
Endif
                  
// Monta matrix de trabalho...
aVetAux := PLS791VET()
aDadBB7 := aVetAux[1]
aTrbBB7 := aVetAux[2]

If Len(aDadBB7) == 0 
   If nOpcx == K_Visualizar
       MsgStop(STR0013) //"Agenda nao cadastrada!"
      Return
   EndIf   
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Clona agenda original para fazer comparacoes apos o OK...           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Altera
	aCompara := aClone(aDadBB7)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informacoes sobre a resolucao de tela para montar os objetos...     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 100, 200, .T., .T.,.T. } )
AAdd( aObjects, { 200, 100, .T., .T.,.T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetEnch("")
DEFINE MSDIALOG oDlg TITLE Alltrim(cCadastro)+Space(05)+" - "+Space(05)+"[ " + STR0014+cMes+Space(10)+STR0015+cAno+" ]" FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL  //"Mes: "###"Ano: "

oBrwBAX := BAX->(TPLSBrw():New(033,005,aPosObj[1][3],aPosObj[1][4],nil,oDlg,nil,{||.t.},nil,nil,nil,.T.,nil,.T.,nil,aCabBAX,aDadBAX,.F.,"BAX",K_Visualizar,STR0017,nil,nil,nil,aVetBAX,,,)) //"Agenda Medica"
oBrwBAX:bGotFocus 	:= {||Eval(oBrwBAX:bLostFocus), oBrwBB7:ForceRefresh(oBrwBAX)}
oBrwBAX:bLostFocus 	:= {||Eval(bAtuBB7)}
oBrwBAX:bChange 	:= {||Eval(bAtuBB7), Eval(oBrwBAX:bLostFocus), oBrwBB7:ForceRefresh(oBrwBAX),oSayTxt1:Refresh(),oSayTxt2:Refresh()} 

@ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlg PIXEL PROMPTS STR0017 //"Agenda"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Agenda medica...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFilter := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BB7_CODINT",aHeader)] == cCodInt .and. ;
				aCols[nLine,GdFieldPos("BB7_CODLOC",aHeader)] == cCodLoc .and. ;
				aCols[nLine,GdFieldPos("BB7_CODESP",aHeader)] == cCodEsp}                                                                                                               

oBrwBB7 := TPLSBrw():New(002,002,aPosObj[2][3]-05,aPosObj[2][4]-38,nil,oFolder:aDialogs[1],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBB7,aDadBB7,.F.,"BB7",nOpcx,STR0017,nil,nil,nil,aTrbBB7,,,bFilter) //"Agenda Medica"
oBrwBB7:oPai    := oBrwBAX
oBrwBB7:aOrigem := {"BAX_CODINT","BAX_CODLOC","BAX_CODESP"}
oBrwBB7:aRelac  := {"BB7_CODINT","BB7_CODLOC","BB7_CODESP"}                      
oBrwBB7:oBrowse:bDelOk 	:= {|| .F. } 
oBrwBB7:lAddLine 		:= .T.
oBrwBB7:cVldLine := 'PLSVLDBB7()'		
If nOpc == 3
	oBrwBB7:nOpc		:= K_Alterar
	oBrwBB7:nOpcx		:= K_Alterar
	nOpc				:= K_Alterar
Endif

@ aPosObj[2][4]-31, 001 Say oSayTxt1 PROMPT STR0018 SIZE 060, 010 OF oFolder:aDialogs[1] PIXEL FONT oFontRod //"Local Atend.:"
@ aPosObj[2][4]-31, 050 Say oSayTxt1 PROMPT Alltrim(oBrwBAX:aCols[oBrwBAX:Linha(),oBrwBAX:FieldPos("BAX_NOMLOC")]);
                              SIZE 130, 010 OF oFolder:aDialogs[1] PIXEL COLOR CLR_HBLUE FONT oFontRod
                              
@ aPosObj[2][4]-31, 190 Say oSayTxt2 PROMPT STR0019 SIZE 060, 010 OF oFolder:aDialogs[1] PIXEL FONT oFontRod //"Especialidade:"
@ aPosObj[2][4]-31, 245 Say oSayTxt2 PROMPT Alltrim(oBrwBAX:aCols[oBrwBAX:Linha(),oBrwBAX:FieldPos("BAX_NOMESP")]);
                              SIZE 130, 010 OF oFolder:aDialogs[1] PIXEL COLOR CLR_HBLUE FONT oFontRod
                        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa refresh na agenda medica...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(oBrwBAX:bChange)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bTudoOk,bCancel,K_MsgDel,aButtons)
               
If nOpca == K_OK .And. nOpcx != K_Visualizar
	// Instrucao para nao deixar gravar linhas em branco.             	
	If Altera .and. Len(oBrwBB7:aCols) <> Len(aCompara)
		Aviso(STR0020,STR0021,{"Ok"}) //"Icompatibilidade de estruturas"###"As alteracoes nao poderao ser salvas, devido a uma incompatibilidade interna de estruturas. Tente novamente!"
		Return()
	Endif
		
	For nCnt :=  1 To Len(oBrwBB7:aCols)         
	                                                                                  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Coleta dados da matriz, para evitar acessos redundantes...          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		dDatAge := cTod(oBrwBB7:FieldGet("BB7_DIAMES",nCnt)+"/"+cMes+"/"+cAno)
		cHorEnt := oBrwBB7:FieldGet("BB7_HORENT",nCnt)
		cHorSai	:= oBrwBB7:FieldGet("BB7_HORSAI",nCnt)
		cPltIni	:= oBrwBB7:FieldGet("BB7_PLTINI",nCnt)
		cPltFin	:= oBrwBB7:FieldGet("BB7_PLTFIN",nCnt)
						                      
		cCodInt := oBrwBB7:FieldGet("BB7_CODINT",nCnt)
		cCodLoc := oBrwBB7:FieldGet("BB7_CODLOC",nCnt)
		cCodEsp := oBrwBB7:FieldGet("BB7_CODESP",nCnt)
		
		If Empty(cHorEnt) .and. Empty(cHorSai) .and. Empty(cPltIni) .and. Empty(cPltFin)
	   
		   	oBrwBB7:aCols[nCnt, (Len(oBrwBB7:aHeader)+1)] := .T.   // Deleta linha
		   
		Elseif Altera .and. oBrwBB7:FieldGet("BB7_INTERV", nCnt) <> aCompara[nCnt][oBrwBB7:FieldPos("BB7_INTERV")]		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida Existecia do indice no sindex do ambiente...                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SIX->( dbSetorder(01) )
			If SIX->( dbSeek("BBD7") )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Encontra as consultas ja agendadas para transforma-las em encaixe...³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
				BBD->( dbSetorder(07) )
				If BBD->( dbSeek(xFilial("BBD")+cCodint+BAU->BAU_CODIGO+cCodLoc+cCodEsp+'1'+dTos(dDatAge)  ) )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta os horarios dos medicos...                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aAux := PLSA300HR(cHorEnt,cHorSai,oBrwBB7:FieldGet("BB7_INTERV", nCnt),;
											    oBrwBB7:FieldGet("BB7_EXCINI", nCnt),oBrwBB7:FieldGet("BB7_EXCFIN", nCnt))
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Processa as consultas ja agendadas...                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ									
					While ! BBD->( Eof() ) .and. BBD->(BBD_CODINT+BBD_CODIGO+BBD_CODLOC+BBD_CODESP+'1'+dTos(BBD_DATA)) == (cCodint+BAU->BAU_CODIGO+cCodLoc+cCodEsp+'1'+dTos(dDatAge))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Testa se a consulta esta no intervalo de horario da agenda...       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If StrTran(BBD->BBD_HORA,":","") >= StrTran(cHorEnt, ":", "") .and.;
						   StrTran(BBD->BBD_HORA,":","") <= StrTran(cHorSai, ":", "")
							 
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Se o horario nao coincidir, transforma em encaixe...                ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							
							If Ascan(aAux, BBD->BBD_HORA) == 0
								BBD->( RecLock("BBD", .F.) )
									BBD->BBD_TIPO 	:= '4'
									BBD->BBD_ENCAIX := '1'
								BBD->( msUnlock() )
							Else
								If BBD->BBD_TIPO == '4' .and. BBD->BBD_ENCAIX == '1'
									BBD->( RecLock("BBD", .F.) )
										BBD->BBD_TIPO 	:= '1'
										BBD->BBD_ENCAIX := '0'
									BBD->( msUnlock() )	
								Endif
							Endif
						Endif
						BBD->( dbSkip() )
					Enddo
				Endif
			Endif
		Endif		
	Next		   	

	aChave := {}
	aadd(aChave,{"BB7_CODIGO",BAU->BAU_CODIGO})
	aadd(aChave,{"BB7_ANO",cAno})
	aadd(aChave,{"BB7_MES",cMes})
	oBrwBB7:Grava(aChave,,.F.)
EndIf

Set Key VK_F5 TO
Set Key VK_F6 TO

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³InsColuna ºAutor  ³Geraldo Felix Juniorº Data ³  03/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inserir uma coluna nos arrays aCabAlias, aDadAlias para uso º±±
±±º          ³na browse da classe plsbrw                                  º±±
±±º          ³somente colunas caracteres, criando campo virtual - Visual  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function InsColuna(aCab, aDad, nPos, cAlias, cTitle, cCampo, bRotFun)
Local nTamCpo, nCtd

ASIZE(aCab,Len(aCab)+1)
AINS(aCab, nPos)

For nCtd := 1 TO LEN(aDad)
	ASIZE(aDad[nCtd], Len(aDad[nCtd])+1)
	AINS(aDad[nCtd], nPos)
	aDad[nCtd][nPos] := Eval(bRotFun, nCtd)
	nTamCpo := Len(aDad[nCtd][nPos])
Next	

/*
[ 1] := SX3->X3_TITULO
[ 2] := SX3->X3_CAMPO
[ 3] := SX3->X3_PICTURE
[ 4] := SX3->X3_TAMANHO
[ 5] := SX3->X3_DECIMAL
[ 6] := SX3->X3_VALID
[ 7] := SX3->X3_USADO
[ 8] := SX3->X3_TIPO
[ 9] := SX3->X3_ARQUIVO
[10] := SX3->X3_CONTEXT
*/

aCab[nPos] := {}
aAdd(aCab[nPos], cTitle)
aAdd(aCab[nPos], cCampo)
aAdd(aCab[nPos], "@!")
aAdd(aCab[nPos], nTamCpo)
aAdd(aCab[nPos], 0)
aAdd(aCab[nPos], "")
aAdd(aCab[nPos], "")
aAdd(aCab[nPos], "C")
aAdd(aCab[nPos], cAlias)
aAdd(aCab[nPos], "V")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FunHeader ºAutor  ³Geraldo Felix Juniorº Data ³  03/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Devolver um array contendo somente os campos desejados no   º±±
±±º          ³alias determinado com array enviado como argumento          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FunHeader(cAlias, aHeader)
Local aAuxCab, nPos, cCampo, nCtd
Local aCab := {}

Store Header cAlias TO aAuxCab For .T.

For nCtd := 1 TO Len(aHeader)
    cCampo := aHeader[nCtd]
    nPos := ASCAN(aAuxCab,{|aVal| aVal[2] == cCampo})
    If nPos > 0
    	aAdd(aCab, aAuxCab[nPos])
    EndIf
Next

Return(aCab)

Static Function PLSA366TOK()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS791VET ºAutor  ³Geraldo Felix Juniorº Data ³  24-07-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria a agenda generica...                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/      
Function PLS791VET()
LOCAL aDados := {}
LOCAL aTrab	 := {}
Local nCnt
LOCAL nCodIntPai	:= PLRETPOS("BAX_CODINT",aCabBAX,.F.)
LOCAL nCodEspPai	:= PLRETPOS("BAX_CODESP",aCabBAX,.F.)
LOCAL nCodLocPai	:= PLRETPOS("BAX_CODLOC",aCabBAX,.F.)
LOCAL nCodSubPai	:= PLRETPOS("BAX_CODSUB",aCabBAX,.F.)
Local nCols

// Monta quadro de horarios...
nDias := PLSDIAMES(Val(cMes), cAno)
For nCols := 1 To Len(aDadBAX)
	cCodint := aDadBAX[nCols,nCodIntPai]
	cCodEsp := aDadBAX[nCols,nCodEspPai]
	cCodLoc := aDadBAX[nCols,nCodLocPai]	                
	
	For nCnt := 1 To nDias
		
		dData := cTod(StrZero(nCnt,2)+"/"+cMes+"/"+cAno)
		Aadd(aDados, {	StrZero(nCnt,2),;
		PLSDIASEM(dData),;
		CriaVar("BB7_HORENT"),;
		CriaVar("BB7_HORSAI"),;
		CriaVar("BB7_EXCINI"),;
		CriaVar("BB7_EXCFIN"),;	
		CriaVar("BB7_PLTINI"),;
		CriaVar("BB7_PLTFIN"),;
		CriaVar("BB7_INTERV"),;
		CriaVar("BB7_EXTRA") ,;
		CriaVar("BB7_OBSDIA"),;
		CriaVar("BB7_STATUS"),;
		CriaVar("BB7_CODESP"),;
		CriaVar("BB7_CODINT"),;
		CriaVar("BB7_CODLOC"),;
		CriaVar("BB7_CODSUB"),;
		Alltrim(Str(Dow(dData))),;
		.F.})
		nOpcx := K_Incluir
		lInclui := .T.
		lAltera := .F.
		
		Aadd(aTrab, 0)
	Next

	BB7->( dbSetorder(04) )
	If BB7->( dbSeek(xFilial("BB7")+BAU->BAU_CODIGO+cAno+cMes+cCodLoc+cCodEsp) )
		While !BB7->( Eof() ) .and. BB7->BB7_CODIGO == BAU->BAU_CODIGO .and.;
									BB7->BB7_ANO 	== cAno 	.and.;
									BB7->BB7_MES 	== cMes 	.and.;
									BB7->BB7_CODLOC == cCodLoc  .and.;
									BB7->BB7_CODESP == cCodEsp
														
			If Empty(BB7->BB7_HORENT) .and.;
			   Empty(BB7->BB7_HORSAI) .and.;
			   Empty(BB7->BB7_PLTINI) .and.;
			   Empty(BB7->BB7_PLTFIN)
			   
				BB7->( dbSkip() )
				Loop
			Endif
			
			If (nPos := Ascan(aDados, {|x| x[01] == BB7->BB7_DIAMES .and.;
			                           x[13] == BB7->BB7_CODESP .and.;
			                           x[14] == BB7->BB7_CODINT .and.;
		    	                       x[15] == BB7->BB7_CODLOC }) ) <> 0
		
				aDados[nPos][03] := BB7->BB7_HORENT
				aDados[nPos][04] := BB7->BB7_HORSAI
				aDados[nPos][05] := BB7->BB7_EXCINI
				aDados[nPos][06] := BB7->BB7_EXCFIN
				aDados[nPos][07] := BB7->BB7_PLTINI
				aDados[nPos][08] := BB7->BB7_PLTFIN
				aDados[nPos][09] := BB7->BB7_INTERV
				aDados[nPos][10] := BB7->BB7_EXTRA
				aDados[nPos][11] := BB7->BB7_OBSDIA
				                                         
				aTrab[nPos] := BB7->( Recno() )
			
			Endif
			BB7->( dbSkip() )
		Enddo
	Endif
Next

Return({aDados,aTrab})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Plsa360Hr  ³ Autor ³Geraldo Felix Junior ³ Data ³ 22.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacoes dos BB7_HORENT pois a condicao nao cabe no campo³±±
±±³          ³ X3_WHEN                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nCampo - (1) BB7_HORENT                                    ³±±
±±³          ³ nCampo - (2) BB7_SAIENT                                    ³±±
±±³          ³ nCampo - (3) BB7_DIA                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 22/08/02 ³      ³ Geraldo Felix Junior                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes³ Validar data menor que 24:00, nao permitir incluir duas    ³±±
±±³          ³ Linhas iguais na mesma getdados e validar se o medico ja   ³±±
±±³          ³ tem outros compromissos no mesmo dia e hora digitada.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Plsa791Hr(nCampo)
Local nPosCpoE := 0
Local nPosCpoS := 0
Local nPosDia  := 0           
Local nI
nPosCpoE       := oBrwBB7:PLRetPos("BB7_HORENT")
nPosCpoS       := oBrwBB7:PLRetPos("BB7_HORSAI")
nPosDia        := oBrwBB7:PLRetPos("BB7_DIA")
If nCampo == 1      // BB7_HORENT    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Hora nao pode estar fora desta faixa 			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(Left(M->BB7_HORENT,2) <= "24" .and. Right(M->BB7_HORENT,2) <= "59")
		//Hora invalida              
		HELP(" ",1,"PLSA360HR1")
		Return(.F.)                           
	Endif
	For nI := 1 to Len(oBrwBB7:aCols)
		If oBrwBB7:nOpcx == 4 // Validacao abaixo so e considerada na alteracao...
			If nI == oBrwBB7:Linha() .or. M->BB7_DIA # oBrwBB7:aCols[nI,nPosDia] .or. oBrwBB7:aCols[nI,oBrwBB7:ColDel()]
				Loop
			EndIf
		Endif                                                 
/*		
	  	If 	(M->BB7_DIA == oBrwBB7:aCols[nI,nPosDia] 	.and.;
		 	M->BB7_HORENT >= oBrwBB7:aCols[nI,nPosCpoE].and.;
		 	M->BB7_HORENT <= oBrwBB7:aCols[nI,nPosCpoS]) 
			HELP(" ",1,"PLSA360HR1")
			Return .F.
		EndIf
*/		
	Next
ElseIf nCampo == 2

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a Hora for em branco ignora a validacao		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(Alltrim(StrTran(M->BB7_HORSAI,":","")))
		Return(.T.)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Hora nao pode estar fora desta faixa 			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(Left(M->BB7_HORENT,2) <= "24" .and. Right(M->BB7_HORENT,2) <= "59")
		HELP(" ",1,"PLSA360HR1") 	//Hora invalida          
		Return(.F.)
	Endif

	If M->BB7_HORSAI <= M->BB7_HORENT
		HELP(" ",1,"PLSA360HR2")
		Return .F.
	EndIf
	For nI := 1 to Len(oBrwBB7:aCols)
		If oBrwBB7:nOpcx == 4
			If nI == oBrwBB7:Linha() .or. M->BB7_DIA # oBrwBB7:aCols[nI,nPosDia] .or. oBrwBB7:aCols[nI,oBrwBB7:ColDel()]
				Loop
			EndIf
		Endif           
		If ! ( ( oBrwBB7:aCols[nI,PLRETPOS("BB7_CODINT",oBrwBB7:aHeader,.F.)] == cCodInt ) .And. ;
               ( oBrwBB7:aCols[nI,PLRETPOS("BB7_CODLOC",oBrwBB7:aHeader,.F.)] == cCodLoc ) .And. ;
               ( oBrwBB7:aCols[nI,PLRETPOS("BB7_CODESP",oBrwBB7:aHeader,.F.)] == cCodEsp ) .And. ;
               ( oBrwBB7:aCols[nI,PLRETPOS("BB7_CODSUB",oBrwBB7:aHeader,.F.)] == cCodSub ) )
            Loop
        Endif    
/*		
		If 	(M->BB7_DIA == oBrwBB7:aCols[nI,nPosDia]	.and.;
			M->BB7_HORSAI >= oBrwBB7:aCols[nI,nPosCpoE].and.; 
			M->BB7_HORSAI <= oBrwBB7:aCols[nI,nPosCpoS]) 
			HELP(" ",1,"PLSA360HR1")
			Return .F.
		EndIf
*/		
	Next
Elseif 	nCampo == 3
	For nI := 1 to Len(oBrwBB7:aCols)
		If oBrwBB7:nOpcx == 4
			If nI == oBrwBB7:Linha() .or. M->BB7_DIA # oBrwBB7:aCols[nI,nPosDia] .or. oBrwBB7:aCols[nI,oBrwBB7:ColDel()]
				Loop
			EndIf
		Endif
		If 	(M->BB7_DIA == oBrwBB7:aCols[nI,nPosDia]	 .and.;
			M->BB7_HORSAI >= oBrwBB7:aCols[nI,nPosCpoE] .and.; 
			M->BB7_HORSAI <= oBrwBB7:aCols[nI,nPosCpoS]).And.	! Empty(M->BB7_HORSAI)
			HELP(" ",1,"PLSA360HR1")
			Return .F.
		EndIf
		If 	(M->BB7_DIA == oBrwBB7:aCols[nI,nPosDia] 	.and.;
		 	M->BB7_HORENT >= oBrwBB7:aCols[nI,nPosCpoE].and.;
		 	M->BB7_HORENT <= oBrwBB7:aCols[nI,nPosCpoS]) .And. ! Empty(M->BB7_HORENT)
			HELP(" ",1,"PLSA360HR1")
			Return .F.
		EndIf
	Next
EndIf
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS791cls ºAutor  ³Geraldo Felix Juniorº Data ³  26-07-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Limpa a agenda posicionada...                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS791CLS()
LOCAL nCnt

LOCAL nPosCodInt	:= PLRETPOS("BB7_CODINT",aCabBB7,.F.)
LOCAL nPosCodEsp	:= PLRETPOS("BB7_CODESP",aCabBB7,.F.)
LOCAL nPosCodLoc	:= PLRETPOS("BB7_CODLOC",aCabBB7,.F.)
LOCAL nPosHorIni	:= PLRETPOS("BB7_HORENT",aCabBB7,.F.)
LOCAL nPosHorFin	:= PLRETPOS("BB7_HORSAI",aCabBB7,.F.)
LOCAL nPosExcIni	:= PLRETPOS("BB7_EXCINI",aCabBB7,.F.)
LOCAL nPosExcFin	:= PLRETPOS("BB7_EXCFIN",aCabBB7,.F.)
LOCAL nPosPltIni	:= PLRETPOS("BB7_PLTINI",aCabBB7,.F.)
LOCAL nPosPltFin	:= PLRETPOS("BB7_PLTFIN",aCabBB7,.F.)
LOCAL nPosAgeExt	:= PLRETPOS("BB7_EXTRA" ,aCabBB7,.F.)
LOCAL nPosObsDia	:= PLRETPOS("BB7_OBSDIA",aCabBB7,.F.)
LOCAL nPosInterv	:= PLRETPOS("BB7_INTERV",aCabBB7,.F.)

If Aviso(STR0036,STR0022,{STR0046,STR0047}) <> 1	 //"Agenda."###"Deseja realmente Lipar esta agenda?"###"Sim"###"Nao"    
	Return()
Endif

For nCnt := 1 To Len(oBrwBB7:aCols)    
	If oBrwBB7:aCols[nCnt,nPosCodInt] == cCodInt .and. oBrwBB7:aCols[nCnt,nPosCodEsp] == cCodEsp .and.;
	   oBrwBB7:aCols[nCnt,nPosCodLoc] == cCodLoc //.and. oBrwBB7:aCols[nCnt,nPosDia] < Alltrim(Str(Day(dDataBase)))
		oBrwBB7:aCols[nCnt,nPosHorIni] := CriaVar("BB7_HORENT")
		oBrwBB7:aCols[nCnt,nPosHorFin] := CriaVar("BB7_HORSAI")
		oBrwBB7:aCols[nCnt,nPosExcIni] := CriaVar("BB7_EXCINI")
		oBrwBB7:aCols[nCnt,nPosExcFin] := CriaVar("BB7_EXCFIN")
		oBrwBB7:aCols[nCnt,nPosPltIni] := CriaVar("BB7_PLTINI")
		oBrwBB7:aCols[nCnt,nPosPltFin] := CriaVar("BB7_PLTFIN")
		oBrwBB7:aCols[nCnt,nPosAgeExt] := CriaVar("BB7_EXTRA")
		oBrwBB7:aCols[nCnt,nPosObsDia] := CriaVar("BB7_OBSDIA")
		oBrwBB7:aCols[nCnt,nPosInterv] := CriaVar("BB7_INTERV")		
	Endif
Next

aChave := {}
aadd(aChave,{"BB7_CODIGO",BAU->BAU_CODIGO})
aadd(aChave,{"BB7_ANO",cAno})
aadd(aChave,{"BB7_MES",cMes})
oBrwBB7:Grava(aChave,,.F.) 

oBrwBB7:Atualiza()

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS791MIRRORºAutor  ³Geraldo Felix Juniorº Data ³  27-07-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Espelha uma agenda para todo o mes ou para toda a semana...  º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS791MIRROR()
Local nCnt
Local nCols
Local nFirstCol
Local nAux
LOCAL nOpcao  
LOCAL nPosCodInt	:= PLRETPOS("BB7_CODINT",aCabBB7,.F.)
LOCAL nPosCodEsp	:= PLRETPOS("BB7_CODESP",aCabBB7,.F.)
LOCAL nPosCodLoc	:= PLRETPOS("BB7_CODLOC",aCabBB7,.F.)
LOCAL nPosDia		:= PLRETPOS("BB7_DIA"   ,aCabBB7,.F.)
LOCAL nPosCodSub	:= PLRETPOS("BB7_CODSUB",aCabBB7,.F.)
LOCAL nDiaMes		:= PLRETPOS("BB7_DIAMES",aCabBB7,.F.)

LOCAL nPosHorIni	:= PLRETPOS("BB7_HORENT",aCabBB7,.F.)
LOCAL nPosHorFin	:= PLRETPOS("BB7_HORSAI",aCabBB7,.F.)
LOCAL nPosExcIni	:= PLRETPOS("BB7_EXCINI",aCabBB7,.F.)
LOCAL nPosExcFin	:= PLRETPOS("BB7_EXCFIN",AcabBB7,.F.)
LOCAL nPosPltIni	:= PLRETPOS("BB7_PLTINI",aCabBB7,.F.)
LOCAL nPosPltFin	:= PLRETPOS("BB7_PLTFIN",AcabBB7,.F.)
LOCAL nPosAgeExt	:= PLRETPOS("BB7_EXTRA" ,AcabBB7,.F.)
LOCAL nPosObsDia	:= PLRETPOS("BB7_OBSDIA",AcabBB7,.F.)
LOCAL nPosInterv	:= PLRETPOS("BB7_INTERV",AcabBB7,.F.) 

LOCAL oDlgMrr
LOCAL oTipo
LOCAL nTipo
LOCAL Bold
LOCAL cCab
LOCAL oBmp
LOCAL oChkSab
LOCAL oChkDom
LOCAL oChkExt 
LOCAL lChkSab		:= .F.
LOCAL lChkDom		:= .F.
LOCAL lChkExt		:= .F.
LOCAL oBtnBaca
LOCAL lOk			:= .F.
LOCAL lGrava 		:= .T.
LOCAL lCheck		:= .T.
LOCAL _aAux_ := {}

DEFINE MSDIALOG oDlgMrr FROM 0,0 TO 210,300 TITLE STR0003 Of oMainWnd PIXEL //"Espelhar agenda"
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

@ 0, 0 BITMAP oBmp RESNAME "PARAINICIAL" oF oDlgMrr SIZE 150,030 NOBORDER WHEN .F. PIXEL
@ 36 ,05  TO 37 ,150 LABEL '' OF oDlgMrr PIXEL

@ 28 ,10  SAY cCab Of oDlgMrr PIXEL SIZE 130 ,9 FONT oBold 
@ 42 ,05  SAY STR0023 Of oDlgMrr PIXEL SIZE 060,140 //"Tipo de espelhamento -"

@ 42, 65 RADIO oTipo VAR nTipo 3D SIZE 80,10 PROMPT "&1-" + STR0024,"&2-" + STR0025,"&3-" + STR0026; //"Para toda a semana"###"Para todo o mes"###"Estes dias para todo o Mes"
													 ON CHANGE (Iif(nTipo==3,(lCheck:= lChkSab := lChkDom := .F.),lCheck:=.T.),oDlgMrr:Refresh(),oChkSab:SetFocus()) OF oDlgMrr PIXEL 

@ 080,005 CHECKBOX oChkSab VAR lChkSab PROMPT STR0027  			When lCheck PIXEL SIZE 120, 09 OF oDlgMrr //"Inclusive Sabados"
@ 080,070 CHECKBOX oChkDom VAR lChkDom PROMPT STR0028 			When lCheck PIXEL SIZE 120, 09 OF oDlgMrr //"Inclusive Domingos"
@ 090,005 CHECKBOX oChkExt VAR lChkExt PROMPT STR0029 				PIXEL SIZE 120, 09 OF oDlgMrr //"Inclusive Agendas Extras"

DEFINE SBUTTON oBtnBaca FROM 090,090 TYPE 1 ACTION (lOk:=.T.,oDlgMrr:End()) OF oDlgMrr ENABLE PIXEL
DEFINE SBUTTON oBtnBaca FROM 090,120 TYPE 2 ACTION (lOk:=.F.,oDlgMrr:End()) OF oDlgMrr ENABLE PIXEL

ACTIVATE MSDIALOG oDlgMrr CENTERED

If lOk

	If nTipo == 1 // 1-Para toda a Semana
	
		If oBrwBB7:aCols[oBrwBB7:Linha(),nPosCodInt] == cCodInt .and. oBrwBB7:aCols[oBrwBB7:Linha(),nPosCodEsp] == cCodEsp .and.;
			oBrwBB7:aCols[oBrwBB7:Linha(),nPosCodLoc] == cCodLoc
			If !Empty(Alltrim(StrTran(oBrwBB7:aCols[oBrwBB7:Linha(),nPosHorIni],":",""))) .or.;
				!Empty(Alltrim(StrTran(oBrwBB7:aCols[oBrwBB7:Linha(),nPosPltIni],":","")))      
				nFirstCol := oBrwBB7:Linha()
				Aadd( _aAux_, Aclone(oBrwBB7:aCols[oBrwBB7:Linha()]))
			Endif
		Endif

		If Len(_aAux_) == 0
			MsgStop(STR0030) //"A agenda esta vazia. Por Favor, monte uma agenda para que possa ser espelhanda."
			Return()
		Endif    
		
		Do Case               
			Case oBrwBB7:aCols[nFirstCol,nPosDia] == '1'
				lChkDom := .T.
			Case oBrwBB7:aCols[nFirstCol,nPosDia] == '3' 
				nFirstCol := nFirstCol - 1
			Case oBrwBB7:aCols[nFirstCol,nPosDia] == '4'
				nFirstCol := nFirstCol - 2
			Case oBrwBB7:aCols[nFirstCol,nPosDia] == '5'
				nFirstCol := nFirstCol - 3             
			Case oBrwBB7:aCols[nFirstCol,nPosDia] == '6'
				nFirstCol := nFirstCol - 4
			Case oBrwBB7:aCols[nFirstCol,nPosDia] == '7'
				nFirstCol := nFirstCol - 5      
				lChkSab := .T.
		EndCase	   
		
		If nFirstCol > 1		
			If oBrwBB7:aCols[nFirstCol,nPosDia] <> '1' .And. lChkDom 
				nFirstCol := nFirstCol - 1
			EndIf             
		Else
			nFirstCol := 1
		EndIf
		
		For nCols := nFirstCol To Len(oBrwBB7:aCols)  
			If oBrwBB7:aCols[nCols,nPosCodInt] == cCodInt .and. oBrwBB7:aCols[nCols,nPosCodEsp] == cCodEsp .and.;
				oBrwBB7:aCols[nCols,nPosCodLoc] == cCodLoc
				
					lGrava := .T.
					
					If 	oBrwBB7:aCols[nCols,nPosDia] == '1' .and. !lChkDom
						lGrava := .F.                      
					ElseIf oBrwBB7:aCols[nCols,nPosDia] == '7' .and. !lChkSab
						lGrava := .F.
					Elseif  _aAux_[1,nPosAgeExt] == '1' .and. !lChkExt
						lGrava := .F.						
					Elseif PlsFeriado(STOD(cAno+cMes+oBrwBB7:aCols[nCols,nDiaMes]))
						lGrava := .F.						
					Endif
					
					If lGrava
						oBrwBB7:aCols[nCols,nPosHorIni] := _aAux_[1, nPosHorIni]
						oBrwBB7:aCols[nCols,nPosHorFin] := _aAux_[1, nPosHorFin]
						oBrwBB7:aCols[nCols,nPosExcIni] := _aAux_[1, nPosExcIni]
						oBrwBB7:aCols[nCols,nPosExcFin] := _aAux_[1, nPosExcFin]
						oBrwBB7:aCols[nCols,nPosPltIni] := _aAux_[1, nPosPltIni]
						oBrwBB7:aCols[nCols,nPosPltFin] := _aAux_[1, nPosPltFin]
						oBrwBB7:aCols[nCols,nPosAgeExt] := _aAux_[1, nPosAgeExt]
						oBrwBB7:aCols[nCols,nPosInterv] := _aAux_[1, nPosInterv]
						oBrwBB7:aCols[nCols,nPosObsDia] := _aAux_[1, nPosObsDia]
					EndIf                                                 
					
					If oBrwBB7:aCols[nCols,nPosDia] == '7'
						Exit
					EndIf	
			EndIf			
		Next

	ElseIf nTipo == 2
		For nCnt := 1 To Len(oBrwBB7:aCols)
			If oBrwBB7:aCols[nCnt,nPosCodInt] == cCodInt .and. oBrwBB7:aCols[nCnt,nPosCodEsp] == cCodEsp .and.;
				oBrwBB7:aCols[nCnt,nPosCodLoc] == cCodLoc
				If !Empty(Alltrim(StrTran(oBrwBB7:aCols[nCnt,nPosHorIni],":",""))) .or.;
					!Empty(Alltrim(StrTran(oBrwBB7:aCols[nCnt,nPosPltIni],":","")))
					Aadd( _aAux_, Aclone(oBrwBB7:aCols[nCnt]))
					Exit
				Endif
			Endif
		Next
		
		If Len(_aAux_) == 0
			MsgStop(STR0030) //"A agenda esta vazia. Por Favor, monte uma agenda para que possa ser espelhanda."
			Return()
		Endif
		
		For nCols := 1 To Len(oBrwBB7:aCols)
			If oBrwBB7:aCols[nCols,nPosCodInt] == cCodInt .and. oBrwBB7:aCols[nCols,nPosCodEsp] == cCodEsp .and.;
				oBrwBB7:aCols[nCols,nPosCodLoc] == cCodLoc //.and. oBrwBB7:aCols[nCnt,nPosDia] < Alltrim(Str(Day(dDataBase)))
				
				lGrava := .T.
				If 		oBrwBB7:aCols[nCols,nPosDia] == '7' .and. !lChkSab
					lGrava := .F.
				Elseif 	oBrwBB7:aCols[nCols,nPosDia] == '1' .and. !lChkDom
					lGrava := .F.
				Elseif  _aAux_[1,nPosAgeExt] == '1' .and. !lChkExt
					lGrava := .F.
					
				Elseif PlsFeriado(STOD(cAno+cMes+oBrwBB7:aCols[nCols,nDiaMes]))
					lGrava := .F.
					
				Endif
				
				If lGrava
					oBrwBB7:aCols[nCols,nPosHorIni] := _aAux_[1, nPosHorIni]
					oBrwBB7:aCols[nCols,nPosHorFin] := _aAux_[1, nPosHorFin]
					oBrwBB7:aCols[nCols,nPosExcIni] := _aAux_[1, nPosExcIni]
					oBrwBB7:aCols[nCols,nPosExcFin] := _aAux_[1, nPosExcFin]
					oBrwBB7:aCols[nCols,nPosPltIni] := _aAux_[1, nPosPltIni]
					oBrwBB7:aCols[nCols,nPosPltFin] := _aAux_[1, nPosPltFin]
					oBrwBB7:aCols[nCols,nPosAgeExt] := _aAux_[1, nPosAgeExt]
					oBrwBB7:aCols[nCols,nPosInterv] := _aAux_[1, nPosInterv]
					oBrwBB7:aCols[nCols,nPosObsDia] := _aAux_[1, nPosObsDia]
				Else
					oBrwBB7:aCols[nCols,nPosHorIni] := CriaVar("BB7_HORENT")
					oBrwBB7:aCols[nCols,nPosHorFin] := CriaVar("BB7_HORSAI")
					oBrwBB7:aCols[nCols,nPosExcIni] := CriaVar("BB7_EXCINI")
					oBrwBB7:aCols[nCols,nPosExcFin] := CriaVar("BB7_EXCFIN")
					oBrwBB7:aCols[nCols,nPosPltIni] := CriaVar("BB7_PLTINI")
					oBrwBB7:aCols[nCols,nPosPltFin] := CriaVar("BB7_PLTFIN")
					oBrwBB7:aCols[nCols,nPosAgeExt] := CriaVar("BB7_EXTRA")
					oBrwBB7:aCols[nCols,nPosInterv] := CriaVar("BB7_INTERV")
					oBrwBB7:aCols[nCols,nPosObsDia] := CriaVar("BB7_OBSDIA")
				Endif
				
			Endif
		Next
		
	Elseif nTipo == 3
		For nCnt := 1 To Len(oBrwBB7:aCols)
			If oBrwBB7:aCols[nCnt,nPosCodInt] == cCodInt .and. oBrwBB7:aCols[nCnt,nPosCodEsp] == cCodEsp .and.;
				oBrwBB7:aCols[nCnt,nPosCodLoc] == cCodLoc
				If (nPos := Ascan( _aAux_, {|x| x[nPosDia] == oBrwBB7:aCols[nCnt,nPosDia]})) == 0
					Aadd( _aAux_, oBrwBB7:aCols[nCnt])
				Endif
			Endif
		Next
		
		If Len(_aAux_) == 0
			MsgStop(STR0030) //"A agenda esta vazia. Por Favor, monte uma agenda para que possa ser espelhanda."
			Return()
		Endif
		
		For nAux := 1 To Len(_aAux_)
			For nCols := 1 To Len(oBrwBB7:aCols)
				lGrava := .T.
				If oBrwBB7:aCols[nCols,nPosCodInt] == cCodInt .and. oBrwBB7:aCols[nCols,nPosCodEsp] == cCodEsp .and.;
					oBrwBB7:aCols[nCols,nPosCodLoc] == cCodLoc .and. oBrwBB7:aCols[nCols,nPosDia]    == _aAux_[nAux,nPosDia]
					
					If  _aAux_[nAux,nPosAgeExt] == '1' .and. !lChkExt
						lGrava := .F.
						
					Elseif PlsFeriado(STOD(cAno+cMes+oBrwBB7:aCols[nCols,nDiaMes]))
						lGrava := .F.
						
					Endif
					
					If lGrava
						oBrwBB7:aCols[nCols,nPosHorIni] := _aAux_[nAux, nPosHorIni]
						oBrwBB7:aCols[nCols,nPosHorFin] := _aAux_[nAux, nPosHorFin]
						oBrwBB7:aCols[nCols,nPosExcIni] := _aAux_[nAux, nPosExcIni]
						oBrwBB7:aCols[nCols,nPosExcFin] := _aAux_[nAux, nPosExcFin]
						oBrwBB7:aCols[nCols,nPosPltIni] := _aAux_[nAux, nPosPltIni]
						oBrwBB7:aCols[nCols,nPosPltFin] := _aAux_[nAux, nPosPltFin]
						oBrwBB7:aCols[nCols,nPosAgeExt] := _aAux_[nAux, nPosAgeExt]
						oBrwBB7:aCols[nCols,nPosInterv] := _aAux_[nAux, nPosInterv]
						oBrwBB7:aCols[nCols,nPosObsDia] := _aAux_[nAux, nPosObsDia]
					Endif
				Endif
			Next
		Next
	Endif
Endif

oBrwBB7:Atualiza()
aDadBB7 := aClone(oBrwBB7:aCols)
	
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS791MULTºAutor  ³Geraldo Felix Juniorº Data ³  28-07-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Multiplicador de agendas... gera agenda para os proximos   º±±
±±º          ³meses baseado na agenda atualmente posiconada...            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS791MULT(nOpcx)                                        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define as variaveis locais...        			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nMeses
Local nCnt
Local nI
LOCAL oDlgMul      
LOCAL oBold
LOCAL oBmp
LOCAL oBtnBaca
LOCAL nRegBB7	
LOCAL lOk 		:= .F.
LOCAL lGrava	:= .T.	
LOCAL lGravou	:= .F.
LOCAL nCntMes 	:= 0
LOCAL nVarAno 	:= ''
LOCAL nQuant	:= 0
LOCAL nFields	:= 0
LOCAL aFields	:= {}
LOCAL aWeeks	:= {}
LOCAL cDiaMes   := ''
LOCAL cVarDia 	:= ''
LOCAL nExtra	:= 1
LOCAL cFilial   := ''

LOCAL nCodIntPai	:= PLRETPOS("BAX_CODINT",aCabBAX,.F.)
LOCAL nCodEspPai	:= PLRETPOS("BAX_CODESP",aCabBAX,.F.)
LOCAL nCodLocPai	:= PLRETPOS("BAX_CODLOC",aCabBAX,.F.)
LOCAL nCodSubPai	:= PLRETPOS("BAX_CODSUB",aCabBAX,.F.)
LOCAL cAgeExt
LOCAL lGraExt		:= .F.
LOCAL aArea := BB7->( GetArea() )

PRIVATE cHorEnt
PRIVATE cHorSai 
PRIVATE cExcIni
PRIVATE cExcFin
PRIVATE cPltIni
PRIVATE cPltFin
				      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza variaveis do grupo de perguntas...   	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("PL791M",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define dialogo...                             	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgMul FROM 0,0 TO 180,400 TITLE STR0003 Of oMainWnd PIXEL //"Espelhar agenda"
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

@ 001 ,02  TO 060 ,200 LABEL '' OF oDlgMul PIXEL

@ 05 ,05  SAY STR0031	Of oDlgMul PIXEL SIZE 200,010 //"    Esta rotina tem como objetivo gerar agendas para os proximos meses	"
@ 15 ,05  SAY STR0032	Of oDlgMul PIXEL SIZE 200,010 //"de acordo com os paramentros e com base na agenda atualmente 			"
@ 25 ,05  SAY STR0033 	Of oDlgMul PIXEL SIZE 200,010 //"posicionada.                                                      		"
@ 35 ,05  SAY STR0034 	Of oDlgMul PIXEL SIZE 200,010 //"    ATENCAO: Ao ser confirmada, a rotina gravara fisicamente as novas 	"
@ 45 ,05  SAY STR0035 	Of oDlgMul PIXEL SIZE 200,010 //"agendas.                                                          		"

DEFINE SBUTTON oBtnBaca FROM 065,110 TYPE 5 ACTION (Pergunte("PL791M",.T.))		OF oDlgMul ENABLE PIXEL
DEFINE SBUTTON oBtnBaca FROM 065,140 TYPE 1 ACTION (lOk:=.T.,oDlgMul:End()) 	OF oDlgMul ENABLE PIXEL
DEFINE SBUTTON oBtnBaca FROM 065,170 TYPE 2 ACTION (lOk:=.F.,oDlgMul:End()) 	OF oDlgMul ENABLE PIXEL

ACTIVATE MSDIALOG oDlgMul CENTERED                                              
    
nQuant 	:= mv_par01 
nExtra	:= mv_par02

If lOk
	If nOpcx != K_Visualizar .and. oBrwBB7:lAltered
		If Aviso(STR0036,STR0037,{STR0038,STR0039}) == 1 //"Agenda."###"Os dados dessa agenda nao estao salvos! Nao sera possivel continuar sem que os dados sejam salvos!"###"&Salvar"###"Sai&r"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Trata agendas deletadas...                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			For nI := 1 To Len(oBrwBB7:aCols)
				If Empty(oBrwBB7:FieldGet("BB7_HORENT",nI)) .and.;
				   Empty(oBrwBB7:FieldGet("BB7_HORSAI",nI)) .and.;
				   Empty(oBrwBB7:FieldGet("BB7_PLTINI",nI)) .and.;
				   Empty(oBrwBB7:FieldGet("BB7_PLTFIN",nI))
				   
				   oBrwBB7:aCols[nI, (Len(oBrwBB7:aHeader)+1)] := .T.   // Deleta linha
				Endif
			Next		
			
			aChave := {}
			aadd(aChave,{"BB7_CODIGO",BAU->BAU_CODIGO})
			aadd(aChave,{"BB7_ANO",cAno})
			aadd(aChave,{"BB7_MES",cMes})      
			oBrwBB7:Grava(aChave,,.F.)
			oBrwBB7:lAltered := .F.
		Else
			Return()
		Endif
	EndIf
	
	nCntMes := Val(cMes)
	cVarAno := cAno
	For nMeses := 1 To nQuant
		
		If (nCntMes+1) > 12
			nCntMes := 01
			cVarAno	:= Alltrim(Str((Val(cAno)+1)))
		Else
			nCntMes ++
		Endif
		
		cVarMes := StrZero(nCntMes,2)
		lGrava 	:= .T.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem as posicoes dos campos no array aCols		   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodint := aDadBAX[oBrwBax:Linha(),nCodIntPai]
		cCodEsp := aDadBAX[oBrwBax:Linha(),nCodEspPai]
		cCodLoc := aDadBAX[oBrwBax:Linha(),nCodLocPai]
					                                                                    
		BB7->( dbSetorder(04) )
		If BB7->(DbSeek(xFilial	("BB7")+BAU->BAU_CODIGO+cVarAno+cVarMes+cCodLoc+cCodEsp))
			MsgAlert(STR0040+cVarMes+"!") //"Ja existe agenda para o mes "
			lGrava := .F.
		Endif
		
		If lGrava
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica quantos dias tem o mes      			   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nDias := PLSDIAMES(nCntMes, cVarAno)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obtem as posicoes dos campos no array aCols		   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCodint := aDadBAX[oBrwBax:Linha(),nCodIntPai]
			cCodEsp := aDadBAX[oBrwBax:Linha(),nCodEspPai]
			cCodLoc := aDadBAX[oBrwBax:Linha(),nCodLocPai]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicia sempre na primeira semana do mes			   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nSemana := 1
			aWeeks	:= {}
			nCntDias:= 1
			
			BB7->( dbSetorder(04) )
			BB7->(dbSeek(xFilial("BB7")+BAU->BAU_CODIGO+cAno+cMes+cCodLoc+cCodEsp))
			While !BB7->(Eof()) .and. BB7->(BB7_CODIGO+BB7_ANO+BB7_MES+BB7_CODLOC+BB7_CODESP) == ;
				BAU->BAU_CODIGO+cAno+cMes+cCodLoc+cCodEsp
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Armazeda os dados do registro...              	   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cHorEnt := BB7->BB7_HORENT
				cHorSai := BB7->BB7_HORSAI
				cExcIni	:= BB7->BB7_EXCINI
				cExcFin	:= BB7->BB7_EXCFIN
				cPltIni	:= BB7->BB7_PLTINI
				cPltFin	:= BB7->BB7_PLTFIN
				cInterv := BB7->BB7_INTERV
				cAgeExt	:= BB7->BB7_EXTRA
				cFilial := BB7->BB7_FILIAL                              
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ignora dias em branco...               			   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								                                        
				If Empty(cHorEnt) .and. Empty(cHorSai) .and. Empty(cPltIni) .and. Empty(cPltFin)
					BB7->( dbSkip() )
					Loop
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Obtem dados sobre a semana do mes...   			   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (nPos:=Ascan(aWeeks, {|x| x[1] == BB7->BB7_DIA})) # 0
					aWeeks[nPos,2] ++
				Else
					Aadd( aWeeks, {BB7->BB7_DIA,1} )
					nPos := Len(aWeeks)
				Endif
				
				nCntDias := 1
				lGravou	 := .F.
				nRegBB7 := BB7->( Recno() )
				For nCnt := 1 To nDias
					dData  := cTod(StrZero(nCnt,2)+"/"+cVarMes+"/"+cVarAno)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Trata feriado...                       			   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
					If PlsFeriado(dData)
						Loop
					Endif
					
					lGraExt := .T.
					If Alltrim(Str(Dow(dData))) == BB7->BB7_DIA
						If nCntDias == aWeeks[nPos,2]
						    If cAgeExt == "1" .and. nExtra <> 1
						    	lGraExt := .F.
						    Endif
						    If lGraExt
								BB7->( Reclock("BB7",.T.) )
									BB7->BB7_CODIGO	:= BAU->BAU_CODIGO
									BB7->BB7_DIAMES	:= StrZero(nCnt,2)
									BB7->BB7_DESDIA	:= PLSDIASEM(dData)
									BB7->BB7_FILIAL := cFilial
									BB7->BB7_HORENT	:= cHorEnt
									BB7->BB7_HORSAI	:= cHorSai
									BB7->BB7_EXCINI	:= cExcIni
									BB7->BB7_EXCFIN	:= cExcFin
									BB7->BB7_PLTINI	:= cPltIni
									BB7->BB7_PLTFIN	:= cPltFin
									BB7->BB7_INTERV := cInterv
									BB7->BB7_CODESP	:= cCodEsp
									BB7->BB7_CODINT	:= cCodInt
									BB7->BB7_CODLOC	:= cCodLoc
									BB7->BB7_CODSUB	:= cCodSub
									BB7->BB7_MES	:= cVarMes
									BB7->BB7_ANO	:= cVarAno
									BB7->BB7_DIA	:= Alltrim(Str(Dow(dData)))
									lGravou := .T.
								BB7->( MsUnlock() )
								Exit
							Endif
						Else
							nCntDias ++
						Endif
					Endif
				Next                                       

				BB7->( dbGoto(nRegBB7) )
				BB7->( dbSkip() )
			Enddo
		Endif
	Next
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³uCopy     ºAutor  ³Geraldo Felix Juniorº Data ³  08-01-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Copia registro da agenda...                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function uCopiar()
LOCAL nPosHorIni	:= PLRETPOS("BB7_HORENT",aCabBB7,.F.)
LOCAL nPosHorFin	:= PLRETPOS("BB7_HORSAI",aCabBB7,.F.)
LOCAL nPosExcIni	:= PLRETPOS("BB7_EXCINI",aCabBB7,.F.)
LOCAL nPosExcFin	:= PLRETPOS("BB7_EXCFIN",AcabBB7,.F.)
LOCAL nPosPltIni	:= PLRETPOS("BB7_PLTINI",AcabBB7,.F.)
LOCAL nPosPltFin	:= PLRETPOS("BB7_PLTFIN",AcabBB7,.F.)
LOCAL nPosObsDia	:= PLRETPOS("BB7_OBSDIA",AcabBB7,.F.)
LOCAL nPosInterv	:= PLRETPOS("BB7_INTERV",AcabBB7,.F.)

LOCAL aDados		:= aClone(oBrwBB7:aCols)
LOCAL nLinha		:= oBrwBB7:Linha()
aCopy := {	aDados[nLinha,nPosHorIni],aDados[nLinha,nPosHorFin],;
			aDados[nLinha,nPosExcIni],aDados[nLinha,nPosExcFin],;
		  	aDados[nLinha,nPosPltIni],aDados[nLinha,nPosPltFin],;
		  	aDados[nLinha,nPosObsDia],aDados[nLinha,nPosInterv] }
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³uColar    ºAutor  ³Geraldo Felix Juniorº Data ³  08-01-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cola o registro amazenado pela copia...                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function uColar()
LOCAL nPosHorIni	:= PLRETPOS("BB7_HORENT",aCabBB7,.F.)
LOCAL nPosHorFin	:= PLRETPOS("BB7_HORSAI",aCabBB7,.F.)
LOCAL nPosExcIni	:= PLRETPOS("BB7_EXCINI",aCabBB7,.F.)
LOCAL nPosExcFin	:= PLRETPOS("BB7_EXCFIN",AcabBB7,.F.)
LOCAL nPosPltIni	:= PLRETPOS("BB7_PLTINI",AcabBB7,.F.)
LOCAL nPosPltFin	:= PLRETPOS("BB7_PLTFIN",AcabBB7,.F.)
LOCAL nPosObsDia	:= PLRETPOS("BB7_OBSDIA",AcabBB7,.F.)
LOCAL nPosInterv	:= PLRETPOS("BB7_INTERV",AcabBB7,.F.)
LOCAL nLinha		:= oBrwBB7:Linha()

If !Empty(oBrwBB7:aCols[nLinha,nPosHorIni]) .or. !Empty(oBrwBB7:aCols[nLinha, nPosPltIni])
	If Aviso(STR0041,STR0042,{STR0043,STR0044}) == 2 //"Agenda!"###"Este dia ja possui uma agenda cadastra. O que deseja fazer?"###"Sobrepor"###"Cancelar"
		Return()
	Endif
Elseif Len(aCopy) == 0
	Return()
Endif

oBrwBB7:aCols[nLinha,nPosHorIni] := aCopy[1]
oBrwBB7:aCols[nLinha,nPosHorFin] := aCopy[2]
oBrwBB7:aCols[nLinha,nPosExcIni] := aCopy[3]
oBrwBB7:aCols[nLinha,nPosExcFin] := aCopy[4]
oBrwBB7:aCols[nLinha,nPosPltIni] := aCopy[5]
oBrwBB7:aCols[nLinha,nPosPltFin] := aCopy[6]
oBrwBB7:aCols[nLinha,nPosObsDia] := aCopy[7] 
oBrwBB7:aCols[nLinha,nPosInterv] := aCopy[8] 
        
aDadBB7 := aClone(oBrwBB7:aCols)
oBrwBB7:Atualiza()
oBrwBB7:SetPos(nLinha)

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA791AVANCA   ºAutor  ³Geraldo Felix Juniorº Data ³  08-09-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Avanca ou volta mes na agenda medica....                         º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS791AVANCA(lTipo,nOpcx,Obj1,oBj2)
LOCAL cMovMes 
Local nCols
Local nCnt
Local nI
LOCAL nCodIntPai	:= PLRETPOS("BAX_CODINT",aCabBAX,.F.)
LOCAL nCodEspPai	:= PLRETPOS("BAX_CODESP",aCabBAX,.F.)
LOCAL nCodLocPai	:= PLRETPOS("BAX_CODLOC",aCabBAX,.F.)
LOCAL nCodSubPai	:= PLRETPOS("BAX_CODSUB",aCabBAX,.F.)
LOCAL nPos			:= 0

If nOpcx != K_Visualizar .and. oBrwBB7:lAltered
	If Aviso(STR0036,STR0045,{STR0046,STR0047}) == 1	 //"Agenda."###"Deseja salvar as alteracoes na agenda?"###"Sim"###"Nao"
		aChave := {}
		aadd(aChave,{"BB7_CODIGO",BAU->BAU_CODIGO})
		aadd(aChave,{"BB7_ANO",cAno})
		aadd(aChave,{"BB7_MES",cMes})
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Trata agendas deletadas...                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		For nI := 1 To Len(oBrwBB7:aCols)
			If Empty(oBrwBB7:FieldGet("BB7_HORENT",nI)) .and.;
			   Empty(oBrwBB7:FieldGet("BB7_HORSAI",nI)) .and.;
			   Empty(oBrwBB7:FieldGet("BB7_PLTINI",nI)) .and.;
			   Empty(oBrwBB7:FieldGet("BB7_PLTFIN",nI))
			   
			   oBrwBB7:aCols[nI, (Len(oBrwBB7:aHeader)+1)] := .T.   // Deleta linha
			Endif
		Next
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o mes inteiro foi excluido ou Alterado, elimino da matriz auxiliar tambem... ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		If (nPos := Ascan(aAgeAux, {|x| x[1] == cAno+cMes})) > 0
		 	aAgeAux[nPos][1] := ''
		 	aAgeAux[nPos][2] := {}
		 	aAgeAux[nPos][3] := {}
		Endif 

		oBrwBB7:Grava(aChave,,.F.)
	Endif
EndIf

If lTipo
	cMes := StrZero(Val(cMes)+1,2)
Else
	cMes := StrZero(Val(cMes)-1,2)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta data caso mude o ano...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cMes > '12'
	cAno := Alltrim(Str(Val(cAno)+1))
	cMes := '01'
Elseif cMes < '01'
	cAno := Alltrim(Str(Val(cAno)-1))
	cMes := '12'
Endif	       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O foco tem que estar na getdados pai antes de avancar...            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwBAX:oBrowse:oBrowse:Setfocus()       

aDadBB7 := {}
aCabBB7 := {}
aTrbBB7 := {}
aCols	:= {}
aHeader	:= {}

oBrwBB7:aHeader		:= {}
oBrwBB7:aCols 		:= {}
oBrwBB7:AVETTRAB   	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Agenda RDAxOperadoraxLocal de atendimentoxEspecialidade             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BB7" TO aCabBB7 For !Alltrim(SX3->X3_CAMPO) $ "BB7_MES,BB7_ANO,BB7_ORIGEM,BB7_CODIGO"
BB7->(DbSetOrder(3))
If !BB7->(DbSeek(xFilial("BB7")+BAU->BAU_CODIGO+cAno+cMes))
	If nOpcx == K_Visualizar
    	MsgStop(STR0048) //"Nao ha agenda cadastrada"
      	Return
	EndIf  
	nOpcx := K_Alterar
	
	If (nPos := Ascan(aAgeAux, {|x| x[1] == cAno+cMes})) == 0
		aDadBB7 := PLS791VET()[1]
		aTrbBB7 := PLS791VET()[2]
	Else
		aDadBB7 := aClone(aAgeAux[nPos,2])
		aTrbBB7 := aClone(aAgeAux[nPos,3])
	Endif
Else                  
	Store COLS "BB7" TO aDadBB7 FROM aCabBB7 VETTRAB aTrbBB7 ;
	While BB7->(BB7_FILIAL+BB7_CODIGO+BB7_ANO+BB7_MES) == xFilial("BB7")+BAU->BAU_CODIGO+cAno+cMes

    nDias := PLSDIAMES(Val(cMes),cAno)
	For nCols := 1 To Len(aDadBAX)
		cCodint := aDadBAX[nCols,nCodIntPai]
		cCodEsp := aDadBAX[nCols,nCodEspPai]
		cCodLoc := aDadBAX[nCols,nCodLocPai]
	    
		If (nPos := Ascan(aDadBB7, {|x| x[13]+x[14]+x[15] == cCodEsp+cCodInt+cCodLoc })) == 0
			For nCnt := 1 To nDias
				dData := cTod(StrZero(nCnt,2)+"/"+cMes+"/"+cAno)
				Aadd(aDadBB7, {	StrZero(nCnt,2),;
					PLSDIASEM(dData),;
					CriaVar("BB7_HORENT"),;
					CriaVar("BB7_HORSAI"),;
					CriaVar("BB7_EXCINI"),;
					CriaVar("BB7_EXCFIN"),;	
					CriaVar("BB7_PLTINI"),;
					CriaVar("BB7_PLTFIN"),;
					CriaVar("BB7_INTERV"),;
					CriaVar("BB7_EXTRA") ,;
					CriaVar("BB7_OBSDIA"),;
					CriaVar("BB7_STATUS"),;
					CriaVar("BB7_CODESP"),;
					CriaVar("BB7_CODINT"),;
					CriaVar("BB7_CODLOC"),;
					CriaVar("BB7_CODSUB"),;
					Alltrim(Str(Dow(dData))),;
					.F.})		
				Aadd(aTrbBB7, 0)
			Next
		Else
			If (nPos := Ascan(aAgeAux, {|x| x[1] == cAno+cMes})) == 0
				aDadBB7 := PLS791VET()[1]
				aTrbBB7 := PLS791VET()[2]
				Aadd(aAgeAux, {cAno+cMes,aDadBB7,aTrbBB7})
			Else
				aDadBB7 := aClone(aAgeAux[nPos,2])
				aTrbBB7 := aClone(aAgeAux[nPos,3])
			Endif
			nOpcx := K_Alterar
			lInclui := .T.
			lAltera := .F.			
			
			Exit
		Endif			
	Next
	
	If nOpcx != K_Visualizar
		nOpcx := K_Alterar
		lInclui := .F.
		lAltera := .T.
	EndIf	
Endif

If Len(aDadBB7) == 0 
   If nOpcx == K_Visualizar
      MsgStop(STR0049) //"Agenda nao cadastradas!"
      Return
   EndIf
	If (nPos := Ascan(aAgeAux, {|x| x[1] == cAno+cMes})) == 0
		aDadBB7 := PLS791VET()[1]
		aTrbBB7 := PLS791VET()[2]
		Aadd(aAgeAux, {cAno+cMes,aDadBB7,aTrbBB7})
	Else
		aDadBB7 := aClone(aAgeAux[nPos,2])
		aTrbBB7 := aClone(aAgeAux[nPos,3])
	Endif
	nOpcx := K_Alterar
	lInclui := .T.
	lAltera := .F.
EndIf                             

oBrwBB7:aHeader 	:= aClone(aCabBB7)
oBrwBB7:aCols		:= aClone(aDadBB7)
oBrwBB7:AVETTRAB	:= aClone(aTrbBB7)

// Reposiciona o nAt para ser usado na funcao Linha()
// no Voltar e Avançar
oBrwBB7:oBrowse:oBrowse:nAt:= Len(oBrwBB7:aCols)

Eval(oBrwBAX:bGotFocus)

oBrwBB7:lAltered := .F.       
oBj2:cCaption := Alltrim(cCadastro)+Space(05)+" - "+Space(05)+"[ " + STR0014+cMes+Space(10)+STR0015+cAno+" ]" //"Mes: "###"Ano: "
oBj2:Refresh()

Return()          
                  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL791FILTROºAutor  ³Geraldo Felix Juniorº Data ³  11-02-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Filtra medicos por local de atendimento e especialidade...  º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PL791FILTRO()                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL791FILTRO()
LOCAL cSql := ''
LOCAL cBAUName := RetSqlName("BAU")
LOCAL cBB8Name := RetSqlName("BB8")
LOCAL cBAXName := RetSqlName("BAX")
LOCAL cUsuario := retcodusr()  // ---> Codigo do Usuario
                                                                         
If BAU->(FieldPos("BAU_FILTRO")) > 0 .And. BAU->(FieldPos("BAU_USRFIL")) > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa o filtro atual...                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
	cSql := "UPDATE "+cBAUName+" SET BAU_FILTRO = ' ', BAU_USRFIL = '' "
	cSql += "WHERE BAU_USRFIL = '"+cUsuario+"'"
	TcSqlExec(cSql)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona os registros baseado nos parametros...                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSql := "SELECT DISTINCT "+cBAUName+".R_E_C_N_O_ AS BAUREC FROM "+cBAUName+","+cBB8Name
	If !Empty(mv_par02)
		cSql += ","+cBAXName
	Endif
	cSql += " WHERE BB8_CODIGO = BAU_CODIGO "
	If  !Empty(mv_par02) 
		cSql += "AND BAX_CODIGO = BAU_CODIGO "
	Endif
	cSql += " AND BB8_LOCAL  = '"+mv_par01+"'"
	If  !Empty(mv_par02)  
		cSql += "AND BAX_CODESP = '"+mv_par02+"'"
	Endif
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBFIL",.F.,.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava os campos usados para o filtro...                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRBFIL->( dbGotop() )
	While  !TRBFIL->( Eof() )
		cSql := "UPDATE "+cBAUName+" SET BAU_FILTRO = '*', BAU_USRFIL = '"+cUsuario+"'"
		cSql += " WHERE "+cBAUName+".R_E_C_N_O_ = "+Alltrim(Str(TRBFIL->BAUREC))
		TcSqlExec(cSql)
		TRBFIL->( dbSkip() )
	Enddo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha area temporaria de trabalho...                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
	TRBFIL->( dbClosearea() )
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aplica o filtro na rede de atendimento...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BAU->( dbClearFilter() )

If BAU->(FieldPos("BAU_FILTRO")) > 0 .And. BAU->(FieldPos("BAU_USRFIL")) > 0
	cFilter := "@BAU_TIPPE = 'F' AND BAU_DATBLO = '       ' AND BAU_FILTRO = '*' AND BAU_USRFIL = '"+cUsuario+"'"
Else
	cFilter := "@BAU_TIPPE = 'F' AND BAU_DATBLO = '       '"
Endif 

dbSelectarea("BAU")
SET FILTER TO &cFilter
BAU->( dbSeek(xFilial("BAU")) )
        
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³05/01/2007³±±
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
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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
Private aRotina := {	{ STR0050	,'AxPesqui'		, 0 ,K_Pesquisar , 0, .F.},; //"Pesquisar"
						{ STR0051	,'PLS791AGE'	, 0 ,K_Visualizar, 0, Nil},; //"Vis.Agenda   "
						{ STR0017	,'PLS791AGE'	, 0 ,K_Alterar   , 0, Nil} } //"Agenda Medica"
Return(aRotina)

/*Valida a alteracao de registro na agenda verificando se ja existe consulta marcada*/
Function PLSVLDBB7()
Local lReturn	:= .T.
Local nLinha   := oBrwBB7:oBrowse:NAT
Local cCodRda	:= BAU->BAU_CODIGO
Local dDatAge	:= CTOD(M->BB7_DIAMES+"/"+cMes+"/"+cAno)
Local cHorEnt	:= M->BB7_HORENT//oBrwBB7:aCols[nLinha,aScan(oBrwBB7:aHeader,{|x| x[2] == "BB7_HORENT"})]
Local cHorSai	:= M->BB7_HORSAI//oBrwBB7:aCols[nLinha,aScan(oBrwBB7:aHeader,{|x| x[2] == "BB7_HORSAI"})] 
Local cPltIni	:= M->BB7_PLTINI//oBrwBB7:aCols[nLinha,aScan(oBrwBB7:aHeader,{|x| x[2] == "BB7_PLTINI"})]
Local cPltFin	:= M->BB7_PLTFIN//oBrwBB7:aCols[nLinha,aScan(oBrwBB7:aHeader,{|x| x[2] == "BB7_PLTFIN"})]

If oBrwBB7:NOPC <> 4//So valida na alteracao
	Return .T.
EndIf

If Empty(cCodRda) .Or. Empty(dDatAge)
	Return .T.
EndIf

cSql := "SELECT BBD_HORA FROM " + RetSqlName("BBD") + " WHERE BBD_FILIAL = '" + xFilial("BBD") + "' "
cSql += " AND BBD_CODIGO = '"+cCodRda+"' AND BBD_DATA = '"+DTOS(dDatAge)+"' AND BBD_STATUS <>'7'  AND D_E_L_E_T_ <> '*'"
cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

While !TRB1->(Eof()) .And. lReturn

	cHora := TRB1->BBD_HORA

	If (cHora < cHorEnt) .Or. (cHora > cHorSai .And. (Empty(cPltIni) .Or. cHora < cPltIni)) .Or. (!Empty(cPltFin) .And. cHora > cPltFin)
		lReturn := .F. 
		MsgInfo(STR0052,"TOTVS")//Existe(m) agendamento(s) marcado(s) no intervalo alterado. Alteração não será efetivada.
	EndIf
	
	TRB1->(dbSkip())

EndDo

TRB1->(DbCloseArea())

Return lReturn