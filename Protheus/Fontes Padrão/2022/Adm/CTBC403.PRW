#Include "Ctbc403.ch"
#Include "PROTHEUS.Ch"
#Include "TCBrowse.ch"
#INCLUDE "DBINFO.CH"

# Define cNomeArqConf 'CTBC403'

Static lCtbIsCube := FindFunction("CtbIsCube")

Static _oCTBC403

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o   ³ CTBC403  ³ Autor ³ TOTVS                 ³ Data ³ 23/06/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o³ Consulta de contas cont beis ( raz„o )                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ CTBC403 ()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBC403()
Local lGetFil	:= .F.

Local aPergs		:= {}  

Local cFilIni		:= ""
Local cFilFim		:= ""
Local cMacro		:= ""
Private cPerg		:= "CTBC403"
Private nQtdEntid	:= CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
Private aEntidades 	:= {}	//Array( nQtdEntid * 2)  
Private aEstrCT0	:= {}            
Private aParCubo	:= {}            
Private aSelFil		:= {}
Private cCadastro  	:= STR0001  //"Consulta ú Raz„o Anal¡tico"
Private aRotina 	:= MenuDef()

If !lCtbIsCube .And. !CtbIsCube()
	Return()
EndIf

DbSelectArea('CT0') 
DbSetOrder(1)
If DbSeek( xFilial('CT0') ) 
	While CT0->(!Eof()) .AND. xFilial('CT0') == CT0->CT0_FILIAL 
		AADD( aEstrCT0,{ CT0->CT0_ID,TamSx3(CT0->CT0_CPOCHV)[1],CT0->CT0_DSCRES,CT0->CT0_F3ENTI } )	
		AADD( aEntidades , Space(TamSx3(CT0->CT0_CPOCHV)[1]) )		// Parametro entidade inicio		 
		AADD( aEntidades , Space(TamSx3(CT0->CT0_CPOCHV)[1]) )		// Parametro entidade fim			
		CT0->(DbSkip())   
	EndDo
EndIf           
CtbParCubo(.t.,cNomeArqConf)

DbSelectArea("SX1")
DbSetOrder(1)

/////////////////////////////
// Data Inicial            //
// Data Final              //
// Moeda                   //
// Tipo de Saldo           //
// Descricao na moeda      //
// Cod Configuracao Livros //
// Consulta ate Entidades  //
// Seleciona Filiais       //
/////////////////////////////

If !Pergunte( cPerg , .T.)
	Return
EndIf	
If Val(Mv_par07) >= 1 .And. Val(Mv_par07) <= nQtdEntid
	// Seleciona filiais
	If mv_par08 == 1
		aSelFil := AdmGetFil()
		If Empty(aSelFil)
			Return
		EndIf
	End
		
	aParCubo := CtbCfCubo(Mv_par07,cNomeArqConf,.T.)
	
	SetKey(VK_F12, { || If(Pergunte( cPerg , .T. ), If( mv_par08 == 1, aSelFil := AdmGetFil(),aSelFil := {} ),NIL) })
	
	cFilIni	:= aParCubo[1,1]
	cFilFim := aParCubo[1,2]
	
	dbSelectarea("CT1")
	//Atualizado por Fernando Radu Muscalu em 30/09/11 - Macro Execucao, pois, na chamada do relatorio, como ha um seek
	//na tabela CT1 e ha um filtro, as linhas abaixo sao checadas.
	If 	len(aParCubo) > 0
		cMacro := "CT1_CONTA >='" +  StrTran(Strtran(cFilini, chr(10), ""),chr(3),"") + "' .And. CT1_CONTA <='" +StrTran(Strtran(cFilFim, chr(10), ""),chr(3),"") + "'"
		Set Filter to &(cMacro)
	Endif
	
	mBrowse(06, 01, 22, 75, "CT1")
	SetKey(VK_F12, Nil)
	
	dbSelectarea("CT1")
	dbSetOrder(1)
	
	Set Filter to
	
	dbSelectarea("CT2")
	dbSetOrder(1)
Else
	Help(" ",1,"CTBC403ERR",,STR0033,3,1)//"Selecionar uma entidade válida."
EndIf



Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CT400Con ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 19/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia para funcao que monta o arquivo de trabalho com as   ³±±
±±³          ³ movimentacoes e mostra-o na tela                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBC400                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTC403Con()   

LOCAL nAlias
Local oDlg,oBrw,oCOl,aBrowse:={},ni, aCpos, nCpo
Local aSize		:= MsAdvSize(,.F.,430)
Local aSizeAut 	:= MsAdvSize(), cArqTmp
Local aEntCtb	:= {}
Local aObjects	:= {	{ 375,  70, .T., .T. },;
						{ 100, 650, .T., .T., .T. },;
						{ 050, 070, .T., .T. },;
						{ 100, 200, .T., .T. } }
