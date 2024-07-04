#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCBROWSE.CH" 
#INCLUDE "FILEIO.CH"                     
#INCLUDE "QMTA010.CH"
#DEFINE K_F4    VK_F4

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QMTA010	³ Autor ³ Wanderley Goncalves Jr³ Data ³ 12/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Instrumentos					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³	MOTIVO DA ALTERACAO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Antonio A.    ³03/08/99³  --  ³ Ajuste no For que carrega a aCols no   ³±±
±±³              ³        ³      ³  a010CaTR                              ³±± 
±±³Denis Martins ³23/11/00³Verif.³ Inclusao lCtrlCalib,Tratamento de Sta- ³±± 
±±³              ³        ³      ³ tus e Integridade de Arqs(QM2/QMR/QMG) ³±± 
±±³Denis Martins ³27/11/00³Melhor³ Melhoramento na funcao de visualizacao.³±± 
±±³Denis Martins ³29/11/00³Melhor³ Ajuste na rotina A010VERJU(), quando da³±±  
±±³              ³        ³      ³ alteracao do status do instrumento obri³±± 
±±³              ³        ³      ³ gar a digitacao da justificativa.      ³±±
±±³Denis Martins ³25/02/01³Melhor³ Permitir digitacao de sinal negativo   ³±±  
±±³              ³        ³      ³ nos limites inferior e superior.       ³±± 
±±³Denis Martins ³07/02/02³Melhor³ Permitir visualizacao e gravacao de jus³±±  
±±³              ³        ³      ³ tificativas anteriores do instrumento  ³±± 
±±³              ³        ³      ³ corrente.                              ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MenuDef()

Local aRotina := {{OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},; // "Pesquisar"
					{OemToAnsi(STR0017),"A010VIns"  , 0 , 2},; // "Visualizar"
					{OemToAnsi(STR0018),"A010IIns"  , 0 , 3},; // "Incluir"
					{OemToAnsi(STR0019),"A010IIns"  , 0 , 4},; // "Alterar"
					{OemToAnsi(STR0020),"A010DIns"  , 0 , 5, 3},; // "Excluir"
					{OemToAnsi(STR0021),"A010Textos", 0 , 6},;  // "Textos"
					{OemToAnsi(STR0095),"MsDocument", 0 , 4},; //"Conhecimento"
					{OemToAnsi(STR0099),"A010Legend", 0 , 7}} //"Legenda"
					

Return aRotina

Function QMTA010
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis 											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Local oDlg
Local aCores     := {}
Local aCoresNew  := {}
Local aRotAdic   := {}
Local cFilter    := ""
Local lFilter    := .F.
Local lQM010Brow := ExistBlock("QM010BROW")
Local lQM010Filt := ExistBlock("QM010FILT")

Private aDigita      := {}
Private aSalvaGuarda :={OemToAnsi(STR0086), OemToAnsi(STR0087), OemToAnsi(STR0088)} //Lacre # Construcao # Treinamento
Private axtextos     := {}
Private cEspecie     := ""
Private cQM2Tipo     := ""
Private lCtrlCalib   := .T. //Tratamendo de Telas qdo Calibrador

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0006)  //"Instrumentos"
Private lTamSom	:= GetMv("MV_QMTPCES") == "1" //Para escalas do tipo soma considerar decimais definida na escala

Private oArialGr	:= TFont():New("Arial",11,14,,.F.)          

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄT¿
//³Tipos de Movimentação:                                                   ³
//³1 = Movimentação Tipo 1 (Movimentação entre Departamentos de uma Filial) ³
//³2 = Movimentação Tipo 2 (Movimentação de Instrumentos Entre Filiais)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄTÙ
*/
Private cTpMov		:= GetMV("MV_QMTPMOV", .F., "1") // 1 = Mov Tipo 1 / 2 = Mov Tipo 2
Private lQMovIns 	:= .F.