Local aInfo   		:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 } 
Local aPosObj 		:= MsObjSize( aInfo, aObjects, .T. ) , nSaldoAnterior := 0
Local nTotalDebito	:= nTotalCredito := nTotalSaldo := 0
Local cMascara1
Local cMascara2
Local cMascara3
Local cMascara4
Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""
Local aSetOfBook 	:= {}
Local nDecimais 	:= 0
Local lCusto 		:= .T.
Local lItem			:= .T.
Local lCLVL			:= .T.
Local aArea 		:= GetArea(), nTamanho        
Local cPictVal  	:= PesqPict("CT2","CT2_VALOR")
Local nX 
Local nH
Local cArq 
Local aEntidIni	:= {}
Local aEntidFim := {}
Local dDataIni	:= Mv_Par01
Local dDataFim	:= Mv_Par02
Local cMoeda	:= Mv_Par03
Local cTpSald   := Mv_Par04  

Local nEntSel
Local lEntidade1
Local lEntidade2
Local lEntidade3
Local lEntidade4
Local lEntidade5
Local lEntidade6
Local lEntidade7 
Local lEntidade8
Local lEntidade9
Local aSaldoAnt

Private aCposCub := {}

Pergunte( cPerg , .F.)

aSetOfBook 	:= CTBSetOf(mv_par06)
nDecimais 	:= CTbMoeda(mv_par04)[5]	// Recarrego as perguntas

If Empty( mv_par03 )
    Help(" ",1,"NOMOEDA")
	Return(.F.)
EndIf

dbSelectArea("CTO")
dbSetOrder(1)
If !dbSeek(xFilial("CTO")+mv_par03,.F.)
    Help(" ",1,"NOMOEDA")
	Return(.F.)	
EndIf

nSaldoAnterior := 0
// Soma o saldo anterior da conta de todas as filiais
//nSaldoAnterior := SaldoCT7Fil(CT1->CT1_CONTA,mv_par01,mv_par03,mv_par04,,,,aSelFil)[6]	 

// Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara1 := GetMv("MV_MASCARA")
Else
	cMascara1	:= RetMasCtb(aSetOfBook[2],@cSepara1)
EndIf               

For nX:=1 To Len(aParCubo) 
	If nX == 1
		AADD( aEntidIni,CT1->CT1_CONTA)
		AADD( aEntidFim,CT1->CT1_CONTA)	
	Else
		AADD( aEntidIni,If(MsAscii(aParCubo[nX][1])== 13,"",aParCubo[nX][1]))
		AADD( aEntidFim,If(MsAscii(aParCubo[nX][2])== 13,"",aParCubo[nX][2]))
	EndIf
Next nX	
 
aSaldoAnt 		:= CtbSldCubo(aEntidIni,aEntidFim,dDataIni,dDataFim,cMoeda,cTpSald,aSelFil)	 
nSaldoAnterior  := aSaldoAnt[6]
            
nEntSel		:= Len(aEntidIni)
lEntidade1 	:= nEntSel >=1
lEntidade2	:= nEntSel >=2
lEntidade3	:= nEntSel >=3
lEntidade4	:= nEntSel >=4
lEntidade5	:= nEntSel >=5
lEntidade6	:= nEntSel >=6
lEntidade7 	:= nEntSel >=7
lEntidade8	:= nEntSel >=8
lEntidade9	:= nEntSel ==9

MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CtGerRzCubo(aEntidIni,aEntidFim,dDataIni,dDataFim,cMoeda,cTpSald,aSelFil,@cArqTmp,@aEntCtb) },;
			STR0006,;		// "Criando Arquivo Tempor rio..."
			STR0005)		// "Emissao do Razao"

RestArea(aArea)

aCpos := ((cArqTmp)->(DbStruct()))
If ((cArqTmp)->(Eof()))
   Help(" ", 1, "CC010SEMMO")
End

CT403CplHis(@nSaldoAnterior, @nTotalSaldo, @nTotalDebito, @nTotalCredito,,cArqTmp)

nAlias 	:= Select(cArqTmp)
aBrowse := {	{STR0009,"DATAL"},;
				{STR0010,	{ || (cArqTmp)->LOTE + (cArqTmp)->SUBLOTE + (cArqTmp)->DOC +'/' + (cArqTmp)->LINHA } } }
				
	For nH:= 1 To Len(aCposCub)				
		AADD(aBrowse,{aCposCub[nH][1],aCposCub[nH][2]})				
	Next nH				
	
	AADD(aBrowse,{STR0011,"HISTORICO"})
	AADD(aBrowse,{STR0012,{ || MascaraCTB((cArqTmp)->XPARTIDA,cMascara1,,cSepara1) }})
	AADD(aBrowse,{STR0013,"LANCDEB"})
	AADD(aBrowse,{STR0014,"LANCCRD"})
	AADD(aBrowse,{STR0015,"SALDOSCR"})
	AADD(aBrowse,{STR0029,"TPSLDATU"})
	AADD(aBrowse,{"Filial","FILORI"})    				
   				
DEFINE 	MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
	SX3->(DbSetOrder(2))
	SX3->(DbSeek("CT1_NORMAL"))
	cCondA := Iif(nSaldoAnterior<0,"D","C")
	@ 35, 04  SAY STR0018 + MascaraCTB(CT1->CT1_CONTA,cMascara1,,cSepara1) + " - " +AllTrim(Substr(&("CT1->CT1_DESC" + mv_par03),1,45)) +;
				  " - " + X3Titulo() + " - " + CT1->CT1_NORMAL PIXEL //"Conta - " 
	@ 35,aPosObj[1][4] - 100 Say STR0026 +;
			Transform(Abs(nSaldoAnterior),cPictVal) + " " + cCondA PIXEL //"Saldo Anterior "
			SX3->(DbSetOrder(1))
	@ 45,4 COLUMN BROWSE oBrw SIZE 	aPosObj[2][3],aPosObj[2][4] PIXEL OF oDlg
	oBrw:lColDrag := .T.  // Permite a mudanca das ordens das colunas
	oBrw:lMChange := .T.  // Permitir o ajuste do tamanho dos campos
	For ni := 1 to Len(aBrowse)
		uCpo := aBrowse[ni][2]
		If ValType(uCpo) <> "B"
			nCpo := Ascan(aCpos, { |x| x[1] = aBrowse[ni][2]})
		Else
			nCpo := 0
		Endif
		If Len(aBrowse[ni]) > 2
			nTamanho := aBrowse[ni][3]
		Else
			If nCpo > 0
				nTamanho := aCpos[nCpo][3]
			Else
				nTamanho := 0
			Endif
		Endif
		If nCpo = 0
			DEFINE COLUMN oCol DATA { || "" };
			HEADER aBrowse[ni][1];
			SIZE CalcFieldSize("C",	If(nTamanho = 0, Len(Eval(uCpo)), nTamanho), 0,"",aBrowse[ni][1])
			oCol:bData := uCpo
		ElseIf ValType(&(aBrowse[ni][2])) != "N"
			DEFINE COLUMN oCol DATA FieldWBlock(aBrowse[ni][2], nAlias);
			HEADER aBrowse[ni][1];
			SIZE CalcFieldSize(aCpos[nCpo][2],nTamanho,aCpos[nCpo][4],"",aBrowse[ni][1]) -; 
			If(ValType(&(aBrowse[ni][2])) = "D", 7, 0)
		Else
			uCpo := aBrowse[ni][2]
			DEFINE COLUMN oCol DATA FieldWBlock(aBrowse[ni][2], nAlias);
			PICTURE cPictVal;
			HEADER aBrowse[ni][1] SIZE CalcFieldSize(aCpos[nCpo][2],aCpos[nCpo][3],aCpos[nCpo][4],cPictVal,aBrowse[ni][1]) RIGHT
		Endif
		oBrw:ADDCOLUMN(oCol)
	Next ni
DEFINE COLUMN oCol DATA { || Space(10) } HEADER " " SIZE 10 RIGHT
oBrw:ADDCOLUMN(oCol)
oBrw:bChange := { || C403ChgBrw( mv_par03, @aEntCtb, cArqTmp ) }

@ aPosObj[3][1]    ,002 TO aPosObj[3][3], aPosObj[3][4] LABEL STR0019 PIXEL
@ aPosObj[3][1] + 8,005  Say STR0013 + Trans(nTotalDebito,tm(nTotalDebito,17,2/*nDecimais*/)) PIXEL		//"D‚bito "
@ aPosObj[3][1] + 8,170  Say STR0014 + Trans(nTotalCredito,tm(nTotalCredito,17,2/*nDecimais*/)) PIXEL  	//"Cr‚dito "
cCondF := Iif(nTotalSaldo<0,"D","C")			
@ aPosObj[3][1] + 8,aPosObj[3][4] - 80 Say STR0020+ Transform(ABS(nTotalSaldo),cPictVal) + " " + cCondF Pixel //"Saldo "
 
//----------- DESCRICOES -----------------------------------------------//                               
@ aPosObj[4][1], 002 TO aPosObj[4][3], aPosObj[4][4] LABEL STR0030 PIXEL	// "Descrições"

nPos	:= aPosObj[4][1]+8
@ nPos,005 SAY aEntCtb[1,7] PIXEL	// "Contra Partida"
@ nPos,045 MSGET aEntCtb[1,3] VAR aEntCtb[1,2] WHEN .F. SIZE 150,08 PIXEL

If lEntidade2
	@ nPos,aPosObj[4][4] -185 SAY aEntCtb[3,7] PIXEL	
	@ nPos,aPosObj[4][4] -152 MSGET aEntCtb[3,3] VAR aEntCtb[3,2] WHEN .F. SIZE 150,08 PIXEL
EndIF        

If lEntidade3 
	nPos += 10
	@ nPos,005 SAY aEntCtb[4,7] PIXEL	
	@ nPos,045 MSGET aEntCtb[4,3] VAR aEntCtb[4,2] WHEN .F. SIZE 150,08 PIXEL
EndIf     
                
If lEntidade4
	@ nPos,aPosObj[4][4] -185 SAY aEntCtb[5,7] PIXEL	
	@ nPos,aPosObj[4][4] -152 MSGET aEntCtb[5,3] VAR aEntCtb[5,2] WHEN .F. SIZE 150,08 PIXEL
EndIf
     
If lEntidade5 
	nPos += 10
	@ nPos,005 SAY aEntCtb[6,7] PIXEL	
	@ nPos,045 MSGET aEntCtb[6,3] VAR aEntCtb[6,2] WHEN .F. SIZE 150,08 PIXEL