If cTpMov == "2"
	If ChkFile("QN5")
		lQMovIns := .T.
	Endif
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa 	 ³
//³ ----------- Elementos contidos por dimensao ------------	 ³
//³ 1. Nome a aparecer no cabecalho 							 ³
//³ 2. Nome da Rotina associada									 ³
//³ 3. Usado pela rotina										 ³
//³ 4. Tipo de Transa‡„o a ser efetuada							 ³
//³	 1 - Pesquisa e Posiciona em um Banco de Dados				 ³
//³	 2 - Simplesmente Mostra os Campos							 ³
//³	 3 - Inclui registros no Bancos de Dados					 ³
//³	 4 - Altera o registro corrente								 ³
//³	 5 - Remove o registro corrente do Banco de Dados			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Status do Instrumento                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCores,{"QM2->QM2_VALDAF >= Date() .AND. QM2->QM2_STATUS = 'A'","BR_VERDE"})
Aadd(aCores,{"QM2->QM2_VALDAF < Date() .AND. QM2->QM2_STATUS = 'A'","BR_VERMELHO"})
Aadd(aCores,{"QM2->QM2_VALDAF < Date() .AND. QM2->QM2_STATUS <> 'A'","BR_AMARELO"})
Aadd(aCores,{"QM2->QM2_VALDAF >= Date() .AND. QM2->QM2_STATUS <> 'A'","BR_LARANJA"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para alterar cores da Legenda de Status de Instrumento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QM010COR")
	aCoresNew := ExecBlock("QM010COR",.F.,.F.,{aCores})
	If ValType(aCoresNew) == "A"
		aCores := aCoresNew
	EndIf
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nQaConpad := 2
QM2->(DbSetOrder(1))
If lQM010Brow
	ExecBlock("QM010BROW",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada responsável pelo filtro no BROWSER			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQM010Filt
	lFilter = .F.
	cFilter := ExecBlock("QM010FILT",.F.,.F.)
	If(Valtype(cFilter) == "C" .And. !Empty(cFilter))	
		lFilter := .T.
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
//³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
If ExistBlock("QM010ROT")
	aRotAdic := ExecBlock("QM010ROT", .F., .F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

If lFilter
	mBrowse( 6, 1, 22, 75, "QM2", , , , , , aCores , , , , , , , , cFilter )
Else
	mBrowse( 6, 1, 22, 75, "QM2", , , , , , aCores )
EndIf

Set Key VK_F12 To
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010IIns ³ Autor ³ Wanderley Gonalves Jr ³ Data ³ 06/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao Instrumentos - Inc/Alt			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010IIns(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo									  ³±±
±±³			 ³ ExpN1 = Numero do registro 								  ³±±
±±³			 ³ ExpN2 = Opcao selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010IIns(cAlias,nReg,nOpc)
Local nOpcA:=0
Local lRet := .T.
Local i	:= 0	
Local oDlgC
Local cCampo
Local lGravaOk := .f.
Local lVoinst  := .F.	
Local nLcGer   := 0	
Local ni := 0
Local lQMT010QMK := ExistBlock("QMT010QMK")
Local aArea := {}

Private lNumSX8 := .F.
Private cCampoNGR := GetMV("MV_QNGREV")
Private lAltRevisao := .F.
Private cMemoJu	:= "",cMemoJuAnt := ""
Private aEscs	:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cChvAnt := ""
Private lPodeAlt := .T.
Private oEnchoice1
Private oPanel2
Private nVals := 1  
Private aCols := {}
Private aHeader[0]
Private oGetFi        
Private oGetPto
Private cFamilia := ""
Private aColsQMR := {} 	
Private aColsQMG := {} 	
Private aColsPto := {}	
Private aHeaderQMR := {} 	
Private aHeaderQMG := {} 	
Private lFzCal	 := .F.
Private nPos := 0
Private nUsado:=0
Private	lNoMoAc := .f.
Private cRevAnt := ""
Private oSayEsc       
Private oGrp
Private oGrpCatr
Private oGrpSit
Private cBmp1
Private cBmp2
Private cBmp3
Private cBmp4
Private cBmp5
Private cBmp6
Private cBmp7
Private lCalibr
Private oSayTes
Private oChkCal
Private oChkApro
Private oChkApCo
Private oChkRepro
Private oSayFam
Private	oChkLac
Private	oChkConst
Private	oChkTrei
Private	oSayAC
Private	oSayRe
Private	oSayApro
Private oSayCali
Private	oSayLc
Private	oSayTro
Private oBtn1
Private oBtn2
Private oBtn3
Private oBtn4
Private lTud := .F.
Private oBtIncEs
Private aColsQMC := {}
Private aClsQMR2 := {} 	
Private lPrimeira:= .T.
Private nOpcF	 := 3	
Private aTbsQMA	 := {}
Private aTabGer	 := {}	
Private aTabPads := {}	
Private aColsGer := {} 	
Private bCampo	:= {|nCPO| Field(nCPO) }
Private cFilMat
Private nPosPdr	 := 0		// Posicao QMC_PADRAO
Private nPosTol := 0		// Posicao QMC_TOLER
Private nOldTol
Private nOldTMin
Private nPosTMin := 0		//Posicao QMC_TOLMIN
Private nPosTpTt := 0
Private lIncEs	 := .F.
Private lAltEs	 := .F. 
Private lGerou   :=.T.
Private oSayTT
Private aTELA[0][0]
Private aGETS[0]         


dbSelectArea("QM2")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA:=0
	lAltRevisao := .F.	
 	cMemoJu := cMemoJuAnt := ""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa consulta de instrumentos no campo    ³
	//³ localizacao para instrumentos com status   ³
	//³ = M (Malha) para a tecla F4.               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetKey(K_F4, {|a,b,c| a010ConIns(a, b, c, "INS") } )		 

If nOpc == 3 
   For i := 1 To FCount()
       cCampo := Eval( bCampo, I )
       lInit  := .F.
       If ExistIni( cCampo ) .AND. !lNumSX8
       	  If ("GETSX8NUM" $ Upper(GetSx3Cache(cCampo,"X3_RELACAO")) .or. "GETSXENUM" $ Upper(GetSx3Cache(cCampo,"X3_RELACAO")))
       	  	  lNumSX8 := .T.
       	  Else
	          lInit := .T.
	          M->&( cCampo ) := InitPad( GetSx3Cache(cCampo,"X3_RELACAO") )
	          If ValType( M->&( cCampo ) ) = "C"
	             M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo,"X3_TAMANHO") )
	          EndIf
	          If M->&( cCampo ) == Nil
	             lInit := .F.
	          EndIf
          EndIf
       EndIf
       If !lInit
          M->&( cCampo ) := FieldGet( I )
          If ValType( M->&( cCampo ) ) = "C"
             M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
          ElseIf ValType( M->&( cCampo ) ) = "N"
             M->&( cCampo ) := 0
          ElseIf ValType( M->&( cCampo ) ) = "D"
             M->&( cCampo ) := CtoD( "  /  /  " )
          ElseIf ValType( M->&( cCampo ) ) = "L"
             M->&( cCampo ) := .f.
          EndIf
       EndIf
	Next I
	M->QM2_FILIAL:= xFilial("QM2")    	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpar o Filtro do QAA na Inclusao. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	Set Filter To
Else
   For i := 1 To FCount()
       M->&( Eval( bCampo, I ) ) := FieldGet( I )
   Next I
EndIf   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula dimensões oSize                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize := FwDefSize():New()
	oSize:AddObject( "BOTAO"   ,  100, 4, .T., .T., .T. ) // Totalmente dimensionavel
	oSize:AddObject( "ENCHOICE"  ,  100, 96, .T., .T., .T. ) // Totalmente dimensionavel	
       
	oSize:lProp := .T. // Proporcional             
	oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
	
	oSize:Process() // Dispara os calculos  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula dimensões oSize2                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize2 := FwDefSize():New()
	oSize2:aWorkArea := oSize:GetNextCallArea( "ENCHOICE" )
	
	oSize2:AddObject( "PANEL"    ,  100, 18, .T., .T., .T. ) // Totalmente dimensionavel
	oSize2:AddObject( "GROUP"    ,  100, 82, .T., .T., .T. ) // Totalmente dimensionavel	

	oSize2:lProp := .T. // Proporcional             
	oSize2:aMargins := { 3, 3, 0, 0 } // Espaco ao lado dos objetos 0, entre eles 3 
	
	oSize2:Process() // Dispara os calculos  
	
	If nOpc == 3	// Inclusao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Dialog                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlgC TITLE cCadastro ;  //"Cadastro Instrumentos"
								FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
			        
		@ oSize:GetDimension("BOTAO","LININI"),oSize:GetDimension("BOTAO","COLINI")     BUTTON oBtn3 PROMPT STR0079 SIZE 65, 11 OF oDlgC PIXEL ACTION (nVals := 1,qmta010TrBut(oDlgC,oEnchoice1,oBtn1)) //"&Cadastro"
		@ oSize:GetDimension("BOTAO","LININI"),oSize:GetDimension("BOTAO","COLINI")+97  BUTTON oBtn1 PROMPT STR0080 SIZE 65, 11 OF oDlgC PIXEL ACTION (nVals := 2,If(Obrigatorio(aGets,aTela),qmta010TrBut(oDlgC,oEnchoice1,oBtn1),))  //"&Escala(s)"
		@ oSize:GetDimension("BOTAO","LININI"),oSize:GetDimension("BOTAO","COLINI")+197 BUTTON oBtn2 PROMPT STR0081 SIZE 65, 11 OF oDlgC PIXEL ACTION (nVals := 3,qmta010TrBut(oDlgC,oEnchoice1,oBtn1)) //"&Pontos/Calibradores"
		oBtn1:Disable()
		oBtn2:Disable()
		
		If oSayEsc == Nil	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Panel Para Groups                                      ³    
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			oPanel2:= tPanel():New(oSize2:GetDimension("PANEL","LININI"),oSize2:GetDimension("PANEL","COLINI"),,oDlgC,,,,/*CLR_YELLOW*/,/*CLR_BLUE*/,oSize2:GetDimension("PANEL","XSIZE"),oSize2:GetDimension("PANEL","YSIZE"))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Group                                                  ³    
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		 	@ 003,000 Group oGrp    TO 45,120 LABEL STR0082 OF oPanel2 COLOR CLR_HRED PIXEL  //"Informacoes"
		 	@ 003,122 Group oGrpSit TO 45,240 LABEL STR0083 OF oPanel2 COLOR CLR_HRED PIXEL //"Situacao da Ult. Calibracao"
		 	@ 003,242 Group oGrpSav TO 45,360 LABEL STR0057 OF oPanel2 COLOR CLR_HRED PIXEL //"Salva Guarda"

			oGrp:Hide()  
			oPanel2:Hide()
			oGrpSit:Hide()
			oGrpSav:Hide()
			cBmp1  := "LBNO"
			cBmp2  := "LBNO"
			cBmp3  := "LBNO"			
			cBmp4  := "LBNO"			
			cBmp5  := "LBNO"
			cBmp6  := "LBNO"
			cBmp7  := "LBNO"			

			//Primeiro Group - Informacoes
			@ 15,6  SAY oSayEsc PROMPT OemToAnsi(STR0012)+" : "+AllTrim(M->QM2_INSTR)+" - "+AllTrim(M->QM2_REVINS) SIZE 140,7 COLOR CLR_BLUE OF oGrp PIXEL 
			@ 25,6  SAY oSayFam PROMPT STR0065+AllTrim(M->QM2_TIPO) SIZE 140,7 COLOR CLR_BLUE OF oGrp PIXEL //"Familia : "
						
			oSayEsc:Hide()
			oSayFam:Hide()
					
		
			//Segundo Group - Situacao da Ult. Calibracao               

			@ 15,130 BITMAP oChkCal RESOURCE cBmp1 PIXEL OF oGrp NOBORDER WHEN .F. SIZE 7,7
			@ 15,140  SAY oSayCali PROMPT STR0058 SIZE 70,7 COLOR CLR_BLUE OF oGrp PIXEL 
			 
			oChkCal:Hide()
			oSayCali:Hide()
					
			@ 15,170 BITMAP oChkApro RESOURCE cBmp2 SIZE 7,7 OF oGrpSit NOBORDER WHEN .F. PIXEL			
			@ 15,180  SAY oSayApro PROMPT STR0059 SIZE 70,7 COLOR CLR_BLUE OF oGrpSit PIXEL  //Aprovado
			@ 25,170 BITMAP oChkApCo RESOURCE cBmp3 PIXEL OF oGrpSit NOBORDER WHEN .F. SIZE 7,7			
			@ 25,180  SAY oSayAC PROMPT STR0060 SIZE 70,7 COLOR CLR_BLUE OF oGrpSit PIXEL //"Aprovado Condicional"	
			@ 35,170 BITMAP oChkRepro RESOURCE cBmp4 PIXEL OF oGrpSit NOBORDER WHEN .F. SIZE 7,7			
			@ 35,180  SAY oSayRe PROMPT STR0061 SIZE 70,7 COLOR CLR_BLUE OF oGrpSit PIXEL //"Reprovado"	

			oSayAC:Hide()
			oSayRe:Hide()
			oSayApro:Hide()
			oChkApro:Hide()                 
			oChkApCo:Hide()
			oChkRepro:Hide()			
			
			//Terceiro Group - Salva Guarda
			@ 15,250 BITMAP oChkLac RESOURCE cBmp5 PIXEL OF oGrpSav NOBORDER WHEN .F. SIZE 7,7			
			@ 15,260 SAY oSayLc PROMPT STR0062 SIZE 70,7 COLOR CLR_BLUE OF oGrpSav PIXEL //"Lacre"
			@ 25,250 BITMAP oChkConst RESOURCE cBmp6 PIXEL OF oGrpSav NOBORDER WHEN .F. SIZE 7,7			
			@ 25,260 SAY oSayCon PROMPT STR0063 SIZE 70,7 COLOR CLR_BLUE OF oGrpSav PIXEL //Construcao                         			
			@ 35,250 BITMAP oChkTrei RESOURCE cBmp7 PIXEL OF oGrpSav NOBORDER WHEN .F. SIZE 7,7			
			@ 35,260 SAY oSayTro PROMPT STR0064 SIZE 70,7 COLOR CLR_BLUE OF oGrpSav PIXEL  //"Treinamento"
		   
			oSayCon:Hide()
			oSayLc:Hide()
			oChkConst:Hide()
			oSayTro:Hide()
			oChkLac:Hide()
			oChkConst:Hide()
			oChkTrei:Hide()
        Endif                     
          		         
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a Enchoice                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		RegToMemory("QM2",.T.)
		
		oEnchoice1:=MsMGet():New( cAlias, nReg, nOpc,,,,,;
								 {oSize:GetDimension("ENCHOICE","LININI"),;
								 oSize:GetDimension("ENCHOICE","COLINI"),;
								 oSize:GetDimension("ENCHOICE","LINEND"),;
								 oSize:GetDimension("ENCHOICE","COLEND")};
								,,,,,,oDlgC,,.T.,,,,,,,.T.)
        
		ACTIVATE MSDIALOG oDlgC ON INIT EnchoiceBar(oDlgC,{|| lRetn := qm010VeRes(M->QM2_FILRES,M->QM2_RESP),lRetn := Obrigatorio(aGets,aTela),IIf(lRetn,lRetn := QMA010VlLo(M->QM2_LOCAL),lRetn := .F.),;
		IIf(lRetn,lRetn := a010VlEscM(M->QM2_INSTR,M->QM2_LOCAL,M->QM2_ESCMAL,M->QM2_STATUS),lRetn:= .F.),;
		IIf(lRetn,lRetn := qmt010VlAf(.F.),lRetn := .F.),;
		IIf(lRetn,(qmt010SavAco(),lRetn := qmt010vcal(oDlgC,@nOpca,M->QM2_TIPO,M->QM2_INSTR,M->QM2_REVINS),nOpca := qmt010AcAcol(oDlgC),If(lRetn,.t.,nOpca := 3),If(nOpca == 1,(dbselectarea("QM2"),If(lRetn,oDlgC:End(),)),)),)},{|| nOpca := 2,oDlgC:End()}) CENTERED
		If nOpcA == 1          	
			//Veririca se existe faixas para que o instrumento seja incluido...
			For i := 1 To Len(aColsQMR)
				If !aColsQMR[i][Len(aColsQMR[i])]
					If !Empty(aColsQMR[i][1])//Devera existir dados na linha...
						lGravaOk := .T.				
						Exit
					Endif	
				Endif
			Next i
            
			If lGravaOk
				If lFzCal
					lGravaOk := .F.
					If Len(aColsQMG) > 0
    					For i := 1 to Len(aColsQMG)
							If !aColsQMG[i][Len(aColsQMG[i])]
								If !Empty(aColsQMG[i][1])//Devera existir dados na linha...
									lGravaOk := .T.				
									Exit
								Endif	
							Endif
    					Next i
					Else
						MessageDlg(STR0068,,3)
					Endif
				Endif
			Endif
			
			If lGravaOk 
				BEGIN TRANSACTION
				RecLock(cAlias,.T.)
				For i := 1 TO FCount()  
					If "_FILRES"$Field(i)
						FieldPut(i,M->QM2_FILRES)
					Else
						FieldPut(i,M->&(EVAL(bCampo,i)))
					EndIf
				Next i
				
				QM2->QM2_FILIAL:= xFilial("QM2")  
				QM2->QM2_REVINV := Inverte( QM2->QM2_REVINS ) 
				QM2->QM2_FLAG   := "1" // Flag para rotina de movim.de instrumento
				MsUnlock()     
				FKCommit()
				If lQMovIns
					dbSelectArea("QAA")
					dbSetOrder(1)
					If QAA->(DbSeek(QM2->QM2_FILRES+QM2->QM2_RESP))
						QMTAtuIDis(QM2->QM2_INSTR,QM2->QM2_REVINS,QM2->QM2_RESP,QM2->QM2_FILRES,QAA->QAA_CC,QM2->QM2_TIPO,"I")
					EndIf
	        	EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de Entrada para Tratamento da numeracao sequencial do instrumento.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("QMT010SEQ")
					ExecBlock("QMT010SEQ",.F., .F., {nOpc,QM2->QM2_INSTR,QM2->QM2_REVINS})
				EndIf

				//Realiza Gravacao das Escalas - QMR      
				a010GrvTr(cAlias,QM2->QM2_INSTR,QM2->QM2_REVINS)
				
				lGravaOk := A010grvPt(QM2->QM2_INSTR,QM2->QM2_REVINS)
				If !lGravaOK
					Help(" ",1,"A010NAOGRV")
				Else
					//Processa Gatilhos
					EvalTrigger()
				EndIf
				
				If Len(aColsQMC) > 0
					dbSelectArea("QMC")
					dbSetOrder(1)
					For i := 1 To Len(aColsQMC)
						If !dbSeek(xFilial("QMC")+aColsQMC[i][1]+Inverte(aColsQMC[i][2])+aColsQMC[i][3])	
							RecLock("QMC",.T.)
						Else			        	
							RecLock("QMC",.F.)
						Endif            
					
						Replace QMC->QMC_FILIAL	With xFilial("QMC")
						Replace QMC->QMC_ESCALA	With aColsQMC[i][1]
						Replace QMC->QMC_REVESC	With aColsQMC[i][2]
						Replace QMC->QMC_PADRAO	With aColsQMC[i][3]
						Replace QMC->QMC_TOLER	With aColsQMC[i][4]
						Replace QMC->QMC_TOLMIN	With aColsQMC[i][5]
						Replace QMC->QMC_TIPTOL	With aColsQMC[i][6]
						Replace QMC->QMC_REVINV	With Inverte(aColsQMC[i][2])
						MsUnLock()
					Next i
					If ExistBlock("QMT010QMC")
						ExecBlock("QMT010QMC",.F.,.F.,{QM2->QM2_INSTR,QM2->QM2_REVINS})
					Endif	
				Endif
				
				If Len(aTabPads) > 0
					dbSelectArea("QMA")
					dbSetOrder(1)
					For i := 1 To Len(aTabPads)
						If !dbSeek(xFilial("QMA")+aTabPads[i][9]+aTabPads[i][10]+aTabPads[i][6]+aTabPads[i][1])	
							RecLock("QMA",.T.)
							lVoinst := .T.
							Replace QMA->QMA_FILIAL	With xFilial("QMA")
							Replace QMA->QMA_ESCALA	With aTabPads[i][9]
							Replace QMA->QMA_REVESC	With aTabPads[i][10]
							Replace QMA->QMA_FAIXA	With aTabPads[i][6]
							Replace QMA->QMA_PADRAO	With aTabPads[i][1]
							Replace QMA->QMA_TOLER	With Alltrim(aTabPads[i][3])
							Replace QMA->QMA_TOLMIN	With Alltrim(aTabPads[i][4])
							Replace QMA->QMA_TIPTOL	With Alltrim(Substr(aTabPads[i][7],1,1))
							MsUnLock()
						Endif            
					Next i
					If ExistBlock("QMT010QMA")
						ExecBlock("QMT010QMA",.F.,.F.,{QM2->QM2_INSTR,QM2->QM2_REVINS})
					Endif	
				Endif			
	
				If nVals == 2
					//Atualizar o aCols auxiliar em caso de delecao de uma ou mais faixas...
					aColsQMR := aClone(aCols)
				Endif
	
				If Len(aColsGer) > 0
					For ni := 1 To Len(aColsQMR)
						nLcGer := aScan(aColsGer,{|x| Alltrim(x[1]) = Alltrim(aColsQMR[ni][1])})
						If nLcGer <= 0
							If !aColsQMR[ni][Len(aColsQMR[ni])] .and. !Empty(aColsQMR[ni][1])
								lVoinst := .T.
								dbSelectArea("QMK")
								dbSetOrder(1)
								If !dbSeek(xFilial()+M->QM2_TIPO+QM1->QM1_REVINV+aColsQMR[ni][1])
									RecLock("QMK",.T.)
									Replace QMK->QMK_FILIAL	With xFilial()
									Replace QMK->QMK_TIPO	With M->QM2_TIPO
									Replace QMK->QMK_REVTIP	With QM1->QM1_REVTIP
									Replace QMK->QMK_ESCALA	With aColsQMR[ni][1]
									Replace QMK->QMK_REVINV	With Inverte(QM1->QM1_REVTIP)	
									MsUnLock()									
								Endif
								If lQMT010QMK
									ExecBlock("QMT010QMK",.F.,.F.,{QM2->QM2_INSTR,QM2->QM2_REVINS})
								Endif	
							Endif	
						Else
							If aColsQMR[ni][Len(aColsQMR[ni])] //Se estiver deletado...
								dbSelectArea("QMK")
								dbSetOrder(1)
								If dbSeek(xFilial()+M->QM2_TIPO+QM1->QM1_REVINV+aColsQMR[ni][1])
									RecLock("QMK",.F.)
									dbDelete()
									MsUnLock()									
									lVoinst := .T.								
								Endif						
								//Se existir no QMR para na proxima montagem nao trazer o mesmo...
								dbSelectArea("QMR")
								dbSetOrder(1)
								If dbSeek(xFilial()+M->QM2_TIPO+QM1->QM1_REVTIP+aColsQMR[ni][1])
									RecLock("QMR",.F.)
									dbDelete()
									MsUnLock()									
									lVoinst := .T.								
								Endif						
							Endif												
						Endif	
					Next ni	
				Else
					For ni := 1 To Len(aColsQMR)
						If !aColsQMR[ni][Len(aColsQMR[ni])] .and. !Empty(aColsQMR[ni][1])
							lVoinst := .T.
							dbSelectArea("QMK")
							dbSetOrder(1)
							If !dbSeek(xFilial()+M->QM2_TIPO+QM1->QM1_REVINV+aColsQMR[ni][1])
								RecLock("QMK",.T.)
								Replace QMK->QMK_FILIAL	With xFilial()
								Replace QMK->QMK_TIPO	With M->QM2_TIPO
								Replace QMK->QMK_REVTIP	With QM1->QM1_REVTIP
								Replace QMK->QMK_ESCALA	With aColsQMR[ni][1]
								Replace QMK->QMK_REVINV	With Inverte(QM1->QM1_REVTIP)	
								MsUnLock()									
							Endif
							If lQMT010QMK
								ExecBlock("QMT010QMK",.F.,.F.,{QM2->QM2_INSTR,QM2->QM2_REVINS})
							Endif	  
						Endif	
					Next ni
				Endif			
	
				If lVoinst
					A030AtuIns(QM2->QM2_TIPO, QM1->QM1_REVINV, "S", .F.)				
				Endif
				
				If lNumSX8
					ConfirmSX8()
				EndIf
				
				aArea := QM2->(GetArea())
				
				QM2->(DbSkip())
				If QM2->(!EOF()) .AND. QM2->QM2_STATUS <> "I"
					Reclock("QM2",.F.)
						QM2->QM2_STATUS = "I"
					QM2->(MsUnlock())
				EndIf

				QM2->(ResTArea(aArea))
				
				END TRANSACTION

				If ExistBlock("CompInst")
					ExecBlock("CompInst",.F.,.F.,{QM2->QM2_INSTR, QM2->QM2_REVINS, nOpca}) // instrumento+rev atual
				EndIf              
            Else
            	MessageDlg(STR0089,,3) //"Nao foi possivel incluir/alterar o instrumento, pois nao existe faixa(s) relacionadas ao mesmo"
            Endif
		Else
		
			If lNumSX8
				RollBackSX8()
			EndIf
			//Ponto de entrada para tratamento do botao Cancela - Tela de Instrumentos
        	If ExistBlock("QM010CAC")
				ExecBlock("QM010CAC",.F.,.F.,{QM2->QM2_INSTR, QM2->QM2_REVINS,nOpca}) 
        	Endif
		EndIf 
	ElseIf nOpc == 4	// Alteracao
	    dbSelectArea("QM2")
	    lCtrlCalib := .T. 
		If QM2->QM2_REVINS <> QMA010UltR(QM2->QM2_INSTR)
			HELP(" ",1,"QMTALTREV") // Nao e possivel alterar esta revisao. Somente a ultima revisao pode ser alterada.
		Else
			If !QMA010Cal(QM2->QM2_INSTR,QM2->QM2_REVINS)
		  		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  			//³ Monta Dialog                                                 ³
	   			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 			DEFINE MSDIALOG oDlgC TITLE cCadastro ;  //"Cadastro Instrumentos"
					           		  FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
				dbSelectArea("QM2")  
			   
				@ oSize:GetDimension("BOTAO","LININI"),oSize:GetDimension("BOTAO","COLINI")     BUTTON oBtn3 PROMPT STR0079 SIZE 65, 11 OF oDlgC PIXEL ACTION (nVals := 1,qmta010TrBut(oDlgC,oEnchoice1,oBtn1)) //"&Cadastro"
				@ oSize:GetDimension("BOTAO","LININI"),oSize:GetDimension("BOTAO","COLINI")+97  BUTTON oBtn1 PROMPT STR0080 SIZE 65, 11 OF oDlgC PIXEL ACTION (nVals := 2,If(Obrigatorio(aGets,aTela),qmta010TrBut(oDlgC,oEnchoice1,oBtn1),))  //"&Escala(s)"
				@ oSize:GetDimension("BOTAO","LININI"),oSize:GetDimension("BOTAO","COLINI")+197 BUTTON oBtn2 PROMPT STR0081 SIZE 65, 11 OF oDlgC PIXEL ACTION (nVals := 3,qmta010TrBut(oDlgC,oEnchoice1,oBtn1)) //"&Pontos/Calibradores"
				
				If oSayEsc == Nil	
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta Panel Para Groups                                      ³    
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
					oPanel2:= tPanel():New(oSize2:GetDimension("PANEL","LININI"),oSize2:GetDimension("PANEL","COLINI"),,oDlgC,,,,/*CLR_YELLOW*/,/*CLR_BLUE*/,oSize2:GetDimension("PANEL","XSIZE"),oSize2:GetDimension("PANEL","YSIZE"))
					
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta Group                                                  ³    
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
				 	@ 003,000 Group oGrp    TO 45,120 LABEL STR0082 OF oPanel2 COLOR CLR_HRED PIXEL  //"Informacoes"
				 	@ 003,122 Group oGrpSit TO 45,240 LABEL STR0083 OF oPanel2 COLOR CLR_HRED PIXEL //"Situacao da Ult. Calibracao"
				 	@ 003,242 Group oGrpSav TO 45,360 LABEL STR0057 OF oPanel2 COLOR CLR_HRED PIXEL //"Salva Guarda"

					oGrp:Hide()  
					oPanel2:Hide()
					oGrpSit:Hide()
					oGrpSav:Hide()
					cBmp1  := "LBNO"
					cBmp2  := "LBNO"
					cBmp3  := "LBNO"			
					cBmp4  := "LBNO"			
					cBmp5  := "LBNO"
					cBmp6  := "LBNO"
					cBmp7  := "LBNO"			
		
					//Primeiro Group - Informacoes
					@ 15,6  SAY oSayEsc PROMPT OemToAnsi(STR0012)+" : "+AllTrim(M->QM2_INSTR)+" - "+AllTrim(M->QM2_REVINS) SIZE 140,7 COLOR CLR_BLUE OF oGrp PIXEL 
					@ 25,6  SAY oSayFam PROMPT STR0065+AllTrim(M->QM2_TIPO) SIZE 140,7 COLOR CLR_BLUE OF oGrp PIXEL //"Familia : "
								
					oSayEsc:Hide()
					oSayFam:Hide()
							
				
					//Segundo Group - Situacao da Ult. Calibracao               
		
					@ 15,130 BITMAP oChkCal RESOURCE cBmp1 PIXEL OF oGrp NOBORDER WHEN .F. SIZE 7,7
					@ 15,140  SAY oSayCali PROMPT STR0058 SIZE 70,7 COLOR CLR_BLUE OF oGrp PIXEL 
					 
					oChkCal:Hide()
					oSayCali:Hide()
							
					@ 15,170 BITMAP oChkApro RESOURCE cBmp2 SIZE 7,7 OF oGrpSit NOBORDER WHEN .F. PIXEL			
					@ 15,180  SAY oSayApro PROMPT STR0059 SIZE 70,7 COLOR CLR_BLUE OF oGrpSit PIXEL  //Aprovado
					@ 25,170 BITMAP oChkApCo RESOURCE cBmp3 PIXEL OF oGrpSit NOBORDER WHEN .F. SIZE 7,7			
					@ 25,180  SAY oSayAC PROMPT STR0060 SIZE 70,7 COLOR CLR_BLUE OF oGrpSit PIXEL //"Aprovado Condicional"	
					@ 35,170 BITMAP oChkRepro RESOURCE cBmp4 PIXEL OF oGrpSit NOBORDER WHEN .F. SIZE 7,7			
					@ 35,180  SAY oSayRe PROMPT STR0061 SIZE 70,7 COLOR CLR_BLUE OF oGrpSit PIXEL //"Reprovado"	
		
					oSayAC:Hide()
					oSayRe:Hide()
					oSayApro:Hide()
					oChkApro:Hide()                 
					oChkApCo:Hide()
					oChkRepro:Hide()			
					
					//Terceiro Group - Salva Guarda
					@ 15,250 BITMAP oChkLac RESOURCE cBmp5 PIXEL OF oGrpSav NOBORDER WHEN .F. SIZE 7,7			
					@ 15,260 SAY oSayLc PROMPT STR0062 SIZE 70,7 COLOR CLR_BLUE OF oGrpSav PIXEL //"Lacre"
					@ 25,250 BITMAP oChkConst RESOURCE cBmp6 PIXEL OF oGrpSav NOBORDER WHEN .F. SIZE 7,7			
					@ 25,260 SAY oSayCon PROMPT STR0063 SIZE 70,7 COLOR CLR_BLUE OF oGrpSav PIXEL //Construcao                         			
					@ 35,250 BITMAP oChkTrei RESOURCE cBmp7 PIXEL OF oGrpSav NOBORDER WHEN .F. SIZE 7,7			
					@ 35,260 SAY oSayTro PROMPT STR0064 SIZE 70,7 COLOR CLR_BLUE OF oGrpSav PIXEL  //"Treinamento"
				   
					oSayCon:Hide()
					oSayLc:Hide()
					oChkConst:Hide()
					oSayTro:Hide()
					oChkLac:Hide()
					oChkConst:Hide()
					oChkTrei:Hide()
		        Endif                     
		          				         
		        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta a Enchoice                                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				RegToMemory("QM2",.F.)
				
				oEnchoice1:=MsMGet():New( cAlias, nReg, nOpc,,,,,;
										 {oSize:GetDimension("ENCHOICE","LININI"),;
										 oSize:GetDimension("ENCHOICE","COLINI"),;
										 oSize:GetDimension("ENCHOICE","LINEND"),;
										 oSize:GetDimension("ENCHOICE","COLEND")};
										,,,,,,oDlgC,,.T.,,,,,,,.T.)     

				qmt010VerPtos(QM2->QM2_INSTR,QM2->QM2_REVINS,QM2->QM2_TIPO)
				aCols := {}
				aHeader := {}
				A010CaTR(QM2->QM2_TIPO,QM2->QM2_INSTR,QM2->QM2_REVINS)
				If oGetFi <> Nil
					oGetFi:oBrowse:lDisablePaint := .t.
					oGetFi:Hide()
					aColsQMR := aClone(aCols)
					aHeaderQMR := aClone(aHeader)
					
					If !lFzCal
						oBtn2:Disable()
					Else
						aCols := {}
						aHeader := {}
						A010CaPo(QM2->QM2_TIPO,QM2->QM2_INSTR,QM2->QM2_REVINS,oDlgC)
						oGetPto:oBrowse:lDisablePaint := .t.
						oGetPto:Hide()
						aColsQMG := aClone(aCols)
						aHeaderQMG := aClone(aHeader)
					Endif
				Else
					oBtn1:Disable()
					oBtn1:Refresh()
					oBtn2:Disable()
					oBtn2:Refresh()
					oBtn3:Disable()
					oBtn3:Refresh()
				Endif

				//No activate verifca se:
				// - Todos os campos obrigatorios foram digitados;
				// - Instrumento principal pertence ao tipo malha;
				// - Escala do instrumento malha pertence ao tipo malha;
				// - Salva integridade de acols;
				// - Verifica se existe pontos de calibradores/calibradores completos
                dbSelectArea("QM2")
                				
				ACTIVATE MSDIALOG oDlgC ON INIT EnchoiceBar(oDlgC,{|| lReta := qm010VeRes(M->QM2_FILRES,M->QM2_RESP),lRetn := Obrigatorio(aGets,aTela),;
				IIf(lRetn,IIf(lRetn,lRetn := QMA010VlLo(M->QM2_LOCAL),lRetn := .F.),),IIf(lretn,;
				lRetn := a010VlEscM(M->QM2_INSTR,M->QM2_LOCAL,M->QM2_ESCMAL,M->QM2_STATUS),),;
				IIf(lRetn,(qmt010SavAco(),lOk := qmt010vcal(oDlgC,@nOpca,M->QM2_TIPO,M->QM2_INSTR,M->QM2_REVINS),;
				If(lRetn,if(lOk,lOk := qmt010VlAf(.F.),),lRetn := .F.),;
				If(lOk,(nOpca := qmt010AcAcol(oDlgC),a010CaJu(),lTud := qmt010VerRev(oDlgC,@nOpca),If(nOpca == 1,If(lReta,oDlgC:End(),),nOpca := 1)),)),)},{|| nOpca := 2,oDlgC:End()}) CENTERED
			 

				If nOpcA == 1
					If !Empty(QM2->QM2_CHAVE)
						A010GvJu(cMemoJu)        	
					EndIf	

					//Grava alteracoes do QM2 - Cadastro de Instrumentos			
					RecLock("QM2",.F.)
					For i := 1 TO FCount()
						FieldPut(i,M->&(EVAL(bCampo,i)))
					Next i
                    MsUnLock()
    
				    //Verifica se incluiu ou alterou faixas do QMK...
					A010AltEs(@lIncEs,@lAltEs)		     
				
					If lIncEs .or. lAltEs
						lVoInst := .T.
						A010grves(cAlias)	
					Endif

					//Realiza Gravacao das Escalas - QMR      
					a010GrvTr(cAlias,QM2->QM2_INSTR,QM2->QM2_REVINS)
			
					//Realiza Gravacao dos Pontos - Escala Calibradores/Calibradores Completos
					lGravaOk := A010grvPt(QM2->QM2_INSTR,QM2->QM2_REVINS)

					If !lGravaOK
						Help(" ",1,"A010NAOGRV")
					Else
						//Processa Gatilhos
						EvalTrigger()
					EndIf
			
					If ExistBlock("CompInst")
						ExecBlock("CompInst",.F.,.F.,{QM2->QM2_INSTR, QM2->QM2_REVINS, nOpca}) // instrumento+rev atual
					EndIf
					
					If Len(aColsQMC) > 0
						dbSelectArea("QMC")
						dbSetOrder(1)
						For i := 1 To Len(aColsQMC)
							If !dbSeek(xFilial("QMC")+aColsQMC[i][1]+Inverte(aColsQMC[i][2])+aColsQMC[i][3])	
								RecLock("QMC",.T.)
							Else			        	
								RecLock("QMC",.F.)
							Endif            
						
							Replace QMC->QMC_FILIAL	With xFilial("QMC")
							Replace QMC->QMC_ESCALA	With aColsQMC[i][1]
							Replace QMC->QMC_REVESC	With aColsQMC[i][2]
							Replace QMC->QMC_PADRAO	With aColsQMC[i][3]
							Replace QMC->QMC_TOLER	With aColsQMC[i][4]
							Replace QMC->QMC_TOLMIN	With aColsQMC[i][5]
							Replace QMC->QMC_TIPTOL	With aColsQMC[i][6]
							Replace QMC->QMC_REVINV	With Inverte(aColsQMC[i][2])
							MsUnLock()
						Next i
					Endif
					
					If Len(aTabPads) > 0
						dbSelectArea("QMA")
						dbSetOrder(1)
						For i := 1 To Len(aTabPads)
							If !dbSeek(xFilial("QMA")+aTabPads[i][9]+aTabPads[i][10]+aTabPads[i][6]+aTabPads[i][1])	
								RecLock("QMA",.T.)
								lVoinst := .T.
								Replace QMA->QMA_FILIAL	With xFilial("QMA")
								Replace QMA->QMA_ESCALA	With aTabPads[i][9]
								Replace QMA->QMA_REVESC	With aTabPads[i][10]
								Replace QMA->QMA_FAIXA	With aTabPads[i][6]
								Replace QMA->QMA_PADRAO	With aTabPads[i][1]
								Replace QMA->QMA_TOLER	With Alltrim(aTabPads[i][3])
								Replace QMA->QMA_TOLMIN	With Alltrim(aTabPads[i][4])
								Replace QMA->QMA_TIPTOL	With Alltrim(Substr(aTabPads[i][7],1,1))
							MsUnLock()
							Endif            
						Next i
					Endif			

					If nVals == 2
						//Atualizar o aCols auxiliar em caso de delecao de uma ou mais escalas...
						aColsQMR := aClone(aCols)
					Endif

					If Len(aColsGer) > 0
						For ni := 1 To Len(aColsQMR)
							nLcGer := aScan(aColsGer,{|x| Alltrim(x[1]) = Alltrim(aColsQMR[ni][1])})
							If nLcGer <= 0
								If !aColsQMR[ni][Len(aColsQMR[ni])]
									lVoinst := .T.
									dbSelectArea("QMK")
									dbSetOrder(1)
									If !dbSeek(xFilial()+M->QM2_TIPO+QM1->QM1_REVINV+aColsQMR[ni][1])
										RecLock("QMK",.T.)
										Replace QMK->QMK_FILIAL	With xFilial()
										Replace QMK->QMK_TIPO	With M->QM2_TIPO
										Replace QMK->QMK_REVTIP	With QM1->QM1_REVTIP
										Replace QMK->QMK_ESCALA	With aColsQMR[ni][1]
										Replace QMK->QMK_REVINV	With Inverte(QM1->QM1_REVTIP)	
										MsUnLock()									
									Endif
								Endif	
							Else
								If aColsQMR[ni][Len(aColsQMR[ni])] //Se estiver deletado...
									If dbSeek(xFilial()+M->QM2_TIPO+QM1->QM1_REVINV+aColsQMR[ni][1])
										RecLock("QMK",.F.)
										dbDelete()
										MsUnLock()									
										lVoinst := .T.
									Endif						
									//Se existir no QMR para na proxima montagem nao trazer o mesmo...
									dbSelectArea("QMR")
									dbSetOrder(1)
									If dbSeek(xFilial()+M->QM2_TIPO+QM1->QM1_REVTIP+aColsQMR[ni][1])
										RecLock("QMR",.F.)
										dbDelete()
										MsUnLock()									
										lVoinst := .T.								
									Endif						
								Endif																			
							Endif	
						Next ni	
					Endif			
		
					If lVoinst
						A030AtuIns(QM2->QM2_TIPO, QM1->QM1_REVINV, "S", .F.)				
					Endif					
				Else
					//Ponto de entrada para tratamento do botao Cancela - Tela de Instrumentos
        			If ExistBlock("QM010CAC")
						ExecBlock("QM010CAC",.F.,.F.,{QM2->QM2_INSTR, QM2->QM2_REVINS,nOpca}) 
        			Endif
				EndIF
			Else
				lAltRevisao := .T.
				cTipoAnt	:= QM2->QM2_TIPO
				lCtrlCalib := .T.
                dbSelectArea("QM2")    
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta Dialog                                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DEFINE MSDIALOG oDlgC TITLE cCadastro ;  //"Cadastro Instrumentos"
										FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
				
				@ oSize:GetDimension("BOTAO","LININI"),oSize:GetDimension("BOTAO","COLINI")     BUTTON oBtn3 PROMPT STR0079 SIZE 65, 11 OF oDlgC PIXEL ACTION (nVals := 1,qmta010TrBut(oDlgC,oEnchoice1,oBtn1)) //"&Cadastro"
	  			@ oSize:GetDimension("BOTAO","LININI"),oSize:GetDimension("BOTAO","COLINI")+97  BUTTON oBtn1 PROMPT STR0080 SIZE 65, 11 OF oDlgC PIXEL ACTION (nVals := 2,If(Obrigatorio(aGets,aTela),(qmt010VerRev(oDlgC),qmta010TrBut(oDlgC,oEnchoice1,oBtn1)),)) //"&Escala(s)"
	   			@ oSize:GetDimension("BOTAO","LININI"),oSize:GetDimension("BOTAO","COLINI")+197 BUTTON oBtn2 PROMPT STR0081 SIZE 65, 11 OF oDlgC PIXEL ACTION (nVals := 3,qmta010TrBut(oDlgC,oEnchoice1,oBtn1)) //"&Pontos/Calibradores"
				
				If oSayEsc == Nil	
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta Panel Para Groups                                      ³    
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
					oPanel2:= tPanel():New(oSize2:GetDimension("PANEL","LININI"),oSize2:GetDimension("PANEL","COLINI"),,oDlgC,,,,/*CLR_YELLOW*/,/*CLR_BLUE*/,oSize2:GetDimension("PANEL","XSIZE"),oSize2:GetDimension("PANEL","YSIZE"))
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta Group                                                  ³    
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
				 	@ 003,000 Group oGrp    TO 45,120 LABEL STR0082 OF oPanel2 COLOR CLR_HRED PIXEL  //"Informacoes"
				 	@ 003,122 Group oGrpSit TO 45,240 LABEL STR0083 OF oPanel2 COLOR CLR_HRED PIXEL //"Situacao da Ult. Calibracao"
				 	@ 003,242 Group oGrpSav TO 45,360 LABEL STR0057 OF oPanel2 COLOR CLR_HRED PIXEL //"Salva Guarda"
		
					oGrp:Hide()  
					oPanel2:Hide()
					oGrpSit:Hide()
					oGrpSav:Hide()
					cBmp1  := "LBNO"
					cBmp2  := "LBNO"
					cBmp3  := "LBNO"			
					cBmp4  := "LBNO"			
					cBmp5  := "LBNO"
					cBmp6  := "LBNO"
					cBmp7  := "LBNO"			
		
					//Primeiro Group - Informacoes
					@ 15,6  SAY oSayEsc PROMPT OemToAnsi(STR0012)+" : "+AllTrim(M->QM2_INSTR)+" - "+AllTrim(M->QM2_REVINS) SIZE 140,7 COLOR CLR_BLUE OF oGrp PIXEL 
					@ 25,6  SAY oSayFam PROMPT STR0065+AllTrim(M->QM2_TIPO) SIZE 140,7 COLOR CLR_BLUE OF oGrp PIXEL //"Familia : "
								
					oSayEsc:Hide()
					oSayFam:Hide()
							
				
					//Segundo Group - Situacao da Ult. Calibracao               
		
					@ 15,130 BITMAP oChkCal RESOURCE cBmp1 PIXEL OF oGrp NOBORDER WHEN .F. SIZE 7,7
					@ 15,140  SAY oSayCali PROMPT STR0058 SIZE 70,7 COLOR CLR_BLUE OF oGrp PIXEL 
					 
					oChkCal:Hide()
					oSayCali:Hide()
							
					@ 15,170 BITMAP oChkApro RESOURCE cBmp2 SIZE 7,7 OF oGrpSit NOBORDER WHEN .F. PIXEL			
					@ 15,180  SAY oSayApro PROMPT STR0059 SIZE 70,7 COLOR CLR_BLUE OF oGrpSit PIXEL  //Aprovado
					@ 25,170 BITMAP oChkApCo RESOURCE cBmp3 PIXEL OF oGrpSit NOBORDER WHEN .F. SIZE 7,7			
					@ 25,180  SAY oSayAC PROMPT STR0060 SIZE 70,7 COLOR CLR_BLUE OF oGrpSit PIXEL //"Aprovado Condicional"	
					@ 35,170 BITMAP oChkRepro RESOURCE cBmp4 PIXEL OF oGrpSit NOBORDER WHEN .F. SIZE 7,7			
					@ 35,180  SAY oSayRe PROMPT STR0061 SIZE 70,7 COLOR CLR_BLUE OF oGrpSit PIXEL //"Reprovado"	
		
					oSayAC:Hide()
					oSayRe:Hide()
					oSayApro:Hide()
					oChkApro:Hide()                 
					oChkApCo:Hide()
					oChkRepro:Hide()			
					
					//Terceiro Group - Salva Guarda
					@ 15,250 BITMAP oChkLac RESOURCE cBmp5 PIXEL OF oGrpSav NOBORDER WHEN .F. SIZE 7,7			
					@ 15,260 SAY oSayLc PROMPT STR0062 SIZE 70,7 COLOR CLR_BLUE OF oGrpSav PIXEL //"Lacre"
					@ 25,250 BITMAP oChkConst RESOURCE cBmp6 PIXEL OF oGrpSav NOBORDER WHEN .F. SIZE 7,7			
					@ 25,260 SAY oSayCon PROMPT STR0063 SIZE 70,7 COLOR CLR_BLUE OF oGrpSav PIXEL //Construcao                         			
					@ 35,250 BITMAP oChkTrei RESOURCE cBmp7 PIXEL OF oGrpSav NOBORDER WHEN .F. SIZE 7,7			
					@ 35,260 SAY oSayTro PROMPT STR0064 SIZE 70,7 COLOR CLR_BLUE OF oGrpSav PIXEL  //"Treinamento"
				   
					oSayCon:Hide()
					oSayLc:Hide()
					oChkConst:Hide()
					oSayTro:Hide()
					oChkLac:Hide()
					oChkConst:Hide()
					oChkTrei:Hide()
		        Endif                     
		          	         
		        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta a Enchoice                                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oEnchoice1:=MsMGet():New( cAlias, nReg, nOpc,,,,,;
										 {oSize:GetDimension("ENCHOICE","LININI"),;
										 oSize:GetDimension("ENCHOICE","COLINI"),;
										 oSize:GetDimension("ENCHOICE","LINEND"),;
										 oSize:GetDimension("ENCHOICE","COLEND")};
										,,,,,,oDlgC,,.T.,,,,,,,.T.)                     
								
				qmt010VerPtos(M->QM2_INSTR,M->QM2_REVINS,M->QM2_TIPO)
				aCols := {}
				aHeader := {}
				A010CaTR(QM2->QM2_TIPO,QM2->QM2_INSTR,QM2->QM2_REVINS)
				If oGetFi <> Nil
					oGetFi:oBrowse:lDisablePaint := .t.
					oGetFi:Hide()
					aColsQMR := aClone(aCols)
					aHeaderQMR := aClone(aHeader)

					If !lFzCal
						oBtn2:Disable()
					Else
						aCols := {}
						aHeader := {}
						A010CaPo(M->QM2_TIPO,M->QM2_INSTR,M->QM2_REVINS,oDlgC)				
						oGetPto:oBrowse:lDisablePaint := .t.
						oGetPto:Hide()
						aColsQMG := aClone(aCols)
						aHeaderQMG := aClone(aHeader)
					Endif	
                Else
					oBtn1:Disable()                
					oBtn1:Refresh()
					oBtn2:Disable()                
					oBtn2:Refresh()
					oBtn3:Disable()                					
					oBtn3:Refresh()                					
                Endif        
                dbSelectArea("QM2")
				ACTIVATE MSDIALOG oDlgC ON INIT EnchoiceBar(oDlgC,{|| lReta := qm010VeRes(M->QM2_FILRES,M->QM2_RESP),lRetn := Obrigatorio(aGets,aTela),;
					IIf(lRetn,IIf(lRetn,lRetn := QMA010VlLo(M->QM2_LOCAL),lRetn := .F.),),IIf(lretn, ;
					lRetn := a010VlEscM(M->QM2_INSTR,M->QM2_LOCAL,M->QM2_ESCMAL,M->QM2_STATUS),),;				
			        IIf(lRetn,(qmt010SavAco(),;
					lOk := qmt010vcal(oDlgC,@nOpca,M->QM2_TIPO,M->QM2_INSTR,M->QM2_REVINS),;
					If(lOk,(nOpca := qmt010AcAcol(oDlgC),a010CaJu(),lTud := qmt010VerRev(oDlgC,@nOpca),If(nOpca == 1,oDlgC:End(),nOpca := 2)),)),)},;
					{|| nOpca := 2,oDlgC:End()}) CENTERED 
					
				

				If nOpcA == 1 // Confirmou a alteracao e gerou nova Revisao
					If !lTud
						RecLock("QM2",.F.)
						For i := 1 TO FCount()
							FieldPut(i,M->&(EVAL(bCampo,i)))
						Next i
	
                    Else                  
	                    QM2->(dbSetOrder(1))
	                    If QM2->(dbSeek(xFilial("QM2")+M->QM2_INSTR+Inverte(cRevAnt)))
		                    RecLock("QM2",.F.) //Grava campos do registro anterior
    						Replace QM2->QM2_REVINV With Inverte(QM2->QM2_REVINS)					
							Replace QM2->QM2_FLAG With "2"
							Replace QM2->QM2_STATUS With "I"					
							MsUnLock()
                		Endif
						
						RecLock("QM2",.T.)
						For i := 1 TO FCount()
							If "_FILRES"$Field(i)
								FieldPut(i,M->QM2_FILRES)
							Else
								FieldPut(i,M->&(EVAL(bCampo,i)))
							EndIf
						Next i
						 		
						QM2->QM2_REVINV := Inverte( QM2->QM2_REVINS ) 
						QM2->QM2_FLAG   := "1" // Flag para rotina de movim.de instrumento
						//QM2->QM2_FILRES := cFilAnt
						MsUnlock()  
						FKCommit()
            		Endif

					If cTipoAnt == QM2->QM2_TIPO			
						QA010Dupl("QMG",QM2->QM2_INSTR,QM2->QM2_REVINS,cRevAnt,"QMG->QMG_FILIAL+QMG->QMG_INSTR+QMG->QMG_REVINS","QMG_REVINS")
						QA010Dupl("QMR",QM2->QM2_INSTR,QM2->QM2_REVINS,cRevAnt,"QMR->QMR_FILIAL+QMR->QMR_INSTR+QMR->QMR_REVINS","QMR_REVINS")
					EndIf					
					DbSelectArea("QM2")
					M->QM2_REVINS := QM2->QM2_REVINS
					IF lQMovIns
						cIndice := CriaTrab(NIL,.F.)
						cChvQET := "QN5_INSTR+QN5_REVINS"
						cQuery  := "QN5_INSTR=='"+QM2->QM2_INSTR+"'.And."
						cQuery  += "QN5_REVINS =='"+cRevAnt+"'"
			                		
						IndRegua("QN5",cIndice,cChvQET,,cQuery,STR0041) // Selecionando Registros. . .
						nIndice := RetIndex("QN5")
						dbSetOrder(nIndice+1)
						If DbSeek(QM2->QM2_INSTR+cRevAnt)
							while QN5->(!EOF()) .and. QN5->QN5_INSTR == QM2->QM2_INSTR
								Reclock("QN5",.F.)
									QN5->QN5_REVINS:=QM2->QM2_REVINS
								MsUnlock()          
								QN5->(DbSkip())
							enddo
						Else
						    If lQMovIns
					           dbSelectArea("QAA")
					           dbSetOrder(1)
					             If QAA->(DbSeek(QM2->QM2_FILRES+QM2->QM2_RESP))
						            QMTAtuIDis(QM2->QM2_INSTR,QM2->QM2_REVINS,QM2->QM2_RESP,QM2->QM2_FILRES,QAA->QAA_CC,QM2->QM2_TIPO,"I")
					             EndIf
					             lGerou:=.T.
	        	            EndIf 
						Endif
					   	If !lGerou
							Ferase(cIndice + OrdBagExt())
	
							cIndice := CriaTrab(NIL,.F.)
							cChvQET := "QN4_INSTR+QN4_REVINS"
							cQuery  := "QN4_INSTR=='"+QM2->QM2_INSTR+"'.And."
							cQuery  += "QN4_REVINS =='"+cRevAnt+"'"
			                		
							IndRegua("QN4",cIndice,cChvQET,,cQuery,STR0041) // Selecionando Registros. . .
							nIndice := RetIndex("QN4")
							dbSetOrder(nIndice+1)
							If DbSeek(QM2->QM2_INSTR+cRevAnt)
							while QN4->(!EOF()) .and. QN4->QN4_INSTR == QM2->QM2_INSTR
								Reclock("QN4",.F.)
									QN4->QN4_REVINS:=QM2->QM2_REVINS
								MsUnlock()       
								QN4->(DbSkip())   
							Enddo
						Endif 
						Ferase(cIndice + OrdBagExt())
						Endif   
					Endif
				Else
					//Ponto de entrada para tratamento do botao Cancela - Tela de Instrumentos
		        	If ExistBlock("QM010CAC")
						ExecBlock("QM010CAC",.F.,.F.,{QM2->QM2_INSTR, QM2->QM2_REVINS,nOpca}) 
		        	Endif
				EndIf
				If nOpca == 1 .Or. nOpca == 4	// Confirmou a Alteracao
					If !Empty(QM2->QM2_CHAVE)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Grava Justificativa.						           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						A010GvJu(cMemoJu)
					EndIf	
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava Tolerancia e Redutor para cada escala 		   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					a010GrvTr("QM2",QM2->QM2_INSTR,QM2->QM2_REVINS)      
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Cadastra Pontos para escala(s) calibrador(es)  		   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					A010grvPt(QM2->QM2_INSTR,QM2->QM2_REVINS)
						
					If ExistBlock("CompInst")
						ExecBlock("CompInst",.F.,.F.,{QM2->QM2_INSTR, QM2->QM2_REVINS, nOpca}) // instrumento+rev atual
					EndIf
					
					If Len(aColsQMC) > 0
						dbSelectArea("QMC")
						dbSetOrder(1)
						For i := 1 To Len(aColsQMC)
							If !dbSeek(xFilial("QMC")+aColsQMC[i][1]+Inverte(aColsQMC[i][2])+aColsQMC[i][3])	
								RecLock("QMC",.T.)
							Else			        	
								RecLock("QMC",.F.)
							Endif            
						
							Replace QMC->QMC_FILIAL	With xFilial("QMC")
							Replace QMC->QMC_ESCALA	With aColsQMC[i][1]
							Replace QMC->QMC_REVESC	With aColsQMC[i][2]
							Replace QMC->QMC_PADRAO	With aColsQMC[i][3]
							Replace QMC->QMC_TOLER	With aColsQMC[i][4]
							Replace QMC->QMC_TOLMIN	With aColsQMC[i][5]
							Replace QMC->QMC_TIPTOL	With aColsQMC[i][6]
							Replace QMC->QMC_REVINV	With Inverte(aColsQMC[i][2])
							MsUnLock()
						Next i
					Endif
					
					If Len(aTabPads) > 0
						dbSelectArea("QMA")
						dbSetOrder(1)
						For i := 1 To Len(aTabPads)
							If !dbSeek(xFilial("QMA")+aTabPads[i][9]+aTabPads[i][10]+aTabPads[i][6]+aTabPads[i][1])	
								RecLock("QMA",.T.)
								lVoinst := .T.
								Replace QMA->QMA_FILIAL	With xFilial("QMA")
								Replace QMA->QMA_ESCALA	With aTabPads[i][9]
								Replace QMA->QMA_REVESC	With aTabPads[i][10]
								Replace QMA->QMA_FAIXA	With aTabPads[i][6]
								Replace QMA->QMA_PADRAO	With aTabPads[i][1]
								Replace QMA->QMA_TOLER	With Alltrim(aTabPads[i][3])
								Replace QMA->QMA_TOLMIN	With Alltrim(aTabPads[i][4])
								Replace QMA->QMA_TIPTOL	With Alltrim(Substr(aTabPads[i][7],1,1))
							MsUnLock()
							Endif            
						Next i
					Endif			

					If nVals == 2 //Botao Escala 
						//Em caso de delecao de uma ou mais escalas...
						aColsQMR := aClone(aCols)
					Endif
		            
					If Len(aColsGer) > 0
						For ni := 1 To Len(aColsQMR)
							nLcGer := aScan(aColsGer,{|x| Alltrim(x[1]) = Alltrim(aColsQMR[ni][1])})
							If nLcGer <= 0
								If !aColsQMR[ni][Len(aColsQMR[ni])]
									lVoinst := .T.
									dbSelectArea("QMK")
									dbSetOrder(1)
									If !dbSeek(xFilial()+M->QM2_TIPO+QM1->QM1_REVINV+aColsQMR[ni][1])
										RecLock("QMK",.T.)
										Replace QMK->QMK_FILIAL	With xFilial()
										Replace QMK->QMK_TIPO	With M->QM2_TIPO
										Replace QMK->QMK_REVTIP	With QM1->QM1_REVTIP
										Replace QMK->QMK_ESCALA	With aColsQMR[ni][1]
										Replace QMK->QMK_REVINV	With Inverte(QM1->QM1_REVTIP)	
										MsUnLock()									
									Endif
								Endif	
							Else
								If aColsQMR[ni][Len(aColsQMR[ni])] //Se estiver deletado...
									dbSelectArea("QMK")
									dbSetOrder(1)
									If dbSeek(xFilial()+M->QM2_TIPO+QM1->QM1_REVINV+aColsQMR[ni][1])
										RecLock("QMK",.F.)
										dbDelete()
										MsUnLock()									
										lVoinst := .T. //Verificar se gera revisao de instrumento...
									Endif						
									//Se existir no QMR para na proxima montagem nao trazer o mesmo...
									dbSelectArea("QMR")
									dbSetOrder(1)
									If dbSeek(xFilial()+M->QM2_TIPO+QM1->QM1_REVTIP+aColsQMR[ni][1])
										RecLock("QMR",.F.)
										dbDelete()
										MsUnLock()									
										lVoinst := .T.								
									Endif															
//									dbSelectArea("QM2")
								Endif																			
							Endif	
						Next ni	
					Endif			
		
					If lVoinst
						A030AtuIns(QM2->QM2_TIPO, QM1->QM1_REVINV, "S", .F.)				
					Endif					
				EndIf				
			EndIf				
		EndIf		
	EndIf      
	
	SetKey(K_F4, { || Nil } )

	dbSelectArea(cAlias)
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010Dins ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 14/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exclusao de Instrumentos						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010DINS(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo									  ³±±
±±³			 ³ ExpN1 = Numero do registro 								  ³±±
±±³			 ³ ExpN2 = Opcao selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010DINS(cAlias,nReg,nOpc)
Local nOpcA 
Local oDlgC
Local cRevisao	:= ""
Local lApgQET	:= .T.
Local lApgQPT	:= .T.
Local lApgQI2	:= .T.
Local lDelQIEP	:= GetMv("MV_QAPQIEP") == "1"
Local cChvQET	:= ""
Local cChvQPT	:= ""
Local cIndice   := ""
Local cQuery    := ""
Local cChvQI2	:= ""
Local cVarPesq := ""
Local lDelqns   := .F.    //Controlm de Deleta a QN4 e QN5
Local lCompInsE := ExistBlock("CompInsE")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]
Private aEscs := {}
Private lPodeAlt := .F.
Private cFilMat

Private nPosPdr	 := 0		// Posicao QMC_PADRAO
Private nPosTol := 0		// Posicao QMC_TOLER
Private nOldTol
Private nOldTMin
Private nPosTMin := 0		//Posicao QMC_TOLMIN
Private nPosTpTt := 0

While .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA:=0
	RegToMemory("QM2",.F.)	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula dimensões oSize                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize := FwDefSize():New()
	oSize:AddObject( "ENCHOICE"  ,  100, 100, .T., .T., .T. ) // Totalmente dimensionavel	
	       
	oSize:lProp := .T. // Proporcional             
	oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
	
	oSize:Process() // Dispara os calculos  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Dialog                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgC TITLE cCadastro ;  //"Cadastro Instrumentos"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL	
	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a Enchoice                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEnchoice1:=MsMGet():New( cAlias, nReg, nOpc,,,,,;
							 {oSize:GetDimension("ENCHOICE","LININI"),;
							 oSize:GetDimension("ENCHOICE","COLINI"),;
							 oSize:GetDimension("ENCHOICE","LINEND"),;
							 oSize:GetDimension("ENCHOICE","COLEND")};
							,,,,,,oDlgC,,.T.,,,,,,,.T.)         
	
							 									 
	ACTIVATE MSDIALOG oDlgC ON INIT EnchoiceBar(oDlgC,{|| nOpca := 2,oDlgC:End()},{|| nOpca := 1,oDlgC:End()})CENTERED
	dbSelectArea(cAlias)
	If nOpcA == 2
		
		//Verifica se houve movimentação do instrumento
		//So permitira a inclusao se o instrumento foi incluido ou revisado e nao efetuou nenhuma outra movimentacao no QN4
		

		cQuery := "SELECT COUNT(*) MOVIMENTO"
		cQuery += " FROM " + RetSqlName("QN4")
		cQuery += " WHERE QN4_FILIAL = '" + xFilial("QN4") + "' AND "
		cQuery += " QN4_INSTR = '"  + QM2->QM2_INSTR + "' AND " 
		cQuery += " QN4_REVINS = '"  + QM2->QM2_REVINS + "' AND "
		cQuery += " QN4_FILINS = '" + xFilial("QN4") + "' AND" 
		cQuery += " D_E_L_E_T_<> '*' "					
							
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QN4TRB", .F., .T.)
		dbSelectArea("QN4TRB")
		   	    
	   	If QN4TRB->MOVIMENTO > 1 // Houve movimentação
	   		MsgAlert(STR0096)   //"Nao e possivel excluir este instrumento, pois existem movimentações entre filiais relacionadas a ele")
	   		Exit
	   	Elseif QN4TRB->MOVIMENTO = 1 // se houve apenas a inclusao permite a exclusão
	   		lDelqns = .T. //Indica se serão deletados os registros da QN4 e da QN5
	   		cVarPesq := QM2->QM2_INSTR+QM2->QM2_REVINS
	   	Endif
	   	         
  		QN4TRB->(dbCloseArea())

		
		
		cRevisao := QMA010UltR(QM2->QM2_INSTR)
		If QM2->QM2_REVINS <> cRevisao
			HELP(" ",1,"QMTDELREV") // Nao e possivel excluir esta revisao. Somente a ultima revisao pode ser excluida.
		Else
			QM6->(DbSetOrder(1))
			If QM6->(DbSeek(xFilial("QM6")+QM2->QM2_INSTR+QM2->QM2_REVINS))
				HELP(" ",1,"A010NEXCI") // N„o ‚ poss¡vel excluir este instrumento,
				// pois existem medi‡”es relacionadas a ele.
				Exit
			Else
				If lDelQIEP 

					cQuery := "SELECT QET_FILIAL,QET_INSTR,QET_REVINS"
					cQuery += " FROM " + RetSqlName("QET")
					cQuery += " QET WHERE QET.QET_FILIAL = '" + xFilial("QET") + "' AND "
					cQuery += " QET.QET_INSTR = '"  + QM2->QM2_INSTR + "' AND " 
					cQuery += " QET.QET_REVINS = '"  + QM2->QM2_REVINS + "' AND " 
					cQuery += " QET.D_E_L_E_T_<>'*' "					
	
					cQuery += " ORDER BY " + SqlOrder(QET->(IndexKey()))			
				
					dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QETTRB", .F., .T.)
					dbSelectArea("QETTRB")
		   	    
				   	If QETTRB->(!Eof())
						lApgQET := .F.	
				   	Endif           
	  				QETTRB->(dbCloseArea())																								
				Else
					lApgQET := .T.
				Endif				
			    
				If lDelQIEP 
					cQuery := "SELECT QPT_FILIAL,QPT_INSTR,QPT_REVINS"
					cQuery += " FROM " + RetSqlName("QPT")
					cQuery += " QPT WHERE QPT.QPT_FILIAL = '" + xFilial("QPT") + "' AND "
					cQuery += " QPT.QPT_INSTR = '"  + QM2->QM2_INSTR + "' AND " 
					cQuery += " QPT.QPT_REVINS = '"  + QM2->QM2_REVINS + "' AND " 
					cQuery += " QPT.D_E_L_E_T_<>'*' "					
	
					cQuery += " ORDER BY " + SqlOrder(QPT->(IndexKey()))			
				
					dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QPTTRB", .F., .T.)
					dbSelectArea("QPTTRB")
		   	    
				   	If QPTTRB->(!Eof())
						lApgQPT := .F.	
				   	Endif           
				   	QPTTRB->(dbCloseArea())  																								
				Else
					lApgQPT := .T.
				Endif				

				If lDelQIEP 
					cQuery := "SELECT QI2_FILIAL,QI2_INSTR,QI2_REVINS"
					cQuery += " FROM " + RetSqlName("QI2")
					cQuery += " QI2 WHERE QI2.QI2_FILIAL = '" + xFilial("QI2") + "' AND "
					cQuery += " QI2.QI2_INSTR = '"  + QM2->QM2_INSTR + "' AND " 
					cQuery += " QI2.QI2_REVINS = '"  + QM2->QM2_REVINS + "' AND " 
					cQuery += " QI2.D_E_L_E_T_<>'*' "					
	
					cQuery += " ORDER BY " + SqlOrder(QI2->(IndexKey()))			
				
					dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QI2TRB", .F., .T.)
					dbSelectArea("QI2TRB")
		   	    
				   	If QI2TRB->(!Eof())
						lApgQI2 := .F.	
				   	Endif           
				   	QI2TRB->(dbCloseArea())  																								
				Else
					lApgQI2 := .T.
				Endif				

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se Tipo = 4, deleta os Ptos tambem			   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lApgQET .and. lApgQPT .and. lApgQI2
					QMK->(dbSetOrder(1))
					If QMK->(DbSeek(xFilial("QMK")+QM2->QM2_TIPO))
						QM9->(DbSetOrder(1))
						If QM9->(DbSeek(xFilial("QM9")+QMK->QMK_ESCALA))
							If QM9->QM9_TIPAFE == '4' .Or. QM9->QM9_TIPAFE == '8'
								If QMG->(dbSeek( xFilial("QMG")+QM2->QM2_INSTR+QM2->QM2_REVINS ))
									Do While QMG->(!Eof()) 	.And. xFilial("QMG") == QMG->QMG_FILIAL ;
										.And. QMG->QMG_INSTR+QMG->QMG_REVINS == QM2->QM2_INSTR+QM2->QM2_REVINS
										RecLock("QMG",.F.,.T.)
										QMG->(dbDelete())
										MsUnlock()
										QMG->(dbSkip())
									EndDo
								EndIf
							EndIf
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Apaga Redutor/Tolerancia por Escala - QMR  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					QMR->(DbSetOrder(1))
					If QMR->(DbSeek(xFilial("QMR")+QM2->QM2_INSTR+QM2->QM2_REVINS))
						Do while QM2->QM2_INSTR+QM2->QM2_REVINS ==;
							QMR->QMR_INSTR+QMR->QMR_REVINS .and.;
							QM2->QM2_FILIAL == xFilial("QMR")
							RecLock("QMR",.F.,.T.)
							QMR->(DbDelete())
							MsUnlock()
							QMR->(DbSkip())
						EndDo
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Apaga tambem no QA2 -> Textos dos Instrumentos³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					QA_DelTxt(QM2->QM2_CHAVE,'QMTA010H') // QAXFUN
					QA_DelTxt(QM2->QM2_CHAVE,'QMTA010I') // QAXFUN
					A010DelTxt(QM2->QM2_CHAVE,'QMTA010S',"QA3")
					A010DelTxt(QM2->QM2_CHAVE,'QMTA010R',"QA3")
				
					If lCompInsE
	  					ExecBlock("CompInsE",.F.,.F.,{QM2->QM2_INSTR, QM2->QM2_REVINS, nOpca}) // instrumento+rev atual
	   			    EndIf
	
					RecLock(cAlias,.F.,.T.)
					dbDelete()
					MsUnlock()
					
					//Busca a ultima revisao antes da delecao e grava flag como revisao atual
					dbSelectArea("QM2")
					dbSetOrder(1)
					If dbSeek(xFilial("QM2")+QM2->QM2_INSTR)
						RecLock("QM2",.F.)
						Replace QM2->QM2_FLAG With "1"
						MsUnLock()
					Endif
				Else            
					HELP(" ",1,"A010NEIRE") //N„o ‚ poss¡vel excluir este instrumento, pois o mesmo esta 
					//relacionado no(s) ambiente(s) Inspecao de Processo e/ou Inspecao de Entradas.					
				Endif
			EndIf
		EndIf
	EndIf		
	Exit
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui a amarracao com os conhecimentos                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsDocument( Alias(), RecNo(), 2, , 3 ) 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Deleta amarração da QN4 e QN5³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if lQMovIns
	if lDelqns
	     DbselectArea("QN4")
	     DbSetOrder(1)
		If dbSeek(xFilial("QN4")+cVarPesq)
			RecLock("QN4",.F.)
			dbDelete()
			MsUnlock()
		Endif
		DbselectArea("QN5")      
	     DbSetOrder(1)
		If dbSeek(xFilial("QN5")+cVarPesq)
			RecLock("QN5",.F.)
			dbDelete()
			MsUnlock()
		Endif
	Endif
Endif

dbSelectArea(cAlias)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010VIns ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 27.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa atualizacao Instrumentos - Visualizacao			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010VIns(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo									  ³±±
±±³			 ³ ExpN1 = Numero do registro 							      ³±±
±±³			 ³ ExpN2 = Opcao selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010VIns(cAlias, nReg, nOpc)

Local bCampo,oDlgC,aPosEnch 
Local i := 0 
Private aTELA[0][0],aGETS[0],aVisDig := {},aHeader[0],aCols:={}
Private aEscs := {}    
Private lPodeAlt := .F.
Private oGetFi        
Private oGetPto
Private cFamilia := ""
Private aColsQMR := {} 	
Private aColsQMG := {} 	
Private aColsPto := {}	
Private aHeaderQMR := {} 	
Private aHeaderQMG := {} 	
Private cCampoNGR := GetMV("MV_QNGREV")
Private lFzCal	 := .F.
Private nPos := 0
Private nUsado:=0
Private lTud := .F.
Private	lNoMoAc := .f.
Private cRevAnt := ""
Private oSayEsc       
Private nVals :=1
Private oBtIncEs
Private aColsQMC := {}
Private aClsQMR2 := {} 	
Private lPrimeira:= .T.
Private	nOpcF := 2
Private aTbsQMA	 := {}
Private aTabGer	 := {}	
Private aTabPads := {}	
Private aColsGer := {} 	
Private	oSayAC
Private	oSayRe
Private	oSayApro
Private oSayCali
Private	oSayLc
Private	oSayTro
Private oBtn1,oBtn2,oBtn3,oBtn4
Private oGrp
Private oGrpCatr
Private oGrpSit
Private cBmp1
Private cBmp2
Private cBmp3
Private cBmp4
Private cBmp5
Private cBmp6
Private cBmp7
Private lCalibr
Private oSayTes
Private oChkCal
Private oChkApro
Private oChkApCo
Private oChkRepro
Private oSayFam
Private	oChkLac
Private	oChkConst
Private	oChkTrei
Private cFilMat
Private nPosPdr	 := 0		// Posicao QMC_PADRAO
Private nPosTol := 0		// Posicao QMC_TOLER
Private nOldTol
Private nOldTMin
Private nPosTMin := 0		//Posicao QMC_TOLMIN
Private nPosTpTt := 0
Private oSayTT

bCampo	:= {|nCPO| Field(nCPO) }

dbSelectArea("QM2")
//Localiza o registro no banco
For i := 1 To FCount()
	M->&( Eval( bCampo, I ) ) := FieldGet( I )
Next I

cRevAnt := M->QM2_REVINS
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões oSize                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New()
oSize:AddObject( "BOTAO"   ,  100, 4, .T., .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "ENCHOICE"  ,  100, 96, .T., .T., .T. ) // Totalmente dimensionavel	
       
oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões oSize2                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize2 := FwDefSize():New()
oSize2:aWorkArea := oSize:GetNextCallArea( "ENCHOICE" )

oSize2:AddObject( "PANEL"    ,  100, 18, .T., .T., .T. ) // Totalmente dimensionavel
oSize2:AddObject( "GROUP"    ,  100, 82, .T., .T., .T. ) // Totalmente dimensionavel	

oSize2:lProp := .T. // Proporcional             
oSize2:aMargins := { 3, 3, 0, 0 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize2:Process() // Dispara os calculos  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgC TITLE cCadastro ;  //"Cadastro Instrumentos"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL		     

				
@ oSize:GetDimension("BOTAO","LININI"),oSize:GetDimension("BOTAO","COLINI")     BUTTON oBtn3 PROMPT STR0079 SIZE 65, 11 OF oDlgC PIXEL ACTION (nVals := 1,qmta010TrBut(oDlgC,oEnchoice1,oBtn1)) //"&Cadastro"
@ oSize:GetDimension("BOTAO","LININI"),oSize:GetDimension("BOTAO","COLINI")+97  BUTTON oBtn1 PROMPT STR0080 SIZE 65, 11 OF oDlgC PIXEL ACTION (nVals := 2,qmta010TrBut(oDlgC,oEnchoice1,oBtn1)) //"&Escala"
@ oSize:GetDimension("BOTAO","LININI"),oSize:GetDimension("BOTAO","COLINI")+197 BUTTON oBtn2 PROMPT STR0081 SIZE 65, 11 OF oDlgC PIXEL ACTION (nVals := 3,qmta010TrBut(oDlgC,oEnchoice1,oBtn1)) //"&Pontos/Calibradores"
																					
If oSayEsc == Nil	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Panel Para Groups                                      ³    
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	oPanel2:= tPanel():New(oSize2:GetDimension("PANEL","LININI"),oSize2:GetDimension("PANEL","COLINI"),,oDlgC,,,,/*CLR_YELLOW*/,/*CLR_BLUE*/,oSize2:GetDimension("PANEL","XSIZE"),oSize2:GetDimension("PANEL","YSIZE"))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Group                                                  ³    
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
 	@ 003,000 Group oGrp    TO 45,120 LABEL STR0082 OF oPanel2 COLOR CLR_HRED PIXEL  //"Informacoes"
 	@ 003,122 Group oGrpSit TO 45,240 LABEL STR0083 OF oPanel2 COLOR CLR_HRED PIXEL //"Situacao da Ult. Calibracao"
 	@ 003,242 Group oGrpSav TO 45,360 LABEL STR0057 OF oPanel2 COLOR CLR_HRED PIXEL //"Salva Guarda"

	oGrp:Hide()  
	oPanel2:Hide()
	oGrpSit:Hide()
	oGrpSav:Hide()
	cBmp1  := "LBNO"
	cBmp2  := "LBNO"
	cBmp3  := "LBNO"			
	cBmp4  := "LBNO"			
	cBmp5  := "LBNO"
	cBmp6  := "LBNO"
	cBmp7  := "LBNO"			

	//Primeiro Group - Informacoes
	@ 15,6  SAY oSayEsc PROMPT OemToAnsi(STR0012)+" : "+AllTrim(M->QM2_INSTR)+" - "+AllTrim(M->QM2_REVINS) SIZE 140,7 COLOR CLR_BLUE OF oGrp PIXEL 
	@ 25,6  SAY oSayFam PROMPT STR0065+AllTrim(M->QM2_TIPO) SIZE 140,7 COLOR CLR_BLUE OF oGrp PIXEL //"Familia : "
				
	oSayEsc:Hide()
	oSayFam:Hide()
			

	//Segundo Group - Situacao da Ult. Calibracao               

	@ 15,130 BITMAP oChkCal RESOURCE cBmp1 PIXEL OF oGrp NOBORDER WHEN .F. SIZE 7,7
	@ 15,140  SAY oSayCali PROMPT STR0058 SIZE 70,7 COLOR CLR_BLUE OF oGrp PIXEL 
	 
	oChkCal:Hide()
	oSayCali:Hide()
			
	@ 15,170 BITMAP oChkApro RESOURCE cBmp2 SIZE 7,7 OF oGrpSit NOBORDER WHEN .F. PIXEL			
	@ 15,180  SAY oSayApro PROMPT STR0059 SIZE 70,7 COLOR CLR_BLUE OF oGrpSit PIXEL  //Aprovado
	@ 25,170 BITMAP oChkApCo RESOURCE cBmp3 PIXEL OF oGrpSit NOBORDER WHEN .F. SIZE 7,7			
	@ 25,180  SAY oSayAC PROMPT STR0060 SIZE 70,7 COLOR CLR_BLUE OF oGrpSit PIXEL //"Aprovado Condicional"	
	@ 35,170 BITMAP oChkRepro RESOURCE cBmp4 PIXEL OF oGrpSit NOBORDER WHEN .F. SIZE 7,7			
	@ 35,180  SAY oSayRe PROMPT STR0061 SIZE 70,7 COLOR CLR_BLUE OF oGrpSit PIXEL //"Reprovado"	

	oSayAC:Hide()
	oSayRe:Hide()
	oSayApro:Hide()
	oChkApro:Hide()                 
	oChkApCo:Hide()
	oChkRepro:Hide()			
	
	//Terceiro Group - Salva Guarda
	@ 15,250 BITMAP oChkLac RESOURCE cBmp5 PIXEL OF oGrpSav NOBORDER WHEN .F. SIZE 7,7			
	@ 15,260 SAY oSayLc PROMPT STR0062 SIZE 70,7 COLOR CLR_BLUE OF oGrpSav PIXEL //"Lacre"
	@ 25,250 BITMAP oChkConst RESOURCE cBmp6 PIXEL OF oGrpSav NOBORDER WHEN .F. SIZE 7,7			
	@ 25,260 SAY oSayCon PROMPT STR0063 SIZE 70,7 COLOR CLR_BLUE OF oGrpSav PIXEL //Construcao                         			
	@ 35,250 BITMAP oChkTrei RESOURCE cBmp7 PIXEL OF oGrpSav NOBORDER WHEN .F. SIZE 7,7			
	@ 35,260 SAY oSayTro PROMPT STR0064 SIZE 70,7 COLOR CLR_BLUE OF oGrpSav PIXEL  //"Treinamento"
   
	oSayCon:Hide()
	oSayLc:Hide()
	oChkConst:Hide()
	oSayTro:Hide()
	oChkLac:Hide()
	oChkConst:Hide()
	oChkTrei:Hide()
Endif                     
          	         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a Enchoice                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oEnchoice1:=MsMGet():New( cAlias, nReg, nOpc,,,,,;
				     	 {oSize:GetDimension("ENCHOICE","LININI"),;
					     oSize:GetDimension("ENCHOICE","COLINI"),;
				     	 oSize:GetDimension("ENCHOICE","LINEND"),;
				     	 oSize:GetDimension("ENCHOICE","COLEND")};
			        	 ,,,,,,oDlgC,,.F.,,,,,,,.T.)               
			        	 
qmt010VerPtos(M->QM2_INSTR,M->QM2_REVINS,M->QM2_TIPO)
aCols := {}
aHeader := {}
A010CaTR(QM2->QM2_TIPO,QM2->QM2_INSTR,QM2->QM2_REVINS)
If oGetFi <> Nil
	oGetFi:oBrowse:lDisablePaint := .t.
	oGetFi:Hide()
	aColsQMR := aClone(aCols)
	aHeaderQMR := aClone(aHeader)
	
	If !lFzCal
		oBtn2:Disable()
	Else
		aCols := {}
		aHeader := {}
		A010CaPo(M->QM2_TIPO,M->QM2_INSTR,M->QM2_REVINS,oDlgC)
		If oGetPto <> Nil
			oGetPto:oBrowse:lDisablePaint := .t.
			oGetPto:Hide()
			aColsQMG := aClone(aCols)
			aHeaderQMG := aClone(aHeader)
		Endif	
	Endif
Else
	oBtn1:Disable()
	oBtn1:Refresh()
	oBtn2:Disable()
	oBtn2:Refresh()
	oBtn3:Disable()
	oBtn3:Refresh()
Endif
dbSelectArea("QM2")
ACTIVATE MSDIALOG oDlgC ON INIT EnchoiceBar(oDlgC,{|| nOpca := 1,oDlgC:End()},{|| nOpca := 2,oDlgC:End()}) CENTERED

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010Text ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 08.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de chamada para texto de Hist./Inform.Complement. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010Text(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo									  ³±±
±±³			 ³ ExpN1 = Numero do registro 								  ³±±
±±³			 ³ ExpN2 = Opcao selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010Text(cAlias, nReg, nOpc)

Local cChave
Local cCabec
Local cTitulo	:= OemtoAnsi(STR0012)  // "Instrumento"
Local nTamLin	:= TamSX3("QA2_TEXTO")[1]
Local lTxtQa	:= .T.
axtextos := {} // Vetor que contem os textos

cChave := QM2_FILIAL + QM2_INSTR + QM2_REVINS

If nOpc == 6
	cCabec := OemtoAnsi(STR0013)	// "Hist¢rico"
	cEspecie := 'QMTA010H'
Else
	cCabec := OemtoAnsi(STR0011)	// "Complemento"
	cEspecie := 'QMTA010I'
EndIf

If !empty(QM2->QM2_CHAVE)
	cChave := QM2->QM2_CHAVE
Else
	cChave := Qmt010VText(.T.,@cChave,QM2->QM2_INSTR,QM2->QM2_REVINS) //Existencia/Reserva de Chave
	dbSelectArea("QM2")
	RecLock("QM2",.F.)
	QM2->QM2_CHAVE := cChave
	MsUnlock()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Digita o Texto  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QMA010DT")
	lTxtQa := ExecBlock("QMA010DT",.F.,.F.,{cChave,cEspecie,nTamlin,cTitulo,alltrim(QM2_INSTR)+' - '+QM2_REVINS,@axtextos,1,cCABEC,{.t.,.f.}})
Else
	lTxtQa := QA_TEXTO(cChave,cEspecie,nTamlin,cTitulo,;
	alltrim(QM2_INSTR)+' - '+QM2_REVINS,@axtextos,1,;
	cCABEC,.T.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Texto do Procedimento de Calibracao no QA2		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTxtQa
	QA_GrvTxt(cChave,cEspecie,1,@axtextos)   // QAXFUN
Endif	
dbselectArea("QM2")

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010SaGa ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 11.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Selecao de opcoes de salva guarda						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010SaGa()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010SaGa()
Local cRetorno:=""
Local lLacre	:= .F.
Local lConstru := .F.
Local lTreina	:= .F.
Local nI
Local oDlg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega selecao ja gravada									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !empty(M->QM2_SGUARD) 
	For nI := 1 to 3
		If Subs(M->QM2_SGUARD,nI,1) == 'L'
			lLacre	:= .T.
		ElseIf Subs(M->QM2_SGUARD,nI,1) == 'C'
			lConstru := .T.
		ElseIf Subs(M->QM2_SGUARD,nI,1) == 'T'
			lTreina	:= .T.
		EndIf
	Next
EndIf
                    
Do while .t. 

	DEFINE MSDIALOG oDlgC FROM	41,218 TO 165,550 TITLE STR0024 PIXEL  //"Selecione"
	@ 3, 4 TO 55, 129 OF oDlg	PIXEL
	@ 7.0,10 CHECKBOX lLacre	PROMPT STR0025  SIZE 60,10 OF oDlgC PIXEL FONT oDlgC:oFont  //"&Lacre"
	@ 25 ,10 CHECKBOX lConstru 	PROMPT STR0026  SIZE 60,10 OF oDlgC PIXEL FONT oDlgC:oFont  //"&Constru‡„o"
	@ 43 ,10 CHECKBOX lTreina	PROMPT STR0027  SIZE 60,10 OF oDlgC PIXEL FONT oDlgC:oFont  //"&Treinamento"
	DEFINE SBUTTON FROM 10, 135 TYPE 1 ENABLE OF oDlgC Action (oDlgC:End())
	
	ACTIVATE MSDIALOG oDlgC CENTERED
	
	Exit
EndDo
cRetorno := IIF( lLacre  , "L", "" )
cRetorno += IIF( lConstru, "C", "" )
cRetorno += IIF( lTreina , "T", "" )
Return cRetorno

/*
antiga a010Chav
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ qmt010Chv³ Autor ³ Wanderley Goncalves   ³ Data ³ 21/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao dos campos chave 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010 - E' chamada no X3_VALID.                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010Chv()
Local lRet := .T.

If ! Empty( M->QM2_INSTR ) .and. ! Empty( M->QM2_REVINS )
	
	dbSelectArea("QM2")
	If dbSeek(xFilial() + M->QM2_INSTR)
		If QM2_REVINS > M->QM2_REVINS
			msgstop('Ja existe revisão superior a que esta sendo incluida',STR0031)	// "Escala não encontrada."
			lret := .F.
		EndIf 		  
	EndIf	
		
	If dbSeek( xFilial() + M->QM2_INSTR + Inverte(M->QM2_REVINS) )
		Help( " ", 1, "JAGRAVADO" )
		lRet := .F.
	Endif
	
	If lRet
		lRet := FreeForUse("QM2",M->QM2_INSTR+M->QM2_REVINS)	
	Endif
	
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010IPon ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 06/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao de Pontos de Medicao para Instrumentos do Tipo  ³±±
±±³			 ³ Calibrador. (Para determinar que um instrumento ‚ deste	  ³±±
±±³			 ³ Tipo, o sistema esta obrigando o usuario cadastrar uma uni-³±±
±±³			 ³ ca Escala.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010IPon()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QmtA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010IPon(cInstr,cRevIns,oDlgC,lMtAc)

Local nCnt
Local nSavRec
Local nOpca 	:= 0
Local nRecNc
Local lInclui	:= .f.
Local lRet		:= .F.
Local nDec 		:= 0  // Numero de casas decimais para LIE/LSE
Local nPosAli
Local nPosRec
Local aStruQMG := FWFormStruct(3, "QMG")[3]
Local nX

Default lMtAc := .T.
If Inclui
	nOpcx := 3
ElseIf Altera
	If QMA010Cal(cInstr,cRevIns)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Instrumento tem medicoes, nao pode ser alterado.                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOpcx := 2        
		lPodeAlt := .F.
	Else		
		nOpcx := 4
	EndIf	
Else
	nOpcx := 5
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ha' pontos ja' existentes para o tipo de instrumento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QMG")
nSavRec	:= RecNo()
dbSeek( xFilial("QMG")+cInstr+cRevIns)

nRecNc	:= RecNo()
nCnt		:= 0

While !EOF() .And.;
	QMG->QMG_INSTR+QMG->QMG_REVINS == ;
	cInstr+cRevIns .and.;
	QMG->QMG_FILIAL == xFilial("QMG")
	nCnt++
	dbSkip()
EndDo

lInclui := Iif(nCnt==0,.t.,.f.)
dbGoto(nRecNc)

Private	nOpc:=3		
nUsado:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados 			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX2")  // Posiciona pq. rotinas internas utilizam inf. do SX2
dbSeek("QMG")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor Aheader a ser utilizado na getdados				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MontAhead("QMG")  // QAXFUN

// Inclui coluna de registro atraves de funcao generica
ADHeadRec("QMG",aHeader)

nPosAli := Ascan(aHeader,{|x| AllTrim(x[2]) == "QMG_ALI_WT"})
nPosRec := Ascan(aHeader,{|x| AllTrim(x[2]) == "QMG_REC_WT"})

dbSelectArea("QMG")
dbGoto(nRecNc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define vetor aCols para a getdados 							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lInclui	// Def. vetor com 1 elemento, para a inclusao
	nCnt := 1
EndIf

Private aColsAux[nCnt][Len(aHeader)+1]
aCols := aClone(aColsAux)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica qual a posicao do campo PONTO no Header		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := aScan(aHeader,{|x| alltrim(x[2]) = "QMG_PONTO" })

If !lInclui
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alimenta vetor aCols com os escalas ja existentes 			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nCnt := 0
	dbSelectArea("QMG")
	
	While !EOF() .And. QMG->QMG_INSTR + QMG->QMG_REVINS ==;
		cInstr + cRevIns .and.;
		QMG->QMG_FILIAL == xFilial("QMG")
		nCnt++
		nUsado:=0
		
		For nX := 1 To Len(aStruQMG)
			If cNivel >= GetSx3Cache(aStruQMG[nX,1], "X3_NIVEL") 
				nUsado++
				If GetSx3Cache(aStruQMG[nX,1], "X3_CONTEXT") # "V"
					
					// Calcula os Valores de LIE e LSE
					If alltrim(aHeader[nUsado][2]) $ "QMG_LIE|QMG_LSE"
						If QMG->QMG_TIPCAL <> "A"						
							If alltrim(aHeader[nUsado][2]) =="QMG_LIE"
								nDec := 0
								nDec := Iif("," $ AllTrim(QMG->QMG_NOMIN),;
								Len(AllTrim(QMG->QMG_NOMIN))-At(",",AllTrim(QMG->QMG_NOMIN)),nDec)
								If QMG->QMG_TIPTOL == "1" 
									aCOLS[nCnt][nUsado] := Str(SuperVal(QMG->QMG_LIE)-SuperVal(QMG->QMG_NOMIN),;
									TamSx3("QMG_NOMIN")[1],nDec)
								Else 
									If !Empty(QMG->QMG_LIEAUX)
										aCOLS[nCnt][nUsado] := 	QMG->QMG_LIEAUX		
									Else
										If SuperVal(QMG->QMG_LIE) >= SuperVal(QMG->QMG_NOMIN)
											aCOLS[nCnt][nUsado] := Str((SuperVal(QMG->QMG_LIE)*100/SuperVal(QMG->QMG_NOMIN)-100),;
											TamSx3("QMG_NOMIN")[1],nDec)
										Else 
											aCOLS[nCnt][nUsado] := "-"+Alltrim(Str((100 - (SuperVal(QMG->QMG_LIE)*100/SuperVal(QMG->QMG_NOMIN))),;
											TamSx3("QMG_NOMIN")[1],nDec))
										Endif	
										aCOLS[nCnt][nUsado] := StrTran(aCols[nCnt][nUsado],".",",")
									Endif	
								Endif	
							EndIf
							If alltrim(aHeader[nUsado][2]) =="QMG_LSE"
								If QMG->QMG_TIPTOL == "1" 
									aCOLS[nCnt][nUsado] := Str(SuperVal(QMG->QMG_LSE)-SuperVal(QMG->QMG_NOMIN),;
									TamSx3("QMG_NOMIN")[1],nDec)
								Else 
									If !Empty(QMG->QMG_LSEAUX)
										aCOLS[nCnt][nUsado] := QMG->QMG_LSEAUX							
									Else
										If SuperVal(QMG->QMG_LSE) >= SuperVal(QMG->QMG_NOMIN)
											aCOLS[nCnt][nUsado] := Str((SuperVal(QMG->QMG_LSE)*100/SuperVal(QMG->QMG_NOMIN)-100),;
											TamSx3("QMG_NOMIN")[1],nDec)
   	        	                    	Else
											aCOLS[nCnt][nUsado] := "-"+Alltrim(Str((100 - (SuperVal(QMG->QMG_LSE)*100/SuperVal(QMG->QMG_NOMIN))),;
											TamSx3("QMG_NOMIN")[1],nDec))
										Endif	
										aCOLS[nCnt][nUsado] := StrTran(aCols[nCnt][nUsado],".",",")
									Endif	
								Endif
								aCOLS[nCnt][nUsado] := StrTran(aCols[nCnt][nUsado],".",",")
							EndIf
						Endif
					Else
						aCOLS[nCnt][nUsado] := &("QMG->"+aStruQMG[nX,1])//X3_CAMPO
					EndIf
				Else
					If Alltrim(GetSx3Cache(aStruQMG[nX,1], "X3_PROPRI")) == "U"
						aCOLS[nCnt][nUsado] := 	CriaVar(alltrim(aHeader[nUsado][2]),.T.)
					Endif	
				Endif
			EndIf
		Next nX
		
		If nPosAli > 0 .And. nPosRec > 0
			aCols[nCnt][nPosAli] := "QMG"
			If IsHeadRec(aHeader[nPosRec,2])
				aCols[nCnt][nPosRec] := QMG->(RecNo())
			EndIf
		Endif
		aCols[nCnt][Len(aHeader)+1] := .F.
		dbSelectArea("QMG")
		dbSkip()
	Enddo
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alimenta vetor aCols com um elemento em branco p/ inclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsado:=0
	
	For nX := 1 To Len(aStruQMG)
		If cNivel >= GetSx3Cache(aStruQMG[nX,1], "X3_NIVEL") 
			nUsado++
			aCols[1][nUsado] := CriaVar(allTrim(aStruQMG[nX,1]))//X3_CAMPO
		EndIf
	Next nX

	nUsado := Len(aHeader)
	If nPosAli > 0 .And. nPosRec > 0
		aCols[nCnt][nPosAli] := "QMG"
		If IsHeadRec(aHeader[nPosRec,2])
			aCols[nCnt][nPosRec] := 0
		EndIf
	Endif
	aCOLS[nCnt][nUsado+1] := .F.
	nCnt := 0	// Retorna valor
EndIf

dbSelectArea("QMG")
dbGoto(nRecNc)

nOpca 		:= 0
aColsPto	:= aClone(aCols) 
If QMA010Cal(M->QM2_INSTR,M->QM2_REVINS) //Bloqueia a alteracao dos pontos
	lPodeAlt := .F.
EndIf

oGetPto := MSGetDados():New(oSize2:GetDimension("GROUP","LININI"),oSize2:GetDimension("GROUP","COLINI"),;
                                   oSize2:GetDimension("GROUP","LINEND"),oSize2:GetDimension("GROUP","COLEND"),;
                                   nOpcx,"qmt010LnOk","Qmt010TdOk",,lPodeAlt,,,,,,,,,oDlgC) //Pontos Calibradores

oGetPto:lActive := lPodeAlt

If lMtAc
	oGetPto:Show()
Else
	oGetPto:Hide()
Endif

oGetPto:oBrowse:bLostFocus := {||aHeaderQMG := aClone(aHeader),aColsQMG := aClone(aCols)}

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A010GrvPt ³ Autor ³ Wanderley Goncalves   ³ Data ³ 09/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os Pontos de Medicao por Instrumento p/ Tipo Calibr. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³	MOTIVO DA ALTERACAO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Iuri Seto    ³17/07/00³ 04999³ Acerto na consistencia do campo        ³±±
±±³              ³        ³      ³ QMG_LIE, pois estava sempre gravando   ³±±
±±³              ³        ³      ³ valores negativos. Foi alterado para   ³±±
±±³              ³        ³      ³ consistir como o campo QMG_LSE.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010GrvPt(cInstr,cRevins)

Local nx ,ny ,  nMaxArray := Len(aColsQMG)
Local nPosTTol	:= ascan(aHeaderQMG, { |x| alltrim(x[2]) == 'QMG_TIPTOL' })
Local nPosTCal	:= ascan(aHeaderQMG, { |x| alltrim(x[2]) == 'QMG_TIPCAL' })
Local lGrPtos	:= .F.

nPosNom := ascan(aHeaderQMG, { |x| alltrim(x[2]) == 'QMG_NOMIN' })
nPos := aScan(aHeader,{|x| alltrim(x[2]) = "QMG_PONTO" })

//Verificar se realmente existe escalas calibrador/calibradores completos para poder gravar os pontos...

For nx := 1 To Len(aColsQMR)
	dbSelectArea("QM9")
	dbSetOrder(1)
	If dbSeek(xFilial()+aColsQMR[nx][1])
		If QM9->QM9_TIPAFE $ "4|8" .and. !aColsQMR[nx][Len(aColsQMR[nx])]
        	lGrPtos := .T.
        	Exit
		Endif	
	Endif
Next nx

dbSelectArea("QMG")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o arquivo QMG 	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGrPtos 
	For nX := 1 to nMaxArray
		If nPos > 0 
			If ! Empty(aColsQMG[nX][nPos]) // Ponto nao vazio
				If !AcolsQMG[nX][Len(aHeaderQMG)+1] // Nao esta deletado
					If dbSeek(xFilial("QMG") + cInstr + cRevIns+ aColsQMG[nX][nPos])
						RecLock("QMG",.F.)   // Lock
					Else
						RecLock("QMG",.T.)   // Append
					Endif
					For ny := 1 to Len(aHeaderQMG)
						If aHeaderQMG[ny][10] # "V"
							cVar := Trim(aHeaderQMG[ny][2])
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Calcula e grava os LIE e LSE 		  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If cVar $ "QMG_LIE|QMG_LSE"
								If Alltrim(aColsQMG[nX][nPosTCal]) <> "A" // Se for diferente de atributo
									nDec := 0
									nDec := Iif("," $ AllTrim(QMG_NOMIN),;
									Len(AllTrim(QMG_NOMIN))-At(",",AllTrim(QMG_NOMIN)),nDec)
									If cVar = "QMG_LIE"
										If aColsQMG[nX][nPosTTol] == "1" //Tipo de Calculo Numerico para Tolerancia
											nLie := SuperVal(aColsQMG[nX][nPosNom])+SuperVal(aColsQMG[nX][ny])
											QMG->QMG_LIE := StrTran(Str(nLie,TamSX3("QMG_LIE")[1],nDec),".",",")
										Else 
											nLie := SuperVal(aColsQMG[nX][nPosNom])+(SuperVal(aColsQMG[nX][nPosNom])*SuperVal(aColsQMG[nX][ny]))/100
											QMG->QMG_LIE := StrTran(Str(nLie,TamSX3("QMG_LIE")[1],nDec),".",",")
										Endif	
										QMG->QMG_LIEAUX := aColsQMG[nX][ny]								
									Else
										If aColsQMG[nX][nPosTTol] == "1" //Tipo de Calculo Numerico para Tolerancia
											nLse := SuperVal(aColsQMG[nX][nPosNom])+SuperVal(aColsQMG[nX][ny])
											QMG->QMG_LSE := StrTran(Str(nLse,TamSX3("QMG_LSE")[1],nDec),".",",")
										Else
											nLse := SuperVal(aColsQMG[nX][nPosNom])+(SuperVal(aColsQMG[nX][nPosNom])*SuperVal(aColsQMG[nX][ny]))/100
											QMG->QMG_LSE := StrTran(Str(nLse,TamSX3("QMG_LSE")[1],nDec),".",",")
										Endif
										QMG->QMG_LSEAUX := aColsQMG[nX][ny]
									EndIf
								Endif	
							Else
								Replace &cVar. With aColsQMG[nx][ny]
							EndIf
						Endif
					Next ny
					QMG->QMG_INSTR  := cInstr
					QMG->QMG_REVINS := cRevIns
					QMG->QMG_FILIAL := xFilial("QMG")
					MsUnlock()
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Cancela o padrao no QMG				  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If dbSeek(xFilial("QMG") + cInstr + cRevIns + aColsQMG[nX][nPos])
						dbSelectArea("QM7")
						dbSetOrder(3)
						If ! dbSeek(cFilial+QMG->QMG_INSTR+QMG->QMG_REVINS+QMG->QMG_PONTO)
							dbSelectArea("QMG")
							RecLock("QMG",.F.)
							dbDelete()
							MsUnlock()
						EndIf
						dbSelectArea("QMG")
					EndIf
				EndIf
			EndIf
		Endif
	Next nx
Endif
Return .T.

/*
antigo A010WhEscF
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt010WhEF³ Autor ³ Wanderley Goncalves   ³ Data ³ 09/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ When para Escala Final (Permite preencher escala final so- ³±±
±±³			 ³ mente quando preenchida escala inicial).					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010WhEF()

Local nPosLi := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMG_ESCALI" })

If !empty(aCols[n][nPosLi])
	Return(.T.)
EndIf

Return(.F.)

/*
antigo A010WhLIE
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt010WhLI³ Autor ³ Wanderley Goncalves   ³ Data ³ 09/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ When para Escala Final (Permite preencher limite superior  ³±±
±±³			 ³ somente quando preenchido limite inferior 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010WhLI()

Local lRet := .F.
Local nPosLie := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMG_LIE" })

If !empty(aCols[n][nPosLie]) .and. qmt010WhMe()
	lRet := .T.
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010VlPr ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 10/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Precisao									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010 - E' chamada no X3_VALID do cpo. QM2_PREC - SX3    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010VlPr()
Local lRetu := .t., cVar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o valor digitado e' um numero valido    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cVar := M->QM2_PREC
If ! QA_VerNum(@cVar)
	HELP(" ",1,"QA_NUMINV")
	lRetu := .f.
EndIf

M->QM2_PREC := cVar	 // atualizacao p/ getdados

Return(lRetu)

/*
antiga a010VlRes
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt010VlRe³ Autor ³ Wanderley Goncalves   ³ Data ³ 10/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Resolucao									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010 - E' chamada no X3_VALID do cpo. QM2_RESOL - SX3   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010VlRe()
Local lRetu := .t.,cVar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o valor digitado e' um numero valido    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cVar := M->QM2_RESOL
If ! QA_VerNum(@cVar)
	HELP(" ",1,"QA_NUMINV")
	lRetu := .f.
EndIf

M->QM2_RESOL := cVar   // atualizacao p/ getdados

Return(lRetu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010VlInc³ Autor ³ Wanderley Goncalves   ³ Data ³ 10/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Incerteza									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010 - E' chamada no X3_VALID do cpo. QM2_INCERT - SX3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010VlInc()
Local lRetu := .t., cVar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o valor digitado e' um numero valido    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cVar := M->QM2_INCERT
If ! QA_VerNum(@cVar)
	HELP(" ",1,"QA_NUMINV")
	lRetu := .f.
EndIf

M->QM2_INCERT := cVar	// atualizacao p/ getdados

Return(lRetu)

/*
antigo a010VlNm
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt010VlNm³ Autor ³ Wanderley Goncalves   ³ Data ³ 10/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Nominal 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010 - E' chamada no X3_VALID do cpo. QMG_NOMIN - SX3   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010VlNm()
Local lRetu := .t., cVar
Local nPosNi := ascan(aHeader, { |x| alltrim(x[2]) == "QMG_NOMIN" })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o valor digitado e' um numero valido    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cVar := M->QMG_NOMIN
If ! QA_VerNum(@cVar)
	HELP(" ",1,"QA_NUMINV")
	lRetu := .f.
EndIf

aCols[n][nPosNi] := cVar		// atualizacao p/ getdados
M->QMG_NOMIN := cVar   // atualizacao p/ getdados

Return(lRetu)

/*
antigo A010EscI
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt010EscI³ Autor ³ Wanderley Goncalves   ³ Data ³ 10/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Escala Inicial								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010 - E' chamada no X3_VALID do cpo. QMG_ESCALI - SX3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010EscI()
Local lRetu := .t., cVar
Local nPosEI := ascan(aHeader, { |x| alltrim(x[2]) == 'QMG_ESCALI' })


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o valor digitado e' um numero valido    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cVar := M->QMG_ESCALI
If ! QA_VerNum(@cVar)
	HELP(" ",1,"QA_NUMINV")
	lRetu := .f.
EndIf

aCols[n][nPosEI] := cVar		// atualizacao p/ getdados
M->QMG_ESCALI := cVar	// atualizacao p/ getdados

Return(lRetu)

/*
antiga a010UIni
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ qmt010UIN³ Autor ³ Wanderley Goncalves   ³ Data ³ 18/12/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Data uso inicial							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010 - E' chamada no X3_VALID do cpo. QM2_USOINI - SX3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010UIN()

Local lRetu := .t.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a data digitada e' um valida  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If M->QM2_USOINI > dDataBase
	HELP(" ",1,"A010USOINI") // Uso inicial do instrumento maior que data de hoje.
	lRetu := .f.
EndIf

Return(lRetu)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010Pc	³ Autor ³ Wanderley Goncalves   ³ Data ³ 10/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a funcao que monta a picture de um campo. 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010Pc(cCampo) 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do Campo que tera' a picture a ser definida   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010Pc(cCampo)
Local cPict

cPict := QA_PICT(cCampo,&("M->"+cCampo))

return cPict
/*
antigo A010Pg
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ q010Pg	³ Autor ³ Wanderley Goncalves   ³ Data ³ 10/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a funcao que monta a picture de um campo em GetDados ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ q010Pg(cCampo) 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do Campo que tera' a picture a ser definida   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function q010Pg(cCampo)
Local cPict
Local nPosPic := 0

If ( FUNNAME() <> "LERDA" .AND. FUNNAME() <> "EDAPP" )//Caso haja utilizacao fora da Telas do PPAP e QMT
	nPosPic := ascan(aHeader, { |x| alltrim(x[2]) == cCampo })
EndIf

If nPosPic > 0
	cPict := QA_PICT(cCampo,aCols[n][nPosPic])// QA_PICT ( <Campo> , <Valor de Referencia> )
Else
	cPict := "@!"
EndIf

Return cPict

/*
antigo A010VlPt
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt010VlPt³ Autor ³ Wanderley Goncalves   ³ Data ³ 10/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Ponto de Calibracao para Instr. Tp.Calibrador ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030 - E' chamada no X3_VALID do cpo. QMG_PONTO  - SX3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010VlPt()
Local lRetu := .t.
Local nI
Local nPosP := Ascan(aHeader,{|x| AllTrim(x[2]) == "QMG_PONTO"})
Local cVar  := &(readvar()) // Conteudo da variavel do campo Ponto

If empty(cVar)
	Help(" ",1,"A010OBRIGA")   // Preenchimento do campo obrigatorio.
	lRetu := .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se mudou o Ponto (Alterou o campo ja' digitado)       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[n][nPosP]) .and. !Empty(cVar) .and. aCols[n][nPosP] <> cVar
	Help(" ",1,"NAOALTERA") // Campo nao pode ser alterado
	lRetu := .f.
EndIf

If lRetu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Ponto ja' existe                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 to len(aCols)
		If cVar == aCols[nI][nPosP] .and. nI <> n // Se ja' existir este ponto
			Help(" ",1,"A010EXIPTO") // "Ponto j  relacionado e este Instrumento"
			lRetu := .f.
		EndIf
	Next nI
EndIf

Return(lRetu)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt010LnOk³ Autor ³ Wanderley Goncalves   ³ Data ³ 10/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Qmta010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT010LnOk(o)

Local nx, lRet := .T.
Local nPosCa	:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QMG_TIPCAL" })
Local nPosNoM	:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QMG_NOMIN" })	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se campo escala esta' preenchido                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !aCols[n][Len(aHeader)+1]
	
	For nx := 1 To Len(aHeader)
		
		If Empty(aCols[n][nPosCa])
			If (Trim(aHeader[nx][2]) == "QMG_NOMIN" .or.;
				 Trim(aHeader[nx][2]) == "QMG_LIE"   .or.;
				 Trim(aHeader[nx][2]) == "QMG_ESCALI") .and.;
				aCols[n][nPosCa] == 'A'
				Help(" ",1,"QA_CPOOBR")
				lRet := .F.
			EndIf
			
			If Trim(aHeader[nx][2]) == "QMG_PONTO"
				Help(" ",1,"QA_CPOOBR")
				lRet := .F.
				Exit
			Endif
			
			If !lRet
				Exit
			Endif
		Else
			If (Trim(aHeader[nx][2]) == "QMG_NOMIN") .and. Alltrim(aCols[n][nPosCa]) == "M"		
				If Empty(aCols[n][nPosNoM])
					Help(" ",1,"QA_CPOOBR")
					lRet := .F.
					Exit
				Endif
				If !lRet
					Exit
				Endif
			Endif
		Endif	
	Next nx		
EndIf

Return(lRet)
/*
antigo a010TudoOk
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Qmt010TdOk³ Autor ³ Wanderley Goncalves   ³ Data ³ 10/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se toda a getdados esta' Ok                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt010TdOk(o)
Local nI, lRet := .t.

For nI := 1 to Len(aCols)
	If !aCols[n][nUsado+1]
		If ! QMT010LnOk(o)
			lRet := .f.
			Exit
		EndIf
	EndIf
Next

Return(lRet)

/*
antigo A010VlAfa
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt010VlAf³ Autor ³ Wanderley Goncalves   ³ Data ³ 10/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se Afastamento Superior ‚ maior que o Inferior 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010VlAf(lLse)

Local nPosLIE := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMG_LIE" })
Local nPosNOM := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMG_NOMIN" })
Local nPosLSE := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMG_LSE" })
Local nPosTpc := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMG_TIPCAL" })
Local nx	  := 1

Default lLse  := .T.

If nPosLIE > 0 .and. nPosNOM > 0 .and. nPosTpc > 0
	If !lLse 
		If nVals == 2
			For nx := 1 To Len(aColsQMG)
				If Alltrim(aColsQMG[nx,2]) <> "A"
					If SuperVal(aColsQMG[nx,nPosNOM]) + SuperVal(aColsQMG[nx,nPosLIE]) >;
						SuperVal(aColsQMG[nx,nPosNOM]) + SuperVal(aColsQMG[nx,nPosLSE])
						Help(" ",1,"A010AFAMOR")  // Afastamento Inferior maior que Superior
						Return(.F.)
					EndIf            
				Endif
			Next nx
		ElseIf nVals == 3
			If Alltrim(aCols[n,nPosTpc]) <> "A"
				If SuperVal(aCols[n,nPosNOM]) + SuperVal(aCols[n,nPosLIE]) >;
					SuperVal(aCols[n,nPosNOM]) + SuperVal(aCols[n,nPosLSE])
					Help(" ",1,"A010AFAMOR")  // Afastamento Inferior maior que Superior
					Return(.F.)
				Endif	
			EndIf            
		Endif
	Else
		If Alltrim(aCols[n,nPosTpc]) <> "A"
			If SuperVal(aCols[n,nPosNOM]) + SuperVal(aCols[n,nPosLIE]) >;
				SuperVal(aCols[n,nPosNOM]) + SuperVal(M->QMG_LSE)
				Help(" ",1,"A010AFAMOR")  // Afastamento Inferior maior que Superior
				REturn(.F.)
			EndIf
		Endif	
	Endif
ElseIf Len(aColsQMG) > 0
	For nx := 1 To Len(aColsQMG)
		If Alltrim(aColsQMG[nx,2]) <> "A"
			If SuperVal(aColsQMG[nx,4]) + SuperVal(aColsQMG[nx,5]) >;
				SuperVal(aColsQMG[nx,4]) + SuperVal(aColsQMG[nx,6])
				Help(" ",1,"A010AFAMOR")  // Afastamento Inferior maior que Superior
				REturn(.F.)
			EndIf
		Endif
	Next nx	
Endif

Return(.T.)

/*
antigo A010VlLim
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt010VlLi³ Autor ³ Wanderley Goncalves   ³ Data ³ 10/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se Escala Superior ‚ maior que a Inferior			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010VlLi()

Local nPosEsc := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMG_ESCALI" })

If SuperVal(aCols[n,nPosEsc]) > SuperVal(M->QMG_ESCALF)
	Help(" ",1,"A010ESCMOR")  // Limites Inv lidos
	REturn(.F.)
EndIf

Return(.T.)

/*
antigo a010WhMens
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt010WhMe³ Autor ³ Wanderley Goncalves   ³ Data ³ 25/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Clausula When para digitacao de Valores somente se tipo de ³±±
±±³Descri‡…o ³ ponto for Mensuravel.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010 -  - X3_VALID dos cpos. QMG_NOMIN e QMG_LIE		  ³±±
±±³			 ³ 				 e A010WhLi       							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010WhMe()

Local lRet := .F.
Local nPosAl := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMG_TIPCAL" })

If aCols[n,nPosAl] == 'M'
	lRet := .t.
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A010Textos³ Autor ³ Alessandro B. Freire  ³ Data ³ 10/03/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao utilizada para limitar os botoes da mbrowse em 6.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010Textos( cAlias, nReg, nOpc )
Local oDlgC
Local oRad
Local nTecla	:= 1
Local nOpcx 	:= 0
Local oFontDlg := TFont():New("Arial",6,15,.f.,.t.)

While .T.
	DEFINE MSDIALOG oDlgC FROM	35,37 TO 140,300 TITLE STR0021 PIXEL // "Textos"
	
	@ 05,05 TO 45,80 OF oDlgC PIXEL
	
	@ 10, 11 RADIO oRad VAR nTecla 3D SIZE 52, 11;
	PROMPT  OemToAnsi(STR0022),;		// "Hist¢rico"
	OemToAnsi(STR0023),;			 	// "Complemento"
	OemToAnsi(STR0043) OF oDlgC PIXEL	// "Reprogramacao"
	
	DEFINE SBUTTON FROM 11, 90 TYPE 1 ENABLE OF oDlgC Action (nOpcx:=1,oDlgC:End())
	DEFINE SBUTTON FROM 24, 90 TYPE 2 ENABLE OF oDlgC Action (nopcx:=0,oDlgC:End())
	
	ACTIVATE MSDIALOG oDlgC Centered
	
	If nOpcx == 1
		If nTecla == 1
			A010Text(cAlias,nReg,nOpc)
		ElseIf nTecla == 2
			A010Text(cAlias,nReg, 7 )
		ElseIf nTecla == 3
			A010Just(cAlias,nReg, 7 )
		EndIf
	EndIf
	Exit
	
EndDo

oFontDlg:End()
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A010CATR	³ Autor ³ Wanderley Goncalves   ³ Data ³ 30/03/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastra Tolerancia de Processo / Redutor por Escala		  ³±±
±±³			 ³ do Instrumento selecionado.								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto ³ 14/08/00 ³Consultar instr.+rev. no QMR ao inves do QMK.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A010CaTR(cTipo,cInstr,cRevIns,lGrvPt,oDlgC,lMtAc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A array aDigita indica quais campos poderao ser digitados, de acordo	 ³
//³com o tipo de laudo:                                                  ³
//³- Se for Laudo com confirmacao metrologica, deve-se digitar os campos ³
//³  tolerancia e redutor.												 ³
//³- Se for Laudo sem confirmacao metrologica, deve-se digitar somente o ³
//³  campo incerteza permitida   										 ³
//³A variavel aDigita ‚ PRIVATE porque o X3_WHEN usa.	 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cRev
Local nCntFor
Local lRet := .T.
Local cCampo := "" // Auxiliar
Local lVisual := IIf(Inclui .or. Altera,.F.,.T.)
Local nI

Default lMtAc := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private Continua := .F.
Private nOpc     :=  3
Private nUsado   :=  0
Private aCampos  := { }
Private nPosAli  :=  0
Private nPosRec  :=  0

IIF(lGrvPt == Nil,lGrvPt := .F.,) 
IIF(lCtrlCalib == Nil,lCtrlCalib := .T.,)

aDigita := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reinicializo a variavel utilizada pela getdados, pois a  ³
//³ mesma se perde, provocando erro (protheus)               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
n := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados 		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX2")  // Posiciona pq. rotinas internas utilizam inf. do SX2
dbSeek("QMR")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor Aheader a ser utilizado na getdados				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MontAhead("QMR")  // QAXFUN

// Inclui coluna de registro atraves de funcao generica
ADHeadRec("QMR",aHeader)

nPosAli := Ascan(aHeader,{|x| AllTrim(x[2]) == "QMR_ALI_WT"})
nPosRec := Ascan(aHeader,{|x| AllTrim(x[2]) == "QMR_REC_WT"})

If Altera .or. lVisual
	cQM2Tipo := cTipo
Endif

DbSelectArea("QM9")
QM9->(dbSetOrder(1))
DbSelectArea("QMR")
QMR->(dbSetOrder(1))
If QMR->(dbSeek(xFilial("QMR")+cInstr+cRevIns))
	If QM2->QM2_TIPO == cQM2Tipo
		While QMR->(!Eof()) .And. xFilial("QMR")+cInstr+cRevIns == QMR->QMR_FILIAL+QMR->QMR_INSTR+QMR->QMR_REVINS
			QM9->(dbSetOrder(1))
			If QM9->( dbSeek( xFilial( "QM9" ) + QMR->QMR_ESCALA ) ) 
				If Alltrim(QM9->QM9_TIPAFE) $ "4|8" 
					lFzCal := .T.
					oBtn2:Enable()
				Endif	
				If QM9->QM9_LAUDO == "1"  // Com confirmacao meterol¢gica
					aadd(aDigita,{QMR->QMR_ESCALA,.t.,.t.,.f.,.t.,.t.}) // True para os cpos tolerancia e redutor
				ElseIf QM9->QM9_LAUDO == "2"
					aadd(aDigita,{QMR->QMR_ESCALA,.f.,.f.,.t.,.t.,.t.}) // True para incerteza permitida
				Else
					aadd(aDigita,{QMR->QMR_ESCALA,.f.,.f.,.f.,.t.,.t.})
				EndIf
				aCampos := {QMR->QMR_ESCALA}
				For nCntFor := 2 To Len( aHeader )          
					If !(aHeader[nCntFor,2] $ "QMR_ALI_WT | QMR_REC_WT")
						cCampo := "QMR->"+aHeader[nCntFor,2]			
						aadd(aCampos,"")  
						aCampos[nCntFor] := &cCampo
					Else
						aAdd(aCampos,"")
					EndIf
				Next nCntFor
				If nPosAli > 0 .And. nPosRec > 0
					aCampos[nPosAli] := "QMR"
					If IsHeadRec(aHeader[nPosRec,2])
						aCampos[nPosRec] := QMR->(RecNo())
					EndIf
				Endif
				aadd(aCampos,.F.)
				aadd(aCols,aCampos)
			EndIf			
			QMR->(DbSkip())
		EndDo		
	Else
		a010MoQMK(cTipo,cRev)
	Endif
Else
	lRet := a010MoQMK(cTipo,cRev)
	//Seta lRet .t. mesmo que nao exista associacoes em QMK e QMR, dando a possibilidade do usuario incluir/deletar	
    //faixas...
	lRet := .T. 
		If Len(ACols) == 0
		aCols := Array(1,Len(aHeader)+1)
		For nI = 1 To Len(aHeader)
			If aHeader[nI,8] == "C"
				aCols[1,nI] := Space(aHeader[nI,4])
			ElseIf aHeader[nI,8] == "N"
				aCols[1,nI] := 0
			ElseIf aHeader[nI,8] == "D"
				aCols[1,nI] := CtoD("  /  /  ")
			ElseIf aHeader[nI,8] == "M"
				aCols[1,nI] := ""
			Else
				aCols[1,nI] := .F.
			EndIf
		Next nI
		If nPosAli > 0 .And. nPosRec > 0
			aCols[1][nPosAli] := "QMR"
			If IsHeadRec(aHeader[nPosRec,2])
				aCols[1][nPosRec] := 0
			EndIf
		Endif
		aCols[1,Len(aHeader)+1] := .F.
	EndIf
EndIf                 

If lRet
	dbSelectArea("QMR")
	Continua 	:= .F.
	nOpca 		:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta TGroup                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGrpCatr:= TGroup():New(oSize2:GetDimension("GROUP","LININI"),oSize2:GetDimension("GROUP","COLINI"),; //Faixas
						    oSize2:GetDimension("GROUP","LINEND"),oSize2:GetDimension("GROUP","COLEND"),STR0076,oDlgC,CLR_HRED,,.T.)
	
	oGrpCatr:Hide()
	If nVals == 2 .or. !Inclui
		If oBtIncEs == Nil                                                           
			@ oSize2:GetDimension("GROUP","LININI")+12,oSize2:GetDimension("GROUP","COLINI")+4 BUTTON oBtIncEs PROMPT STR0077 SIZE 45, 11 OF oGrpCatr PIXEL ACTION QMT010Paes(aHeaderQMR,aColsQMR) //"Padroes"
		Endif 
		//Colocado Altera por motivo de alteracao de familia...
		If (!Inclui .and. (nVals == 1 .or. nVals == 3)) .or. lFzCal
			oBtIncEs:Hide()
		Endif
	Endif		
	aColsGer := aClone(aCols)
	oGetFi := MSGetDados():New(oSize2:GetDimension("GROUP","LININI")+24,oSize2:GetDimension("GROUP","COLINI")+4,;
                                   oSize2:GetDimension("GROUP","LINEND")-2,oSize2:GetDimension("GROUP","COLEND")-3,;
                                   nOpcF,,"qmt010ChkAc",,.t.,,,,,,,,,oDlgC) //.T.  
                                   
	oGetFi:oBrowse:bLostFocus := {||QMT010ChkAc(),aHeaderQMR := aClone(aHeader),aColsQMR := aClone(aCols)}
	oGetFi:oBrowse:lDisablePaint := .F.
	If Inclui .or. lNoMoAc 
		oGetFi:Hide()		
	Endif                  
	lNoMoAc := .T.		
	nOpcA := 2
EndIf
dbSelectArea("QM2")
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A010GrvTR ³ Autor ³ Wanderley Goncalves   ³ Data ³ 31/03/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Tolerancia/REdutor por Escala 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010GrvTR(cAlias,cInstr,cRevIns)

Local nx ,ny ,  nMaxArray := Len(aColsQMR)
Local nPEsc := aScan(aHeaderQMR,{|x| alltrim(x[2]) = "QMR_ESCALA"})

If nPEsc > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	                                        *** ATENCAO ***                                              ³
	//³A delecao do QMR devera ocorrer sempre, pois em um possivel troca de familia ficara residuo de escalas³	
	//³antigas (pertencentes a penultima familia)                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QMR")
	DbSetOrder(1)
	If dbSeek(xFilial("QMR")+ cInstr + cRevIns)
		Do while xFilial("QMR")  + cInstr + cRevIns ==;
			QMR->QMR_FILIAL + QMR->QMR_INSTR + QMR->QMR_REVINS
			RecLock("QMR",.F.)   // Lock
			QMR->(DbDelete())
			MsUnLock()
			QMR->(DbSkip())
		EndDo
	EndIf

	//Devera ser aColsQMR pois podera ser faixa do tipo calibrador / calibrador completo...
	For nX := 1 to nMaxArray
		If ! Empty(aColsQMR[nX][nPEsc]) .and. !aColsQMR[nX][Len(aColsQMR[nx])] // Cod. Escala nao vazio
			If dbSeek(xFilial("QMR")+ cInstr + cRevIns + aColsQMR[nX][nPEsc])
				RecLock("QMR",.F.)   // Append                        
			Else
				RecLock("QMR",.T.)   // Regrava
			Endif	
			For ny := 1 to Len(aHeaderQMR)
				If aHeader[ny][10] # "V"
					cVar := Trim(aHeaderQMR[ny][2])
					Replace &cVar. With aColsQMR[nx][ny]
				Endif	
			Next ny
			QMR->QMR_FILIAL := xFilial("QMR")
			QMR->QMR_INSTR  := cInstr	
			QMR->QMR_REVINS := cRevIns
			QMR->QMR_ESCALA := aColsQMR[nX][nPEsc]
			MsUnlock()		
		EndIf
	Next nx
Endif

Return(.t.)
/*
antigo a010whtl
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³qmt010WhTl³ Autor ³ Fernando Godoy		³ Data ³ 21/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Se Laudo ‚ com confirmacao metrologica, digitar tolerancia  ³±±
±±³Descri‡„o ³e redutor                                                   ³±±
±±³Descri‡„o ³Se Laudo ‚ sem confirmacao metrologica, digitar apenas      ³±±
±±³Descri‡„o ³a incerteza permitida                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³.T. ou .F.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010whTl(o)

Local lRet := .F.  

Local nPosTolr := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMR_TOLPRO" })
Local nPosRed := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMR_REDUT" })
Local nPosInc := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMR_INPERM" })

//Somente permitir digitacao de tolerancia/redutor/precisao se e somente se ja digitado faixa..
If n <= Len(aDigita)
	If aDigita[n,nPosTolr] == .T. .or. aDigita[n,nPosRed] == .T.
		If o:Colpos == nPosTolr .or. o:ColPos == nPosRed
			If !Inclui
				dbSelectArea("QM6")
				dbSetOrder(1)
				If dbSeek(xFilial("QM6")+M->QM2_INSTR+M->QM2_REVINS)
					lRet := .F.
					MessageDlg(OemToAnsi(STR0049)+OemToAnsi(STR0050),,3)//"Nao e permitido alterar esse campo para instrumento/revisao que apresente "
					//"calibracoes. Por favor, realize duplicacao do instrumento."
				Else
					lRet := .t.
				Endif
			Else
				lRet := .t.
			Endif
		EndIf
	ElseIf aDigita[n,nPosInc] == .T.
		If o:Colpos == nPosInc
			If !Inclui
				dbSelectArea("QM6")
				dbSetOrder(1)
				If dbSeek(xFilial("QM6")+M->QM2_INSTR+M->QM2_REVINS)
					lRet := .F.
					MessageDlg(OemToAnsi(STR0049)+OemToAnsi(STR0050),,3)//"Nao e permitido alterar esse campo para instrumento/revisao que apresente "
					//"calibracoes. Por favor, realize duplicacao do instrumento."
				Else
					lRet := .t.
				Endif
			Else
				lRet := .t.
			Endif
		EndIf
	EndIf
Endif

//https://jiraproducao.totvs.com.br/browse/DMANQUALI-74
If .Not. lRet .And. (QM9->QM9_LAUDO $ '3|4')
	lRet := .T.
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A010CaJu	³ Autora³ Iuri Seto             ³ Data ³ 09/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se e uma nova revisao e se for, pede uma          ³±±
±±³			 ³ justificativa                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1: Controla a gravaçao do Memo						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010CaJu(lGrvJu)
Local oDlgFim
Local oIcon
Local oSay
Local oMemo
Local oBtn1
Local cEspec	:= "QMTA010S"
Local lCaJu		:= .F.
Local cMens	:= ""
Local cChaveJu	:= ""
Local lContinua := .T.
Local nx
Local bCampo
Local cNEspec := ""
Local lCaJuPE := ExistBlock("QMA010CAJU")

Private lFecha := .F.
bCampo	:= {|nCPO| Field(nCPO) }
IIF(lGrvJu == Nil,lGrvJu := .F.,)

cMemoJu := cMemoJuAnt := ""  

If lAltRevisao 
	If QM2->QM2_STATUS <> M->QM2_STATUS 
		lCaJu := .T.
		cChaveJu := QA_CvKey(xFilial("QM2")+M->QM2_INSTR+M->QM2_REVINS,"QM2",6)		
		If Empty(QM2->QM2_CHAVE)              
			cChaveJu := Qmt010VText(.T.,@cChaveJu,M->QM2_INSTR,M->QM2_REVINS) //Existencia/Reserva de Chave
			cMemoJu := cMemoJuAnt := ""
			If lCaJuPE 
				cMemoJuAnt := cMemoJu := ExecBlock("QMA010CAJU",.F.,.F., {cMemoJu})
			EndIf
		Else
			cChaveJu := QM2->QM2_CHAVE		
			cChvAnt	 := QM2->QM2_CHAVE		
			cNEspec	 := "QMTA010S" 
			dbSelectArea("QA3")
			dbSetOrder(1)
			
			cQuery := "SELECT QA3_FILIAL,QA3_ESPEC,QA3_CHAVE,QA3_TEXTO"
			cQuery += " FROM " + RetSqlName("QA3") +" QA3 "
			cQuery += " WHERE QA3.QA3_FILIAL = '"	+ xFilial("QA3") + "' AND "
			cQuery += " QA3.QA3_ESPEC = '" + cNEspec + "' AND " 
			cQuery += " QA3.QA3_CHAVE = '" + cChaveJu + "' AND " 			
			cQuery += " QA3.D_E_L_E_T_<>'*' "
		
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QTRB", .F., .T.)
			dbSelectArea("QTRB")

			While !Eof()
				cMemoJu := cMemoJu + QTRB->QA3_TEXTO 
				cMemoJuAnt := cMemoJu
				dbSkip()
			Enddo
			If lCaJuPE 
				cMemoJuAnt := cMemoJu := ExecBlock("QMA010CAJU",.F.,.F., {cMemoJu})
			EndIf                    
			QTRB->(dbCloseArea())
			dbSelectArea("QA3")				
			dbSetOrder(1)
			
			cChaveJu := Qmt010VText(.T.,@cChaveJu,M->QM2_INSTR,M->QM2_REVINS) //Existencia/Reserva de Chave
		Endif	
		cMens := STR0038	//"Digite abaixo a justificativa para alteracao do Status do instrumento "
		cEspec := "QMTA010H"

		For nx := 1 To 2
			//Zera o array para considerar Chaves diversas
			axTextos := {}     
			//Recupera texto da chave 
			QA_TEXTO(cChvAnt,cEspec,TamSx3("QA2_TEXTO")[1],"",alltrim(M->QM2_INSTR)+' - '+M->QM2_REVINS,;
			@axtextos,1,"",.T.,,.F.)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava Texto do Procedimento de Calibracao no QA2		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QA_GrvTxt(cChaveJu,cEspec,1,@axtextos)   // QAXFUN
	    	cEspec := "QMTA010I"
	    Next nx
		M->QM2_CHAVE := cChaveJu
	Else
		cChvAnt := QM2->QM2_CHAVE
		M->QM2_CHAVE := QM2->QM2_CHAVE //Associo a chave antiga para buscar as desc. da revisao anterior"" - Denis 05/03/02
		lContinua := .T.
		cChaveJu := Qmt010VText(.T.,@cChaveJu,M->QM2_INSTR,M->QM2_REVINS) //Existencia/Reserva de Chave
		dbSelectArea("QA3")                          
		dbSetOrder(1)

		cQuery := "SELECT QA3_FILIAL,QA3_ESPEC,QA3_CHAVE,QA3_TEXTO "
		cQuery += " FROM " + RetSqlName("QA3") +" QA3 "
		cQuery += " WHERE QA3.QA3_FILIAL = '"	+ xFilial("QA3") + "' AND "
		cQuery += " QA3.QA3_ESPEC = 'QMTA010S' AND " 
		cQuery += " QA3.QA3_CHAVE = '" + cChvAnt + "' AND " //cChaveJu			
		cQuery += " QA3.D_E_L_E_T_<>'*' "
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QTRB", .F., .T.)
		dbSelectArea("QTRB")

		While !Eof() 
			cMemoJu := cMemoJu + QTRB->QA3_TEXTO
			cMemoJuAnt := cMemoJu
			dbSkip()    	
		Enddo    
		If lCaJu
			If lCaJuPE 
				cMemoJuAnt := cMemoJu := ExecBlock("QMA010CAJU",.F.,.F., {cMemoJu})
		   	EndIf
	   	EndIf
		QTRB->(dbCloseArea())
		dbSelectArea("QA3")
		dbSetOrder(1)

		cEspec	:= "QMTA010H"
			For nx := 1 To 2
			axTextos := {}     
			//Recupera texto da chave 
			QA_TEXTO(cChvAnt,cEspec,TamSx3("QA2_TEXTO")[1],"",alltrim(M->QM2_INSTR)+' - '+M->QM2_REVINS,;
			@axtextos,1,"",.T.,,.F.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava Texto do Procedimento de Calibracao no QA2		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QA_GrvTxt(cChaveJu,cEspec,1,@axtextos)   // QAXFUN
	    	cEspec := "QMTA010I"
	    Next nx
		M->QM2_CHAVE := cChaveJu
	EndIf
Else	
	dbSelectArea("QA3")
	dbSetOrder(1)
	If DbSeek(xFilial("QA3")+cEspec+M->QM2_CHAVE)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao esta gerando uma nova revisao, permite alterar	 ³
		//³ a justificativa se existir           					 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Deve-se verificar o conteudo do campo QM2_STATUS com M->QM2_STATUS   ³
		//³pois se o conteudo dos campos sao iguais, a variavel lCaju devera    ³
		//³ficar .F. nesse caso, NAO devera cadastrar justificativa.			³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄDenisÄÄÄÄÄÄÄÄÙ

	 	If QM2->QM2_STATUS <> M->QM2_STATUS 
	 	   lCaJu := .T.  
	 	Else
	 	   lCaJu := .F.  
	 	Endif   
		cChaveJu := M->QM2_CHAVE

		cQuery := "SELECT QA3_FILIAL,QA3_ESPEC,QA3_CHAVE,QA3_TEXTO "
		cQuery += " FROM " + RetSqlName("QA3") +" QA3 "
		cQuery += " WHERE QA3.QA3_FILIAL = '"	+ xFilial("QA3") + "' AND "
		cQuery += " QA3.QA3_ESPEC = 'QMTA010S' AND " 
		cQuery += " QA3.QA3_CHAVE = '" + cChaveJu + "' AND " 			
		cQuery += " QA3.D_E_L_E_T_<>'*' "
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QTRB", .F., .T.)
		dbSelectArea("QTRB")

		While !Eof() 
			cMemoJu := cMemoJu + QTRB->QA3_TEXTO
			cMemoJuAnt := cMemoJu
		    dbSkip()
		Enddo                    
		If lCaJu
			If lCaJuPE 
				cMemoJuAnt := cMemoJu := ExecBlock("QMA010CAJU",.F.,.F., {cMemoJu})
			EndIf
		EndIf
		QTRB->(dbCloseArea())
		dbSelectArea("QA3")
		dbSetOrder(1)

	ElseIf QM2->QM2_STATUS <> M->QM2_STATUS 
		lCaJu    := .T.                    
		If Empty(QM2->QM2_CHAVE)              
			lContinua := .T.
			cChaveJu := Qmt010VText(.T.,@cChaveJu,M->QM2_INSTR,M->QM2_REVINS) //Existencia/Reserva de Chave
		Else
			cChaveJu := QM2->QM2_CHAVE		
		Endif	
		cMemoJu  := cMemoJuAnt := ""
		If lCaJuPE 
			cMemoJuAnt := cMemoJu := ExecBlock("QMA010CAJU",.F.,.F., {cMemoJu})
		EndIf
		cMens    := STR0038	//"Digite abaixo a justificativa para alteracao do Status do instrumento "
	EndIf
EndIf
	              
If lCaJu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³															 ³
	//³ Justificativa alteracao do status do instrumento.        ³
	//³															 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgFim FROM 58,1 TO 290,300 TITLE STR0028 PIXEL OF oMainWnd  //"Justificativa"
	@ 003,003 TO 095,147 OF oDlgFim PIXEL		
	@ 0.7,002 ICON oIcon RESOURCE "CLIPS" OF oDlgFim NOBORDER       		
	@ 011,045 SAY oSay PROMPT cMens+Capital(M->QM2_INSTR)+"-"+Capital(M->QM2_REVINS)+"." SIZE 096, 30 OF oDlgFim PIXEL 
	@ 035,017 GET oMemo VAR cMemoJu SIZE 116,50 OF oDlgFim MEMO NO VSCROLL PIXEL
	oMemo:bGotFocus := { || oMemo:nPos := 0,oMemo:Refresh()}

	@ 100, 100 BUTTON oBtn1 PROMPT STR0008 SIZE 44, 11 OF oDlgFim PIXEL ACTION (lFecha := .T.,A010VerJu(cMemoJu,cChaveJu,oDlgFim,cMemoJuAnt,@lFecha)) 

	ACTIVATE MSDIALOG oDlgFim CENTER VALID lFecha
	lFecha := .F.
EndIf

Return lGrvJu   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A010VerJu ³ Autora³ Iuri Seto             ³ Data ³ 15/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se foi digitada alguma justificativa.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010VerJu(ExpC1,ExpC2)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Texto da justificativa                              ³±±
±±³          ³ ExpC2: Chave da justificativa                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010VerJu(cMemoJu,cChaveJu,oDlgFim,cMemoJuAnt,lFecha)
Local aArea := GetArea()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso da alteracao do status do instrumento, devemos verificar se a variavel³
//³cMemoJu = cMemoJuAnt. Em caso afirmativo, exibir mensagem de obrigatoriedade  ³
//³da digitacao da justificativa.                       						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄDenisÄÄÄÄÄÙ
If Empty(cMemoJu) .or. cMemoJu == cMemoJuAnt
	msgstop(STR0030,STR0031)	//"Justificativa nao digitada.","Atencao"
	lFecha := .F.
Else
	RecLock("QM2",.F.)	
		M->QM2_CHAVE := cChaveJu
		QM2->QM2_CHAVE:=cChaveJu 
		lGrvJu := .T.
		oDlgFim:End()
	MsUnLock()
EndIf
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A010GvJu  ³ Autora³ Iuri Seto             ³ Data ³ 09/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Justificativa para criacao de uma nova revisao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010GvJu(ExpC1,ExpC2)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Objeto Memo 										  ³±±
±±³			 ³ ExpC2: Objeto caixa de diálogo               			  ³±±
±±³			 ³ ExpL1: Controle de gravacao do memo            			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010GvJu(cMemoJu)
Local nTamQM3  := 1
Local nDivQM3  := 0
Local nd	   := 0
Local nSeqQA3  := 0
dbSelectArea("QA3")
dbSetOrder(1)
If DbSeek(xFilial("QA3")+"QMTA010S"+QM2->QM2_CHAVE)
	While !Eof() .and. QA3->QA3_FILIAL+QA3->QA3_ESPEC == xFilial("QA3")+"QMTA010S"
		If Alltrim(QA3->QA3_CHAVE) == Alltrim(QM2->QM2_CHAVE)
			RecLock("QA3",.F.) 
			dbDelete()
			MsUnlock()
		Endif	
	dbSkip()
	Enddo	
EndIf
If !Empty(cMemoJu)
	nDivQM3 := Int(Len(cMemoJu)/75)+1
	nTamQM3 := 1
	For nd := 1 to nDivQM3
		nSeqQA3++						
		If !Empty(SubsTr(cMemoJu,nTamQM3,75))             
			RecLock("QA3",.T.)
			QA3->QA3_FILIAL := xFilial("QA3")
			QA3->QA3_CHAVE  := QM2->QM2_CHAVE
			QA3->QA3_ESPEC  := "QMTA010S"
			If nd == 1
				QA3->QA3_TEXTO := Substr(cMemoJu,nTamQM3,75)
				nTamQM3 = 0
			Else
				QA3->QA3_TEXTO := Substr(cMemoJu,nTamQM3+1,75)   
			Endif
			nTamQM3 := nTamQM3+75
			QA3->QA3_SEQ	:= StrZero(nSeqQA3,3)
			QA3->QA3_DATA	:= dDatabase
			QA3->QA3_DATINV := Inverte(QA3->QA3_DATA)
			MsUnlock()	
		Endif
	Next
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A010DelTxt³ Autora³ Iuri Seto         	³ Data ³ 09/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Deleta o texto.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010DelTxt(ExpC1,ExpC2,ExpN1,ExpC3)		    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Chave do Texto (j  convertida) 					  ³±±
±±³			 ³ ExpC2 = Especie do Texto									  ³±±
±±³			 ³ ExpC3 = Alias do arquivo para leitura                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010DelTxt(cChave,cEspecie,cAlias)

Local cOldAlias := Select()
Local cEspecT
Local cChaveT

cEspecT := cAlias+"->"+cAlias+"_ESPEC"
cChaveT := cAlias+"->"+cAlias+"_CHAVE"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o texto                                 			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbseek(xFilial(cAlias) + cEspecie + cChave)
While !Eof() .and. xFilial(cAlias)+&cEspecT+&cChaveT == xFilial(cAlias)+cEspecie+cChave
	RecLock(cAlias, .f.) // Lock
	dbDelete()
	dbSkip()
Enddo

dbSelectArea(cOldAlias)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QMA010VlLo³ Autora³ Iuri Seto         	³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida Localizacao para instrumentos que pertencem a malha ³±±
±±³          ³ (QM2->QM2_STATUS = M)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QMA010VlLo(cExp1)                  		    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parâmetros³ cExp1 : Código do Instrumento Malha						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010      											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMA010VlLo(cInsMal)                                                   
Local lRet
Local cOldAlias := QM2->(Select())
Local nReg	:= QM2->(Recno())

lRet := .T.

If M->QM2_STATUS == "0" 
	If Empty(cInsMal)
		msgstop(STR0032,STR0031)	// "Digite na Localização o Código da Malha a qual este instrumento pertence.","Atenção"
		lRet := .F.
	Else   
		dbSelectArea("QM2")
		QM2->(dbSetOrder(1))
		If QM2->(dbSeek(xFilial("QM2")+cInsMal))
			If QM2->QM2_STATUS == "0"
				msgstop(STR0033+QM2->QM2_LOCAL+".",STR0031)	// "Instrumento digitado no campo Localização inválido, pertence a malha ","Atenção"
				lRet := .F.		
			EndIf
		Else
			msgstop(STR0034,STR0031)	// "Instrumento digitado no campo Localização não encontrado ","Atenção"
			lRet := .F.
		EndIF                    
	EndIf
EndIf

dbSelectArea(cOldAlias)
dbGoto(nReg)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A010ConIns³ Autora³ Iuri Seto         	³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta de instrumentos para o campo localizacao qdo      ³±±
±±³          ³ o status for igual a M (Malha), para a tecla F4            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010ConsIns()                     		    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010        											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                
Function a010ConIns(a,b,c,cArq)
If ReadVar() == "M->QM2_LOCAL"               	
	If ConPad1(a,b,c,cArq)
		M->QM2_Local := QM2->QM2_INSTR
	Endif
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A010VlEscM³ Autora³ Iuri Seto         	³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a Escala da Malha para permitir somente as escalas  ³±±
±±³          ³ da família do instrumento digitado no campo Localização.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010VlEscM(cExp1,cExp2,cExp3)       		    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parâmetros³ cExp1 : Código do Instrumento Malha   					  ³±±
±±³          ³ cExp2 : Escala do Instrumento Malha 						  ³±±
±±³          ³ cExp3 : Escala do Instrumento Malha 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010        											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                
Function a010VlEscM(cInstr,cInsMal,cEscMal,cStatus)
Local lRet
Local cOldAlias := Select()
Local nReg	:= Recno()
Local cRev

lRet := .T.
If cStatus == "0" 

	If Empty(cEscMal)
		msgstop(STR0037,STR0031)	// "Escala não encontrada."
		lRet := .F.
	EndIf
	
	If lRet		
		dbSelectArea("QM2")
		dbSetOrder(1)
		If QM2->(dbSeek(xFilial("QM2")+cInsMal))
			dbSelectArea("QMK")
			dbSetOrder(1)
			If QMK->(dbSeek(xFilial("QMK")+QM2->QM2_TIPO))    
				cRev := QMK->QMK_REVINV
				QMK->(dbGoTop())
				If !QMK->(dbSeek(xFilial("QMK")+QM2->QM2_TIPO+cRev+cEscMal))
					msgstop(STR0035,STR0031)	// "Escala não pertence ao instrumento Malha.","Atenção"
					lRet := .F.                                
				EndIf
			Else
				msgstop(STR0037,STR0031)	// "Escala não encontrada."
				lRet := .F.                                
			EndIf	
		Else
			msgstop(STR0037,STR0031)	// "Escala não encontrada."
			lRet := .F.                                
		EndIf
	EndIf
	
	If lRet
		dbSelectArea("QM2")
		dbSetOrder(7)
		If QM2->(dbSeek(xFilial("QM2")+"0"+cInsMal+cEscMal))
			If QM2->QM2_INSTR <> cInstr
				lRet := .F.                                
				msgstop(STR0036+QM2->QM2_INSTR,STR0031)	// "Escala já cadastrada no instrumento "+QM2->QM2_INSTR,"Atenção"
			EndIf	
		EndIf
	EndIf
EndIf
	
dbSelectArea(cOldAlias)
dbGoto(nReg)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A010FlEscM³ Autora³ Iuri Seto         	³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtro da consulta F3 QMK do campo Escala da Malha. Filtra ³±±
±±³          ³ somente as escalas da família do instrumento digitado no   ³±±
±±³          ³ campo Localização.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010FilEsc()                     		    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010        											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                
Function a010FlEscM()
Local lRet
Local aArea := GetArea()

lRet := .F.
dbSelectArea("QM2")
dbSetOrder(1)
If QM2->(dbSeek(xFilial("QM2")+M->QM2_LOCAL))
	If QMK->QMK_TIPO = QM2->QM2_TIPO
		lRet := .T.
	EndIf	
EndIf

RestArea(aArea) 

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QMA010UltR³ Autora³ Iuri Seto             ³ Data ³ 31/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a ultima revisao do instr. enviando como parametro.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMA010UltR(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do instrumento                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMA010UltR(cInstr)
Local cRevisao 	:= ""            
Local aArea		:= GetArea()
/*Local cAlias	:= Select()
Local nOrdem	:= IndexOrd()
Local nRegis 	:= RECNO()
*/
DbSelectArea("QM2")
DbSetOrder(1)
If QM2->(DbSeek(xFilial("QM2")+cInstr))
	cRevisao := QM2->QM2_REVINS
EndIf

RestArea(aArea)

/*DbSelectArea(cAlias)
DbSetOrder(nOrdem)
DbGoto(nRegis)*/
Return(cRevisao)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A010CAPo	³ Autora³ Iuri Seto             ³ Data ³ 01/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastra Pontos para Tipo = 4						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A010CaPo(cTipo,cInstr,cRevIns,oDlgC,lMtAc,lMtPto)
Local lRet := .T.
Local	cIndice := CriaTrab(NIL,.F.)
Local	cChave 	:= "QMR_FILIAL+QMR_INSTR+QMR_REVINS"   
Local	cChvQmk := "QMK_FILIAL+QMK_TIPO"   
Local	cFiltro	:= ""
Local	lFzPto	:= .F.
Local	aArea	:= GetArea()
Local 	cQMKEsc := ""
Local	cQMKRev := ""
Local	cRev	:= ""
Local	nPosicao:= 0
Local   nx		:= 0
Default lMtAc	:= .T.
Default lMtPto	:= .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³* * * O objetivo dessa rotina e verificar se digitarei PONTOS para escalas 			³
//³calibradores e/ou calibradores completos. Caso a Familia tenha somente escala do tipo³
//³de calibracao VAZIO e o Orgao Aferidor for EXTERNO nao ha necessidade de cadastramen-³
//³to de PONTOS * * *                                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("QM9")
QM9->(dbSetOrder(1))
DbSelectArea("QMR")
QMR->(dbSetOrder(1))
If QMR->(dbSeek(xFilial("QMR")+cInstr+cRevIns))
	While !Eof() .And. xFilial("QMR")+cInstr+cRevIns == QMR->QMR_FILIAL+QMR->QMR_INSTR+QMR->QMR_REVINS
		QM9->(dbSetOrder(1))
		If QM9->( dbSeek( xFilial( "QM9" ) + QMR->QMR_ESCALA ))
			nPosicao := aScan(aEscs,{|x| alltrim(x[1]) = Alltrim(QMR->QMR_ESCALA)})
			If nPosicao == 0
				Aadd(aEscs,{QM9->QM9_ESCALA,QM9->QM9_UNIMED,QM9->QM9_TIPAFE})
			Endif
		Endif
		QMR->(dbSkip())
	Enddo
Else
	dbSelectArea("QMK")
	dbSetOrder(1)
	If QMK->(dbSeek(xFilial("QMK")+cTipo))
		cRev := QMK->QMK_REVTIP
		While !EOF() .And. xFilial("QMK")+cTipo+cRev == QMK->QMK_FILIAL+QMK->QMK_TIPO+QMK->QMK_REVTIP
			QM9->(dbSetOrder(1))
			If QM9->( dbSeek( xFilial( "QM9" ) + QMK->QMK_ESCALA ))
				nPosicao := aScan(aEscs,{|x| alltrim(x[1]) = Alltrim(QMK->QMK_ESCALA)})
				If nPosicao == 0
					Aadd(aEscs,{QM9->QM9_ESCALA,QM9->QM9_UNIMED,QM9->QM9_TIPAFE})
				Endif	
			EndIf
			QMK->(DbSkip())
		EndDo
	Endif	
Endif	

QMK->(DbSetOrder(1))
If QMK->(DbSeek(xFilial("QMK")+cTipo))
	If QM9->(DbSeek(xFilial("QM9")+QMK->QMK_ESCALA))
		dbSelectArea("QM2")
		If	!Inclui .and. QM2->QM2_TIPO <> cTipo
			dbSelectArea("QMK")
			dbSetOrder(1)
			cQuery := "SELECT QMK_FILIAL,QMK_TIPO,QMK_REVTIP,QMK_ESCALA,QMK_REVINV"
			cQuery += " FROM " + RetSqlName("QMK")
			cQuery += " QMK WHERE QMK_FILIAL = '" + xFilial("QMK") + "' AND "
			cQuery += " QMK.QMK_TIPO = '"  + cTipo + "' AND " 
			cQuery += " QMK.D_E_L_E_T_<>'*' "					
			cQuery += " ORDER BY " + SqlOrder(QMK->(IndexKey()))
	
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QMKTRB", .F., .T.)
			dbSelectArea("QMKTRB")
   	    
		   	If QMKTRB->(Eof())
		   		lFzPto := .T.
		   	Endif           

			If !lFzPto
				cQMKEsc := QMKTRB->QMK_TIPO
				cQMKRev := QMKTRB->QMK_REVTIP
                        While !Eof() .and. QMKTRB->QMK_FILIAL+QMKTRB->QMK_TIPO+;
                        					QMKTRB->QMK_REVTIP == xFilial("QMK")+;
                        					cQMKEsc+cQMKRev
					QM9->(DbSetOrder(1))
					If QM9->(DbSeek(xFilial("QM9")+QMKTRB->QMK_ESCALA))
						If	QM9->QM9_TIPAFE == '4' .Or. QM9->QM9_TIPAFE == '8'
							lFzPto := .T.
							Exit
						Else
							lFzPto := .F.
						Endif
					Endif
					dbSelectArea("QMKTRB")
					dbSkip()
				Enddo
				dbCloseArea()		            
			Endif
		Else
			If	QM9->QM9_TIPAFE $ '4|8| ' 
		
				cQuery := "SELECT QMR_FILIAL,QMR_INSTR,QMR_REVINS,QMR_ESCALA,QMR_CAOBRI"
				cQuery += " FROM " + RetSqlName("QMR")
				cQuery += " QMR WHERE QMR_FILIAL = '" + xFilial("QMR") + "' AND "
				cQuery += " QMR.QMR_INSTR = '"  + cInstr  + "' AND " 
				cQuery += " QMR.QMR_REVINS = '" + cRevIns + "' AND " 			
				cQuery += " QMR.D_E_L_E_T_<>'*' "
				cQuery += " ORDER BY " + SqlOrder(QMR->(IndexKey()))
	        	
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QMRTRB", .F., .T.)
				dbSelectArea("QMRTRB")
	   	
			   	If QMRTRB->(Eof())
			   		lFzPto := .T.
			   	Endif           
	   	
		   		If !lFzPto
					dbSelectArea("QM9")
					dbSetOrder(1)
				   	While !Eof()
						If QMRTRB->QMR_FILIAL+QMRTRB->QMR_INSTR+QMRTRB->QMR_REVINS == xFilial("QMR")+cInstr+cRevIns 
							dbSelectArea("QM9")
							dbSetOrder(1)								
							If QM9->(dbSeek(xFilial("QM9")+QMRTRB->QMR_ESCALA))
								If QM9->QM9_TIPAFE $ "4|8"
									lFzPto := .T.
									Exit       					
	        							Endif
							Endif
						Endif   
					dbSelectArea("QMRTRB")
					dbSkip()
					EndDo
				Else
					cQMKEsc := QMK->QMK_TIPO
					cQMKRev := QMK->QMK_REVTIP
					dbSelectArea("QMK")
					dbSetOrder(1)
	            	            While !Eof() .and. QMK->QMK_FILIAL+QMK->QMK_TIPO+;
	                	        					QMK->QMK_REVTIP == xFilial("QMK")+;
	                    	    					cQMKEsc+cQMKRev
						QM9->(DbSetOrder(1))
						If QM9->(DbSeek(xFilial("QM9")+QMK->QMK_ESCALA))
							If	QM9->QM9_TIPAFE == '4' .Or. QM9->QM9_TIPAFE == '8'
								lFzPto := .T.
								Exit
							Else
								lFzPto := .F.
							Endif
						Endif
					dbSelectArea("QMK")
					dbSkip()
					Enddo		            
				Endif	
			dbSelectArea("QMRTRB")
			dbCloseArea()
			Endif
		Endif
		RestArea(aArea)		

		//Colocar lFzPto T analisando...
	
		If lFzPto
			If lMtPto
				lRet := A010IPon(cInstr,cRevIns,oDlgC,lMtAc)		
			Else
				lRet := lMtPto
			Endif
		Else
			//Verificar no aColsQMR se existe alguma escala calibrador / calibrador completo		
			For nx := 1 To Len(aColsQMR)
				dbSelectArea("QM9")
				dbSetOrder(1)
				If dbSeek(xFilial()+aColsQMR[nx][1])
					If QM9->QM9_TIPAFE $ "4|8" .and. !aColsQMR[nx][Len(aColsQMR[nx])]
						lFzPto := .T.
						Exit
					Endif
				Endif
			Next nx
			If lFzPto
				lRet := A010IPon(cInstr,cRevIns,oDlgC,lMtAc)		
			Endif
		Endif
	Endif
Else
	If oBtIncEs <> Nil
		oBtIncEs:Hide()
	Endif	
	If Len(aColsQMR) == 0
		MessageDlg(OemToAnsi(STR0040),,3)//"Nao existe(m) faixa(s) associada(s) a essa familia."
		lRet := .F.
	Else
		//Verificar no aColsQMR se existe alguma escala calibrador / calibrador completo		
		For nx := 1 To Len(aColsQMR)
			dbSelectArea("QM9")
			dbSetOrder(1)
			If dbSeek(xFilial()+aColsQMR[nx][1])
				If QM9->QM9_TIPAFE $ "4|8" .and. !aColsQMR[nx][Len(aColsQMR[nx])]
					lFzPto := .T.
					Exit
				Endif
			Endif
		Next nx
		If lFzPto
			lRet := A010IPon(cInstr,cRevIns,oDlgC,lMtAc)		
		Endif
	Endif	
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A010GeraRe³ Autora³ Iuri Seto             ³ Data ³ 01/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se e para gerar nova revisao.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010GeraRe(cAlias,cCampoNGR)
Local lRet := .F.
Local bCampo
Local i
Local cOldAlias := Select()

dbSelectArea(cAlias)		 
bCampo := {|nCPO| Field(nCPO) }

FOR i := 1 TO FCount()
    If M->&(EVAL(bCampo,i)) <> FieldGet(i) .And. !( EVAL(bCampo,i) $ cCampoNGR )
		lRet := .T.
		Exit
	EndIf
NEXT i                
dbSelectArea(cOldAlias)		 

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QA010Dupl ³ Autora³ Iuri Seto             ³ Data ³ 05/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Duplica QMG para a nova revisao.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QA010Dupl(cAlias,cInstr,cRevIns,cRevAnt,cChave,cCamRev)

Local	bCampo := {|nCPO| Field(nCPO) }
Local 	nRegis
Local 	i
Local 	lContinua := .T.

DbSelectArea(cAlias)
DbSetOrder(1)
If cAlias == "QMG"  
	If (&cAlias.->(DbSeek(xFilial(cAlias)+cInstr+cRevIns)))
		lContinua := .F.
	EndIf 
EndIf

IF &cAlias.->(DbSeek(xFilial(cAlias)+cInstr+cRevAnt)) .AND. lContinua
	While !EOF() .And. xFilial(cAlias)+cInstr+cRevAnt ==	&cChave.

		FOR i := 1 TO FCount()
			If EVAL(bCampo,i) $ cCamRev
				M->&(EVAL(bCampo,i)) := cRevIns
			Else
				M->&(EVAL(bCampo,i)) := FieldGet(i)
			EndIf		
		NEXT i
		nRegis := Recno()							
						
		RecLock(cAlias,.T.)
		For i := 1 TO FCount()
			FieldPut(i,M->&(EVAL(bCampo,i)))
		Next i
		MsUnlock()   
                    	
		DbGoto(nRegis)
		DbSkip()
	EndDo							
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QMA010Cal ³ Autora³ Iuri Seto             ³ Data ³ 13/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a revisao do instrumento ja foi calibrada.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMA010Cal(cInstr,cRevIns)
Local lRet := .F.
   
DbSelectArea("QM6")
QM6->(DbSetOrder(1))
If QM6->(DbSeek(xFilial("QM6")+cInstr+cRevIns))
	lRet := .T.
EndIf
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³qmt010CaPe³ Autor ³ Denis Martins 		³ Data ³27.11.00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de Visualizacao: Evitar digitacao na MsGetDados().   ³±±
±±³Descri‡„o ³Essa funcao devera ser colocada nos campos QMR_CAOBRI e     ³±±
±±³Descri‡„o ³QMR_PREC(X3_WHEN).                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³.T. ou .F.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010CaPe(o)

Local lRet := .f.
Local nPosCal  := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMR_CAOBRI" })
Local nPosPrec := ASCAN(aHeader,{|x| alltrim(x[2]) = "QMR_PREC" })

If aDigita[n,nPosCal] == .T. .or. aDigita[n,nPosPrec] == .T.
	If o:Colpos == nPosCal .or. o:ColPos == nPosPrec
		If !Inclui
			dbSelectArea("QM6")
			dbSetOrder(1)
			If dbSeek(xFilial("QM6")+QM2->QM2_INSTR+QM2->QM2_REVINS)
				lRet := .F.
				MessageDlg(OemToAnsi(STR0049)+OemToAnsi(STR0050),,3)//"Nao e permitido alterar esse campo para instrumento/revisao que apresente "+;
																	//"calibracoes. Por favor, realize duplicacao do instrumento."	
			Else
				lRet := .T.			
			Endif
		Else
			lRet := .T.	
		Endif	
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a010MoQMK ºAutor  ³Denis Martins       º Data ³  05/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta GetDados das escalas apartir do arquivo QMK qdo nao   º±±
±±º          ³existir no QMR.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA010(Chamada na funcao a010CatR())                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a010MoQMK(cTipo,cRev)
Local	lRet := .F.
Local	nCntFor := 0

nPosAli := Ascan(aHeader,{|x| AllTrim(x[2]) == "QMR_ALI_WT"})
nPosRec := Ascan(aHeader,{|x| AllTrim(x[2]) == "QMR_REC_WT"})

dbSelectArea("QMK")
QMK->(dbSetOrder(1))
If QMK->(dbSeek(xFilial("QMK")+cTipo))
	cRev := QMK->QMK_REVTIP
	While !EOF() .And. xFilial("QMK")+cTipo+cRev == QMK->QMK_FILIAL+QMK->QMK_TIPO+QMK->QMK_REVTIP
		QM9->(dbSetOrder(1))
		If QM9->( dbSeek( xFilial( "QM9" ) + QMK->QMK_ESCALA ))
			If Alltrim(QM9->QM9_TIPAFE) $ "4|8"
				lFzCal := .T.
				oBtn2:Enable()
			Endif 
		    lRet := .T.
			If QM9->QM9_LAUDO == "1"  // Com confirmacao meterol¢gica
				aadd(aDigita,{QMK->QMK_ESCALA,.t.,.t.,.f.,.t.,.t.}) // True para os cpos tolerancia e redutor
			ElseIf QM9->QM9_LAUDO == "2"
				aadd(aDigita,{QMK->QMK_ESCALA,.f.,.f.,.t.,.t.,.t.}) // True para incerteza permitida
			Else
				aadd(aDigita,{QMK->QMK_ESCALA,.f.,.f.,.f.,.t.,.t.})
			EndIf
			aCampos := {QMK->QMK_ESCALA}
			For nCntFor := 2 To Len( aHeader )          
				If !(aHeader[nCntFor,2] $ "QMR_ALI_WT | QMR_REC_WT")
					aadd(aCampos,CriaVar(aHeader[nCntFor,2],.t.))
				Else
					aAdd(aCampos,"")
				EndIf
			Next nCntFor
			If nPosAli > 0 .And. nPosRec > 0
				aCampos[nPosAli] := "QMR"
				If IsHeadRec(aHeader[nPosRec,2])
					aCampos[nPosRec] := QMR->(RecNo())
				EndIf
			Endif
			aadd(aCampos,.F.)
			aadd(aCols,aCampos)
		EndIf
		QMK->(DbSkip())
	EndDo
Endif	
If nVals == 2
	aHeaderQMR := aClone(aHeader)
	aColsQMR := aClone(aCols)
ElseIf nVals == 3
	aHeaderQMG := aClone(aHeader)
	aColsQMG := aClone(aCols)
Endif	
Return lRet			

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt010vcalºAutor  ³Denis Martins		 º Data ³  01/16/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe mais que uma escala tipo calibrador/cali-º±±
±±º          ³brador completo com calibracao obrigatoria ativada.CAOBRI=S º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010vcal(oDlgC,nOpca,cTipo,cInstr,cRevIns)
Local nx
Local lRetu := .T.
Local nPosArray	:= 0
Local nCount	:= 0
Local cFamis	:= ""
Local aEscas	:= {} 
Local nPosicao	:= 0
Local cRev		:= ""
Local cInstrum  := ""
Local cRevInst  := ""

cFamis		:= cTipo
cInstrum	:= cInstr
cRevInst	:= cRevIns

dbSelectArea("QM1")
dbSetOrder(1)
If dbSeek(xFilial("QM1")+cFamis)
	dbSelectArea("QMK")
	dbSetOrder(1)
	If QMK->(dbSeek(xFilial("QMK")+cFamis))
		cRev := QMK->QMK_REVTIP
		While !EOF() .And. xFilial("QMK")+cFamis+cRev == QMK->QMK_FILIAL+QMK->QMK_TIPO+QMK->QMK_REVTIP
			dbSelectArea("QM9")
			QM9->(dbSetOrder(1))
			If QM9->( dbSeek( xFilial( "QM9" ) + QMK->QMK_ESCALA ))
				If QM9->QM9_TIPAFE $ "4|8| "
					If aScan(aEscas,{|x| alltrim(x[1]) = Alltrim(QMK->QMK_ESCALA)}) > 0
						nPosicao := aScan(aEscas,{|x| alltrim(x[1]) = Alltrim(QMK->QMK_ESCALA)})
					Endif
					If nPosicao == 0
						Aadd(aEscas,{QM9->QM9_ESCALA,QM9->QM9_UNIMED,QM9->QM9_TIPAFE})
					Endif	
				Else
					Aadd(aEscas,{"","",""})				
				EndIf
			Endif	
			QMK->(DbSkip())
		EndDo
	Else
		If Len(aColsQMR) == 0
			MessageDlg(OemToAnsi(STR0040),,3)	//"Nao existe(m) faixa(s) associada(s) a essa familia."
			lRetu := .F.
			dbSelectArea("QM2")
		Endif
	Endif	
Endif
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando as faixas  do aColsQMR forem  maiores que  as  faixas  de aEscas eu  tenho  que   inserir as caracteristicas da  faixa  a mais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aColsQMR)>Len(aEscas)
	For nx := 1 To Len(aColsQMR)
		nPosArray := aScan(aEscas,{|x| alltrim(x[1]) = alltrim(aColsQMR[nx][1])})  
		If nPosArray == 0 
			dbSelectArea("QM9")
			QM9->(dbSetOrder(1))
			If QM9->( dbSeek( xFilial( "QM9" ) + aColsQMR[nx][1]))
				Aadd(aEscas,{aColsQMR[nx][1],QM9->QM9_UNIMED,QM9->QM9_TIPAFE})
			EndIf
		EndIf
	Next nx
EndIf

If nVals == 3 // Pontos Calibradores
	aHeaderQMG := aClone(aHeader)
	aColsQMG   := aClone(aCols)             
	aHeader    := {}
	aCols      := {}
	aHeader    := aClone(aHeaderQMR)
	aCols      := aClone(aColsQMR)
Endif                    

For nx := 1 To Len(aEscas)
	nPosArray := aScan(aColsQMR,{|x| alltrim(x[1]) = alltrim(aEscas[nx][1])})
	If nPosArray > 0
		If nPosArray > Len(aEscas)
			MessageDlg(OemToAnsi(STR0090) + Alltrim(aCols[nPosArray][1]) + OemToAnsi(STR0091) + Alltrim(cFamis) + " - " +Alltrim(cRev)+ ")",,1) //"Existe incompatibilidade entre associacoes de escalas - escalas calibradores ("###") e escalas diferente de calibradores. Revise a associacao da Familia (
			lRetu := .f.
			Exit
		Else
			//Verifica se foi digitado o codigo da faixa para poder contar as faixas...
			If nPosArray <= Len(aCols) .And. !Empty(aColsQMR[nPosArray][1])
				If aEscas[nPosArray][3] $ "4|8" .and. Alltrim(aColsQMR[nPosArray][5]) == "S"
					If !aCols[nPosArray][Len(aCols[nPosArray])] //Se nao estiver deletado
						nCount++                                    
					EndIf
				Endif          
			Endif
		Endif	
	Endif	
Next nx
If nCount > 1
	MessageDlg(OemToAnsi(STR0042),,3) //"Existe mais de uma escala calibrador/calibrador completo com calibracao obrigatoria ativada"
	nOpca := 0
	lRetu := .F.
Endif

If nVals == 3
	aHeaderQMR := aClone(aHeader)
	aColsQMR   := aClone(aCols)             
	aHeader    := {}
	aCols      := {}
	aHeader    := aClone(aHeaderQMG)
	aCols      := aClone(aColsQMG)
Endif                    

Return lRetu //nOpca

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Qmt010VTextºAutor  ³Denis Martins       º Data ³  03/05/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se a chave ja existe e retorna a chave criada.      º±±
±±º          ³                                                             º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºParƒmetros³ Exp1:Start do While									  	   º±±
±±º          ³ Exp2:Chave dos arquivos QA2/QA3							   º±±
±±º          ³ Exp3:Instrumento   									  	   º±±
±±º          ³ Exp4:Revisao       									  	   º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºRetorno	 ³ Chave dos arquivos QA2/QA3								   º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±ºUso       ³                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt010VText(lContinua,cChaveJu,cInstrumento,cRevInst)

Local aArea := GetArea()
Default cChaveJu := ""

While lContinua //Reserva de Chave
	cChaveJu := QA_CvKey(xFilial("QM2")+cInstrumento+cRevInst,"QM2",6)
	dbSelectArea("QA3")
	dbSetOrder(1)
		If !dbSeek(xFilial("QA3")+"QMTA010S"+cChaveJu)
			If !dbSeek(xFilial("QA3")+"QMTA010I"+cChaveJu)
				If !dbSeek(xFilial("QA3")+"QMTA010R"+cChaveJu)			
					dbSelectArea("QA2")
					If !dbSeek(xFilial("QA2")+"QMTA010H"+cChaveJu)
						If !dbSeek(xFilial("QA2")+"QMTA010I"+cChaveJu)
							lContinua := .F.
						Endif
					Endif
				Endif
			Endif			
		Endif	
Enddo	
RestArea(aArea)
Return cChaveJu
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ A010Just ³ Autor ³ Denis Martins			³ Data ³ 24.09.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de chamada para textos Reprogramacao			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010Just(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Instrumento							  ³±±
±±³			 ³ ExpC2 = Revisao do Instrumento							  ³±±
±±³			 ³ ExpC3 = Array com Textos									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010Just(cAlias,nReg, nOpc )
Local oDlgRe
Local oFontMet   := TFont():New("Courier New",6,0)
Local oFontDialog:= TFont():New("Arial",6,15,,.T.)
Local cTit		 := STR0012 //Instrumento
Local cCod		 := QM2->QM2_INSTR
Local cRevRe	 := QM2->QM2_REVINS
Local nOpca		 := 1
Local cTextosD	 := ""
Local oTextosD	 
Local aArea		 := GetArea()
Local cIndice	 := CriaTrab(Nil,.F.)
Local cChvQmd	 := "QMD_FILIAL+QMD_INSTR+DTOS(QMD_DATA)"   
Local cFiltro	 := ""
Local nIndice	 := 0
Local aImps		 := {}
Local oCdRev

dbSelectArea("QMD")
dbSetOrder(1)
If dbSeek(xFilial("QMD")+QM2->QM2_INSTR)
	cFiltro  := "QMD_FILIAL=='"+xFilial("QMD")+"'.And."
	cFiltro  += "QMD_INSTR =='"+QM2->QM2_INSTR+"'"
                		
	IndRegua("QMD",cIndice,cChvQmd,,cFiltro,STR0041) // Selecionando Registros. . .
	nIndice := RetIndex("QMD")
	dbSetOrder(nIndice+1)
	dbGoTop()  
	While !QMD->(Eof()) 
		If QMD->QMD_INSTR == cCod
	    	cTextosD += DtoC(QMD->QMD_DATA)+" - "+QMD->QMD_JUSTIF+CHR(13)+CHR(10)
	    	Aadd(aImps,DtoC(QMD->QMD_DATA)+" - "+QMD->QMD_JUSTIF)
		Endif
		dbSelectArea("QMD")	    
		dbSkip()           
	Enddo

	dbSelectArea("QMD")
	RetIndex("QMD")                      
	Set Filter To
	Ferase(cIndice + OrdBagExt())
Endif

dbSelectArea("QM2")
DEFINE MSDIALOG oDlgRe FROM	62,100 TO 320,610 TITLE OemToAnsi(STR0043) PIXEL FONT oFontDialog //Reprogramacao
	
@ 003, 004 TO 027, 250 LABEL cTit OF oDlgRe PIXEL
@ 040, 004 TO 110, 250	OF oDlgRe PIXEL

@ 013, 010 MSGET oCdRev VAR (Alltrim(cCod)+" - "+cRevRe) SIZE 185, 010 OF oDlgRe PIXEL
oCdRev:lReadOnly := .T.
	
@ 050, 010 GET oTextosD VAR cTextosD MEMO READONLY SIZE 235, 051 OF oDlgRe PIXEL
	
oTextosD:SetFont(oFontMet)
	
DEFINE SBUTTON FROM 115,160 TYPE 6 ACTION (nOpca := 1,qmt010RepI(cCod,cRevRe,aImps),oDlgRe:End()) ENABLE OF oDlgRe
DEFINE SBUTTON FROM 115,190 TYPE 1 ACTION (nOpca := 2,oDlgRe:End()) ENABLE OF oDlgRe
DEFINE SBUTTON FROM 115,220 TYPE 2 ACTION (nOpca := 3,oDlgRe:End()) ENABLE OF oDlgRe
	
ACTIVATE MSDIALOG oDlgRe CENTERED
RestArea(aArea)
Return

/*                                     
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt010IRep³ Autor ³ Denis Martins         ³ Data ³ 24.09.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao dos Textos	Reprogramacao		 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010Just(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Instrumento							  ³±±
±±³			 ³ ExpC2 = Revisao do Instrumento							  ³±±
±±³			 ³ ExpC3 = Array com Textos									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010RepI(cCod,cRevRe,aImps)
Private aTexto		:= aImps
Private cCodIns		:= cCod
Private cRevIns		:= cRevRe

If !TRepInUse()
	QM010IRepR3(cCod,cRevRe,aImps) //Executa versão anterior do fonte
Else
    oReport := ReportDef()
    oReport:PrintDialog()
EndIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ReportDef ³ Autor ³ Cicero Cruz           ³ Data ³ 26.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao dos Textos	Reprogramacao R4	 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Instrumento							  ³±±
±±³			 ³ ExpC2 = Revisao do Instrumento							  ³±±
±±³			 ³ ExpC3 = Array com Textos									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local oReport                                             
Local oSection
Local aOrdem    := {}
Local cFilDep  	:= xFilial("QM2")
Local nX		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport   := TReport():New("QMTA010",;  //Nome do relatorio
							OemToAnsi(STR0045),;  // "Texto de Reprogramacao"
							nIL,;  
							{|oReport| PrintReport(oReport)},;
							OemToAnsi(STR0044)+OemToAnsi(STR0045)) // "Este programa ira emitir a rela‡ao de"###"Texto de Reprogramacao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection := TRSection():New(oReport,OemToAnsi(STR0045),{"QM2"}) // "Texto de Reprogramacao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//TRCell():New(oSection,"QM2_INSTR","QM2",,,,,{|| Posicione("QM2",1,xFilial("QM2")+cCodIns+INVERTE(cRevIns),"QM2_INSTR") } )    
TRCell():New(oSection,"QM2_INSTR" ,"QM2")    
TRCell():New(oSection,"QM2_REVINS","QM2")   
TRCell():New(oSection,"HIST"      ,"   ",STR0095,,45,,) // "Data(s)-Texto(s)"

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³PrintRepor³ Autor ³ Cicero Cruz           ³ Data ³ 26.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao dos Textos	Reprogramacao R4	 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport( oReport )
Local oSection1 := oReport:Section(1)
Local nX := 0

DBSelectArea("QM2")
DBSetOrder(1)

cFiltro:= 'QM2_FILIAL== "'+xFilial("QM2")+'" .AND. '
cFiltro+= 'QM2_INSTR == "'+cCodIns+'" .AND. QM2_REVINV == "'+INVERTE(cRevIns)+'"'

oSection1:SetFilter(cFiltro)   

oSection1:Init()
For nX:=1 to Len(aTexto)
	oSection1:Cell("HIST"):SetValue(aTexto[nX])	
	If nX > 1
		oSection1:Cell('QM2_INSTR'):Hide()
		oSection1:Cell('QM2_REVINS'):Hide()
	EndIf
	oSection1:PrintLine()
	If nX > 1
		oSection1:Cell('QM2_INSTR'):Show()
		oSection1:Cell('QM2_REVINS'):Show()
	EndIf
//	oSection1:Print()
Next

Return

/*                                     
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmt010IRep³ Autor ³ Denis Martins         ³ Data ³ 24.09.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao dos Textos	Reprogramacao		 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010Just(ExpC1,ExpN1,ExpN2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Instrumento							  ³±±
±±³			 ³ ExpC2 = Revisao do Instrumento							  ³±±
±±³			 ³ ExpC3 = Array com Textos									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM010IRepR3(cCod,cRevRe,aImps)

Local wnrel			:= "QMTRREP"
Local cString		:= "QMD"
Local cPerg			:= ""
Local cDesc1		:= OemToAnsi(STR0044) //"Este programa ira emitir a rela‡ao de"
Local cDesc2		:= OemToAnsi(STR0045) //"Texto de Reprogramacao"

Private titulo		:= OemToAnsi(STR0045) //"Texto de Reprogramacao"
Private cabec1		:= ""
Private cabec2		:= ""
Private aReturn		:= { OemToAnsi(STR0046), 1,OemToAnsi(STR0047), 1, 2, 1, "",1 } // "Zebrado"###"Administra‡„o"
Private nomeprog	:= "QMTRREL"
Private nLastKey	:= 0
Private cTamanho	:= "P"
Private lEnd		:= .F.
	
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,,.F.,"",,cTamanho,,.F.)

If nLastKey = 27
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
   Return
Endif

RptStatus({|lEnd| MTR010IRep(@lEnd,wnRel,cString,cCod,cRevRe,aImps)},Titulo)

Return   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTR010IRep³ Autor ³ Denis Martins         ³ Data ³ 24.09.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Certificado de Calibra‡„o                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  MTR030IMP(void)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd     -> Parametro do relatorio	                      ³±±
±±³          ³ wnRel    -> Nome default do arquivo em disco               ³±±
±±³          ³ cCod     -> Codigo do Instrumento                          ³±±
±±³          ³ cRevRe   -> Codigo da Revidao do Instrumento               ³±±
±±³          ³ aImps    -> Array com informacoes dos textos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MTR010IRep(lEnd,wnRel,cString,cCod,cRevRe,aImps)
Local li := 80
Local nx := 1
Local Cabec1 := OemToAnsi(STR0048) //" Instrumento        Rev.      Data(s)-Texto(s)"  
Local Cabec2 := ""
m_pag  := 1
cbCont := 0
cbTXT  := ""     

For nx := 1 To Len(aImps)
	li++
	If li > 54
		Cabec( Titulo, Cabec1, Cabec2, NomeProg, cTamanho, IIF(aReturn[4]==1,15,18))
		li:=8
		@li,01 PSAY cCod
		@li,18 PSAY QM2->QM2_REVINS
	Endif
	//          1         2         3         4         5         6         7         8
	//012345678901234567890123456789012345678901234567890123456789012345678901234567890
	// Instrumento      Rev.      Data(s)-Texto(s)  
	// XXXXXXXXXXXXXXXX XX        XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	@li,28 PSAY Alltrim(aImps[nx])
Next nx

Roda( cbCont, cbTxt, cTamanho )

Set Device To Screen
Set Filter To

If aReturn[5] = 1
	Set Printer TO
	dbCommitall()
	ourspool(wnrel)
End
MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmta010TrButºAutor  ³Denis Martins       º Data ³  06/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controla a troca de botoes(1 - Cadastro, 2 - Escalas, 3 - Ptosº±±
±±º          ³Calibradores).                                              	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA010                                                   	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmta010TrBut(oDlgC,oEnchoice1,oBtn1)
Local aArea:= GetArea()
Local lVisual := If(Inclui .or. Altera,.F.,.T.)
Local aColsFxa := {}

If !Empty(M->QM2_SGUARD)
	If At("L",AllTrim(M->QM2_SGUARD)) > 0
		cBmp5 := "LBTIK" 
	Else
		cBmp5 := "LBNO" 
	Endif
	If At("C",AllTrim(M->QM2_SGUARD)) > 0
		cBmp6 := "LBTIK"
	Else
		cBmp6 := "LBNO"
	Endif
	If At("T",AllTrim(M->QM2_SGUARD)) > 0
		cBmp7 := "LBTIK"
	Else
		cBmp7 := "LBNO"		 		
	Endif
Else
	cBmp5 := "LBNO" 
	cBmp6 := "LBNO"
	cBmp6 := "LBNO" 
Endif

If nVals == 1 //Tratamento para apresentar as escalas								       		
	If !Empty(M->QM2_INSTR)
		If oBtIncEs <> Nil
			oBtIncEs:Hide()
		Endif	

		If oGetFi <> Nil
			oGetFi:Hide()
			oSayEsc:cTitle := ""
			oSayEsc:cCaption := ""
			oSayEsc:Show()
		Endif
		
		If oGetPto <> Nil
			oGetPto:Hide()
		Endif

		If oBtIncEs <> Nil
			oBtIncEs:Hide()
		Endif	

		If oGrpCatr <> Nil
			oGrpCatr:Hide()
		Endif

		If oSayTT <> Nil
			oSayTT:Hide()		
		Endif

		oGrp:Hide()
		oGrpSit:Hide()	
		oPanel2:Hide()		
		oGrpSav:Hide()		
		oChkCal:Hide()
		oSayCali:Hide()
		oChkApro:Hide()		
		oSayApro:Hide()
		oChkApCo:Hide()				
		oSayAC:Hide()		
		oChkRepro:Hide()
		oSayRe:Hide()		
		oChkRepro:Hide()
		oSayLc:Hide()
		oChkLac:Hide()
		oChkConst:Hide()
		oSayCon:Hide()						
		oChkTrei:Hide()				
		oSayCon:Hide()										
		oSayCon:Hide()												
		oSayTro:Hide()														
		oSayEsc:Hide()		       
		oSayFam:Hide()		       		
		oEnchoice1:Show()
		oBtn1:Enable()
		If Alltrim(QM9->QM9_TIPAFE) $ "4|8"      //Tratamento para Calibradores/Calibradores Completos
			oBtn2:Enable()
		Else				  
			oBtn2:Enable()
		Endif
		oBtn3:Disable()
	Endif
	nVals := 1
ElseIf nVals == 2 //Tratamento para apresentar o cadastros
	oEnchoice1:Hide()
	oGrp:Show()
	oGrpSit:Show()
	oGrpSav:Show()	
	oPanel2:Show()	
	oChkCal:Show()
	oSayCali:SetText(STR0058)
	oSayCali:cTitle(STR0058)
	oSayCali:Show()
	oSayCali:Refresh()
	oChkApro:Show()		
	oSayApro:Show()
	oChkApCo:Show()				
	oSayAC:Show()		
	oChkRepro:Show()
	oSayRe:Show()		
	oChkRepro:Show()
	oChkLac:Show()
	oSayLc:Show()
	oChkConst:Show()
	oSayCon:Show()						
	oChkTrei:Show()				
	oSayCon:Show()										
	oSayCon:Show()												
	oSayTro:Show()														
	oSayEsc:Show()		       
	oSayFam:Show()		       				

	If oGetFi <> Nil
		oGetFi:oBrowse:lDisablePaint := .t.
		oGetFi:Hide()			
	Endif
	If oGetPto <> Nil
		oGetPto:oBrowse:lDisablePaint := .t.
		oGetPto:Hide()			
	Endif

	If oSayTT <> Nil
		oSayTT:Hide()		
	Endif

//	oBtn1:cCaption := "Cadastro"
	oSayEsc:cTitle := OemToAnsi(STR0012)+" : "+AllTrim(M->QM2_INSTR)+" - "+AllTrim(M->QM2_REVINS)
	oSayEsc:Show()
	oChkCal:SetBmp(cBmp1)
	oChkCal:Show()
	oChkApro:SetBmp(cBmp2)
	oChkApro:Show()
	oChkApCo:SetBmp(cBmp3)
	oChkApCo:Show()
	oChkRepro:SetBmp(cBmp4)			
	oChkRepro:Show()
	oChkLac:SetBmp(cBmp5)
	oChkLac:Show()
	oChkConst:SetBmp(cBmp6)
	oChkConst:Show()	
	oChkTrei:SetBmp(cBmp7)
	oChkTrei:Show() 
	If oBtIncEs <> Nil 
		If !lFzCal
			oBtIncEs:Show()
		Else
			oBtIncEs:Hide()			
		Endif
	Else
		@ oSize2:GetDimension("GROUP","LININI")+12,oSize2:GetDimension("GROUP","COLINI")+4 BUTTON oBtIncEs PROMPT STR0077 SIZE 45, 11 OF oGrpCatr PIXEL ACTION QMT010Paes(aHeaderQMR,aColsQMR) //"Padroes"
	Endif	
	nVals := 2
	If Len(aColsQMR) <= 0
		If oGetPto <> Nil
			oGetPto:oBrowse:lDisablePaint := .t.
			oGetPto:Hide()			
		Endif
		aHeader := aClone(aHeaderQMR)
		aCols := aClone(aColsQMR)
		A010CaTR(M->QM2_TIPO,M->QM2_INSTR,M->QM2_REVINS,,oDlgC)

		If lPrimeira
			lPrimeira := .F.
			aClsQMR2 := aClone(aCols)
		Endif	
		If oGetFi <> Nil
			//Verificar se existe faixas para poder exibir...
			If Len(aCols) > 0
				oGetFi:Show()
			Else
				If oBtIncEs <> Nil
					oBtIncEs:Hide()
				Endif	
			Endif	
		Endif	
	Else
		aHeader := aClone(aHeaderQMR)
		aCols := aClone(aColsQMR)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada para Tratamento do aCols de Faixas a serem exibidas.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("QMT010FXA")
			aColsFxa := aClone(aCols) 
			aCols := ExecBlock("QMT010FXA",.F., .F.,{aColsFxa})
		EndIf
		oGetFi:oBrowse:lDisablePaint := .f.
		oSayEsc:cTitle := OemToAnsi(STR0012)+" : "+AllTrim(M->QM2_INSTR)+" - "+AllTrim(M->QM2_REVINS)
		oSayEsc:Show()
		oChkCal:Show()
		oGetFi:Show()
		oGetFi:ForceRefresh()		
	Endif
	If oGrpCatr <> Nil
		oGrpCatr:Show()
	Endif
	oBtn1:Disable()
	If Alltrim(QM9->QM9_TIPAFE) $ "4|8"      //Tratamento para Calibradores/Calibradores Completos
		oBtn2:Enable()
	Else				  
		oBtn2:Enable()
	Endif
	oBtn3:Enable()

ElseIf nVals == 3 //Tratamento para Calibradores/Calibradores Completos
	If oGetFi <> Nil
		If oGrpCatr <> Nil
			oGrpCatr:Hide()
		Endif
		oGrp:Show()
		oGrpSit:Show()
		oGrpSav:Show()
		oPanel2:Show()						
		oChkCal:Show()
		oSayCali:Show()
		oChkApro:Show()		
		oSayApro:Show()
		oChkApCo:Show()				
		oSayAC:Show()		
		oChkRepro:Show()
		oSayRe:Show()		
		oChkRepro:Show()
		oChkLac:Show()
		oSayLc:Show()
		oChkConst:Show()
		oSayCon:Show()						
		oChkTrei:Show()				
		oSayCon:Show()										
		oSayCon:Show()												
		oSayTro:Show()														
		oSayEsc:Show()		       
		oSayFam:Show()		       		
		oGetFi:oBrowse:lDisablePaint := .t.
		oGetFi:Hide()
		oSayEsc:cTitle := ""
		oSayEsc:cCaption := ""
		oSayEsc:Show()
	Endif	
	If oEnchoice1 <> Nil
		oEnchoice1:Hide()
		oGrp:Show()
		oGrpSit:Show()
		oGrpSav:Show()  
		oPanel2:Show()		
		oSayAC:Show()
		oSayRe:Show()
		oSayApro:Show()
		oSayCali:Show()
		oSayLc:Show()
		oChkConst:Show()		
	Endif	

	If oGetPto <> Nil
		oGetPto:oBrowse:lDisablePaint := .t.
		oGetPto:Hide()
  		oSayEsc:cTitle := ""
		oSayEsc:cCaption := ""
		oSayEsc:Show()
	Endif	

	If oBtIncEs <> Nil
		oBtIncEs:Hide()
	Endif	
	oSayEsc:cCaption := OemToAnsi(STR0012)+" : "+AllTrim(M->QM2_INSTR)+" - "+AllTrim(M->QM2_REVINS)
	oSayEsc:Show()
	oChkCal:Show()
	oChkApro:SetBmp(cBmp2)
	oChkApro:Show()
	oChkApCo:SetBmp(cBmp3)
	oChkApCo:Show()
	oChkRepro:SetBmp(cBmp4)			
	oChkRepro:Show()
	oChkLac:SetBmp(cBmp5)			
	oChkLac:Show()			
	oChkConst:SetBmp(cBmp6)			
	oChkConst:Show()			
	oChkTrei:SetBmp(cBmp7)			
	oChkTrei:Show()
	If lFzCal
		oBtn2:Enable()
		If Len(aColsQMG) <= 0
			aHeader := {}
			aCols := {}
			A010CaPo(M->QM2_TIPO,M->QM2_INSTR,M->QM2_REVINS,oDlgC,.T.)			
		Else
			aCols := aClone(aColsQMG)
			aHeader := aClone(aHeaderQMG)
			If M->QM2_REVINS <> cRevAnt
				oGetPto:oBrowse:lDisablePaint := .t.
				oGetPto:Hide()
				If QMA010Cal(M->QM2_INSTR,M->QM2_REVINS) //Bloqueia a alteracao dos pontos
					lPodeAlt := .F.
				EndIf
		   
				oGetPto := MSGetDados():New(oSize2:GetDimension("GROUP","LININI"),oSize2:GetDimension("GROUP","COLINI"),;
                                 		    oSize2:GetDimension("GROUP","LINEND"),oSize2:GetDimension("GROUP","COLEND"),;
                                 		 	 4,"qmt010LnOk","Qmt010TdOk",,lPodeAlt,,,,,,,,,oDlgC) //Pontos Calibradores
				oGetPto:oBrowse:bLostFocus := {||aHeaderQMG := aClone(aHeader),aColsQMG := aClone(aCols)}
				oGetPto:lActive := lPodeAlt
				oGetPto:Show()		
			Else
				oGetPto:oBrowse:lDisablePaint := .f.
				oGetPto:Show()
			Endif	          
			oGetPto:ForceRefresh()
			oSayEsc:cCaption := OemToAnsi(STR0012)+" : "+AllTrim(M->QM2_INSTR)+" - "+AllTrim(M->QM2_REVINS)
			oSayEsc:Show()
			oChkCal:Show()
			oChkApro:SetBmp(cBmp2)
			oChkApro:Show()
			oChkApCo:SetBmp(cBmp3)
			oChkApCo:Show()
			oChkRepro:SetBmp(cBmp4)			
			oChkRepro:Show()    
			oChkLac:SetBmp(cBmp5)
			oChkLac:Show()
			oChkConst:SetBmp(cBmp6)
			oChkConst:Show()	
			oChkTrei:SetBmp(cBmp7)
			oChkTrei:Show()	
		Endif	
	Else
		@ oSize2:GetDimension("GROUP","LINEND")/2,(oSize2:GetDimension("GROUP","COLEND")/2)-135 SAY oSayTT PROMPT STR0066 SIZE 350,7 COLOR CLR_HRED FONT oArialGr OF oDlgC PIXEL //"Familia sem Escala(s) do Tipo Calibrador/Calibrador Completo"
		oBtn2:Disable()	
	Endif
	oBtn1:Enable()
	oBtn2:Disable()				
	oBtn3:Enable()
Endif      

dbSelectArea("QM6")
dbSetOrder(1)
If dbSeek(xFilial()+M->QM2_INSTR+M->QM2_REVINS) 
	cBmp1 := "LBTIK" 
	oChkCal:SetBmp(cBmp1)
	oChkCal:Show()	
	If Alltrim(QM6->QM6_LAUDO) == "A"
		cBmp2 := "LBTIK"
		oChkApro:SetBmp(cBmp2)
		oChkApro:Show()
	ElseIf Alltrim(QM6->QM6_LAUDO) == "C"
		cBmp3 := "LBTIK"	
		oChkApCo:SetBmp(cBmp3)
		oChkApCo:Show()
	ElseIf Alltrim(QM6->QM6_LAUDO) == "R"
		cBmp4 := "LBTIK"
		oChkRepro:SetBmp(cBmp4)
		oChkRepro:Show()
	Endif	
Endif

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a010VldFM	ºAutor  ³Denis Martins       º Data ³  06/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida troca de Familia no cadastro de instrumentos.        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a010VldFM()
Local lRet := .t.
Local aArea:= GetArea()

dbSelectArea("QM1")

//Garante integridade da familia
If !ExistCpo2("QM1",M->QM2_TIPO,,STR0067) //"Familia nao cadastra. Favor cadastrar para que possa ser utilizada"
	lRet := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cadastra a Escala da Malha caso seja instrumento que   ³
//³ pertence a uma Malha ( Status = M)                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	lRet := a010VlEscM(M->QM2_INSTR,M->QM2_LOCAL,M->QM2_ESCMAL,M->QM2_STATUS)
EndIf

If lRet	
	If Alltrim(cFamilia) <> Alltrim(M->QM2_TIPO)
		aCols		:= {}
		aHeader		:={}
		aColsQMG	:= {}
		aHeaderQMG	:={}
		aColsQMR	:= {}
		aHeaderQMR	:={}
		oBtn2:Disable()
		lFzCal		:= .f.
		lNoMoAc		:= .t.
		lTud		:= .f.
	Endif

	cFamilia := M->QM2_TIPO
	oBtn1:Enable()
Endif

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt010SavAcoºAutor  ³Denis Martins       º Data ³  06/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Salva integridade das aCols - Escalas / Ptos Calibradores  	º±±
±±º          ³                                                            	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA010                                                   	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010SavAco()
	If nVals == 2
		aHeaderQMR	:= aClone(aHeader)	
		aColsQMR	:= aClone(aCols)  
	ElseIf nVals == 3
		aHeaderQMG	:= aClone(aHeader)	
		aColsQMG	:= aClone(aCols)
	Endif
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt010AcAcolºAutor  ³Denis Martins       º Data ³  06/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existem escalas do tipo calibrador / calibrador 	º±±
±±º          ³completo e verifica se os mesmos foram digitados            	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA010                                                    	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010AcAcol(oDlgC)
Local nOpcs := 1
Local lNaoPto := .t.
Local nx := 1
//Garante a integridade nos arquivos QMR / QMK
If Len(aColsQMR) <= 0 
	aHeaderQMR	:= {}
	aColsQMR	:= {}
	A010CaTR(M->QM2_TIPO,M->QM2_INSTR,M->QM2_REVINS,,oDlgC,.F.)
	aHeaderQMR	:= aClone(aHeader)
	aColsQMR := aClone(aCols)

	//Garantir nao gravar instrumentos sem faixas definidas...
	If Len(aColsQMR) == 0
		nOpcs := 2
		aColsQMR := {}
		aCols	 := {}
	Endif

	If lFzCal
		MessageDlg(STR0068,,3) //"Existe escala calibrador/calibrador completo. Digite os pontos"
		oBtn1:Enable()
		oBtn1:Show()
		oBtn2:Enable()
		oBtn2:Show()
		oEnchoice1:Show()    
		nOpcs := 2
	Endif
Else   
	//No caso de delecao de escalas no QMR
	For nx := 1 To Len(aColsQMR)
		If !Empty(aColsQMR[nx][1])
		dbSelectArea("QM9")
		dbSetOrder(1)
		If dbSeek(xFilial()+aColsQMR[nx][1])  
			If Alltrim(QM9->QM9_TIPAFE) $ "4|8"
				If aColsQMR[nx][Len(aColsQMR[nx])]
					lFzCal := .F.
					lNaoPto := .f.
				Else
					lFzCal := .T.
				Endif
			Else
				oBtn2:Disable()  
				lFzCal := .F.
				lNaoPto := .f.
			Endif
		Endif
		Endif
	Next nx	
	If lFzCal
		lNaoPto := .t.
		For nx := 1 To Len(aColsQMG)
			If !Empty(aColsQMG[nx][1])
				lNaoPto := .F.			
			Endif			
		Next nx
		If lNaoPto 
			MessageDlg(STR0068,,3) //"Existe escala calibrador/calibrador completo. Digite os pontos"
			oBtn2:Enable()
			nOpcs := 2			
		Else
			nOpcs := 1			
		Endif
	Else
		nOpcs := 1	
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valido o acols  se existe Faixa cadastrada e se existe alguma  faixa deletada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nx := 0
	AEval( aColsQMR, { |X| If(X[Len(aColsQMR[1])], nx++ , 0) })  // Conta o numero de linhas deletadas
	If len(aColsQMR)==nx   
		MessageDlg(STR0093,,3) // "Um Instrumento deve ter no minimo uma Faixa"
		nOpcs := 2
	Else
		If nx >= 1 .and. lAltRevisao
			MessageDlg(STR0094,,3)	// "Para deletar uma Faixa e necessario gerar uma Revisao"
			nOpcs := 2
		EndIf
	Endif 
	
Endif	
Return nOpcs


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt010VerPtosºAutor  ³Denis Martins       º Data ³  06/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe pontos para as escalas do instrumento    	 º±±
±±º          ³                                                            	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA010                                                    	 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010VerPtos(cInstr,cRevIns,cTipo)
Local aArea := GetArea()
DbSelectArea("QM9")
QM9->(dbSetOrder(1))
DbSelectArea("QMR")
QMR->(dbSetOrder(1))
If QMR->(dbSeek(xFilial("QMR")+cInstr+cRevIns))
	If QM2->QM2_TIPO == cTipo
		While !Eof() .And. xFilial("QMR")+cInstr+cRevIns == QMR->QMR_FILIAL+QMR->QMR_INSTR+QMR->QMR_REVINS
			QM9->(dbSetOrder(1))
			If QM9->( dbSeek( xFilial( "QM9" ) + QMR->QMR_ESCALA ) ) 
				If Alltrim(QM9->QM9_TIPAFE) $ "4|8"
					lFzCal := .T.
					Exit
				Endif	
			EndIf			
			QMR->(DbSkip())
		EndDo		
	Else
		dbSelectArea("QMK")
		QMK->(dbSetOrder(1))
		If QMK->(dbSeek(xFilial("QMK")+cTipo))
			cRev := QMK->QMK_REVTIP
			While !EOF() .And. xFilial("QMK")+cTipo+cRev == QMK->QMK_FILIAL+QMK->QMK_TIPO+QMK->QMK_REVTIP
				QM9->(dbSetOrder(1))
				If QM9->( dbSeek( xFilial( "QM9" ) + QMK->QMK_ESCALA ))
					If Alltrim(QM9->QM9_TIPAFE) $ "4|8"
						lFzCal := .T.
						Exit
  					Endif 
				Endif
				QMK->(DbSkip())
			EndDo
		Endif	
	Endif
Else
	dbSelectArea("QMK")
	QMK->(dbSetOrder(1))
	If QMK->(dbSeek(xFilial("QMK")+cTipo))
		cRev := QMK->QMK_REVTIP
		While !EOF() .And. xFilial("QMK")+cTipo+cRev == QMK->QMK_FILIAL+QMK->QMK_TIPO+QMK->QMK_REVTIP
			QM9->(dbSetOrder(1))
			If QM9->( dbSeek( xFilial( "QM9" ) + QMK->QMK_ESCALA ))
				If Alltrim(QM9->QM9_TIPAFE) $ "4|8"
					lFzCal := .T.
					Exit
				Endif 
			Endif	
			QMK->(DbSkip())
		EndDo
	Endif	
EndIf                 
RestArea(aArea)	
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt010VerRevºAutor  ³Denis Martins       º Data ³  06/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se criara nova revisao de instrumento              	º±±
±±º          ³                                                            	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA010                                                   	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt010VerRev(oDlgC,nOpp)
Local bCampo:= {|nCPO| Field(nCPO) }
Local I		:= 0
Local ni	:= 0
Local lFech := .F.
Default nOpp:= 1
//Verifica se o instrumento ja sofreu calibracao, em caso afirmativo realiza check

If QMA010Cal(M->QM2_INSTR,M->QM2_REVINS)
	dbSelectArea("QM2")
	
	For I := 1 To FCount()
		If !( EVAL(bCampo,i) $ cCampoNGR )
			If Valtype(M->(Eval( bCampo, I ))) == "D"
				If DtoS(M->&( Eval( bCampo, I ))) <> DtoS(QM2->&( Eval( bCampo, I )))
					If MsgYesNo(STR0069,STR0070) //"Esta alteracao criara uma nova revisao. Confirma ?" ## "Atencao"
						lTud := .t.
						Exit
					Else
						lFech := .T.
						Exit
					Endif
				Endif
			Else
				If M->&(Eval( bCampo, I )) <> QM2->&(Eval( bCampo, I ))
					If MsgYesNo(STR0069,STR0070) //"Esta alteracao criara uma nova revisao. Confirma ?" ## "Atencao"
						lTud := .t.
						Exit
					Else
						lFech := .T.
						Exit
					Endif
				Endif
			Endif
		Endif
	Next I

	If !lTud
		//Deve ser aColsQMR / aColsGer pois na mudanca de status nao criar revisao...
		If Len(aColsGer) > 0
			If Len(aColsQMR) > 0
				For ni := 1 To Len(aColsQMR)
					nLcGer := aScan(aColsGer,{|x| Alltrim(x[1]) = Alltrim(aColsQMR[ni][1])})
					If nLcGer <= 0
						If !aColsQMR[ni][Len(aColsQMR[ni])] //8
							lTud := .T.
							Exit
						Endif	
					Endif	
				Next ni	
			Endif	
		Endif			
	Endif
	If !lFech	
		//Vai gerar revisao
		If lTud
		    cRevAnt         := QM2->QM2_REVINS
			M->QM2_REVINS	:= Soma1(M->QM2_REVINS)
			M->QM2_DATREV	:= dDataBase
		
			lPodeAlt := .t. 
			If QMA010Cal(M->QM2_INSTR,M->QM2_REVINS) //Bloqueia a alteracao dos pontos
				lPodeAlt := .F.
			EndIf
			If oGetPto <> Nil
				oGetPto:Refresh()
				oGetPto:Show()
			Endif
		Endif
		oEnchoice1:Refresh()    
	Else
		nOpp := 2
	Endif
Endif

Return lTud

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QmtEMailInstºAutor  ³Denis Martins       º Data ³  06/0903    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Enviar e-mail ao responsavel alertando sobre a data de cali-  º±±
±±º          ³bracao do mesmo.                                            	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SX2 - Rotina                                              	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QmtEMailInst()
Local aMsg      := {}
Local aUsua     := {}
Local cAliasTRB := GetNextAlias()
Local cHtml     := " "
Local cInstrum  := ""
Local cMail     := ""
Local cNomeArq  := SubStr(DtoS(dDataBase),5,7)+".Q10"
Local cRespos   := " "
Local cSubject  := STR0071 //"Importante - Aviso de Calibracao de Instrumentos"
Local cWhere    := ""
Local lEncont   := .F.
Local lFirst    := .T.
Local lQMTFIL   := ExistBlock("QMTFILST")
Local nDias     := GETMV("MV_QQTDIAS")
Local ni        := 0
Local oExec     := Nil

Private cBufTxt     := ""
Private lAchou      := .F.
Private nBytesTxt   := 0
Private nCurrent    := 0
Private nFilePosTxt := 0
Private nHdl        := 0
Private nTamTxt     := 0
Private TRB_DESC 	:= ""
Private TRB_INSTR	:= ""
Private TRB_RESP	:= ""
Private TRB_VALDAF	:= ""

DEFAULT lFwExecSta := FindClass( Upper("FwExecStatement") ) //Para facilitar a cobertuar de código, declarar essa variável como .F.

	cTpMail :=  Iif(Type('cTpMail')=='C',cTpMail,"")

	//Deleta arquivos anteriores - Vinte Arquivos anteriores
	For ni := 1 to 20
		If File(SubStr(DtoS(dDataBase-ni),5,7)+".Q10")
			FErase(SubStr(DtoS(dDataBase-ni),5,7)+".Q10")
		Endif  
	Next

	//Cria arquivo com data
	If File(cNomeArq)
		nHdl := FOpen( cNomeArq, FO_READWRITE+FO_SHARED ) 
	Else	
		nHdl := FCreate( cNomeArq, FC_NORMAL ) 
	Endif		


	DbSelectArea("QM2")
	QM2->(DbSetOrder(1))
	//Lay-out do Cliente
	//MV_QQTDIAS - Quantidade de dias a serem considerados no aviso do e-mail
	//Ponto de Entrada para tratamento de lay-out de cliente...
	If ExistBlock("QMT010Mai")
		ExecBlock("QMT010Mai",.F.,.F.,{QM2->QM2_INSTR,QM2->QM2_REVINS})
	Else
		cQuery := " SELECT "
		cQuery += 		" QM2.QM2_FILIAL, "
		cQuery += 		" QM2.QM2_INSTR, "
		cQuery += 		" QM2.QM2_REVINV, "
		cQuery += 		" QM2.QM2_VALDAF, "
		cQuery += 		" QM2.QM2_RESP, "
		cQuery += 		" QM2.QM2_FLAG, "
		cQuery += 		" QM2.QM2_DESCR "
		cQuery += " FROM " + RetSqlName("QM2") +" QM2 "
		cQuery += " WHERE QM2.QM2_FILIAL = '" + xFilial("QM2") + "' AND "
		cQuery += 		" (QM2.QM2_VALDAF >= '" + DtoS(dDataBase-nDias) + "' AND " 
		cQuery += 		" QM2.QM2_VALDAF <= '" + DtoS(dDataBase+nDias) + "') AND " 
		cQuery += 		" QM2.QM2_FLAG = '1' AND " 
		cQuery += 		" QM2.QM2_STATUS = 'A' AND "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada criado para mudar o Filtro ou realizar alguma tarefa especifica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lQMTFIL
			cWhere := ExecBlock("QMTFILST",.F.,.F.)
			If ValType(cWhere) == "C" .And. Len(cWhere) > 1
				cQuery += cWhere + ' AND '
			EndIf
		EndIf 
		cQuery += " QM2.D_E_L_E_T_<>'*' "
		cQuery += " GROUP BY "
		cQuery += 			" QM2.QM2_FILIAL, "
		cQuery += 		   	" QM2.QM2_RESP, "
		cQuery += 			" QM2.QM2_INSTR, "
		cQuery += 			" QM2.QM2_REVINV, "
		cQuery += 			" QM2.QM2_VALDAF, "
		cQuery += 			" QM2.QM2_FLAG, "
		cQuery +=			" QM2.QM2_DESCR "			

		If !lFwExecSta
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAliasTRB, .F., .T.)
		else
			oExec := FwExecStatement():New(cQuery)
			cAliasTRB := oExec:OpenAlias()
			oExec:Destroy()
			oExec := nil 
		EndIf

		TcSetField((cAliasTRB),"QM2_VALDAF","D",8,0)

		dbSelectArea(cAliasTRB)
		(cAliasTRB)->(dbGoTop())
		While (cAliasTRB)->(!Eof())

			TRB_INSTR	:= (cAliasTRB)->QM2_INSTR			
			TRB_VALDAF	:= (cAliasTRB)->QM2_VALDAF
			TRB_RESP	:= (cAliasTRB)->QM2_RESP
			TRB_DESC	:= (cAliasTRB)->QM2_DESCR                                                                                                      ``````````````

			If nHdl > 0
				nTamTxt := FSEEK( nHdl, 0, FS_END ) //Verifica o tamanho do arquivo
				FSEEK( nHdl, 0 ) //Seta o FSeek para inicio do arquivo 
			
				nCurrent := 29 //Tamanho da Linha Instrumento + Responsavel 
					
				While( nCurrent <= nTamTxt )
					nFilePosTxt := FSEEK( nHdl, 0, FS_RELATIVE )
					cBufTxt     := FREADSTR( nHdl, nCurrent )
					nBytesTxt   := AT( TRB_INSTR+" "+TRB_RESP, cBufTxt )				
					
					If nBytesTxt > 0
						lAchou	:= .T.
						Exit
					Else
						lAchou	:= .F.	
					Endif  	
					nCurrent += 29
					Loop
				Enddo
			Endif

			If !lAchou
				lEncont := .T.
				FWrite( nHdl, TRB_INSTR+" "+TRB_RESP) 
				FWrite( nHdl, Chr(13)+Chr(10))				

				cInstrum := TRB_INSTR		
				If Alltrim(TRB_RESP) <> Alltrim(cRespos)
					//Caso seja ultimo instrumento de responsaveis diferentes
					If !lFirst 
						If Alltrim(cTpMail) == "1" //Se For HTML
							cHtml +='</body>'
							cHtml +='</html>'
						Endif	
						aMsg:= { { cSubject,cHtml, "" } }     		                                              
						aadd(aUsua,{ IIf(!Empty(cRespos),QAA->QAA_NOME,Alltrim(QAA->QAA_APELID)),Trim(cMail),aMsg })
						QaEnvMail(aUsua,,,,)
						aUsua := {}
					Endif
					
					dbSelectArea("QAA")
					QAA->(dbSetOrder(1))
					QAA->(dbSeek(xFilial("QAA")+TRB_RESP))
					cMail	:= QAA->QAA_EMAIL
					cTpMail := QAA->QAA_TPMAIL
					
					lFirst := .T.
					cRespos := TRB_RESP
					If Alltrim(cTpMail) == "1" //Se For HTML
						cHtml :='<html>'
						cHtml +='<head>' 
						cHtml +='<body>'
						cHtml +='<p></p>'					
						cHtml +='<table borderColor="#0099cc" height="29" cellSpacing="1" width="679" borderColorLight="#0099cc" border="1">'
						cHtml +='  <tr>'
						cHtml +='    <td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="640" bgColor="#0099cc" borderColorDark="#0099cc" height="1">'
						cHtml +='    <p align="center"><font face="Courier New" color="#ffffff" size="4"><b>'+STR0072+'</b></font></td>' //"* * * Relacao de Instrumentos a ser(em) calibrado(s) * * *"
						cHtml +='  </tr>'
						cHtml +='</table>'
						cHtml +='<p align="center">&nbsp;</p>'
						
						If lFirst
							cHtml +='<p align="justify"><font face="Arial">'+STR0073+QAA->QAA_NOME+","+'</font></p>' //"Sr. "
							cHtml +='<p align="justify"><font face="Arial">'+STR0074+'</font></p>' //"Segue relacao de instrumento(s) a ser(em) calibrado(s)."
							cHtml +='<p align="justify">&nbsp;</p>'
							cHtml +='<table borderColor="#0099cc" height="29" cellSpacing="1" width="679" borderColorLight="#0099cc" border="1">'
							cHtml +='  <tr>'
							cHtml +='    <td width="166">'
							cHtml +='	    <p align="center"><b><i>'+STR0085+'</i></b></td>' //Instrumentos
							cHtml +='    <td width="334">'
							cHtml +='	    <p align="center"><b><i>'+STR0092+'</i></b></td>' //Descricao         
							cHtml +='    <td width="166">'
							cHtml +='	    <p align="center"><b><i>'+STR0075+'</i></b></td>' //Data de Calibracao
							cHtml +='  </tr>'
							cHtml +='</table>'
							cHtml +='	<p align="center">&nbsp;</p>'
							cHtml +='	<table borderColor="#0099cc" height="29" cellSpacing="1" width="679" borderColorLight="#0099cc" border="1">'
							cHtml +='	  <tr>'
							cHtml +='    	<td width="166" align="center">'+TRB_INSTR+'</td>' 
							cHtml +='    	<td width="334" align="center">'+TRB_DESC+'</td>' 
							cHtml +='	    <td width="166" align="center">'+SubStr(DtoS(TRB_VALDAF),7,2) + "/" +SubStr(DtoS(TRB_VALDAF),5,2) + "/" + SubStr(DtoS(TRB_VALDAF),1,4)+'</td>'
							cHtml +='	  </tr>'
							cHtml +='	</table>'
							lFirst := .F.
						Else
							cHtml +='<table borderColor="#0099cc" height="29" cellSpacing="1" width="679" borderColorLight="#0099cc" border="1">'
							cHtml +='	  <tr>'
							cHtml +='    	<td width="166" align="center">'+TRB_INSTR+'</td>'
							cHtml +='    	<td width="334" align="center">'+TRB_DESC+'</td>'  
							cHtml +='	    <td width="166" align="center">'+SubStr(DtoS(TRB_VALDAF),7,2) + "/" +SubStr(DtoS(TRB_VALDAF),5,2) + "/" + SubStr(DtoS(TRB_VALDAF),1,4)+'</td>'
							cHtml +='	  </tr>'
							cHtml +='	</table>'
						Endif           
					Else
						If lFirst
							cHtml :=STR0072+Chr(13)+Chr(10)+Chr(13)+Chr(10)  //* * * Relacao de Instrumentos a ser(em) calibrado(s) * * *
							cHtml +=STR0073+QAA->QAA_NOME+","+Chr(13)+Chr(10) //Sr. 
							cHtml +=STR0074+Chr(13)+Chr(10)  //"Segue relacao de instrumento(s) a ser(em) calibrado(s)."
							cHtml +=Chr(13)+Chr(10)
							cHtml +=Chr(13)+Chr(10)
							cHtml +=STR0085+"..............."+STR0092+"....."+STR0075+Chr(13)+Chr(10) //Instrumentos - Descricao - Data de Calibracao
							cHtml +=TRB_INSTR+".........."+TRB_DESC+"....."+SubStr(DtoS(TRB_VALDAF),7,2) + "/" +SubStr(DtoS(TRB_VALDAF),5,2) + "/" + SubStr(DtoS(TRB_VALDAF),1,4)+Chr(13)+Chr(10)
							lFirst := .F.
						Endif
					Endif
				Else
					lFirst := .F.
					If Alltrim(cTpMail) == "1" 
						cHtml +='<table borderColor="#0099cc" height="29" cellSpacing="1" width="679" borderColorLight="#0099cc" border="1">'
						cHtml +='	  <tr>'
						cHtml +='    	<td width="166" align="center">'+TRB_INSTR+'</td>'     
						cHtml +='    	<td width="334" align="center">'+TRB_DESC+'</td>'  
						cHtml +='	    <td width="166" align="center">'+SubStr(DtoS(TRB_VALDAF),7,2) + "/" +SubStr(DtoS(TRB_VALDAF),5,2) + "/" + SubStr(DtoS(TRB_VALDAF),1,4)+'</td>' 
						cHtml +='	  </tr>'
						cHtml +='	</table>'    
					Else
						cHtml +=TRB_INSTR+".........."+TRB_DESC+"....."+SubStr(DtoS(TRB_VALDAF),7,2) + "/" +SubStr(DtoS(TRB_VALDAF),5,2) + "/" + SubStr(DtoS(TRB_VALDAF),1,4)+Chr(13)+Chr(10)
					Endif
				Endif
			Endif
			lAchou := .f.
			dbSelectArea(cAliasTRB)			
			(cAliasTRB)->(dbSkip())
		Enddo
		//Garante o ultimo registro...
		If (cAliasTRB)->(Eof()) .and. lEncont
			If Alltrim(cTpMail) == "1"
				cHtml +='</body>'
				cHtml +='</html>'
			Endif
			aMsg:= { { cSubject,cHtml, "" } }     		                                              
			aadd(aUsua,{ IIf(!Empty(cRespos),QAA->QAA_NOME,Alltrim(QAA->QAA_APELID)),Trim(cMail),aMsg })
			QaEnvMail(aUsua,,,,)
			aUsua := {}
		Endif
		(cAliasTRB)->(dbCloseArea())		
		dbSelectArea("QM2")				
		QM2->(dbSetOrder(1))
	Endif  

Return                


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT010ChkAcºAutor  ³Denis Martins       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Checa se existe mais de uma escala calibrador ; calibrador   º±±
±±º          ³completo no instrumento.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA010                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QMT010ChkAc(o,lEsc)
Local lRet		:= .t.
Local nCount	:= 0
Local cTipAf	:= ""           
Local lCalib	:= .f. 
Local lExtCal	:= .F.
Local lCalibA	:= .f. 

Local lCalibB	:= .F.
Local nI		:= 0
Default lEsc	:= .t.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se deixar a ultima linha em branco, deleta a mesma ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aCols[Len(aCols),1]) .And. n > 1
	Adel( aCols, Len(aCols) )
	ASize( aCols, Len( aCols) - 1)
	n := Len( aCols )
	If lEsc
		oGetFi:oBrowse:Refresh()
		oGetFi:Refresh()
	Else
		oGetPads:oBrowse:Refresh()	
		oGetPads:Refresh()		
	Endif	
EndIf

If lEsc
	//Verifica se existe escala calibrador/calibrador completo
	dbSelectArea("QM9")
	dbSetOrder(1)
	If n > 1
		If dbSeek(xFilial()+aCols[n][1]) //M->QMR_ESCALA
			cTipAf := QM9->QM9_TIPAFE
		Endif
	
/*		If Alltrim(cTipAf) $ "4|8" .and. aCols[n][5] == "S"
			nCount++
		Endif*/
	Endif	
/*
	For nx := 1 To Len(aCols)
		If !aCols[nx][Len(aCols[nx])]
			If QM9->(dbSeek(xFilial()+aCols[nx][1]))
				If Alltrim(QM9->QM9_TIPAFE) $ "4|8" .and. aCols[n][5] == "S"
					nCount++				
				Endif
			Endif
		Endif
	Next nx

	For nx := 1 To Len(aCols)
		If !Empty(aCols[nx][1])
		dbSelectArea("QM9")
		dbSetOrder(1)
		If dbSeek(xFilial()+aCols[nx][1])  
			If Alltrim(QM9->QM9_TIPAFE) $ "4|8"
				If aCols[nx][Len(aCols[nx])]
					oBtn2:Disable()  
				Else
					oBtn2:Enable()  
					Exit
				Endif
			Else
				oBtn2:Disable()  
			Endif
		Endif
		Endif
	Next nx	*/
	For nI := 1 to len(aCols)
		lCalib   := .f. 
		lExtCal := .F.
		If !aCols[nI][Len(aCols[nI])] //Se estiver diferente de deletado
			QM9->(DbSeek(xFilial("QM9")+acols[nI][1]))
			If QM9->QM9_TIPAFE $ '4ù8ù '
				If QM9->QM9_TIPAFE $ '4ù8' 
					If aCols[nI][5] == "S"
						nCount++
					Endif
					lCalibA := .t. //Setar .T., ja existia na ACOLS outros tipos de escala igual ao Calibrador
					lCalib  := .t.            
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o tipo de Calibracao for Vazio e o Tipo de Orgao aferidor igual a ³
				//³Externo, podera associar a familia que tenham calibrador / calibrador³
				//³completo.                                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(QM9->QM9_TIPAFE) .and. QM9->QM9_ORGAFE == "E" 
					lExtCal := .T.
				Endif	
			Else	
				lCalibB := .t. //Setar .T., ja existia na ACOLS outros tipos de escala dif. de Calibrador
			EndIf
			If lCalibA .and. !lCalib .and. !lExtCal .and. nI > 1 //Se alguma escala pertence a Calibrador
				Help(" ",1,"A030ESCCAL") // "Quando instrumento possui escala de tipo
									  // calibrador associada a ele, nÆo pode asso-
									  // ciar escalas de outros tipos a ele.
				lRet := .f.  
				Exit
			ElseIf lCalibA .and. lCalibB .and. lCalib .and. nI > 1
				Help(" ",1,"A030DIFCAL") //Quando instrumento possui escala de tipo
				                        //diferente de calibrador associada a ele, nao podera
				                        //associar escalas de tipo calibrador.
				lRet := .f.        
				Exit
			EndIf                   
		Endif
	Next nI
Endif

If lCaliba .or. lCalib 
	oBtn2:Enable()				
	lFzCal := .T.
Else
	If !Inclui .and. !Altera
		If nVals == 3
			If oGetFi <> Nil
				oGetFi:Hide()
			Endif	
		Endif	
		If lFzCal
			oBtIncEs:Hide()		
		Endif
	Endif	
	oBtn1:Disable()  		
	lFzCal := .F.   
	
Endif

If nCount > 1
	MessageDlg(OemToAnsi(STR0042),,3) //"Existe mais de uma escala calibrador/calibrador completo com calibracao obrigatoria ativada"
	lRet := .T.			
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Qmt010ChkEsºAutor  ³Denis Martins       º Data ³  01/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica as escalas para poder deixar digitar os valores de  º±±
±±º          ³tolerancia / redutor e incerteza permitida dependendo do ti- º±±
±±º          ³po de laudo de escala.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt010ChkEs()
Local lRet	:= .t.
Local aArea := GetArea()

lRet := qmt030VlEs(.T.)

If lRet
	If QM9->QM9_LAUDO == "1"  // Com confirmacao meterol¢gica
		aadd(aDigita,{M->QMR_ESCALA,.t.,.t.,.f.,.t.,.t.}) // True para os cpos tolerancia e redutor
	ElseIf QM9->QM9_LAUDO == "2"
		aadd(aDigita,{M->QMR_ESCALA,.f.,.f.,.t.,.t.,.t.}) // True para incerteza permitida
	Else
		aadd(aDigita,{M->QMR_ESCALA,.f.,.f.,.f.,.t.,.t.})
	EndIf
Endif

If QM9->QM9_TIPAFE $ "4|8"
	oBtn2:Enable()
	lFzCal := .T.
Endif

RestArea(aArea)

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT010PaesºAutor  ³Denis Martins       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Permitir incluir / alterar escalas atraves da tela de instruº±±
±±º          ³mentos.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT010Paes(aHeaderQMR,aColsQMR)

Local nCnt
Local nSavRec
Local nOpca:=0
Local nRecNc
Local lInclui := .f.
Local oDlgAs
Local cCampo := ""		// Auxiliar para macro
Local aArea		:= GetArea()
Local nPosQMC	:= 0
Local nx		:= 0
Local nPosAli
Local nPosRec
Local aStruQMC := FWFormStruct(3, "QMC")[3]

Private oGetPads 			// Getdados
Private aColsQs	 := aClone(aCols)
Private aHeadQs	 := aClone(aHeader)
Private aHeader[0],nUsado:=0
Private lExRev		:= .F.
Private oCbxTol
Private nTipTol := 1
Private cTipTol                                          
Private cTipGrav                                         
Private nTamQM3 := TamSx3("QM3_PADRAO")[1]

If Len(aCols) > 0
	If !Empty(aCols[n][1])
		dbSelectArea("QM9")
		dbSetOrder(1)	
		If !dbSeek(xFilial()+aCols[n][1]) 
			Return .F.
		Endif
	Else
		Return .F.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ So poderao cadastrar padroes os tipos Simples (1), Com-  ³
	//³ pleto(2), Pressao(3) e Relogio(9).						 ³
	//³ - Os Tipos Calibrador(4) e Calibrador Completo(8) SOMENTE³
	//³	padrao Secundario.										 ³
	//³ - O tipo Soma(5) cadastra Pontos.						 ³
	//³ - O tipo Faixa(6) - a ser definido. 					 ³
	//³ - O tipo Folga e Luz (7) NUNCA cadastra padroes.		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If !(QM9->QM9_TIPAFE $ "1,2,3,5,9") 
		If QM9->QM9_TIPAFE $ "4,8"
			Help(" ",1,"A040TIPO48")  // Os Pontos deste Tipo devem ser cadastrados
											// nos pr¢prios Instrumentos.
		Else	 
			Help(" ",1,"A040NCAPAD")  // Tipo nao permite cadastramento de pontos    
		EndIf
		Return(nOpca)
	EndIf

	If QM9->QM9_TIPAFE == "5"  // Se for tipo Soma
		A040SOMA(.T.,aHeaderQMR,aColsQMR)
		Return(nOPCa)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ha' padroes ja' existentes para a escala     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QMC")
	dbSetOrder(1)
	nSavRec := RecNo()
	If dbSeek( xFilial()+QM9->QM9_ESCALA+Inverte(QM9->QM9_REVESC))
		nPosQMC := aScan(aColsQMC,{|x| alltrim(x[1])+alltrim(x[2])+alltrim(x[3]) = Alltrim(QM9->QM9_ESCALA)+Alltrim(QM9->QM9_REVESC)})			
	Endif	

	nRecNc := RecNo()

	If nPosQMC <= 0 //Nao existe no aColsQMC
		nCnt := 0
		While !EOF() .And.;
			QMC->QMC_ESCALA == QM9->QM9_ESCALA .and.;
			QMC->QMC_REVESC == QM9->QM9_REVESC .and.;	
			QMC->QMC_FILIAL == xFilial('QMC')
			nCnt++
			dbSkip()
		EndDo
	Else
		nCnt := 0
	Endif
	
	dbGoto(nRecNc)

	lInclui := Iif(nCnt==0,.t.,.f.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a entrada de dados do arquivo							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a integridade dos campos de Bancos de Dados 			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX2")  // Posiciona pq. rotinas internas utilizam inf. do SX2
	dbSeek("QMC")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta vetor Aheader a ser utilizado na getdados				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MontAhead("QMC")  // QAXFUN
	
	// Inclui coluna de registro atraves de funcao generica
	ADHeadRec("QMC",aHeader)
	

	dbSelectArea("QMC")
	dbGoto(nRecNc)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define vetor aCols para a getdados 							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lInclui	// Def. vetor com 1 elemento, para a inclusao
		nCnt := 1
	EndIf
	
	Private aCOLS[nCnt][Len(aHeader)]
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica qual a posicao do campo PADRAO no Header 		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPosPdr	:=	ASCAN(aHeader,{|x| alltrim(x[2]) = "QMC_PADRAO"})
	nPosTol	:=	ASCAN(aHeader,{|x| alltrim(x[2]) = "QMC_TOLER"})
	nPosTMin:=	ASCAN(aHeader,{|x| alltrim(x[2]) = "QMC_TOLMIN"})
	nPosTpTt:=	ASCAN(aHeader,{|x| alltrim(x[2]) = "QMC_TIPTOL"})
	nPosAli := Ascan(aHeader,{|x| AllTrim(x[2]) == "QMC_ALI_WT"})
	nPosRec := Ascan(aHeader,{|x| AllTrim(x[2]) == "QMC_REC_WT"})

	if !lInclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta vetor aCols com as escalas ja existentes 			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCnt := 0
		dbSelectArea("QMC")
		While !EOF() .And.  QMC->QMC_ESCALA == QM9->QM9_ESCALA .and.;
								  QMC->QMC_REVESC == QM9->QM9_REVESC .and.;
								  QMC->QMC_FILIAL == xFilial("QMC")
			nCnt++
			nUsado:=0
			
			For nX := 1 To Len(aStruQMC)
				If cNivel >= GetSx3Cache(aStruQMC[nX,1], "X3_NIVEL") 
					nUsado++
					If GetSx3Cache(aStruQMC[nX,1], "X3_CONTEXT")  # "V"
						cCampo := "QMC->"	+ aStruQMC[nX,1] //X3_CAMPO
						aCOLS[nCnt][nUsado] := &cCampo
					Endif
				EndIf
			Next nX
			
			If nPosAli > 0 .And. nPosRec > 0
				aCols[nCnt][nPosAli] := "QMC"
				If IsHeadRec(aHeader[nPosRec,2])
					aCols[nCnt][nPosRec] := QMC->(RecNo())
				EndIf
			Endif
			aAdd(aCOLS[nCnt],.F.)
			dbSelectArea("QMC")
			dbSkip()
		Enddo
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta vetor aCols com um elemento em branco p/ inclusao   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nUsado:=0
		
		For nX := 1 To Len(aStruQMC)
			If cNivel >= GetSx3Cache(aStruQMC[nX,1], "X3_NIVEL") 
				nUsado++
				aCols[1][nUsado] := CriaVar(allTrim(aStruQMC[nX,1]))//X3_CAMPO
			EndIf
		Next nX
		
		If nPosAli > 0 .And. nPosRec > 0
			aCols[nCnt][nPosAli] := "QMC"
			If IsHeadRec(aHeader[nPosRec,2])
				aCols[nCnt][nPosRec] := 0
			EndIf
		Endif
		aAdd(aCOLS[nCnt],.F.)
		nCnt := 0	// Retorna valor 
	EndIf

	dbSelectArea("QMC")
	dbGoto(nRecNc)
	
	nOpca 		:= 0
	lNew		:= .T.
	If nPosQMC > 0
		For nx := 1 To Len(aColsQMC)
			If Alltrim(QM9->QM9_ESCALA) == Alltrim(aColsQMC[nx][1])
				If lNew
					lNew := .F.
					aCols[1][nPosPdr]		:= aColsQMC[nx][3]
					aCols[1][nPosTol]		:= aColsQMC[nx][4]
					aCols[1][nPosTMin]		:= aColsQMC[nx][5] 
					aCols[1][nPosTpTt]		:= aColsQMC[nx][6]
					aCols[1][Len(aCols[1])]:= .F.												
				Else
					Aadd(aCols,{aColsQMC[nx][3],aColsQMC[nx][4],aColsQMC[nx][5],aColsQMC[nx][6],aCols[n][5],aCols[n][6],.F.})
				Endif
			Else
				lNew := .T.
			Endif     
		Next nx 
	Endif
	
	DEFINE MSDIALOG oDlgAs TITLE OemToAnsi(STR0078) From 9,0 To 28,80 OF oMainWnd // "Escala - Associacoes"
	
		@ 1.1 , .5	SAY OemToAnsi(STR0076) //Faixa
		@ 1.1 , 4	SAY QM9->QM9_ESCALA    
	
		oGetPads := MSGetDados():New(41,5,130,315,nOpcF,"QMT010ChkAc(,.f.)","Verdade",,.T.)
	

	ACTIVATE MSDIALOG oDlgAs ON INIT EnchoiceBar(oDlgAs,;
		{||nopca:=1,Iif(oGetPads:TudoOk(),(nOpca:=1,oDlgAs:End()),;
		nOpca:=0)},{||nOpca:= 0,oDlgAs:End()}) CENTERED
	
	If nOpca == 1 //Grava associacoes de padroes / escalas
		dbSelectArea("QMC")
		dbSetOrder(1)
		For nx := 1 To Len(aCols)
			nPosQMC := aScan(aColsQMC,{|x| alltrim(x[1])+alltrim(x[2])+alltrim(x[3]) = Alltrim(QM9->QM9_ESCALA)+Alltrim(QM9->QM9_REVESC)+Alltrim(aCols[nx][nPosPdr])})			
			If !aCols[nx][Len(aCols[nx])]
				If nPosQMC <= 0
					Aadd(aColsQMC,{QM9->QM9_ESCALA,QM9->QM9_REVESC,aCols[nx][nPosPdr],aCols[nx][nPosTol],;
						aCols[nx][nPosTMin],aCols[nx][nPosTpTt]})		
				Endif					
			Else
				If nPosQMC > 0
					aDel( aColsQMC, nPosQMC )
					aSize( aColsQMC, Len( aColsQMC ) -1 )
				Endif				
				
				If dbSeek(xFilial("QMC") + QM9->QM9_ESCALA + QM9->QM9_REVINV + aCols[nX][nPosPdr])        
					dbSelectArea("QM7")
					dbSetOrder(2)
					If ! dbSeek(xFilial("QM7")+QMC->QMC_ESCALA+QMC->QMC_REVESC+QMC->QMC_PADRAO)
						RecLock("QMC",.F.,.T.)
						dbDelete()
						MsUnLock()
					Else
						//Quando nao pode deletar pq ja existe uma ou mais calibracoes...
						Aadd(aColsQMC,{QM9->QM9_ESCALA,QM9->QM9_REVESC,aCols[nx][nPosPdr],aCols[nx][nPosTol],;
							aCols[nx][nPosTMin],aCols[nx][nPosTpTt]})						
					EndIf
					dbSelectArea("QMC")              
				EndIf
			Endif
		Next nx	
	Endif
	
	RestArea(aArea)
	
	aCols	 := aClone(aColsQs)
	aHeader	 := aClone(aHeadQs)
	n := 1
Endif
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A010grves ºAutor  ³Denis Martins       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava/Deleta arquivo de amarracao Faixas / Familias         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010grves(cAlias)	
Local  nx ,  nMaxArray := Len(aColsQMR)

dbSelectArea("QMK")
dbSetOrder(01)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o arquivo QMK 	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to nMaxArray
	If ! Empty(aColsQMR[nX][1]) // Cod. Escala nao vazio
		If !aColsQMR[nX][Len(aColsQMR[nX])] // Nao esta deletado
			If dbSeek(xFilial() + QM1->QM1_TIPO + Inverte(QM1->QM1_REVTIP) + aColsQMR[nX][1])
				RecLock("QMK",.F.)   // Lock
			Else
				RecLock("QMK",.T.)   // Append
			Endif
/*			For ny := 1 to Len(aHeaderQMR)
				If aHeaderQMR[ny][10] # "V"
					cVar := Trim(aHeaderQMR[ny][2])
					Replace &cVar. With aColsQMR[nx][ny]
				Endif
			Next ny */
			QMK->QMK_TIPO	:= QM1->QM1_TIPO
			QMK->QMK_REVTIP := QM1->QM1_REVTIP
			QMK->QMK_FILIAL := xFilial("QMK")
			QMK->QMK_REVINV := Inverte(QM1->QM1_REVTIP) 
			QMK->QMK_ESCALA := aColsQMR[nX][1]
         	MsUnlock()
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancela o padrao no QMK				  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If dbSeek(xFilial() + QM1->QM1_TIPO + Inverte(QM1->QM1_REVTIP) + aColsQMR[nX][1])
				RecLock("QMK",.F.)
				dbDelete()  
				MsUnlock()
			EndIf
		EndIf
	EndIf
Next nx
Return .T. 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A010AltEs ³ Autor ³ Denis Martins         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se houve alteracoes nas faixas associadas         ³±±
±±³          ³ (inclusoes ou exclusoes).                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010AltEs(ExpL1,ExpL2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 : .T. nova escala incluida, .F. nao foi incluida     ³±±
±±³          ³         nenhuma escala.                                    ³±±
±±³          ³ ExpL2 : .T. escala alterada, .F. nao foi alterada          ³±±
±±³          ³         nenhuma escala.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010AltEs(lIncEs,lAltEs)
Local  nx , nMaxArray := Len(aColsQMR)

dbSelectArea("QMK")
dbSetOrder(1)
For nX := 1 to nMaxArray
	If ! Empty(aColsQMR[nX][1]) // Cod. Escala nao vazio
		If !aColsQMR[nX][Len(aColsQMR[nx])] // Nao esta deletado
			If !(dbSeek(xFilial() + QM1->QM1_TIPO + Inverte(QM1->QM1_REVTIP) + aColsQMR[nX][1]))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Uma nova escala foi incluida ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lIncEs := .T.				
			   	lAltEs := .T.
			   	Exit
			EndIf			   
		Else 
			lAltEs	:= .T.
		EndIf
		lVoinst := .T.
	EndIf
Next nx

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qm010VeResºAutor  ³Microsiga           º Data ³  08/17/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se responsavel existe                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qm010VeRes(cFilRI,cResPII)
Local lRet := .t.
lRet := QA_CHKMAT(cFilRI,cResPII)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QM010ValAfº Autor ³ Cicero Cruz        º Data ³  21/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a forma de calculo da data de afericao            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA010/QMTM020                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QM010ValAf(dUsoIni, nFreq)  
Local dData
Local lDataUtil := GetMV("MV_QDATAUT", .F., "1") == "1"
Local aSaveArea := GetArea()

if !lDataUtil
	dData := dUsoIni + nFreq
Else                                
	dData := DATAVALIDA( dUsoIni + nFreq,.F.)
EndIf    
RestArea(aSaveArea)
Return dData        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT10VlTp  ºAutor  ³Iolanda Vilanova   º Data ³  02/13/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a alteração do campo QMG_TIPCAL não permitindo a    º±±
±±º          ³ alteração do campo, somente a exclusão e inserção de uma nova
               linha                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
 
Function QMT10VlTp

Local nPosCa	:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QMG_TIPCAL" })
Local cProcura  := aCols[n][nPosCa]

DbSelectarea ("QMG")
DbSetOrder (1)

If ALTERA .and. (cProcura =="M" .or. cProcura=="A")	
  Messagedlg (STR0097)  //"Não é possível alterar o tipo do ponto do calibrador.Deverá excluir este registro e adicionar um novo."
  Return .F.
Endif


Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³A010Legend ³ Autor ³Hederson Bisewski     ³ Data ³ 24/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Exibe a Legenda do status de calibração do instrumento     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010Legend()
Local aLegenda := {}
Local aLegendaNew  := {}
                                                                        
Aadd(aLegenda,{"BR_VERDE",      OemToAnsi(STR0100)}) //"Instrumento Calibrado e Ativo"
Aadd(aLegenda,{"BR_LARANJA",    OemToAnsi(STR0103)}) //"Instrumento Calibrado e Não Ativo"
Aadd(aLegenda,{"BR_VERMELHO",   OemToAnsi(STR0101)}) //"Instrumento Descalibrado e Ativo" 
Aadd(aLegenda,{"BR_AMARELO",    OemToAnsi(STR0102)}) //"Instrumento Descalibrado e Não Ativo"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para alterar cores da legenda do status do instrumento    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QM010LEG")
    aLegendaNew := ExecBlock("QM010LEG",.F.,.F.,{aLegenda})
    If ValType(aLegendaNew) == "A"
        aLegenda := aLegendaNew
    EndIf
EndIf

BrwLegenda(cCadastro,"Instrumento",aLegenda)

Return(NIL)