EndIf     
                
If lEntidade6
	@ nPos,aPosObj[4][4] -185 SAY aEntCtb[7,7] PIXEL	
	@ nPos,aPosObj[4][4] -152 MSGET aEntCtb[7,3] VAR aEntCtb[7,2] WHEN .F. SIZE 150,08 PIXEL
EndIf        

If lEntidade7 
	nPos += 10
	@ nPos,005 SAY aEntCtb[8,7] PIXEL	
	@ nPos,045 MSGET aEntCtb[8,3] VAR aEntCtb[8,2] WHEN .F. SIZE 150,08 PIXEL
EndIf     
                
If lEntidade8
	@ nPos,aPosObj[4][4] -185 SAY aEntCtb[9,7] PIXEL	
	@ nPos,aPosObj[4][4] -152 MSGET aEntCtb[9,3] VAR aEntCtb[9,2] WHEN .F. SIZE 150,08 PIXEL
EndIf        

If lEntidade9 
	nPos += 10
	@ nPos,005 SAY aEntCtb[10,7] PIXEL	
	@ nPos,045 MSGET aEntCtb[10,3] VAR aEntCtb[10,2] WHEN .F. SIZE 150,08 PIXEL
EndIf     

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})

dbSelectArea(cArqTmp)
DbCloseArea()

// Elimina tabela temporaria do banco
If _oCTBC403 <> Nil
	_oCTBC403:Delete()
	_oCTBC403 := Nil
Endif

dbSelectArea("CT1")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTC403Imp³ Autor ³ Wagner Mobile Costa   ³ Data ³ 28/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara a chamada para o relatorio CTBR400                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBC403                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTC403Imp()
Local aAreaCt1 := CT1->(GetArea())

CTBR403( cNomeArqConf ) 

Pergunte(cPerg, .F.)		

CT1->(RestArea(aAreaCt1))   

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CT403CplHis³ Autor ³ Wagner Mobile Costa  ³ Data ³ 28/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que carrega o complemento do historico              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBC403                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CT403CplHis(nSaldoAnterior, nTotalSaldo, nTotalDebito, nTotalCredito,;
					 lDocBranco,cArqTmp)

Local nSALDOSCR  := nLANCDEB := nLANCCRD := 0.00
Local lCplHist := (cArqTmp)->(FieldPos("SEQLAN")) > 0
Local nSaldAnt 	:= nSaldoAnterior		// Armazena Saldo Anterior
Local nTotSld	:= 0  //Auxiliar utilizada para atualizar o saldo total
Local nRegTmp	:= 0
Local lTemMov   := .F.
Local cFilOld := cFilAnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava as movimentacoes no arquivo de trabalho                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CT2")
dbSetOrder(10)

dbSelectArea(cArqTmp)
DbGoTop()
While ! Eof()

	cFilAnt := (cArqTmp)->FILORI
	
	If lDocBranco # Nil .And. ! lDocBranco .And. Empty(CT2KEY)
		DbDelete()
		DbSkip()
		Loop		
	Endif
	If (cArqTmp)->TIPO = "4" //Atualiza o Saldo Total      
	   	nTotSld := nSaldoAnterior + nTotalSaldo - LANCDEB + LANCCRD
		nTotalDebito 	+= LANCDEB
		nTotalCredito	+= LANCCRD
		nSaldoAnterior 	:= 0
		nTotalSaldo 	:= nTotSld
		Replace SALDOSCR With ABS(nTotSld )
		If nTotSld > 0 
			Replace TPSLDATU	With "C"				
		ElseIf nTotSld < 0                              
			Replace TPSLDATU	With "D"
		Else
			Replace TPSLDATU With " "
		EndIf            		
		DbSkip()
		Loop
	Endif

	If lCplHist
		nRegTmp := Recno()			
		// Procura pelo complemento de historico
		dbSelectArea("CT2")
	Endif
	If 	lCplHist .And.;
		dbSeek(xFilial("CT2")+(cArqTMP)->(DTOS(DATAL)+LOTE+SUBLOTE+DOC+SEQLAN+EMPORI+FILORI),.F.)
		dbSkip()
		If CT2->CT2_DC == "4"
			While !Eof() .And. 	CT2->CT2_FILIAL == xFilial() 			.And.;
								CT2->CT2_LOTE == (cArqTMP)->LOTE 			.And.;
								CT2->CT2_SBLOTE == (cArqTMP)->SUBLOTE 	.And.;
								CT2->CT2_DOC == (cArqTmp)->DOC 			.And.;
								CT2->CT2_SEQLAN == (cArqTmp)->SEQLAN 		.And.;
								CT2->CT2_DC == "4" 						.And.;
								CT2->CT2_EMPORI == (cArqTmp)->EMPORI		.And.;
								CT2->CT2_FILORI == (cArqTmp)->FILORI		.And.;
								DTOS(CT2->CT2_DATA) == DTOS((cArqTmp)->DATAL)

				nSALDOSCR 		  := (cArqTmp)->SALDOSCR
				nLANCDEB 		  := (cArqTmp)->LANCDEB
				nLANCCRD 		  := (cArqTmp)->LANCCRD
				(cArqTmp)->SALDOSCR := 0.00
				(cArqTmp)->LANCDEB  := 0.00
				(cArqTmp)->LANCCRD  := 0.00
//				CtbGrvRAZ(.F.,mv_par03,mv_par04,CT2->CT2_DC,,"CT2")
				GrvTmpC403( "CT2" )
				(cArqTmp)->SALDOSCR := nSALDOSCR
				(cArqTmp)->LANCDEB  := nLANCDEB
				(cArqTmp)->LANCCRD  := nLANCCRD
				DbSelectArea("CT2")
				DbSkip()
			EndDo
		EndIf	
		DbSelectArea(cArqTmp)
		DbGoTo(nRegTmp)
	Endif

	DbSelectArea(cArqTmp)
   
	//Atualiza o Saldo Total
	nSldTot := nSaldoAnterior + nTotalSaldo - LANCDEB + LANCCRD
	nTotalDebito 	+= LANCDEB
	nTotalCredito	+= LANCCRD
	nSaldoAnterior 	:= 0
	nTotalSaldo 	:= nSldTot
	Replace SALDOSCR With ABS(nSldTot )
	If nSldTot > 0 
		Replace TPSLDATU	With "C"				
	ElseIf nSldTot < 0                              
		Replace TPSLDATU	With "D"
	Else
		Replace TPSLDATU 	With " "
	EndIf            		
                      
	lTemMov := .T.
	
	DbSkip()

EndDo

cFilAnt := cFilOld
nSaldoAnterior  := nSaldAnt				// Recupera Saldo Anterior

If !lTemMov
	nTotalSaldo := nSaldoAnterior
EndIf

DbGoTop() 

dbSelectArea("CT2")
DbSetOrder(1)	
DbSelectArea(cArqTmp)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ C403ChgBrw ºAutor ³ Gustavo Henrique   º Data ³  01/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza descricoes da contra partida, centro de custo,     º±±
±±º          ³ item contabil e classe de valor.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cMoeda  - Codigo da moeda da consulta                       º±±
±±º          ³ aEntCtb - Array com codigo, descricao e objeto por entidade º±±
±±º          ³           aEntCtb[1] - Conta contabil                       º±±
±±º          ³                  [1,1] - Codigo da conta                    º±±
±±º          ³                  [1,2] - Descricao da conta                 º±±
±±º          ³                  [1,3] - Objeto GET para exibir a descricao º±±
±±º          ³                  [1,4] - Usado na consulta atual            º±±
±±º          ³           aEntCtb[2] - Contra Partida    				   º±±
±±º          ³           aEntCtb[3] - Centro de Custo                      º±±
±±º          ³           aEntCtb[4] - Item Contabil                        º±±
±±º          ³           aEntCtb[5] - Classe de Valor                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Consultas Razao por conta contabil                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C403ChgBrw( cMoeda, aEntCtb, cArqTmp )
Local nJ	:= 0
Local bBloco,cConteudo,cDescr	
For nJ:=1 To Len(aEntCtb)
	bBloco 		:= aEntCtb[nJ,5]
	cConteudo 	:= eVal(&bBloco)
	If aEntCtb[nJ,4] .And. ( Alltrim(aEntCtb[nJ,1]) # Alltrim(cConteudo) )
		bBloco := aEntCtb[nJ,6]
		cDescr := eVal(&bBloco)
		aEntCtb[nJ,1] := cConteudo	
		aEntCtb[nJ,2] := cDescr		
		If ValType(aEntCtb[nJ,3]) == 'O'
			aEntCtb[nJ,3]:Refresh()
		EndIf			
	EndIf
Next nJ

Return  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtGerRzCubo ºAutor  ³Microsiga         º Data ³  07/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtGerRzCubo(aEntdIni,aEntdFim,dDataIni,dDataFim,cMoeda,cTpSald,aSelFil,cArqTmp,aEntCtb)
Local aAreaAtu	:= GetArea()   
Local aTamVal	:= TAMSX3("CT2_VALOR")
Local aTamConta	:= TAMSX3("CT1_CONTA")
Local aCampos
Local aCtbMoeda := CTbMoeda(cMoeda)
Local nDecimais := aCtbMoeda[5]
Local nTamHist	:= Len(CriaVar("CT2_HIST"))
Local cChave	:= "DTOS(DATAL)+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
                
aCampos :={	{ "TIPO"       	, "C", 01			, 0 },;			// Tipo do Registro (Debito/Credito/Continuacao)
			{ "XPARTIDA"   	, "C", aTamConta[1] , 0 },;		// Contra Partida
			{ "LANCDEB"		, "N", aTamVal[1]+2, nDecimais },; // Debito
			{ "LANCCRD"		, "N", aTamVal[1]+2	, nDecimais },; // Credito
			{ "SALDOSCR"	, "N", aTamVal[1]+2, nDecimais },; 			// Saldo
			{ "TPSLDANT"	, "C", 01, 0 },; 					// Sinal do Saldo Anterior => Consulta Razao
			{ "TPSLDATU"	, "C", 01, 0 },; 					// Sinal do Saldo Atual => Consulta Razao			
			{ "HISTORICO"	, "C", nTamHist   	, 0 },;			// Historico
			{ "DATAL"		, "D", 10			, 0 },;			// Data do Lancamento
			{ "LOTE" 		, "C", 06			, 0 },;			// Lote
			{ "SUBLOTE" 	, "C", 03			, 0 },;			// Sub-Lote
			{ "DOC" 		, "C", 06			, 0 },;			// Documento
			{ "LINHA"		, "C", 03			, 0 },;			// Linha
			{ "SEQLAN"		, "C", 03			, 0 },;			// Sequencia do Lancamento
			{ "SEQHIST"		, "C", 03			, 0 },;			// Seq do Historico
			{ "EMPORI"		, "C", TamSx3('CT2_EMPORI')[1], 0 },;			// Empresa Original
			{ "FILORI"		, "C", TamSx3('CT2_FILORI')[1], 0 },;			// Filial Original
			{ "NOMOV"		, "L", 01			, 0 },;			// Conta Sem Movimento
			{ "FILIAL"		, "C", 02			, 0 }} // Filial do sistema

		DbSelectArea('CT0')
		DbSetOrder(1)
		If DbSeek( xFilial('CT0') )
		
	      	AADD(aEntCtb,Array(7)) 
			aEntCtb[Len(aEntCtb)][1] := ''
			aEntCtb[Len(aEntCtb)][2] := ''
			aEntCtb[Len(aEntCtb)][3] := Nil
			aEntCtb[Len(aEntCtb)][4] := .T.
			aEntCtb[Len(aEntCtb)][5] := '{|| cTmpRzCub->XPARTIDA }'
			aEntCtb[Len(aEntCtb)][6] := '{|| CtbDescEnt( cTmpRzCub->XPARTIDA,"CT1", cMoeda )}'		      	
			aEntCtb[Len(aEntCtb)][7] := STR0031 //'Contra Partida'
		
			While CT0->(!Eof()) .And. CT0->CT0_FILIAL == xFilial('CT0') 
		   		                                                         
		      	AADD( aCampos,{ "NIVEL"+CT0->CT0_ID	, "C", TamSx3(CT0->CT0_CPOCHV)[1]	, 0 } ) 
		      	
		      	AADD( aCposCub,{CT0->CT0_DSCRES,"NIVEL"+CT0->CT0_ID}) 
		      	
		      	AADD(aEntCtb,Array(7)) 
				aEntCtb[Len(aEntCtb)][1] := ''
				aEntCtb[Len(aEntCtb)][2] := ''
				aEntCtb[Len(aEntCtb)][3] := Nil
				aEntCtb[Len(aEntCtb)][4] := .T.
				aEntCtb[Len(aEntCtb)][5] := '{|| cTmpRzCub->'+'NIVEL'+CT0->CT0_ID+'}'
//				aEntCtb[Len(aEntCtb)][6] := '{|| CtbDescEnt( cTmpRzCub->'+'NIVEL'+CT0->CT0_ID+',"'+ CT0->CT0_ALIAS+'", cMoeda )}'		      	 
				aEntCtb[Len(aEntCtb)][6] := '{|| CtbDescCub( cTmpRzCub->'+'NIVEL'+CT0->CT0_ID+',"'+ CT0->CT0_ALIAS+'", cMoeda,"'+CT0->CT0_ID+'" )}'		      					
				aEntCtb[Len(aEntCtb)][7] := CT0->CT0_DSCRES		      			      	
						      	
				CT0->(DbSkip())			   		 	                                                        
			EndDo			   		                                                           
		EndIf  

If ( Select ( "cTmpRzCub" ) <> 0 )
	dbSelectArea ( "cTmpRzCub" )
	dbCloseArea()
Endif
	
If _oCTBC403 <> Nil
	_oCTBC403:Delete()
	_oCTBC403 := Nil
Endif

_oCTBC403 := FWTemporaryTable():New( "cTmpRzCub" )  
_oCTBC403:SetFields(aCampos) 
_oCTBC403:AddIndex("1", {"DATAL","LOTE","SUBLOTE","DOC","LINHA","EMPORI","FILORI"})

//------------------
//Criação da tabela temporaria
//------------------
_oCTBC403:Create()  	
		
DbSelectArea("cTmpRzCub") 																		
dbSetOrder(1)
                
RestArea(aAreaAtu)

CTBC403MOV(aEntdIni,aEntdFim,dDataIni,dDataFim,cMoeda,cTpSald,aSelFil)

Return cArqTmp:= "cTmpRzCub" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBC403MOV  ºAutor  ³Microsiga         º Data ³  07/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CTBC403MOV(aEntdIni,aEntdFim,dDataIni,dDataFim,cMoeda,cTpSald,aSelFil)
Local nY		:= 0 
Local nEntidade	:= Len(aEntdIni)
Local cQry		:= "" 
Local cQryDeb	:= ""
Local cQryCre	:= "" 
Local cQryEntDeb:= "" 
Local cQryEntCre:= ""
Local aTam		:= TamSx3('CT2_VALOR')  
Local cQryFil	:= "" 
Local cCodEntInicial
Local cCodEntFinal
Local cTmpCT2Fil

// trataviva para o filtro de multifiliais 
cQryFil := " CT2_FILIAL " + GetRngFil( aSelFil, "CT2", .T., @cTmpCT2Fil )

For nY:=1 To nEntidade
	If nY == 1
		cQryDeb += "CT2_DEBITO NIVEL01,"
		cQryCre += "CT2_CREDIT NIVEL01," 
		cCodEntInicial	:= If(Empty(aEntdIni[nY]),Space(TamSx3('CT2_DEBITO')[1]),aEntdIni[nY]) 
		cCodEntFinal	:= If(Empty(aEntdFim[nY]),Repl('z',TamSx3('CT2_DEBITO')[1]),aEntdFim[nY]) 
		cQryEntDeb += "AND CT2_DEBITO BETWEEN '"+cCodEntInicial+"' AND '"+cCodEntFinal+"' "  + CRLF 
		cQryEntCre += "AND CT2_CREDIT BETWEEN '"+cCodEntInicial+"' AND '"+cCodEntFinal+"' " + CRLF
	ElseIf nY == 2		
		cQryDeb += "CT2_CCD NIVEL02,"
		cQryCre += "CT2_CCC NIVEL02,"    
		cCodEntInicial	:= If(Empty(aEntdIni[nY]),Space(TamSx3('CT2_CCD')[1]),aEntdIni[nY]) 
		cCodEntFinal	:= If(Empty(aEntdFim[nY]),Repl('z',TamSx3('CT2_CCD')[1]),aEntdFim[nY]) 		
		cQryEntDeb += "AND CT2_CCD BETWEEN '"+cCodEntInicial+"' AND '"+cCodEntFinal+"' " + CRLF
		cQryEntCre += "AND CT2_CCC BETWEEN '"+cCodEntInicial+"' AND '"+cCodEntFinal+"' " + CRLF
	ElseIf nY == 3		
		cQryDeb += "CT2_ITEMD NIVEL03,"
		cQryCre += "CT2_ITEMC NIVEL03,"                                                           
		cCodEntInicial	:= If(Empty(aEntdIni[nY]),Space(TamSx3('CT2_ITEMD')[1]),aEntdIni[nY]) 
		cCodEntFinal	:= If(Empty(aEntdFim[nY]),Repl('z',TamSx3('CT2_ITEMD')[1]),aEntdFim[nY])		
		cQryEntDeb += "AND CT2_ITEMD BETWEEN '"+cCodEntInicial+"' AND '"+cCodEntFinal+"' " + CRLF   
		cQryEntCre += "AND CT2_ITEMC BETWEEN '"+cCodEntInicial+"' AND '"+cCodEntFinal+"' " + CRLF		
	ElseIf nY == 4		
		cQryDeb += "CT2_CLVLDB NIVEL04,"
		cQryCre += "CT2_CLVLCR NIVEL04,"                                      
		cCodEntInicial	:= If(Empty(aEntdIni[nY]),Space(TamSx3('CT2_CLVLDB')[1]),aEntdIni[nY]) 
		cCodEntFinal	:= If(Empty(aEntdFim[nY]),Repl('z',TamSx3('CT2_CLVLDB')[1]),aEntdFim[nY])		
		cQryEntDeb += "AND CT2_CLVLDB BETWEEN '"+cCodEntInicial+"' AND '"+cCodEntFinal+"' " + CRLF   
		cQryEntCre += "AND CT2_CLVLCR BETWEEN '"+cCodEntInicial+"' AND '"+cCodEntFinal+"' " + CRLF				
	Else
		cQryDeb += "CT2_EC"+StrZero(nY,2)+"DB NIVEL"+StrZero(nY,2)+","
		cQryCre += "CT2_EC"+StrZero(nY,2)+"CR NIVEL"+StrZero(nY,2)+","        
		cCodEntInicial	:= If(Empty(aEntdIni[nY]),Space(TamSx3("CT2_EC"+StrZero(nY,2)+"DB")[1]),aEntdIni[nY]) 
		cCodEntFinal	:= If(Empty(aEntdFim[nY]),Repl('z',TamSx3("CT2_EC"+StrZero(nY,2)+"DB")[1]),aEntdFim[nY])		
		cQryEntDeb += "AND "+"CT2_EC"+StrZero(nY,2)+"DB BETWEEN '"+cCodEntInicial+"' AND '"+cCodEntFinal+"' " + CRLF  
		cQryEntCre += "AND "+"CT2_EC"+StrZero(nY,2)+"CR BETWEEN '"+cCodEntInicial+"' AND '"+cCodEntFinal+"' " + CRLF			
	EndIF		

Next nY

cQry += "SELECT CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_DC,CT2_HIST,CT2_EMPORI,CT2_FILORI,CT2_SEQHIS,CT2_SEQLAN,'1' TIPOLAN,"
cQry += cQryDeb + "CT2_VALOR " + CRLF
cQry += " FROM " + RetSqlName('CT2') + CRLF
cQry += " WHERE " + cQryFil   
cQry += " AND CT2_DATA >= '"+DTOS(dDataIni)+ "' AND CT2_DATA <= '"+DTOS(dDataFim)+"'"
cQry += " AND CT2_TPSALD = '"+ cTpSald + "'"
cQry += " AND CT2_MOEDLC = '" + cMoeda +"'"
cQry += " AND (CT2_DC = '1' OR CT2_DC = '3') AND CT2_VALOR <> 0 " + cQryEntDeb + " AND D_E_L_E_T_ = ' ' "   
cQry += " UNION ALL " + CRLF
cQry += "SELECT CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_DC,CT2_HIST,CT2_EMPORI,CT2_FILORI,CT2_SEQHIS,CT2_SEQLAN,'2' TIPOLAN,"
cQry += cQryCre + "CT2_VALOR " + CRLF
cQry += " FROM " + RetSqlName('CT2') + CRLF
cQry += " WHERE " + cQryFil   
cQry += " AND CT2_DATA >= '"+DTOS(dDataIni)+ "' AND CT2_DATA <= '"+DTOS(dDataFim)+"'"
cQry += " AND CT2_TPSALD = '"+ cTpSald + "'"
cQry += " AND CT2_MOEDLC = '" + cMoeda +"'"
cQry += " AND (CT2_DC = '2' OR CT2_DC = '3') AND CT2_VALOR <> 0 " + cQryEntCre + " AND D_E_L_E_T_ = ' ' " 
cQry += " ORDER BY CT2_DATA "

//MemoWrite("D:\Querys\CTBC403.sql",cQry)  
                        
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"cArqTmp",.T.,.F.)
                                                          
TCSetField("cArqTmp","CT2_DATA", "D",8,0)	  
TCSetField("cArqTmp","CT2_VALOR", "N",aTam[1],aTam[2])	  

DbSelectArea("cArqTmp")
DbGoTop()
While cArqTmp->(!Eof())

	GrvTmpC403()

	cArqTmp->(DbSkip())
EndDo  

If Select("cArqTmp") > 0
	DbSelectArea("cArqTmp") 
	DbCloseArea()
EndIF

CtbTmpErase(cTmpCT2Fil)
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GrvTmpC403  ºAutor  ³Microsiga         º Data ³  07/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GrvTmpC403( cAliasAtu )
Local nX:= 0
Local cNomeCpo                         

Default cAliasAtu := "cArqTmp"

	RecLock("cTmpRzCub",.T.)		    	
	    Replace DATAL		With (cAliasAtu)->CT2_DATA
		Replace TIPO		With (cAliasAtu)->CT2_DC
		Replace LOTE		With (cAliasAtu)->CT2_LOTE
		Replace SUBLOTE		With (cAliasAtu)->CT2_SBLOTE
		Replace DOC			With (cAliasAtu)->CT2_DOC
		Replace LINHA		With (cAliasAtu)->CT2_LINHA
		Replace HISTORICO	With (cAliasAtu)->CT2_HIST
		Replace EMPORI		With (cAliasAtu)->CT2_EMPORI
		Replace FILORI		With (cAliasAtu)->CT2_FILORI
		Replace SEQHIST		With (cAliasAtu)->CT2_SEQHIS
		Replace SEQLAN		With (cAliasAtu)->CT2_SEQLAN
		
		For nX := 1 To (cAliasAtu)->(fCount())
			cNomeCpo := (cAliasAtu)->(FieldName(nx))
			If 'NIVEL' $ cNomeCpo
				Replace &cNomeCpo With (cAliasAtu)->&(cNomeCpo)		       
			EndIf
		Next nX
	    
		If cAliasAtu != 'CT2
			If (cAliasAtu)->TIPOLAN = '1'
				Replace LANCDEB	With LANCDEB + (cAliasAtu)->CT2_VALOR
			EndIf
			If (cAliasAtu)->TIPOLAN = '2'
				Replace LANCCRD	With LANCCRD + (cAliasAtu)->CT2_VALOR
			EndIf	            
		EndIf
		
	MsUnlock()
	        
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbDescCub  ºAutor  ³Microsiga         º Data ³  07/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CtbDescCub( cCodigo, cAlias, cMoeda , cCodEnt )
Local cRet		:= ""   
Local aAreaAtu	:= GetArea()
Local aAreaEnt	:= (cAlias)->(GetArea())

If cAlias $ "CT1/CTT/CTD/CTH"
	cRet := CtbDescEnt( cCodigo,cAlias, cMoeda )
Else
	DbSelectArea('CT0')
	DbSetOrder(1)
	If DbSeek(xFilial('CT0') + cCodEnt,.f.) 

		cRet := GetAdvFval( CT0->CT0_ALIAS, CT0->CT0_CPODSC, xFilial(cAlias) + CT0->CT0_ENTIDA + cCodigo,1 )
		
	EndIf	
EndIF

RestArea( aAreaEnt )
RestArea(aAreaAtu)
Return cRet                 



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³06/12/06 ³±±
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
Local aRotina   	:= {	{STR0002,"AxPesqui",0,1},;  	//"Pesquisar"
                           	{STR0003,"CTC403Con",0,2},;   	//"Visualizar"
                           	{STR0004,"CTC403Imp",0,2}}    	//"Impressao"
Return(aRotina)
